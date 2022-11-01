import Eventr from 0xc2bf854ac7c824f6
import NonFungibleToken from 0xc2bf854ac7c824f6
import FungibleToken from 0x9a0766d93b6608b7
import FlowToken from 0x7e60df042a9c0868



transaction (){

  prepare(acct: AuthAccount) {    
    acct.save(<- Eventr.createNFTMinter(), to: /storage/MyMintNFT)
    acct.link<&Eventr.MintNFT{Eventr.MintNFTPublic}>(/public/MyMintNFT, target: /storage/MyMintNFT)
  }

  execute {
    log("A user stored a NFTMinter inside their account")
  }
}