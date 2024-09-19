// SPDX-License-Identifier: MIT
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