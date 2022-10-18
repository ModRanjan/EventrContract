import ERC721 from 0x02
import NonFungibleToken from 0x01
pub fun main(account:Address,_collectionPath:PublicPath): [&ERC721.NFT?] {
  let collection = getAccount(account).getCapability(_collectionPath)
                    .borrow<&ERC721.Collection{NonFungibleToken.CollectionPublic, ERC721.CollectionPublic}>()
                    ?? panic("Can't get the User's collection.")
  let returnVals: [&ERC721.NFT?] = []
  let ids = collection.getIDs()
  
  for id in ids {
    returnVals.append(collection.borrowEntireNFT(id: id))
  }
  log(returnVals)
  return returnVals

  }