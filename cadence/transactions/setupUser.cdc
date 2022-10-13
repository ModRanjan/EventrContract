import ERC721 from 0x02
import NonFungibleToken from 0x01
import FungibleToken from 0x03
import FlowToken from 0x04
import NFTMinter from 0x05

transaction {

  prepare(acct: AuthAccount) {
    acct.save(<- ERC721.createEmptyCollection(), to: /storage/MyNFTCollection)
    acct.link<&ERC721.Collection{ERC721.CollectionPublic, NonFungibleToken.CollectionPublic}>(/public/MyNFTCollection, target: /storage/MyNFTCollection)
    acct.link<&ERC721.Collection>(/private/MyNFTCollection, target: /storage/MyNFTCollection)
    
    let MyNFTCollection = acct.getCapability<&ERC721.Collection>(/private/MyNFTCollection)
    
    acct.save(<- NFTMinter.createNFTMinter(), to: /storage/MyMintNFT)
    acct.link<&NFTMinter.MintNFT{NFTMinter.MintNFTPublic}>(/public/MyMintNFT, target: /storage/MyMintNFT)
  }

  execute {
    log("A user stored a Collection and a NFTMinter inside their account")
  }
}