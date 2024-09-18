// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Errors, Events} from "./Utils.sol";

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

    function zeroAddress(address _add) private pure {
        if (_add == address(0)) {
            revert Errors.ZeroAddressDetected();
        }
    }

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

    function validateInvoiceID(uint ivId) private view {
        if (ivId == 0) revert Errors.InvalidInvoiceId();
        if (invoices[ivId].isPaid) {
            revert Errors.InvalidPaidForAlready();
        }
    }

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

    function payInvoice(uint _invoiceId) external nonReentrant {
        zeroAddress(msg.sender);
        validateInvoiceID(_invoiceId);

        Invoice storage _invoice = invoices[_invoiceId];
        validateBalanceAndApproval(_invoice.tokenAddress, msg.sender, _invoice.amount);
        
        IERC20(_invoice.tokenAddress).transferFrom(msg.sender, _invoice.seller, _invoice.amount);
        _invoice.isPaid = true;

        emit Events.PaymentSuccessful(_invoice.seller, _invoice.amount, _invoiceId);
    }

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

    function generateInvoice(uint _invoiceId) external view returns(Invoice memory) {
        return invoices[_invoiceId];
    }
}
