import Eventr from 0x02
import NonFungibleToken from 0x01
import FungibleToken from 0x03
import FlowToken from 0x04



transaction (){

  prepare(acct: AuthAccount) {    
    acct.save(<- Eventr.createNFTMinter(), to: /storage/MyMintNFT)
    acct.link<&Eventr.MintNFT{Eventr.MintNFTPublic}>(/public/MyMintNFT, target: /storage/MyMintNFT)
  }

  execute {
    log("A user stored a NFTMinter inside their account")
  }
}