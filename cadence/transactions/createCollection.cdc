import Eventr from 0xc2bf854ac7c824f6
import NonFungibleToken from 0xc2bf854ac7c824f6
import FungibleToken from 0x9a0766d93b6608b7
import FlowToken from 0x7e60df042a9c0868

/* 
/storage/MyNFTCollection
/public/MyNFTCollection
/private/MyNFTCollection

*/

transaction (_storagePath:StoragePath,_publicPath:CapabilityPath,_privatePath:PrivatePath){

  prepare(acct: AuthAccount) {
    acct.save(<- Eventr.createEmptyCollection(), to: _storagePath)
    acct.link<&Eventr.Collection{Eventr.CollectionPublic, NonFungibleToken.CollectionPublic}>(_publicPath, target: _storagePath)
    acct.link<&Eventr.Collection>(_privatePath, target: _storagePath)
    
    let MyNFTCollection = acct.getCapability<&Eventr.Collection>(_privatePath)    
  }

  execute {
    log("A user stored a Collection inside their account")
  }
}