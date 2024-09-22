import hre, { ethers } from "hardhat";
import addressUtils from "../constants/all_address";
// import { ethers } from "ethers";

export async function deployInvoiceFactory(
  invoiceFunction: string,   // Ensure this is the contract address
  chainSelector: string,
  router: string,
  link: string
) {
  const [owner] = await ethers.getSigners();
  const InvoiceFactory = await hre.ethers.getContractFactory("InvoiceFactory");

  console.log("Deploying invoiceFactory...");

  // Ensure the correct Ethereum address is being passed
    const invoiceFactory = await InvoiceFactory.deploy(
        invoiceFunction,         // This should be the contract address (not 'target')
        owner.address,           // The owner's address
        chainSelector,           // The chain selector
        router,                  // The router address
        link                     // The LINK token address
    );

  // Ensure deployment is complete
//   await invoiceFactory.deployed();

  console.log("Deployed invoiceFactory at:", invoiceFactory["target"]);

  // Save the deployed contract address
  await addressUtils.saveAddresses(hre.network.name, {
//    InvoiceFactory: invoiceFactory.address,
  });

  return invoiceFactory;
}
