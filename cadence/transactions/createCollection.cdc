import ERC721 from 0x02
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
    acct.save(<- ERC721.createEmptyCollection(), to: _storagePath)
    acct.link<&ERC721.Collection{ERC721.CollectionPublic, NonFungibleToken.CollectionPublic}>(_publicPath, target: _storagePath)
    acct.link<&ERC721.Collection>(_privatePath, target: _storagePath)
    
    let MyNFTCollection = acct.getCapability<&ERC721.Collection>(_privatePath)    
  }

  execute {
    log("A user stored a Collection inside their account")
  }
}