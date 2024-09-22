import hre, { ethers } from "hardhat";
import addressUtils from "./constants/all_address";
import { deployInvoiceFactory } from "./deploy/InvoiceFactory";
import { deployInvoiceFunction } from "./deploy/InvoiceFuntion";
import { deployInvoiceUpkeep } from "./deploy/InvoiceUpkeep";

export enum ChainSupport {
    "sepolia" = "sepolia",

    "arbitrumSepolia" = "arbitrumSepolia",
    "hardhat" = "hardhat",
}

const getChainSelector = (chain: ChainSupport) => {
  switch (chain) {
    case ChainSupport.sepolia: 
      return "16015286601757825753";
      case ChainSupport.arbitrumSepolia:
          return "3478487238524512106";

    default:
      throw new Error("Invalid chain");
  }
};

const getRouterAndLink = (chain: ChainSupport) => {
  switch (chain) {
    case ChainSupport.sepolia:
      return {
        router: "0xd0daae2231e9cb96b94c8512223533293c3693bf",
        link: "0x779877A7B0D9E8603169DdbD7836e478b4624789",
      };
    case ChainSupport.arbitrumSepolia:
      return {
        router: "0x2a9C5afB0d0e4BAb2BCdaE109EC4b0c4Be15a165",
        link: "0xf97f4df75117a78c1A5a0DBb814Af92458539FB4",
      };
    case ChainSupport.arbitrumSepolia:
      return {
        router: "0x2a9C5afB0d0e4BAb2BCdaE109EC4b0c4Be15a165",
        link: "0xb1D4538B4571d411F07960EF2838Ce337FE1E80E",
      };
    default:
      throw new Error("Invalid chain");
  }
};

async function main() {
  const chain = hre.network.name as ChainSupport;
  const addressList = await addressUtils.getAddressList(hre.network.name);
  const chainSelector = getChainSelector(chain);
  const { router, link } = getRouterAndLink(chain);
  // const invoiceFunction = addressList.InvoiceFunction;

  const invoiceFunction = await deployInvoiceFunction(chain);
  const invoiceFactory = await deployInvoiceFactory(
    invoiceFunction,
    chainSelector,
    router,
    link
  );
    await deployInvoiceUpkeep(60, invoiceFactory);
    console.log("deployed")
  // console.log(ethers.constants.AddressZero);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
