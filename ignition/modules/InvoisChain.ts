import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const InvoiceChainModule = buildModule("InvoiceChainModule", (m) => {

  const invoiceChain = m.contract("InvoiceChain");

  return { invoiceChain };
});

  export default InvoiceChainModule;
