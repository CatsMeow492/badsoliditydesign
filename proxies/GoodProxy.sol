// Solidity Version 8
pragma solidity 0.8.24;

// This is a proxy contract
contract GoodProxy {
    // This is the address of the contract that will be called
    address public implementation;

    // This is the constructor of the proxy contract
    constructor(address _implementation) {
        implementation = _implementation;
    }

    // This is the fallback function of the proxy contract
    fallback() external payable {
        // This is the address of the contract that will be called
        address _impl = implementation;

        // This is the assembly code that will be executed
        assembly {
            // This is the pointer to the memory location of the first byte of the code
            let ptr := mload(0x40)

            // This is the length of the code
            let size := calldatasize()

            // This copies the code to the memory location of the first byte of the code
            calldatacopy(ptr, 0, size)

            // This executes the code
            let result := delegatecall(gas(), _impl, ptr, size, 0, 0)

            // This is the pointer to the memory location of the first byte of the return data
            let ptr2 := mload(0x40)

            // This is the length of the return data
            let size2 := returndatasize()

            // This copies the return data to the memory location of the first byte of the return data
            returndatacopy(ptr2, 0, size2)

            // This checks if the execution of the code was successful
            switch result
            case 0 {
                // This reverts the transaction
                revert(ptr2, size2)
            }
            default {
                // This returns the return data
                return(ptr2, size2)
            }
        }
    }
}