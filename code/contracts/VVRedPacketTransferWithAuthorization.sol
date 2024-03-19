// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;
pragma abicoder v2;

import "./lib/Nonces.sol";
import "./lib/EIP712Domain.sol";
import "./lib/TransferWithAuthorizationInterface.sol";
import "./lib/MetaTransactionInterface.sol";
import "./lib/IERC20.sol";
import "./lib/Initializable.sol";
import "./lib/Operable.sol";
import "./lib/FeeReceiver.sol";
import "./lib/SafeMath.sol";

contract VVRedPacketTransferWithAuthorization is EIP712Domain, Nonces, Initializable, Operable, FeeReceiver {
    enum CoinTypeSupported {
        USDC_POLYGON,   // polygon链上的usdc合约类型
        USDT_POLYGON    // polygon链上的usdt合约类型
    }

    using SafeMath for uint256;
    // 红包创建
    event RedPacketCreated(uint256 indexed idx, address indexed payer, uint256 indexed amount, uint256 count);
    // 抢红包记录
    event RedPacketGrabbed(uint256 indexed idx, address indexed grabber, uint256 indexed amount, uint256 timestampWeb2);
    // 红包金额超时提现
    event RedPacketWithdrawal(uint256 indexed idx, address indexed receiver, uint256 countRemain, uint256 amountRemain);
    // 红包手续费发送
    event FeeSent(address indexed receiver, uint256 indexed amount);

    // 红包id
    uint256 public id;

    // 红包所有者  user => id
    mapping (address=>uint256[]) public redPacketOwner;

    // 红包创建信息概览   id => overview
    mapping (uint256=>RedPacketOverview) public overviews;

    // 红包grab详情     id => grab detail
    mapping (uint256=>RedPacketGrabDetail[]) public grabs;

    struct RedPacketOverview {
        CoinTypeSupported coinType;      // auto fill coin合约类型
        address coinAddress;             // auto fill coin合约地址
        address owner;  // auto fill
        uint256 amount;  // auto fill
        uint256 expireUtc;  // user specify
        uint256 count;  // user specify
        uint256 grabbedAmount; // 已抢红包的钱
        bool settlement;  // 是否已超时结算
    }

    struct RedPacketGrabDetail {
        uint256 id;
        address receiver;
        uint256 amount;
        uint256 timestamp;
        uint256 timestampWeb2;
    }

    // = keccak256("CreateRedPacket(uint256 expireUtc,uint256 count,address payFrom,uint256 redPacketAmount,uint256 nonce)")
    bytes32 public constant CREATE_RED_PACKET_TYPEHASH = 0x613f877877bb428c18fd57cf15d2a16d53d18c5c425a47fd738bc85aa543972a;

    string public constant EIP712_VERSION = "1";

    /**
     * @notice Initialize the contract after it has been proxified
     * @dev meant to be called once immediately after deployment
     */
    function initialize(
        address feeReceiver,
        string calldata newName
    ) external initializer {
        _updateFeeReceiver(feeReceiver);
        _setDomainSeparator(newName, EIP712_VERSION);
    }

    // 谁都可以call, 固定把钱返还给owner
    function timeoutWithdrawal(uint256 rpId) public returns (uint256) {
        require(msg.sender != address(this), "Caller is this contract");
        require(overviews[rpId].owner != address(0), "red packet not exist");
        require(block.timestamp > overviews[rpId].expireUtc, "red packet can only withdrawal after timeout");
        require(overviews[rpId].count >= grabs[rpId].length, "red packet grabbed count invalid");
        require(overviews[rpId].amount >= overviews[rpId].grabbedAmount, "red packet grabbed amount invalid");
        require(!overviews[rpId].settlement, "settlement already finished");
        // 计算剩余金额和事件
        uint256 amountRemain = overviews[rpId].amount - overviews[rpId].grabbedAmount;
        uint256 countRemain = overviews[rpId].count - grabs[rpId].length;
        // 抛出事件
        emit RedPacketWithdrawal(rpId, overviews[rpId].owner, countRemain, amountRemain);
        // 实际转账
        overviews[rpId].settlement = true;
        IERC20(overviews[rpId].coinAddress).transfer(overviews[rpId].owner, amountRemain);

       return 0;
    }

    function updateGrab(uint256 rpId, address[] memory grabber, uint256[] memory amount, uint256[] memory timestampWeb2) public isOperator returns (uint256) {
        require(msg.sender != address(this), "Caller is this contract");
        require(overviews[rpId].owner != address(0), "red packet not exist");
        require(block.timestamp <= overviews[rpId].expireUtc, "red packet is timeout");
        require(grabber.length == amount.length && grabber.length == timestampWeb2.length, "length mismatch");
        for (uint i = 0; i < grabber.length; i++) {
            _updateGrab(rpId, grabber[i], amount[i], timestampWeb2[i]);
        }
        return grabs[rpId].length;
    }

    function _updateGrab(uint256 rpId, address grabber, uint256 amount, uint256 timestampWeb2) internal {
        require(grabber != address(0), "grabber address can not be null");
        require(amount > 0, "each grab must have valid value");
        require(grabs[rpId].length + 1 <= overviews[rpId].count, "grab count limit reached");
        require(overviews[rpId].grabbedAmount + amount <= overviews[rpId].amount, "grab amount limit reached");
        for (uint256 i = 0;i < grabs[rpId].length;i++) {
            require(grabs[rpId][i].receiver != grabber, "already grabbed");
        }
        overviews[rpId].grabbedAmount += amount;

        RedPacketGrabDetail memory detail = RedPacketGrabDetail({
            id: grabs[rpId].length,
            receiver: grabber,
            amount: amount,
            timestamp: block.timestamp,
            timestampWeb2: timestampWeb2
        });
        grabs[rpId].push(detail);

        // 抛出事件
        emit RedPacketGrabbed(rpId, grabber, amount, timestampWeb2);

        // 实际转账
        IERC20(overviews[rpId].coinAddress).transfer(grabber, amount);
    }

    struct RedPacketCreationParams {
        // coin通用属性
        CoinTypeSupported coinType;
        address coinAddress;
        // 红包参数
        uint256 expireUtc;
        uint256 count;  // 红包个数
        address payFrom;
        uint256 payAmount;// 含手续费的支付金额
        uint256 payFeeAmount;// 手续费金额
        // 代理创建红包的签名
        uint8 cv;
        bytes32 cr;
        bytes32 cs;
        // usdc转账参数
        uint256 validAfter;
        uint256 validBefore;
        bytes32 nonce;
        // u转账的签名
        uint8 pv;
        bytes32 pr;
        bytes32 ps;
    }

    // 代理创建红包（通过xxx方式创建红包, 以实际支付资金的人为红包发起者）
    // 允许批量创建红包（通过multiCall一类的合约）

    function createRedPacket(RedPacketCreationParams memory params) public returns (uint256) {
        // 权限校验
        require(msg.sender != address(this), "Caller is this contract");
        require(params.expireUtc >= block.timestamp, "create red packet: expired");
        require(params.payAmount > params.payFeeAmount, "fee too much");
        require(params.count > 0, "count of red packet must be larger than 0");
        require(params.coinAddress != address(0) && params.coinAddress != address(this), "coinAddress can not be 0 or this contract");
        // 代理call的校验
        bytes memory data = _encodeRedPacketHash(params);
        require(
            EIP712.recover(DOMAIN_SEPARATOR, params.cv, params.cr, params.cs, data) == params.payFrom,
            "createRedPacket: invalid signature"
        );
        return _createRedPacket(params);
    }


    function _encodeRedPacketHash(RedPacketCreationParams memory params) internal returns (bytes memory){
        return abi.encode(
        // = keccak256("CreateRedPacket(uint256 expireUtc,uint256 count,address payFrom,uint256 redPacketAmount,uint256 nonce)")
            CREATE_RED_PACKET_TYPEHASH,
            params.expireUtc,
            params.count,
            params.payFrom,
            params.payAmount - params.payFeeAmount,
            _nonces[params.payFrom]++
        );
    }

    // 核心红包创建方法
    function _createRedPacket(RedPacketCreationParams memory params) internal returns (uint256) {
        // 资金转账
        if (params.coinType == CoinTypeSupported.USDC_POLYGON) {
            TransferWithAuthorizationApi(params.coinAddress).transferWithAuthorization(params.payFrom, address(this), params.payAmount, params.validAfter, params.validBefore, params.nonce, params.pv, params.pr, params.ps);
        } else if (params.coinType == CoinTypeSupported.USDT_POLYGON) {
            bytes memory signature = abi.encodeWithSelector(bytes4(0xa9059cbb), address(this), params.payAmount);
            NativeMetaTransactionApi(params.coinAddress).executeMetaTransaction(params.payFrom, signature, params.pr, params.ps, params.pv);
        } else {
            revert("unsupported coin type for red packet creation");
        }

        // 构造红包
        uint256 newId = id++;
        RedPacketOverview memory overview = RedPacketOverview({
            coinType: params.coinType,
            coinAddress: params.coinAddress,
            owner: params.payFrom,
            amount: params.payAmount - params.payFeeAmount,
            expireUtc: params.expireUtc,
            count: params.count,
            grabbedAmount: 0,
            settlement: false
        });
        // 红包已创建
        emit RedPacketCreated(newId, params.payFrom, params.payAmount - params.payFeeAmount, params.count);
        // 初始化红包
        overviews[newId] = overview;
        redPacketOwner[params.payFrom].push(newId);
        // 手续费已转账
        emit FeeSent(this.feeReceiverAddress(), params.payFeeAmount);
        // 转账手续费
        IERC20(params.coinAddress).transfer(this.feeReceiverAddress(), params.payFeeAmount);
        return newId;
    }
}