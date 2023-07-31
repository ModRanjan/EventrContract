// import NonFungibleToken from 0x01
// import MetadataViews from 0x03
import NonFungibleToken from "./NonFungibleToken.cdc"
import MetadataViews from "./MetadataViews.cdc"

pub contract Eventr: NonFungibleToken {

    // -----------------------------------------------------------------------
    // Eventr contract Events
    // -----------------------------------------------------------------------

    // Emitted when the Eventr contract is created
    pub event ContractInitialized()

    // Emitted when a new Pass struct is created
    pub event PassCreated(id: UInt64, passType: String, dropType: String)
    // Emitted when a new PassCategory struct is created
    pub event PassCategoryCreated(id: UInt64, passID: UInt64, price: UFix64)

    // Events for Set-Related actions
    //

    // Emitted when a new Event is created
    pub event EventCreated(eventID: UInt64)
    // Emitted when a Pass is added to aSet
    pub event PassAddedToEvent(eventID: UInt64, passID: UInt64)
    // Emitted when a PassCategory is added to aSet
    pub event PassCategoryAddedToEvent(eventID: UInt64, categoryID: UInt64)
    // Emitted when a Event is locked, meaning PassCategory cannot be added
    pub event EventLocked(setID: UInt64)
    // Emitted when a Token is minted from Set
    pub event TokenMinted(tokenId: UInt64, categoryID: UInt64, eventID: UInt64)

    // Events for Collection-related actions
    //

    // Emitted when a Token is withdraw from a Collection
    pub event Withdraw(id: UInt64, from: Address?)
    // Emitted when a Token is deposited into a Collection
    pub event Deposit(id: UInt64, to: Address?)
    // Emitted when a Token is destroyed
    pub event TokenDestroyed(id: UInt64)

    // -----------------------------------------------------------------------
    // Eventr contract-level fields.
    // These contain actual values that are stored in the smart contract.
    // -----------------------------------------------------------------------

    // Variable sixe dictionary of PassCategory structure
    access(self) var passCategoryData: {UInt64: PassCategory}

    // Variable size dictionary of Pass structs
    access(self) var passData: {UInt64: Pass}

    // Variable size dictionary of EventData structs
    access(self) var eventDatas: {UInt64: EventData}

    // Variable size dictionary of Series resources
    access(self) var events: @{UInt64: Event}

    // The ID that is used to create Passes. 
    // Every time a Pass is created, passID is assigned 
    // to the new Pass's ID and then is incremented by 1.
    pub var nextPassID: UInt64

    // The ID that is used to create passCategories. 
    // Every time a PassCategory is created, categoryID is assigned 
    // to the new PassCategory's ID and then is incremented by 1.
    pub var nextCategoryID: UInt64

    pub var totalSupply: UInt64
    
    // Named Paths
    pub let CollectionStoragePath: StoragePath
    pub let CollectionPublicPath: PublicPath
    pub let AdminStoragePath: StoragePath
    pub let AdminPrivatePath: PrivatePath

    pub enum PassType: UInt8 {
        pub case erc721
        pub case erc1155
    }

    pub fun passTypeToString(_ type: PassType): String {
        switch type {
            case PassType.erc721:
                return "ERC721"
            case PassType.erc1155:
                return "ERC1155"
        }

        return ""
    }

    pub enum DropType: UInt8 {
        pub case mint
        pub case premint
        pub case claim
    }

    pub fun dropTypeToString(_ type: DropType): String {
        switch type {
            case DropType.mint:
                return "MINT"
            case DropType.premint:
                return "PRE-MINT"
            case DropType.claim:
                return "CLAIM"
        }

        return ""
    }
    
    // -----------------------------------------------------------------------
    // Eventr contract-level Composite Type definitions
    // -----------------------------------------------------------------------

    // Pass
    pub struct Pass {
        pub let passID: UInt64
        pub let passType: PassType
        pub let dropType: DropType

        init(_passType: PassType, _dropType: DropType) {
            self.passID = Eventr.nextPassID
            self.passType = _passType
            self.dropType = _dropType
        }
    }

    // PassCategory
    pub struct PassCategory {
        pub let categoryID: UInt64
        pub let categoryName: String
        pub let eventID: UInt64
        pub let price: UFix64

        // Maximum number of editions that can be minted in this Set
        pub let maxEditions: UInt32

        init(_eventID: UInt64, _categoryName: String, _price: UFix64, _maxEditions: UInt32) {
            pre {
                _maxEditions >= 1 : "maxEdition cannot be less than 1"
            }

            self.categoryID = Eventr.nextCategoryID
            self.categoryName = _categoryName
            self.eventID = _eventID
            self.price = _price
            self.maxEditions = _maxEditions
        }
    }

    pub struct EventData {

        pub let eventID: UInt64
        pub let eventName: String

        access(contract) var passID: UInt64
        access(self) var metadata: {String: String}

        init(eventID: UInt64, eventName: String, passID: UInt64, metadata: {String: String}) {
            pre {
                eventName.length > 0: "New event name cannot be empty"
            }

            self.eventID = eventID
            self.eventName = eventName
            self.passID = passID
            self.metadata = metadata

            emit EventCreated(eventID: eventID)
        }

        pub fun getMetadata(): {String: String} {
            return self.metadata
        }

        pub fun getPassID(): UInt64 {
            return self.passID
        }
    }

    pub resource Event {

        pub let eventID: UInt64
        pub var locked: Bool

        access(contract) var passCategories: [UInt64]

        access(contract) var numberMintedPerPassCategory: {UInt64: UInt32}

        init(_eventID: UInt64, _name: String, _metadata: {String: String}) {

            self.eventID = _eventID
            self.passCategories = []
            self.numberMintedPerPassCategory ={}
            self.locked = false
            
            let passId = Eventr.nextPassID
            // Create a new EventData for this Event and store it in contract storage
            Eventr.eventDatas[self.eventID] = EventData(eventID: _eventID, eventName: _name, passID: passId, metadata: _metadata)     
        }

        access(contract) fun addPassCategory(categoryID: UInt64) {
            pre {
                Eventr.passCategoryData[categoryID] != nil: "Cannot add the PassCategory to Event: Category doesn't exist."
                self.numberMintedPerPassCategory[categoryID] == nil: "The PassCategory has already beed added to the Event."
            }

            self.passCategories.append(categoryID)

            self.numberMintedPerPassCategory[categoryID] = 0

            emit PassCategoryAddedToEvent(eventID: self.eventID, categoryID: categoryID)
        }

        pub fun addPassCategories(categoryIDs: [UInt64]) {
            pre {
                !self.locked: "Cannot add the PassCategory to the Event after the event has been locked."
            }

            for categoryId in categoryIDs {
                self.addPassCategory(categoryID: categoryId)
            }
        }

        pub fun lock() {
            pre {
                self.locked == false: "The Event is already locked"
            }
            
            self.locked = true
            emit EventLocked(setID: self.eventID)
            
        }
 
        pub fun mintToken(eventID:UInt64, categoryID: UInt64): @NFT {
            pre {
                Eventr.events[eventID] != nil: "Event does not exist with this eventID!"
                self.numberMintedPerPassCategory[categoryID]! < Eventr.getPassCategoryMaxLimit(categoryID: categoryID)!:
                    "Pass Category has reached maximum NFT edition capacity."
            }

            let numInPassCategory = self.numberMintedPerPassCategory[categoryID]!

            let newToken: @NFT <- create NFT(eventID: self.eventID, categoryID: categoryID)

            self.numberMintedPerPassCategory[categoryID] = numInPassCategory + (1)

            return <-newToken
        }

        pub fun batchMintToken(eventId: UInt64, categoryId: UInt64, quantity: UInt64): @Collection {
            let newCollection <- create Collection()

            var i: UInt64 = 0
            while i < quantity {
                newCollection.deposit(token: <-self.mintToken(eventID:eventId, categoryID:categoryId))
                i = i + (1)
            }

            return <-newCollection
        }

        pub fun getPassCategories(): [UInt64] {
            return self.passCategories
        }

        pub fun getNumMintedPerPassCategory(): {UInt64: UInt32} {
            return self.numberMintedPerPassCategory
        }
    }

    pub struct QueryEventData {
        pub let eventID: UInt64
        pub let eventName: String
        pub let passID: UInt64
        access(self) var passCategories: [UInt64]
        pub var locked: Bool
        access(self) var numberMintedPerPassCategory: {UInt64: UInt32}

        init(eventID: UInt64) {
            pre {
                Eventr.events[eventID] != nil: "The set with the provided ID does not exist"
            }

            let tempEvent = (&Eventr.events[eventID] as &Event?)!
            let tempEventData = Eventr.eventDatas[eventID]!

            self.eventID = eventID
            self.eventName = tempEventData.eventName
            self.passID = tempEventData.passID
            self.passCategories = tempEvent.passCategories
            self.locked = tempEvent.locked
            self.numberMintedPerPassCategory = tempEvent.numberMintedPerPassCategory
        }

        pub fun getPassCategories(): [UInt64] {
            return self.passCategories
        }

        pub fun getNumberMintedPerPassCategories(): {UInt64: UInt32} {
            return self.numberMintedPerPassCategory
        }
    }

    // This is an implementation of a custom metadata view for Eventr.
    pub struct EventrTokenMetadataView {
        pub let eventID: UInt64
        pub let eventName: String?
        pub let passID: UInt64
        pub let passType: String?
        pub let categoryID: UInt64
        pub let dateOfToken: String?
        pub let passCategoryName: String?
        pub let numTokensInPass: UInt32?

        init(
            eventID: UInt64,
            eventName: String?,
            passID: UInt64,
            passType: String?,
            categoryID: UInt64,
            passCategoryName: String?,
            numTokensInPass: UInt32?,
            dateOfToken: String?
        ) {
            self.eventID = eventID
            self.eventName = eventName
            self.passID = passID
            self.passType = passType
            self.categoryID = categoryID
            self.passCategoryName = passCategoryName
            self.numTokensInPass = numTokensInPass
            self.dateOfToken= dateOfToken
        }
    }

    pub struct TokenData {

        pub let eventID: UInt64
        pub let categoryID: UInt64

        init(_eventID: UInt64, _categoryID: UInt64) {
            self.eventID = _eventID
            self.categoryID = _categoryID
        }
    }

    pub resource NFT: NonFungibleToken.INFT, MetadataViews.Resolver {

        // Global unique moment ID
        pub let id: UInt64
        
        // Struct of Token metadata
        pub let data: TokenData

        init(eventID: UInt64, categoryID: UInt64) {
            Eventr.totalSupply = Eventr.totalSupply + (1)

            self.id = Eventr.totalSupply

            // Set the metadata struct
            self.data = TokenData(_eventID: eventID, _categoryID: categoryID)

            emit TokenMinted(tokenId: self.id, categoryID: categoryID, eventID: self.data.eventID)
        }

        destroy() {
            Eventr.totalSupply = Eventr.totalSupply - (1)
            emit TokenDestroyed(id: self.id)
        }

        pub fun name(): String {
            let eventName: String = Eventr.getEventMetaDataByField(eventID: self.data.eventID,field: "eventName") ?? ""
            let categoryName = Eventr.passCategoryData[self.data.categoryID]?.categoryName ?? ""
            let toknId = self.id
            
            return (eventName
                    .concat(" ")
                    .concat(" ")
                    .concat(categoryName)
                    .concat(" ")
                    .concat(toknId.toString()))
        } 

        access(self) fun buildDescString(): String {
            let eventName: String = Eventr.getEventName(eventID: self.data.eventID) ?? ""
            let categoryName = Eventr.passCategoryData[self.data.categoryID]?.categoryName ?? ""
            let endTimeStamp: String = Eventr.getEventMetaDataByField(eventID: self.data.eventID, field: "endTimeStamp") ?? ""
             let passType: String = Eventr.getEventMetaDataByField(eventID: self.data.eventID, field: "passType") ?? ""

            return categoryName
                    .concat("This token belongs to event name: ")
                    .concat(eventName)
                    .concat(" Pass Type: ")
                    .concat(passType)
                    .concat(" and is valid for")
                    .concat(endTimeStamp)
        }

        pub fun description(): String {
            let eventDescription: String = Eventr.getEventMetaDataByField(eventID: self.data.eventID, field: "description") ?? ""
            
            return eventDescription.length > 0 ? eventDescription : self.buildDescString()
        } 

        // All supported metadata views for the Token including the Core NFT Views
        pub fun getViews(): [Type] {
            return [
                Type<EventrTokenMetadataView>(),
                Type<MetadataViews.Display>(),
                Type<MetadataViews.NFTCollectionData>(),
                Type<MetadataViews.NFTCollectionDisplay>()
            ]
        }    

        pub fun resolveView(_ view: Type): AnyStruct? {
            switch view {
                case Type<MetadataViews.Display>():
                    return MetadataViews.Display(
                        name: self.name(),
                        description: self.description(),
                        thumbnail: MetadataViews.HTTPFile(url: self.thumbnail())
                    )
                // Custom metadata view unique to Eventr Tokens
                case Type<EventrTokenMetadataView>():
                    return EventrTokenMetadataView(
                        eventID:  self.data.eventID,
                        eventName: Eventr.getEventMetaDataByField(eventID: self.data.eventID ,field:"eventName"),
                        passID: (Eventr.getEventData(eventID: self.data.eventID)?.passID)!,
                        passType: Eventr.getEventMetaDataByField(eventID: self.data.eventID, field: "passType"),
                        categoryID: self.id,
                        passCategoryName: Eventr.getEventMetaDataByField(eventID: self.data.eventID, field: "CategoryName"),
                        numTokensInPass: Eventr.getNumTokensInPassCategory(eventID: self.data.eventID, categoryID: self.id),
                        dateOfToken: Eventr.getEventMetaDataByField(eventID: self.data.eventID, field: "dateOfToken")
                    )
                case Type<MetadataViews.NFTCollectionData>():
                    return MetadataViews.NFTCollectionData(
                        storagePath: Eventr.CollectionStoragePath,
                        publicPath: Eventr.CollectionPublicPath,
                        providerPath: /private/EventrCollection,
                        publicCollection: Type<&Eventr.Collection{Eventr.CollectionPublic}>(),
                        publicLinkedType: Type<&Eventr.Collection{Eventr.CollectionPublic,NonFungibleToken.Receiver,NonFungibleToken.CollectionPublic,MetadataViews.ResolverCollection}>(),
                        providerLinkedType: Type<&Eventr.Collection{NonFungibleToken.Provider,Eventr.CollectionPublic,NonFungibleToken.Receiver,NonFungibleToken.CollectionPublic,MetadataViews.ResolverCollection}>(),
                        createEmptyCollectionFunction: (fun (): @NonFungibleToken.Collection {
                            return <-Eventr.createEmptyCollection()
                        })
                    )
                case Type<MetadataViews.NFTCollectionDisplay>():
                    let bannerImage = MetadataViews.Media(
                        file: MetadataViews.HTTPFile(
                            url: Eventr.getEventMetaDataByField(eventID: self.data.eventID,field: "coverURL")!
                        ),
                        mediaType: "image/svg+xml"
                    )
                    let squareImage = MetadataViews.Media(
                        file: MetadataViews.HTTPFile(
                            url: Eventr.getEventMetaDataByField(eventID: self.data.eventID,field: "profileURL")!
                        ),
                        mediaType: "image/png"
                    )
                    return MetadataViews.NFTCollectionDisplay(
                        name: "Eventr",
                        description: "Eventr is DApp to create and manage events tgh creating tokeniztion method. you can create pass,s tokens in the form of NFT.",
                        externalURL: MetadataViews.ExternalURL(""),
                        squareImage: squareImage,
                        bannerImage: bannerImage,
                        socials: {
                            "twitter": MetadataViews.ExternalURL("https://twitter.com/"),
                            "discord": MetadataViews.ExternalURL("https://discord.com/"),
                            "instagram": MetadataViews.ExternalURL("https://www.instagram.com/")
                        }
                    )
            }

            return nil
        }

        pub fun thumbnail(): String {
            let url = Eventr.getEventMetaDataByField(eventID: self.data.eventID,field: "conerURL")!
                        .concat("?width=256")
            return url
        }
    }

    pub resource Admin {
  
        access(self) fun createPass(_ passType: PassType, _ dropType: DropType): UInt64 {
            // Create the new Pass
            var newPass = Pass(_passType: passType, _dropType: dropType)

            let newID = newPass.passID
            let tempPassType = Eventr.passTypeToString(newPass.passType)
            let tempDropType = Eventr.dropTypeToString(newPass.dropType)

            emit PassCreated(id: newPass.passID, passType: tempPassType, dropType: tempDropType)
            Eventr.nextPassID = Eventr.nextPassID + 1

            Eventr.passData[newID] = newPass

            return newID
        }

        pub fun createPassCategory(eventID: UInt64, categoryName: String, price: UFix64, maxLimit: UInt32): UInt64 {
            pre {
                Eventr.events[eventID] != nil: "Cannot create the Category to Event: Event doesn't exist. You have to create Event first"
                false == Eventr.isEventLocked(eventID: eventID): "Cannot create the Category to Event: event has been locked."
            }

            let eventRef = self.borrowEvent(eventID: eventID)
            let passId = Eventr.getEventData(eventID: eventID)?.passID!
            let eventPassType = Eventr.passTypeToString(Eventr.passData[passId]?.passType!)
            
            
            // Create the new PassCategory struct
            var newPassCategory = PassCategory( _eventID: eventID,_categoryName: categoryName, _price: price, _maxEditions: maxLimit)
            let newID = newPassCategory.categoryID
            
            Eventr.nextCategoryID = Eventr.nextCategoryID + (1)
            Eventr.passCategoryData[newID] = newPassCategory

            if(eventPassType == Eventr.passTypeToString(Eventr.PassType.erc721)) { 
                eventRef.addPassCategory(categoryID: newID)              
                eventRef.lock()
            }
            
            emit PassCategoryCreated(id: newID, passID: passId, price: price)

            return newID
        }


        // createEvent creates a new Event resource and stores it 
        // in the events mapping in the Eventr contract
        //
        // Parameters: eventID:
        //             name: The name of the Event 
        //             passID:
        //             passType:
        //             dropType:
        //             metadata:
        //
        // Returns: The ID of the created event
        pub fun createEvent(eventID: UInt64, name: String, passType: PassType, dropType: DropType, metadata: {String: String}): UInt64 {
            let tempPassId = Eventr.nextPassID

            // Create the new Event
            var newEvent <- create Event(_eventID: eventID, _name: name, _metadata: metadata)            

            // Create new Pass
            var passId = self.createPass(passType, dropType)

            let newID = newEvent.eventID

            emit EventCreated(eventID: newEvent.eventID)

            // Store it in the events mapping field
            Eventr.events[newID] <-! newEvent

            return newID
        }

        // borrowEvent returns a reference to a event in the Eventr
        // contract so that the admin can call methods on it
        //
        // Parameters: eventID: The ID of the Event that you want to
        // get a reference to
        //
        // Returns: A reference to the Event with all of the fields
        // and methods exposed
        //
        pub fun borrowEvent(eventID: UInt64): &Event {
            pre {
                Eventr.events[eventID] != nil: "Cannot borrow Event: The Event doesn't exist"
            }
            
            // Get a reference to the Set and return it
            // use `&` to indicate the reference to the object and type
            return (&Eventr.events[eventID] as &Event?)!
        }

        // createNewAdmin creates a new Admin resource
        pub fun createNewAdmin(): @Admin {
            return <-create Admin()
        }
    }

    pub resource interface CollectionPublic {
        pub fun deposit(token: @NonFungibleToken.NFT)
        pub fun batchDeposit(tokens: @NonFungibleToken.Collection)
        pub fun getIDs(): [UInt64]
        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT
        pub fun borrowToken(id: UInt64): &Eventr.NFT? {
            // If the result isn't nil, the id of the returned reference
            // should be the same as the argument to the function
            post {
                (result == nil) || (result?.id == id): 
                    "Cannot borrow Token reference: The ID of the returned reference is incorrect"
            }
        }
    }

    pub resource Collection: CollectionPublic, NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection { 
        // Dictionary of Moment conforming tokens
        // NFT is a resource type with a UInt64 ID field
        pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}

        init() {
            self.ownedNFTs <- {}
        }

        pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {

            // Remove the nft from the Collection
            let token <- self.ownedNFTs.remove(key: withdrawID) 
                ?? panic("Cannot withdraw: Moment does not exist in the collection")

            emit Withdraw(id: token.id, from: self.owner?.address)
            
            // Return the withdrawn token
            return <-token
        }

        pub fun batchWithdraw(ids: [UInt64]): @NonFungibleToken.Collection {
            // Create a new empty Collection
            var batchCollection <- create Collection()
            
            // Iterate through the ids and withdraw them from the Collection
            for id in ids {
                batchCollection.deposit(token: <-self.withdraw(withdrawID: id))
            }
            
            // Return the withdrawn tokens
            return <-batchCollection
        }

        // deposit takes a Moment and adds it to the Collections dictionary
        //
        // Paramters: token: the NFT to be deposited in the collection
        //
        pub fun deposit(token: @NonFungibleToken.NFT) {
            
            // Cast the deposited token as a TopShot NFT to make sure
            // it is the correct type
            let token <- token as! @Eventr.NFT

            // Get the token's ID
            let id = token.id

            // Add the new token to the dictionary
            let oldToken <- self.ownedNFTs[id] <- token

            // Only emit a deposit event if the Collection 
            // is in an account's storage
            if self.owner?.address != nil {
                emit Deposit(id: id, to: self.owner?.address)
            }

            // Destroy the empty old token that was "removed"
            destroy oldToken
        }

        // batchDeposit takes a Collection object as an argument
        // and deposits each contained NFT into this Collection
        pub fun batchDeposit(tokens: @NonFungibleToken.Collection) {

            // Get an array of the IDs to be deposited
            let keys = tokens.getIDs()

            // Iterate through the keys in the collection and deposit each one
            for key in keys {
                self.deposit(token: <-tokens.withdraw(withdrawID: key))
            }

            // Destroy the empty Collection
            destroy tokens
        }

        pub fun getIDs(): [UInt64] {
            return self.ownedNFTs.keys
        }

        // borrowNFT Returns a borrowed reference to a Moment in the Collection
        // so that the caller can read its ID
        //
        // Parameters: id: The ID of the NFT to get the reference for
        //
        // Returns: A reference to the NFT
        //
        // Note: This only allows the caller to read the ID of the NFT,
        // not any topshot specific data. Please use borrowToken to 
        // read Token data.
        //
        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT {
            return (&self.ownedNFTs[id] as &NonFungibleToken.NFT?)!
        }

        // borrowMoment returns a borrowed reference to a Moment
        // so that the caller can read data and call methods from it.
        // They can use this to read its setID, playID, serialNumber,
        // or any of the setData or Play data associated with it by
        // getting the setID or playID and reading those fields from
        // the smart contract.
        //
        // Parameters: id: The ID of the NFT to get the reference for
        //
        // Returns: A reference to the NFT
        pub fun borrowToken(id: UInt64): &Eventr.NFT? {
            if self.ownedNFTs[id] != nil {
                let ref = (&self.ownedNFTs[id] as auth &NonFungibleToken.NFT?)!
                return ref as! &Eventr.NFT
            } else {
                return nil
            }
        }
        
        // Safe way to borrow a reference to an NFT that does not panic
        // Also now part of the NonFungibleToken.PublicCollection interface
        //
        // Parameters: id: The ID of the NFT to get the reference for
        //
        // Returns: An optional reference to the desired NFT, will be nil if the passed ID does not exist
        pub fun borrowNFTSafe(id: UInt64): &NonFungibleToken.NFT? {
            if let nftRef = &self.ownedNFTs[id] as &NonFungibleToken.NFT? {
                return nftRef
            }
            return nil
        }

        pub fun borrowViewResolver(id: UInt64): &AnyResource{MetadataViews.Resolver} {
            let nft = (&self.ownedNFTs[id] as auth &NonFungibleToken.NFT?)! 
            let eventrNFT = nft as! &Eventr.NFT
            return eventrNFT as &AnyResource{MetadataViews.Resolver}
        }

        destroy() {
            destroy self.ownedNFTs
        }
    }

    // -----------------------------------------------------------------------
    // TopShot contract-level function definitions
    // -----------------------------------------------------------------------

    pub fun createEmptyCollection(): @NonFungibleToken.Collection {
        return <-create Eventr.Collection()
    }

    // getAllEvents returns all the Event's Data in Eventr
    //
    // Returns: An array of all the EventData that have been created
    pub fun getAllEvents(): [Eventr.EventData] {
        return Eventr.eventDatas.values
    }

    // fetch
    // Get a reference to a Event from an account's Collection, if available.
    // If an account does not have a Eventr.Collection, panic.
    // If it has a collection but does not contain the Id, return nil.
    // If it has a collection and that collection contains the Id, return a reference to that.
    //
    pub fun fetch(_ from: Address, id: UInt64): &Eventr.NFT? {
        let collection = getAccount(from)
            .getCapability(Eventr.CollectionPublicPath)
            .borrow<&Eventr.Collection{Eventr.CollectionPublic}>()
            ?? panic("Couldn't get collection")

        // We trust Eventr.Collection.borrowToken to get the correct id
        // (it checks it before returning it).
        return collection.borrowToken(id: id)
    }

    // getEventMetaData returns all the metadata associated with a specific event
    // 
    // Parameters: eventID: The id of the Play that is being searched
    //
    // Returns: The metadata as a String to String mapping optional
    pub fun getEventMetaData(eventID: UInt64): {String: String}? {
        return self.eventDatas[eventID]?.getMetadata()
    }

    // getEventMetaDataByField returns the metadata associated with a 
    // specific field of the metadata of that Event
    // 
    // Parameters: eventID: The id of the Event that is being searched
    //             field: The field to search for
    //
    // Returns: The metadata field as a String Optional
    pub fun getEventMetaDataByField(eventID: UInt64, field: String): String? {
        // Don't force a revert if the eventID or field is invalid
        if let tempEvent = Eventr.eventDatas[eventID] {
            let eventMetadata = tempEvent.getMetadata()
            return eventMetadata[field]
        } else {
            return nil
        }
    }

    // geteventData returns the data that the specified Event
    // is associated with.
    // 
    // Parameters: eventID: The id of the Event that is being searched
    //
    // Returns: The QueryEventData struct that has all the important information about the event
    pub fun getEventData(eventID: UInt64): QueryEventData? {
        if Eventr.events[eventID] == nil {
            return nil
        } else {
            return QueryEventData(eventID: eventID)
        }
    }
    
    pub fun getPassData(passID: UInt64): Eventr.Pass? {
        if Eventr.passData[passID] == nil {
            return nil
        } else {
            return Eventr.passData[passID]
        }
    }

    // getEventName returns the name that the specified Event
    // is associated with.
    // 
    // Parameters: eventID: The id of the Event that is being searched
    //
    // Returns: The name of the Event
    pub fun getEventName(eventID: UInt64): String? {
        // Don't force a revert if the setID is invalid
        return Eventr.eventDatas[eventID]?.eventName
    }

    // getEventIDsByName returns the IDs that the specified Event name
    // is associated with.
    // 
    // Parameters: eventName: The name of the Event that is being searched
    //
    // Returns: An array of the IDs of the Event if it exists, or nil if doesn't
    pub fun getEventIDsByName(eventName: String): [UInt64]? {
        var eventIDs: [UInt64] = []

        // Iterate through all the eventDatas and search for the name
        for event in Eventr.eventDatas.values {
            if eventName == event.eventName {
                // If the name is found, return the ID
                eventIDs.append(event.eventID)
            }
        }

        // If the name isn't found, return nil
        // Don't force a revert if the setName is invalid
        if eventIDs.length == 0 {
            return nil
        } else {
            return eventIDs
        }
    }

    // getPassCategoryMaxLimit returns the the maximum number of NFT editions that can
    //        be minted in this PassCategory.
    // 
    // Parameters: categoryID: The id of the PassCategory that is being searched
    //
    // Returns: The max number of NFT editions in this PassCategory
    pub fun getPassCategoryMaxLimit(categoryID: UInt64): UInt32? {
     return Eventr.passCategoryData[categoryID]?.maxEditions
    }

    // getNumTokensInPassCategory return the number of Tokens that have been 
    // minted from a certain category.
    //
    // Parameters: eventID: The id of the Event that is being searched
    //             categoryID: The id of the PassCategory that is being searched
    //
    // Returns: The total number of Tokens that have been minted from an Category
    pub fun getNumTokensInPassCategory(eventID: UInt64, categoryID: UInt64): UInt32? {
        if let tempEventdata = self.getEventData(eventID: eventID) {

            // Read the numMintedPerPerPassCategories
            let amount = tempEventdata.getNumberMintedPerPassCategories()[categoryID]

            return amount
        } else {
            // If the set wasn't found return nil
            return nil
        }
    }

    // getPassCategoryEventId returns the Event Id the PassCategory belongs to
    // 
    // Parameters: categoryId: The id of the PassCategory that is being searched
    //
    // Returns: The Event Id
    pub fun getPassCategoryEventId(categoryId: UInt64): UInt64? {
        return Eventr.passCategoryData[categoryId]?.eventID
    }

    // getCategoriesInPass returns the list of categories IDs that are in the Event
    // 
    // Here we function name is `getCategoriesInPass` but need eventID as parameter
    // because Event has only one pass and Event is storing all Passcategories
    //
    // Parameters: eventID: The id of the Event that is being searched
    //
    // Returns: An array of Categories IDs
    pub fun getCategoriesInPass(eventID: UInt64): [UInt64]? {
        // Don't force a revert if the setID is invalid
        return Eventr.events[eventID]?.passCategories
    }

    // isEventLocked returns a boolean that indicates if a Event
    // is locked. If it's locked, Categories can no longer be added to it,
    // but Tokens can still be minted from Pass the Event contains.
    // 
    // Parameters: eventID: The id of the Event that is being searched
    //
    // Returns: Boolean indicating if the Event is locked or not
    pub fun isEventLocked(eventID: UInt64): Bool {
        if(Eventr.events[eventID]?.locked == true){
            return  true
        }

        return false
    }


    init() {

        // Set named paths
        self.CollectionStoragePath = /storage/EventrCollection
        self.CollectionPublicPath = /public/EventrCollection
        self.AdminStoragePath = /storage/EventrAdmin
        self.AdminPrivatePath = /private/EventrAdminUpgrade

        // Initialize contract fields
        self.nextCategoryID = 1
        self.nextPassID = 1
        self.passData = {}
        self.passCategoryData = {}
        self.eventDatas = {}
        self.events <- {}
        self.totalSupply = 0

        // Put a new Collection in storage
        self.account.save<@Collection>(<- create Collection(), to: self.CollectionStoragePath)

        // Create a public capability for the Collection
        self.account.link<&{CollectionPublic}>(self.CollectionPublicPath, target: self.CollectionStoragePath)

        // Put the Minter in storage
        self.account.save<@Admin>(<- create Admin(), to: self.AdminStoragePath)

        emit ContractInitialized()
    }

}
