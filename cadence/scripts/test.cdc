// get_token_metadata.cdc
import Eventr1 from "../contracts/Eventr.cdc"
import MetadataViews from "../contracts/utils/MetadataViews.cdc"
pub struct tokenMetadata {
    pub let tokenId: UInt64
    pub let eventID: UInt64 
    pub let eventName: String 
    pub let passID: UInt64 
    pub let passName: String 
    pub let passType: String 
    pub let categoryID: UInt64 
    pub let dateOfToken: UFix64
    pub let passCategoryName: String 
    pub let numTokensInPass: UInt32

    init(
        tokenId:UInt64,
        eventID: UInt64 ,
eventName: String,
passID: UInt64 ,
passName: String ,
passType: String,
categoryID: UInt64 ,
dateOfToken: UFix64,
passCategoryName: String,
numTokensInPass: UInt32
    ){
        self.tokenId=tokenId
        self.eventID = eventID
        self.eventName = eventName
        self.passID = passID
        self.passName = passName
        self.passType = passType
        self.categoryID = categoryID
        self.dateOfToken = dateOfToken
        self.passCategoryName = passCategoryName
        self.numTokensInPass = numTokensInPass
    }
}

pub fun main(address: Address) { // : [tokenMetadata]
    let account = getAccount(address)

    let collectionRef = account.getCapability(Eventr1.CollectionPublicPath)
        .borrow<&{Eventr1.CollectionPublic}>()!

    let IDs = collectionRef.getIDs()
    
    var result:[tokenMetadata]= []

    for Id in IDs {
    let nft = collectionRef.borrowToken(id: Id)!
    
    // Get the Top Shot specific metadata for this NFT
    let view = nft.resolveView(Type<Eventr1.EventrTokenMetadataView>())!

    let metadata = view as! Eventr1.EventrTokenMetadataView
    let temp = tokenMetadata(tokenId: Id,
            eventID: metadata.eventID, 
            eventName: metadata.eventName,
            passID: metadata.passID, 
            passName: metadata.passName, 
            passType: metadata.passType,
            categoryID: metadata.categoryID, 
            dateOfToken: metadata.dateOfToken!,
            passCategoryName: metadata.passCategoryName,
            numTokensInPass: metadata.numTokensInPass!
        )
    result.append(temp)
log(temp)
    }
    //return result
}
 