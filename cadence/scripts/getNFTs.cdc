import Eventr from 0x02
import NonFungibleToken from 0x01
pub fun main(account:Address,_collectionPath:PublicPath): [&Eventr.NFT?] {
  let collection = getAccount(account).getCapability(_collectionPath)
                    .borrow<&Eventr.Collection{NonFungibleToken.CollectionPublic, Eventr.CollectionPublic}>()
                    ?? panic("Can't get the User's collection.")
  let returnVals: [&Eventr.NFT?] = []
  let ids = collection.getIDs()
  
  for id in ids {
    returnVals.append(collection.borrowEntireNFT(id: id))
  }
  log(returnVals)
  return returnVals

  }