import hre, { ethers } from "hardhat";
import addressUtils from "../constants/all_address";

export async function deployInvoiceUpkeep(
  interval: number,
  invoiceFactoryAddress: string
) {
  const InvoiceUpkeep = await ethers.getContractFactory("InvoiceUpkeep");
  const invoiceUpkeep = await InvoiceUpkeep.deploy(
    interval,
    invoiceFactoryAddress
  );
//   await invoiceUpkeep.deployed();
  console.log("Deployed invoiceUpkeep at: ", invoiceUpkeep["target"]);
  await addressUtils.saveAddresses(hre.network.name, {
    // InvoiceUpkeep: invoiceUpkeep.address,
  });
  return invoiceUpkeep;
}
