import hre, { ethers } from "hardhat";
import addressUtils from "../constants/all_address";
import { ChainSupport } from "../deploy";

const getRouterAndDonID = (chain: ChainSupport) => {
  switch (chain) {
    case ChainSupport.sepolia:
      return {
        router: "0xb83E47C2bC239B3bf370bc41e1459A34b41238D0",
        donID:
          "0x66756e2d657468657265756d2d7365706f6c69612d3100000000000000000000",
      };
    case ChainSupport.arbitrumSepolia:
      return {
        router: "0x234a5fb5Bd614a7AA2FfAB244D603abFA0Ac5C5C",
        donID:
          "0x66756e2d617262697472756d2d7365706f6c69612d3100000000000000000000",
      };
    default:
      throw new Error("Invalid chain");
  }
};

export async function deployInvoiceFunction(chain: ChainSupport) {
    const { router, donID } = await getRouterAndDonID(chain);
    const InvoiceFunction = await ethers.getContractFactory("InvoiceFunction");
    
    // Deploy the contract
    const invoiceFunction = await InvoiceFunction.deploy(router, donID);
    
    // Wait for deployment to complete
    // await invoiceFunction.deployed(); // This is critical
    
    console.log("Deployed invoiceFunction at: ", invoiceFunction["target"]); // Access address property
    
    await addressUtils.saveAddresses(hre.network.name, {
    //   InvoiceFunction: invoiceFunction.getAddress,
    });
    
    return invoiceFunction; // Return the contract instance with the address
}

  
