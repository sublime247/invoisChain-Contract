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
        uint date;
        uint amount;
        bool isPaid;
        address tokenAddress;
        uint amountPaidInEther;
        uint invoiceId;
    }

    mapping(uint256 => Invoice) public invoices;
    Invoice[] listOfInvoice;
    uint256 _invoiceCount;

    constructor() {}

    function zeroAddress(address _add) private pure {
        if (_add == address(0)) {
            revert Errors.ZeroAddressDetected();
        }
    }

    function validateBalanceAndApproval(
        address _tokenAddress,
        address from,
        uint _amt
    ) private view {
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
            revert Errors.InvoicePaidForAlready();
        }
    }

    function createInvoice(
        address _buyerAddress,
        string[] memory _goods,
        uint _totalAmt,
        address _tokenAddress
    ) external {
        zeroAddress(msg.sender);
        zeroAddress(_tokenAddress);
        zeroAddress(_buyerAddress);

        uint256 _invoiceId = _invoiceCount++;
        Invoice memory _invoice = Invoice({
            buyer: _buyerAddress,
            seller: msg.sender,
            goods: _goods,
            date: block.timestamp,
            amount: _totalAmt,
            isPaid: false,
            tokenAddress: _tokenAddress,
            invoiceId: _invoiceId,
            amountPaidInEther: 0
        });
        invoices[_invoiceId] = _invoice;
        listOfInvoice.push(_invoice);
        emit Events.InvoiceCreatedSuccessfully(
            _buyerAddress,
            _invoice.amount,
            _invoice.invoiceId
        );
    }

    function payInvoice(uint _invoiceId) external nonReentrant {
        zeroAddress(msg.sender);
        validateInvoiceID(_invoiceId);
        require(_invoiceId > 0, "Invalid Id");
        Invoice storage _invoice = invoices[_invoiceId];
        require(_invoice.buyer == msg.sender, "Invalid Id");
        require(_invoice.invoiceId == _invoiceId, "Invalid Id");
        validateBalanceAndApproval(
            _invoice.tokenAddress,
            msg.sender,
            _invoice.amount
        );

        IERC20(_invoice.tokenAddress).transferFrom(
            msg.sender,
            _invoice.seller,
            _invoice.amount
        );
        _invoice.isPaid = true;

        emit Events.PaymentSuccessful(
            _invoice.seller,
            _invoice.amount,
            _invoiceId
        );
    }

    function payWithEther(uint _invoiceId) external payable nonReentrant {
        zeroAddress(msg.sender);
        validateInvoiceID(_invoiceId);

        Invoice storage _invoice = invoices[_invoiceId];
        require(_invoice.buyer == msg.sender, "Invalid Id");
        require(_invoice.invoiceId == _invoiceId, "Invalid Id");
        require(msg.value == _invoice.amount, "Incorrect Ether amount sent");
        require(!_invoice.isPaid, "Invoice already paid");

        _invoice.amountPaidInEther = msg.value;
        _invoice.isPaid = true;

        emit Events.PaymentSuccessful(
            _invoice.seller,
            _invoice.amount,
            _invoiceId
        );
    }

    function sendEtherToSeller(uint _invoiceId) external nonReentrant {
        zeroAddress(msg.sender);
        validateInvoiceID(_invoiceId);
        Invoice storage _invoice = invoices[_invoiceId];
        require(_invoice.seller == msg.sender, "Invalid Id");
        require(_invoice.invoiceId == _invoiceId, "Invalid Id");
        require(
            msg.sender == _invoice.seller,
            "Only the seller can withdraw funds"
        );
        require(_invoice.isPaid, "Invoice not paid");

        uint amount = _invoice.amountPaidInEther;
        require(
            address(this).balance >= amount,
            "Insufficient contract balance"
        );

        _invoice.amountPaidInEther = 0;
        payable(_invoice.seller).transfer(amount);

        emit Events.PaymentSuccessful(_invoice.seller, amount, _invoiceId);
    }

    function generateInvoice(
        uint _invoiceId
    ) external view returns (Invoice memory) {
        return invoices[_invoiceId];
    }

    function generateAllInvoices() external view returns (Invoice[] memory) {
        return listOfInvoice;
    }
}
