pragma solidity ^0.8.0;

// A good voting system with utilize and mapping over an array.
// Array => Linear time search
// Mapping => Constant time search

Request[] public requests;
address public manager;
uint public minimumContribution;
mapping(address => bool) public approvers;

modifer restricted() {
    require(msg.sender == manager);
    _;
}

contract Campaign (uint minContribution) {
    manager = msg.sender;
    minimumContribution = minContribution;

    function contribute() public payable {
        require(msg.value >= minimumContribution);
        // Cannot user .push() method on mappings
        approvers[msg.sender] = true;
    }

    function createRequest(string description, uint value, address recipient) public restricted {
        Request memory newRequest = Request({
            description: description,
            value: value,
            recipient: recipient,
            complete: false
        });
        }
        requests.push(newRequest);
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