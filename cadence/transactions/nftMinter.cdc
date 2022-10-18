import ERC721 from 0x02
import NonFungibleToken from 0x01
import FungibleToken from 0x03
import FlowToken from 0x04



transaction (_storagePath:StoragePath,_publicPath:CapabilityPath,_privatePath:PrivatePath){

  prepare(acct: AuthAccount) {    
    acct.save(<- ERC721.createNFTMinter(), to: /storage/MyMintNFT)
    acct.link<&ERC721.MintNFT{ERC721.MintNFTPublic}>(/public/MyMintNFT, target: /storage/MyMintNFT)
  }

  execute {
    log("A user stored a NFTMinter inside their account")
  }
}