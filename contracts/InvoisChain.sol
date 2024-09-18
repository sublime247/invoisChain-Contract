// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Errors, Events} from "./Utils.sol";

// import for reentrance;


contract InvoiceChain is ReentrancyGuard  {

    /*---------What makes an invoice-------------*/
    struct Invoice {
        address buyer;
        address seller;
        string[] goods;
        string date;
        uint amount;
        bool isPaid;
        address tokenAddress;
        //   address
    }

    /*---------------Trancking an Invoice--------------------*/

    mapping(uint256 => Invoice) public invoices;

    /*-----------------InvoiceId-------------------*/

    uint public invoiceId;

    constructor() {}

    /*-----------------Private Funtion for erros and checks--------------------*/

    function zeroAddress(address _add) private pure {
        if (_add == address(0)) {
            revert Errors.ZeroAddressDetected();
        }
    }

    function validateBalanceAndApproval(address _tokenAddress, address from,  uint _amt) private view {
 uint bal = IERC20(_tokenAddress).balanceOf(from);
         uint allowance = IERC20(_tokenAddress).allowance(from, address(this));

      if(bal<_amt){
        revert Errors.InsufficientBalanace();
      }
      
      if(allowance<_amt){
        revert Errors.InsufficientBalanace();
      }
    }

    function validateInvoiceID(uint ivId) private view {
        if (ivId == 0) revert Errors.InvalidInvoiceId();
        if(invoices[ivId].isPaid){
            revert Errors.InvalidPaidForAlready();
        }
    }

    /*-----------------Funtion to create an Create Invoice--------------------*/

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



    /*-----------------Funtion for buyer to make payment Invoice--------------------*/
    function payInvoice(uint _invoiceId) external nonReentrant  {

        zeroAddress(msg.sender);
        validateInvoiceID(_invoiceId);

        Invoice storage _invoice = invoices[_invoiceId];
        if(_invoice.isPaid){
            revert("Invoice already paid");
        }

            /*-----------------Check user token balance and send allowance to invoichain to send on his behal--------------------*/
          validateBalanceAndApproval(_invoice.tokenAddress, msg.sender, _invoice.amount);
          
          /*-----------------Transfer token to seller--------------------*/
        IERC20(_invoice.tokenAddress).transferFrom(msg.sender, _invoice.seller, _invoice.amount);
      
        _invoice.isPaid = true;

        emit Events.PaymentSuccessful(_invoice.seller, _invoice.amount, _invoiceId);
    }




    /*-----------------Funtion to get Invoice details--------------------*/

    function generateInvoice(uint _invoiceId) external view returns(Invoice memory) {
        return invoices[_invoiceId];

    }
}
