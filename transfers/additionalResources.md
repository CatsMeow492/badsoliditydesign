## address.transfer()

- throws on failure
- forwards 2,300 gas stipend (not adjustable), safe against reentrancy
- should be used in most cases as it's the safest way to send ether

## address.send()

- returns false on failure
- forwards 2,300 gas stipend (not adjustable), safe against reentrancy
- should be used in rare cases when you want to handle failure in the contract

## address.call.value().gas()()

- returns false on failure
- forwards all available gas (adjustable), not safe against reentrancy
- should be used when you need to control how much gas to forward when sending ether or to call a function of another contract
Detailed version below:

The relative tradeoffs between the use of someAddress.send(), someAddress.transfer(), and someAddress.call.value()():

someAddress.send()and someAddress.transfer() are considered safe against reentrancy. While these methods still trigger code execution, the called contract is only given a stipend of 2,300 gas which is currently only enough to log an event.
x.transfer(y) is equivalent to require(x.send(y)), it will automatically revert if the send fails.
someAddress.call.value(y)() will send the provided ether and trigger code execution. The executed code is given all available gas for execution making this type of value transfer unsafe against reentrancy.
Using send() or transfer() will prevent reentrancy but it does so at the cost of being incompatible with any contract whose fallback function requires more than 2,300 gas. It is also possible to use someAddress.call.value(ethAmount).gas(gasAmount)() to forward a custom amount of gas.

One pattern that attempts to balance this trade-off is to implement both a push and pull mechanism, using send() or transfer() for the push component and call.value()() for the pull component.

It is worth pointing out that exclusive use of send() or transfer() for value transfers does not itself make a contract safe against reentrancy but only makes those specific value transfers safe against reentrancy.

More details are here https://consensys.github.io/smart-contract-best-practices/recommendations/#be-aware-of-the-tradeoffs-between-send-transfer-and-callvalue

Reasons for adding transfer(): https://github.com/ethereum/solidity/issues/610

call() can also be used to issue a low-level CALL opcode to make a message call to another contract:

if (!contractAddress.call(bytes4(keccak256("someFunc(bool, uint256)")), true, 3)) {
    revert;
}
The forwarded value and gas can be customized:

contractAddress.call.gas(5000)
    .value(1000)(bytes4(keccak256("someFunc(bool, uint256)")), true, 3);
This is equivalent to using a function call on a contract:

SomeContract(contractAddress).someFunc.gas(5000)
    .value(1000)(true, 3);
Beware of the right padding of the input data in call() https://github.com/ethereum/solidity/issues/2884

transfer(), send() and call() functions are translated by the Solidity compiler into the CALL opcode.

As explained on the Subtleties page in the Ethereum's wiki:

CALL has a multi-part gas cost:

700 base
9000 additional if the value is nonzero
25000 additional if the destination account does not yet exist (note: there is a difference between zero-balance and nonexistent!)
The child message of a nonzero-value CALL operation (NOT the top-level message arising from a transaction!) gains an additional 2300 gas on top of the gas supplied by the calling account; this stipend can be considered to be paid out of the 9000 mandatory additional fee for nonzero-value calls. This ensures that a call recipient will always have enough gas to log that it received funds.
Sending and Receiving ether explained in Solidity docs: