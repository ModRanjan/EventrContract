// get_token_metadata.cdc
import Eventr1 from "../contracts/Eventr.cdc"
import MetadataViews from "../contracts/utils/MetadataViews.cdc"


pub fun main(address: Address, id: UInt64): Eventr1.EventrTokenMetadataView {
    let account = getAccount(address)

    let collectionRef = account.getCapability(Eventr1.CollectionPublicPath)
        .borrow<&{Eventr1.CollectionPublic}>()!

    let nft = collectionRef.borrowToken(id: id)!
    
    // Get the Top Shot specific metadata for this NFT
    let view = nft.resolveView(Type<Eventr1.EventrTokenMetadataView>())!

    let metadata = view as! Eventr1.EventrTokenMetadataView
    
    return metadata
}
