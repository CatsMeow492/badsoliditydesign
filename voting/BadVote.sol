pragma solidity ^0.8.0;

// This is a design pattern I see a lot of new devlopers use. 
// Although this method actually works this costs an enormous amount of gas to execute.
// The gas costs comes from the fact that we are iterating over an unbounded array.
// AVOID ARRAYS WHENEVER POSSIBLE!!

Request[] public requests;
address public manager;
uint public minimumContribution;
address[] public approvers;

modifer restricted() {
    require(msg.sender == manager);
    _;
}

contract Campaign {
    manager = msg.sender;
    minimumContribution = minContribution;

    function contribute() public payable {
        require(msg.value >= minimumContribution);
        approvers.push(msg.sender);
    }

    function approveRequest(Request request) public {
        bool isApprover = false;
        for (uint i = 0; i < approvers.length; i++) {
            if (approvers[i] == msg.sender) {
                isApprover = true;
            }
        }
        require(isApprover);

        for (uint i = 0; i < approvers.length; i++) {
            require(request.approvers[i] != msg.sender);
        }
    }
}