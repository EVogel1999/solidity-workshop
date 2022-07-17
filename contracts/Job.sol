//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";

contract Job {
    // Enums
    enum JobState {
        WAITING,
        ACCEPTED,
        COMPLETED
    }

    // Contract events
    event PaymentReceived(address from, uint256 amount);

    // Job information
    address private client;
    JobState private state = JobState.WAITING;

    // Team information
    address[] private members;
    uint8[] private shares;

    constructor() {
        // Sends the job client to the deployer
        client = msg.sender;
    }

    /**
     * Returns the total payout for the job
     */
    function getPayout() public view returns (uint256) {
        return address(this).balance;
    }

    /**
     * Gets the current job state
     */
    function getJobState() external view returns (string memory) {
        if (state == JobState.WAITING) {
            return "Waiting";
        } else if (state == JobState.ACCEPTED) {
            return "Accepted";
        } else {
            return "Completed";
        }
    }

    /**
     * Deposits ether to the contract
     *
     * NOTE: It is also possible to accept other crypto as payment,
     * see this contract for a working example:
     * https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.7.0/contracts/finance/PaymentSplitter.sol
     */
    function deposit() payable public isClient {
        // Emit an event saying the contract recieved the deposit
        emit PaymentReceived(msg.sender, msg.value);
    }

    /**
     * Accepts a job with a given team array and the shares for each team member
     */
    function acceptJob(address[] memory m, uint8[] memory s) external notClient {
        // Check members and shares are defined and same length
        require(m.length == s.length, "Team members and shares must be same length");
        require(m.length > 0, "Team must have at least one member");
        require (state == JobState.WAITING, "Job must be awaiting team");

        // Check the total shares is equal to 100 (100%)
        uint8 total = 0;
        for (uint i = 0; i < s.length; i++) {
            total += s[i];
        }
        require (total == 100, "Shares must total to 100");

        // Set team members
        members = m;
        shares = s;

        // Set contract state to accepted
        state = JobState.ACCEPTED;
    }

    /**
     * Completes a job and sends out the payment to the team
     */
    function complete() external isClient {
        require(state == JobState.ACCEPTED, "Job must be accepted to complete");

        // Set job state
        state = JobState.COMPLETED;

        // Payout each team member
        // NOTE: In practice you shouldn't payout members in a loop in case the
        // transaction for sending the money fails, this is a vulnerability
        uint256 totalPayout = this.getPayout();
        for (uint i = 0; i < members.length; i++) {
            // NOTE: Solidity doesn't support decimals so you have to multiple the total
            // payout by the member's share and divide by the total number of shares
            // (gets around needing decimals)
            uint256 cut = (totalPayout * shares[i]) / 100;
            Address.sendValue(payable(members[i]), cut);
        }
    }

    /**
     * Check that the client isn't making the transaction
     */
    modifier notClient() {
        require(tx.origin != client, "Client can't perform action");
        _;
    }

    /**
     * Check that the client is making the transaction
     */
    modifier isClient() {
        require(tx.origin == client, "Only client can perform action");
        _;
    }
}