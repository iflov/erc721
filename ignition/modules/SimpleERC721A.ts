import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("SimpleERC721AModule", (m) => {
  const collectionName = m.getParameter("collectionName", "MyERC721A");
  const collectionSymbol = m.getParameter("collectionSymbol", "M721A");
  const baseURI = m.getParameter("baseURI", "https://example.com/metadata/");
  const maxSupply = m.getParameter("maxSupply", 1000n);
  const maxPerWallet = m.getParameter("maxPerWallet", 5n);
  const mintPriceWei = m.getParameter("mintPriceWei", 0n);

  const nft = m.contract("SimpleERC721A", [
    collectionName,
    collectionSymbol,
    baseURI,
    maxSupply,
    maxPerWallet,
    mintPriceWei,
  ]);

  return { nft };
});
