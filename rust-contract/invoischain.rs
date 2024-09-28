#![no_std]
extern crate alloc;

use alloc::string::String;
use alloc::vec::Vec;
use serde::{Deserialize, Serialize};

/// A structure representing an invoice.
#[derive(Default, Debug, Clone, Serialize, Deserialize)]
pub struct Invoice {
    buyer: [u8; 20],           // Equivalent to Solidity's `address`
    seller: [u8; 20],
    goods: Vec<String>,
    date: u64,
    amount: u128,              // Equivalent to Solidity's `uint256`
    is_paid: bool,
    token_address: [u8; 20],
    amount_paid_in_ether: u128,
    invoice_id: u64,
}

/// Contract storage for managing invoices.
pub struct InvoiceChain {
    invoices: Vec<Invoice>,
    invoice_count: u64,
}

impl InvoiceChain {
    /// Constructor to initialize the contract.
    pub fn new() -> Self {
        Self {
            invoices: Vec::new(),
            invoice_count: 0,
        }
    }

    /// Creates a new invoice.
    pub fn create_invoice(
        &mut self,
        buyer: [u8; 20],
        seller: [u8; 20],
        goods: Vec<String>,
        amount: u128,
        token_address: [u8; 20],
    ) -> Result<(), &'static str> {
        // Basic zero-address validation.
        self.zero_address(buyer)?;
        self.zero_address(seller)?;
        self.zero_address(token_address)?;

        // Increment invoice count.
        let invoice_id = self.invoice_count;
        self.invoice_count += 1;

        // Create the new invoice.
        let new_invoice = Invoice {
            buyer,
            seller,
            goods,
            date: Self::get_current_time(),  // Mocked current timestamp
            amount,
            is_paid: false,
            token_address,
            amount_paid_in_ether: 0,
            invoice_id,
        };

        self.invoices.push(new_invoice);
        Ok(())
    }

    /// Pays an invoice using the specified ERC20 token.
    pub fn pay_invoice(&mut self, invoice_id: u64, buyer: [u8; 20]) -> Result<(), &'static str> {
        // Validate the invoice ID.
        let invoice = self.get_invoice_mut(invoice_id)?;
        if invoice.is_paid {
            return Err("Invoice already paid");
        }

        if invoice.buyer != buyer {
            return Err("Only the buyer can pay the invoice");
        }

        // Mark the invoice as paid.
        invoice.is_paid = true;
        Ok(())
    }

    /// Pays an invoice with Ether (Mock functionality as Arbitrum Stylus needs to support native token management).
    pub fn pay_with_ether(&mut self, invoice_id: u64, buyer: [u8; 20], ether_amount: u128) -> Result<(), &'static str> {
        let invoice = self.get_invoice_mut(invoice_id)?;
        if invoice.is_paid {
            return Err("Invoice already paid");
        }

        if invoice.buyer != buyer {
            return Err("Only the buyer can pay the invoice");
        }

        if ether_amount != invoice.amount {
            return Err("Incorrect Ether amount sent");
        }

        invoice.amount_paid_in_ether = ether_amount;
        invoice.is_paid = true;
        Ok(())
    }

    /// Withdraw Ether from a paid invoice by the seller.
    pub fn withdraw_ether(&mut self, invoice_id: u64, seller: [u8; 20]) -> Result<u128, &'static str> {
        let invoice = self.get_invoice_mut(invoice_id)?;
        if invoice.seller != seller {
            return Err("Only the seller can withdraw funds");
        }

        if !invoice.is_paid {
            return Err("Invoice not paid");
        }

        let amount = invoice.amount_paid_in_ether;
        invoice.amount_paid_in_ether = 0;
        Ok(amount)  // Returns the amount for further processing
    }

    /// Retrieves a single invoice by ID.
    pub fn get_invoice(&self, invoice_id: u64) -> Result<&Invoice, &'static str> {
        self.invoices.get(invoice_id as usize).ok_or("Invalid Invoice ID")
    }

    /// Retrieves a mutable reference to an invoice.
    fn get_invoice_mut(&mut self, invoice_id: u64) -> Result<&mut Invoice, &'static str> {
        self.invoices.get_mut(invoice_id as usize).ok_or("Invalid Invoice ID")
    }

    /// Check for zero address.
    fn zero_address(&self, address: [u8; 20]) -> Result<(), &'static str> {
        if address == [0u8; 20] {
            Err("Zero address detected")
        } else {
            Ok(())
        }
    }

    /// Mock function to get the current timestamp.
    fn get_current_time() -> u64 {
        0 // Replace with real-time getter when supported by the framework.
    }
}
