// 2_create_event(erc721).cdc
import Eventr1 from 0x04

// This transaction is for the admin to create a new event resource
// and store it in the Eventr1 smart contract
//
// Parameters: 
//      eventID: 
//      eventName: the name of a new Event to be created
//      passType: either ERC721 or ERC1155
//      dropType: MINT / PRE-MINT / CLAIM
//      metadata: A dictionary of all the event metadata associated
//
transaction(eventID: UInt64, name: String, passName: String, passType: String, dropType: String, metadata:{String: String},categoryName: String, price: UFix64, maxLimit: UInt32) {
    /**     
    { "eventID":"1", 
      "eventName": "event_test-1",
      "passName": "pass_test-2", 
      "passType": "ERC721",
      "dropType": "mint", 
      "description": "event_day celebration", 
      "startTimeStamp": "", 
      "endTimeStamp": "",
      "coverUrl":"https://bafybeieyvgiwrhc4qafndqpcx3ghgm6m7i7i3wcq2fjjtlflub263n5a54.ipfs.nftstorage.link/", 
      "profileUrl": "https://bafybeieyvgiwrhc4qafndqpcx3ghgm6m7i7i3wcq2fjjtlflub263n5a54.ipfs.nftstorage.link/",
      "ownerAddress": ""
      }
    */

    let adminRef: &Eventr1.Admin
    
    prepare(signer: AuthAccount) {
        let adminStoragePath = StoragePath(identifier: "EventrAdminEventId".concat(eventID.toString()))
            ?? panic("does not specify a storage path")

        // borrow a reference to the Admin resource in storage
        self.adminRef = signer.borrow<&Eventr1.Admin>(from: adminStoragePath)
            ?? panic("Could not borrow a reference to the Admin resource")
    }

    execute {
        
        var tempPassType = Eventr1.PassType.erc721
        var tempDropType = Eventr1.DropType.mint
        
        if(passType == Eventr1.passTypeToString(Eventr1.PassType.erc1155)) {
            tempPassType = Eventr1.PassType.erc1155
        }
        if (dropType == Eventr1.dropTypeToString(Eventr1.DropType.premint)){
            tempDropType = Eventr1.DropType.premint
        }

        // Create a Event with the specified name and metadata
        self.adminRef.createEvent(eventID: eventID, name: name, passName: passName, passType: tempPassType, dropType: tempDropType, metadata: metadata)

        log("Event & Pass Both Are Created")

        // Create a passCategory
        let categoryId: UInt64 = self.adminRef.createPassCategory(eventID: eventID, categoryName: categoryName, price: price, maxLimit: maxLimit)
        log("Category Created and added to event")
        log(categoryId)
    }

    post {
        Eventr1.getEventName(eventID: eventID) == name:
          "Could not find the specified set"

        Eventr1.getEventMetaData(eventID: eventID) != nil:
            "eventID doesnt exist"
    }
}
