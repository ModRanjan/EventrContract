import Eventr from 0x02
import NonFungibleToken from 0x01
import FungibleToken from 0x03
import FlowToken from 0x04

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