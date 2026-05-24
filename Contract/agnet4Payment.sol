// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract Agent4Payment is
    Ownable2Step,
    Pausable,
    ReentrancyGuard
{
    /* =========================
       STATE
    ========================= */

    address public paymentReceiver;

    uint256 public analysisFee =
        0.01 ether;

    /* =========================
       RECEIVER TIMELOCK
    ========================= */

    address public pendingReceiver;

    uint256 public receiverUpdateTime;

    uint256 public constant
        TIMELOCK_DELAY = 2 days;

    /* =========================
       EVENTS
    ========================= */

    event AnalysisPaid(
        address indexed user,
        uint256 amount,
        uint256 timestamp
    );

    event ReceiverProposed(
        address indexed oldReceiver,
        address indexed newReceiver,
        uint256 executeAfter
    );

    event ReceiverUpdated(
        address indexed oldReceiver,
        address indexed newReceiver
    );

    event FeeUpdated(
        uint256 oldFee,
        uint256 newFee
    );

    /* =========================
       CONSTRUCTOR
    ========================= */

    constructor(
        address initialReceiver
    )
        Ownable(msg.sender)
    {
        require(
            initialReceiver != address(0),
            "Invalid receiver"
        );

        paymentReceiver =
            initialReceiver;
    }

    /* =========================
       PAY FUNCTION
    ========================= */

    function payForAnalysis()
        external
        payable
        nonReentrant
        whenNotPaused
    {
        require(
            msg.value >= analysisFee,
            "Insufficient payment"
        );

        require(
            paymentReceiver != address(0),
            "Receiver not set"
        );

        (bool success, ) =
            payable(paymentReceiver).call{
                value: msg.value
            }("");

        require(
            success,
            "Payment failed"
        );

        emit AnalysisPaid(
            msg.sender,
            msg.value,
            block.timestamp
        );
    }

    /* =========================
       PROPOSE NEW RECEIVER
    ========================= */

    function proposeReceiver(
        address newReceiver
    )
        external
        onlyOwner
    {
        require(
            newReceiver != address(0),
            "Invalid address"
        );

        pendingReceiver =
            newReceiver;

        receiverUpdateTime =
            block.timestamp +
            TIMELOCK_DELAY;

        emit ReceiverProposed(
            paymentReceiver,
            newReceiver,
            receiverUpdateTime
        );
    }

    /* =========================
       EXECUTE RECEIVER UPDATE
    ========================= */

    function executeReceiverUpdate()
        external
        onlyOwner
    {
        require(
            pendingReceiver != address(0),
            "No pending receiver"
        );

        require(
            block.timestamp >=
                receiverUpdateTime,
            "Timelock active"
        );

        address oldReceiver =
            paymentReceiver;

        paymentReceiver =
            pendingReceiver;

        pendingReceiver =
            address(0);

        receiverUpdateTime = 0;

        emit ReceiverUpdated(
            oldReceiver,
            paymentReceiver
        );
    }

    /* =========================
       CANCEL RECEIVER UPDATE
    ========================= */

    function cancelReceiverUpdate()
        external
        onlyOwner
    {
        pendingReceiver =
            address(0);

        receiverUpdateTime = 0;
    }

    /* =========================
       UPDATE FEE
    ========================= */

    function updateFee(
        uint256 newFee
    )
        external
        onlyOwner
    {
        require(
            newFee > 0,
            "Invalid fee"
        );

        uint256 oldFee =
            analysisFee;

        analysisFee =
            newFee;

        emit FeeUpdated(
            oldFee,
            newFee
        );
    }

    /* =========================
       EMERGENCY PAUSE
    ========================= */

    function pause()
        external
        onlyOwner
    {
        _pause();
    }

    function unpause()
        external
        onlyOwner
    {
        _unpause();
    }

    /* =========================
       VIEW
    ========================= */

    function getRemainingTimelock()
        external
        view
        returns (uint256)
    {
        if (
            receiverUpdateTime == 0 ||
            block.timestamp >=
            receiverUpdateTime
        ) {
            return 0;
        }

        return
            receiverUpdateTime -
            block.timestamp;
    }
}
