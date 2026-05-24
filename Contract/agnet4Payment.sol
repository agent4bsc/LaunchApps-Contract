// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Agent4Payment is Ownable {

    /* =========================
       STATE
    ========================= */

    address public paymentReceiver;

    uint256 public analysisFee =
        0.01 ether;

    /* =========================
       EVENTS
    ========================= */

    event AnalysisPaid(

        address indexed user,
        uint256 amount,
        uint256 timestamp

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

        paymentReceiver =
            initialReceiver;

    }

    /* =========================
       PAY FUNCTION
    ========================= */

    function payForAnalysis()
        external
        payable
    {

        require(

            msg.value >= analysisFee,

            "Insufficient payment"

        );

        /* =========================
           SEND PAYMENT
        ========================= */

        (bool success, ) =

            payable(paymentReceiver).call{

                value: msg.value

            }("");

        require(
            success,
            "Payment failed"
        );

        /* =========================
           EVENT
        ========================= */

        emit AnalysisPaid(

            msg.sender,
            msg.value,
            block.timestamp

        );

    }

    /* =========================
       UPDATE RECEIVER
    ========================= */

    function updateReceiver(

        address newReceiver

    )
        external
        onlyOwner
    {

        require(

            newReceiver != address(0),

            "Invalid address"

        );

        address oldReceiver =
            paymentReceiver;

        paymentReceiver =
            newReceiver;

        emit ReceiverUpdated(

            oldReceiver,
            newReceiver

        );

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

        uint256 oldFee =
            analysisFee;

        analysisFee =
            newFee;

        emit FeeUpdated(

            oldFee,
            newFee

        );

    }

}
