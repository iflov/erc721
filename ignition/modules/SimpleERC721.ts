import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("SimpleERC721Module", (m) => {
  const name = m.getParameter("name", "MyNFT");
  const symbol = m.getParameter("symbol", "MNFT");

  const nft = m.contract("SimpleERC721", [name, symbol]);

  return { nft };
});
