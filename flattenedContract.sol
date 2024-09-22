// Sources flattened with hardhat v2.22.10 https://hardhat.org

// SPDX-License-Identifier: MIT

// File @openzeppelin/contracts/token/ERC20/IERC20.sol@v5.0.2

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}


// File @openzeppelin/contracts/utils/ReentrancyGuard.sol@v5.0.2

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/ReentrancyGuard.sol)

pragma solidity ^0.8.20;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;

    uint256 private _status;

    /**
     * @dev Unauthorized reentrant call.
     */
    error ReentrancyGuardReentrantCall();

    constructor() {
        _status = NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be NOT_ENTERED
        if (_status == ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }

        // Any calls to nonReentrant after this point will fail
        _status = ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == ENTERED;
    }
}


// File contracts/Utils.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.24;
library Errors{

    error ZeroAddressDetected();
    error InsufficientBalanace();
    error InvalidInvoiceId();
    error InvoicePaidForAlready();

}



library Events{
    event InvoiceCreatedSuccessfully(address indexed _add , uint _amt, uint _invoiceId);
    event PaymentSuccessful(address indexed _add, uint _amt, uint _invoiceId);

}


// File contracts/InvoisChain.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.24;


// import from github 

contract InvoiceChain is ReentrancyGuard {


    /*---------What makes an invoice-------------*/
    struct Invoice {
        address buyer;
        address seller;
        string[] goods;
        string date;
        uint amount;
        bool isPaid;
        address tokenAddress;
        uint amountPaidInEther;
    }

    mapping(uint256 => Invoice) public invoices;
    uint public invoiceId;

    constructor() {}





/*--------Zero Address Check------------------*/
    function zeroAddress(address _add) private pure {
        if (_add == address(0)) {
            revert Errors.ZeroAddressDetected();
        }
    }




/*--------Balance and Approval Check------------------*/
    function validateBalanceAndApproval(address _tokenAddress, address from, uint _amt) private view {
        IERC20 token = IERC20(_tokenAddress);
        uint bal = token.balanceOf(from);
        uint allowance = token.allowance(from, address(this));

        if (bal < _amt) {
            revert Errors.InsufficientBalanace();
        }

        if (allowance < _amt) {
            revert Errors.InsufficientBalanace();
        }
    }



/*--------Invoice ID Check------------------*/
    function validateInvoiceID(uint ivId) private view {
        if (ivId == 0) revert Errors.InvalidInvoiceId();
        if (invoices[ivId].isPaid) {
            revert Errors.InvoicePaidForAlready();
        }
    }




/*--------Invoice Creation------------------*/
    function createInvoice(
        address _buyerAddress,
        string[] memory _goods,
        uint _amt,
        address _tokenAddress
    ) external {
        zeroAddress(msg.sender);
        zeroAddress(_tokenAddress);

        uint invId = invoiceId + 1;
        Invoice storage _invoice = invoices[invId];

        _invoice.buyer = _buyerAddress;
        _invoice.goods = _goods;
        _invoice.amount = _amt;
        _invoice.seller = msg.sender;
        _invoice.tokenAddress = _tokenAddress;

        invoiceId += 1;

        emit Events.InvoiceCreatedSuccessfully(_buyerAddress, _amt, invId);
    }



/*--------Payment with ERC20Token------------------*/
    function payInvoice(uint _invoiceId) external nonReentrant {
        zeroAddress(msg.sender);
        validateInvoiceID(_invoiceId);

        Invoice storage _invoice = invoices[_invoiceId];
        validateBalanceAndApproval(_invoice.tokenAddress, msg.sender, _invoice.amount);
        
        IERC20(_invoice.tokenAddress).transferFrom(msg.sender, _invoice.seller, _invoice.amount);
        _invoice.isPaid = true;

        emit Events.PaymentSuccessful(_invoice.seller, _invoice.amount, _invoiceId);
    }





/*--------Payment with Ether------------------*/
    function payWithEther(uint _invoiceId) external payable nonReentrant {
        zeroAddress(msg.sender);
        validateInvoiceID(_invoiceId);

        Invoice storage _invoice = invoices[_invoiceId];
        require(msg.value == _invoice.amount, "Incorrect Ether amount sent");
        require(!_invoice.isPaid, "Invoice already paid");

        _invoice.amountPaidInEther = msg.value;
        _invoice.isPaid = true;

        emit Events.PaymentSuccessful(_invoice.seller, _invoice.amount, _invoiceId);
    }



/*--------Withdraw Ether buy seller ------------------*/
    function sendEtherToSeller(uint _invoiceId) external nonReentrant {
        Invoice storage _invoice = invoices[_invoiceId];
        require(msg.sender == _invoice.seller, "Only the seller can withdraw funds");
        require(_invoice.isPaid, "Invoice not paid");

        uint amount = _invoice.amountPaidInEther;
        require(address(this).balance >= amount, "Insufficient contract balance");

        _invoice.amountPaidInEther = 0;
        payable(_invoice.seller).transfer(amount);

        emit Events.PaymentSuccessful(_invoice.seller, amount, _invoiceId);
    }


/*-------------geberate invoice-----------*/
    function generateInvoice(uint _invoiceId) external view returns(Invoice memory) {
        return invoices[_invoiceId];
    }
}
