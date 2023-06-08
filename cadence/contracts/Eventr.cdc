// for flow-testnet
// import NonFungibleToken from 0x631e88ae7f1d7c20
// import MetadataViews from 0x631e88ae7f1d7c20
// import FungibleToken from 0x9a0766d93b6608b7
// import FlowToken from 0x7e60df042a9c0868

// for flow-emulator
import NonFungibleToken from "./NonFungibleToken.cdc"
import MetadataViews from "./utils/MetadataViews.cdc"
import FungibleToken from 0xee82856bf20e2aa6
import FlowToken from 0x0ae53cb6e3f42a79

pub contract Eventr1: NonFungibleToken {

    // -----------------------------------------------------------------------
    // Eventr contract Events
    // -----------------------------------------------------------------------

    // Emitted when the Eventr contract is created
    pub event ContractInitialized()

    // Emitted when a new Pass struct is created
    pub event PassCreated(passID: UInt64, passType: String, dropType: String)
    // Emitted when a new PassCategory struct is created
    pub event PassCategoryCreated(categoryID: UInt64, categoryName: String, price: UFix64)
    // Emitted when a new Event is created
    pub event EventCreated(eventID: UInt64,eventName: String, passID: UInt64)
    // Emitted when a Pass is added to a Event
    pub event PassAddedToEvent(eventID: UInt64, passID: UInt64)
    // Emitted when a PassCategory is added to a Event
    pub event PassCategoryAddedToEvent(eventID: UInt64, categoryID: UInt64)
    // Emitted when a Event is locked, meaning PassCategory cannot be added
    pub event EventLocked(eventID: UInt64)
    // Emitted when a Token is minted from Event
    pub event TokenMinted(tokenId: UInt64, categoryID: UInt64, eventID: UInt64)

    //
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

    pub struct Pass {
        pub let passID: UInt64
        pub let passName: String
        pub let passType: PassType
        pub let dropType: DropType

        init(_passName: String, _passType: PassType, _dropType: DropType) {
            self.passID = Eventr1.nextPassID
            self.passName = _passName
            self.passType = _passType
            self.dropType = _dropType

            emit PassCreated(passID: Eventr1.nextPassID, passType: Eventr1.passTypeToString(_passType), dropType: Eventr1.dropTypeToString(_dropType))
        }
    }

    pub struct PassCategory {
        pub let categoryID: UInt64
        pub let categoryName: String
        pub let eventID: UInt64
        pub let price: UFix64

        // Maximum number of editions that can be minted in this category
        pub let maxEditions: UInt32

        init(_eventID: UInt64, _categoryName: String, _price: UFix64, _maxEditions: UInt32) {
            pre {
                _maxEditions >= 1 : "maxEdition cannot be less than 1"
            }

            self.categoryID = Eventr1.nextCategoryID
            self.categoryName = _categoryName
            self.eventID = _eventID
            self.price = _price
            self.maxEditions = _maxEditions

            emit PassCategoryCreated(categoryID: self.categoryID, categoryName: _categoryName, price: _price)
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

        init(_eventID: UInt64, _name: String, passID: UInt64, _metadata: {String: String}) {

            self.eventID = _eventID
            self.passCategories = []
            self.numberMintedPerPassCategory ={}
            self.locked = false
            
            // Create a new EventData for this Event and store it in contract storage
            Eventr1.eventDatas[self.eventID] = EventData(eventID: _eventID, eventName: _name, passID: passID, metadata: _metadata)

            emit EventCreated(eventID: _eventID, eventName: _name, passID: passID)      
        }

        access(contract) fun addPassCategory(categoryID: UInt64) {
            pre {
                Eventr1.passCategoryData[categoryID] != nil: "Cannot add the PassCategory to Event: Category doesn't exist."
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
 
        access(contract) fun mintToken(categoryID: UInt64): @NFT {
            pre {
                self.numberMintedPerPassCategory[categoryID]! < Eventr1.getPassCategoryMaxLimit(categoryID: categoryID)!:
                    "Pass-Category has reached maximum NFT edition capacity."
            }
            let numInPassCategory = self.numberMintedPerPassCategory[categoryID]!

            let currentTimestamp = getCurrentBlock().timestamp
            let newToken: @NFT <- create NFT(eventID: self.eventID, categoryID: categoryID, timestamp: currentTimestamp)

            self.numberMintedPerPassCategory[categoryID] = numInPassCategory + (1)

            return <-newToken
        }

        access(contract) fun batchMintToken(categoryID: UInt64, quantity: UInt32): @Collection {
            let newCollection <- create Collection()

            var i: UInt32 = 0
            while i < quantity {
                newCollection.deposit(token: <- self.mintToken(categoryID: categoryID))
                i = i + (1)
            }

            return <- newCollection
        }

        pub fun lock() {
            pre {
                self.locked == false: "The Event is already locked"
            }
            
            self.locked = true
            emit EventLocked(eventID: self.eventID)
            
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
                Eventr1.events[eventID] != nil: "The Event with the provided ID does not exist"
            }

            let tempEvent = (&Eventr1.events[eventID] as &Event?)!
            let tempEventData = Eventr1.eventDatas[eventID]!

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
        pub let eventName: String
        pub let passID: UInt64
        pub let passName: String
        pub let passType: String
        pub let categoryID: UInt64
        pub let dateOfToken: UFix64?
        pub let passCategoryName: String
        pub let numTokensInPass: UInt32?

        init(
            eventID: UInt64,
            eventName: String,
            passID: UInt64,
            passName: String,
            passType: String,
            categoryID: UInt64,
            passCategoryName: String,
            numTokensInPass: UInt32?,
            dateOfToken: UFix64?
        ) {
            self.eventID = eventID
            self.eventName = eventName
            self.passID = passID
            self.passName = passName
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
        pub let timestamp: UFix64

        init(_eventID: UInt64, _categoryID: UInt64, _timestamp: UFix64) {
            self.eventID = _eventID
            self.categoryID = _categoryID
            self.timestamp = _timestamp
        }
    }

    pub resource NFT: NonFungibleToken.INFT, MetadataViews.Resolver {

        // Global unique moment ID
        pub let id: UInt64
        
        // Struct of Token metadata
        pub let data: TokenData

        init(eventID: UInt64, categoryID: UInt64, timestamp: UFix64) {
            Eventr1.totalSupply = Eventr1.totalSupply + (1)

            self.id = Eventr1.totalSupply

            self.data = TokenData(_eventID: eventID, _categoryID: categoryID,_timestamp: timestamp)

            emit TokenMinted(tokenId: self.id, categoryID: categoryID, eventID: self.data.eventID)
        }

        destroy() {
            Eventr1.totalSupply = Eventr1.totalSupply - (1)
            emit TokenDestroyed(id: self.id)
        }

        pub fun name(): String {
            let eventName: String = Eventr1.getEventMetaDataByField(eventID: self.data.eventID,field: "eventName") ?? ""
            let categoryName = Eventr1.passCategoryData[self.data.categoryID]?.categoryName ?? ""
            let toknId = self.id
            
            return (eventName
                    .concat(" ")
                    .concat(" ")
                    .concat(categoryName)
                    .concat(" ")
                    .concat(toknId.toString()))
        } 

        access(self) fun buildDescString(): String {
            let eventName: String = Eventr1.getEventName(eventID: self.data.eventID) ?? ""
            let categoryName = Eventr1.passCategoryData[self.data.categoryID]?.categoryName ?? ""
            let endTimeStamp: String = Eventr1.getEventMetaDataByField(eventID: self.data.eventID, field: "endTimeStamp") ?? ""
             let passType: String = Eventr1.getEventMetaDataByField(eventID: self.data.eventID, field: "passType") ?? ""

            return categoryName
                    .concat("This token belongs to event name: ")
                    .concat(eventName)
                    .concat(" Pass Type: ")
                    .concat(passType)
                    .concat(" and is valid for")
                    .concat(endTimeStamp)
        }

        pub fun description(): String {
            let eventDescription: String = Eventr1.getEventMetaDataByField(eventID: self.data.eventID, field: "description") ?? ""
            
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
                    let passId = (Eventr1.getEventData(eventID: self.data.eventID)?.passID)!

                    let categoryID = self.data.categoryID

                    let passData: Eventr1.Pass = Eventr1.getPassData(passID: passId)!
                    let catgoryData: Eventr1.PassCategory = Eventr1.getPassCategoryData(categoryID: categoryID)!

                    return EventrTokenMetadataView(
                        eventID:  self.data.eventID,
                        eventName: Eventr1.getEventMetaDataByField(eventID: self.data.eventID ,field:"eventName")!,
                        passID: passData.passID,
                        passName: passData.passName,
                        passType: Eventr1.getEventMetaDataByField(eventID: self.data.eventID, field: "passType")!,
                        categoryID: categoryID,
                        passCategoryName: catgoryData.categoryName,
                        numTokensInPass: Eventr1.getNumTokensInPassCategory(eventID: self.data.eventID, categoryID: self.id),
                        dateOfToken: self.data.timestamp
                    )
                case Type<MetadataViews.NFTCollectionData>():
                    return MetadataViews.NFTCollectionData(
                        storagePath: Eventr1.CollectionStoragePath,
                        publicPath: Eventr1.CollectionPublicPath,
                        providerPath: /private/EventrCollection,
                        publicCollection: Type<&Eventr1.Collection{Eventr1.CollectionPublic}>(),
                        publicLinkedType: Type<&Eventr1.Collection{Eventr1.CollectionPublic,NonFungibleToken.Receiver,NonFungibleToken.CollectionPublic,MetadataViews.ResolverCollection}>(),
                        providerLinkedType: Type<&Eventr1.Collection{NonFungibleToken.Provider,Eventr1.CollectionPublic,NonFungibleToken.Receiver,NonFungibleToken.CollectionPublic,MetadataViews.ResolverCollection}>(),
                        createEmptyCollectionFunction: (fun (): @NonFungibleToken.Collection {
                            return <-Eventr1.createEmptyCollection()
                        })
                    )
                case Type<MetadataViews.NFTCollectionDisplay>():
                    let bannerImage = MetadataViews.Media(
                        file: MetadataViews.HTTPFile(
                            url: "https://bafkreigxfamybymhovs3lxgirpwwhdiigkjzx4eoy6cvy6ipcoi7qwcdsa.ipfs.nftstorage.link/"
                        ),
                        mediaType: "image/svg+xml"
                    )
                    let squareImage = MetadataViews.Media(
                        file: MetadataViews.HTTPFile(
                            url: "https://bafkreib66eyzq7hxjwvxg5im5k7ozggddju2iebjxe6xexrr6eldv4i73m.ipfs.nftstorage.link/"
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
            let url = "https://bafkreigxfamybymhovs3lxgirpwwhdiigkjzx4eoy6cvy6ipcoi7qwcdsa.ipfs.nftstorage.link/"
            return url
        }
    }

    // NFTMinterPublic resource having implementation for minting and preminting functionalities
    pub resource interface NFTMinterPublic {

        pub fun mintToken(eventID: UInt64, categoryID: UInt64, collection: &AnyResource{CollectionPublic}, ownerFlowTokenVault: Capability<&FlowToken.Vault{FungibleToken.Receiver}>, buyerFlowTokenVault: &FlowToken.Vault)

        pub fun batchMintToken(eventID: UInt64, categoryID: UInt64, quantity: UInt32, collection: &AnyResource{CollectionPublic}, ownerFlowTokenVault: Capability<&FlowToken.Vault{FungibleToken.Receiver}>, buyerFlowTokenVault: &FlowToken.Vault)
    }

    pub resource Admin: NFTMinterPublic {
  
        access(self) fun createPass(_ passName: String,_ passType: PassType, _ dropType: DropType): UInt64 {
            Eventr1.nextPassID = Eventr1.nextPassID + 1
            // Create the new Pass
            var newPass = Pass(_passName: passName, _passType: passType, _dropType: dropType)
            let newID = newPass.passID

            Eventr1.passData[newID] = newPass

            return newID
        }

        pub fun createPassCategory(eventID: UInt64, categoryName: String, price: UFix64, maxLimit: UInt32): UInt64 {
            pre {
                Eventr1.events[eventID] != nil: "Cannot create the Category to Event: Event doesn't exist. You have to create Event first"
                false == Eventr1.isEventLocked(eventID: eventID): "Cannot create the Category to Event: event has been locked."
            }

            let eventRef = self.borrowEvent(eventID: eventID)
            let passId = Eventr1.getEventData(eventID: eventID)?.passID!
            let eventPassType = Eventr1.passTypeToString(Eventr1.passData[passId]?.passType!)
            
            
            Eventr1.nextCategoryID = Eventr1.nextCategoryID + (1)
            // Create the new PassCategory struct
            var newPassCategory = PassCategory( _eventID: eventID,_categoryName: categoryName, _price: price, _maxEditions: maxLimit)
            let newID = newPassCategory.categoryID
            
            Eventr1.passCategoryData[newID] = newPassCategory

            if(eventPassType == Eventr1.passTypeToString(Eventr1.PassType.erc721)) { 
                eventRef.addPassCategory(categoryID: newID)              
                eventRef.lock()
            }
            
            return newID
        }

        pub fun createEvent(eventID: UInt64, name: String, passName: String, passType: PassType, dropType: DropType, metadata: {String: String}): Bool {
            let tempPassId = Eventr1.nextPassID

            // Create new Pass
            var passId = self.createPass(passName, passType, dropType)

            // Create the new Event
            var newEvent <- create Event(_eventID: eventID, _name: name, passID: passId, _metadata: metadata)


            // Store it in the events mapping field
            Eventr1.events[newEvent.eventID] <-! newEvent

            return true
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
                Eventr1.events[eventID] != nil: "Cannot borrow Event: The Event doesn't exist"
            }
            
            // Get a reference to the Set and return it
            // use `&` to indicate the reference to the object and type
            return (&Eventr1.events[eventID] as &Event?)!
        }

        pub fun mintToken(eventID: UInt64, categoryID: UInt64, collection: &AnyResource{CollectionPublic}, ownerFlowTokenVault: Capability<&FlowToken.Vault{FungibleToken.Receiver}>, buyerFlowTokenVault: &FlowToken.Vault) {
            pre{
                Eventr1.events[eventID] != nil : "Cannot find any Event on given eventID"
                Eventr1.passCategoryData[categoryID] != nil : "Cannot find any Category on given categoryID"
                buyerFlowTokenVault.balance >= Eventr1.passCategoryData[categoryID]?.price! : "Not enough tokens to buy the NFT!"
            }

            // Borrow a reference to the specified event
            let eventRef = self.borrowEvent(eventID: eventID)
            let tokenPrice = Eventr1.passCategoryData[categoryID]?.price!
            let payment <- buyerFlowTokenVault.withdraw(amount: tokenPrice) as! @FlowToken.Vault

            // Mint a new NFT
            let newToken <- eventRef.mintToken(categoryID: categoryID)

            // deposit the NFT in the receivers collection
            collection.deposit(token: <-newToken)
            // deposit the payment in the Owner's Vault
            ownerFlowTokenVault.borrow()!.deposit(from: <- payment)
        }

        pub fun batchMintToken(eventID: UInt64, categoryID: UInt64, quantity: UInt32, collection: &AnyResource{CollectionPublic}, ownerFlowTokenVault: Capability<&FlowToken.Vault{FungibleToken.Receiver}>, buyerFlowTokenVault: &FlowToken.Vault) {

            pre {
                Eventr1.events[eventID] != nil : "Cannot find any Event on given eventID"
                Eventr1.passCategoryData[categoryID] != nil : "Cannot find any Category on given categoryID"
                buyerFlowTokenVault.balance >= (UFix64(quantity) * Eventr1.passCategoryData[categoryID]?.price!) : "Not enough tokens to buy the NFT!"
            }

            // Borrow a reference to the specified event
            let eventRef = self.borrowEvent(eventID: eventID)
            let payableAmt = UFix64(quantity) * Eventr1.passCategoryData[categoryID]?.price!
            let payment <- buyerFlowTokenVault.withdraw(amount: payableAmt) as! @FlowToken.Vault

            let newToken <- eventRef.batchMintToken(categoryID: categoryID, quantity: quantity)

            // deposit the NFT in the receivers collection
            collection.batchDeposit(tokens: <- newToken)
            ownerFlowTokenVault.borrow()!.deposit(from: <- payment)
        }
    }

    pub resource interface CollectionPublic {
        pub fun deposit(token: @NonFungibleToken.NFT)
        pub fun batchDeposit(tokens: @NonFungibleToken.Collection)
        pub fun getIDs(): [UInt64]
        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT
        pub fun borrowToken(id: UInt64): &Eventr1.NFT? {
            // If the result isn't nil, the id of the returned reference
            // should be the same as the argument to the function
            post {
                (result == nil) || (result?.id == id): 
                    "Cannot borrow Token reference: The ID of the returned reference is incorrect"
            }
        }
    }

    pub resource Collection: CollectionPublic, NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection { 
        
        pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}

        init() {
            self.ownedNFTs <- {}
        }

        destroy() {
            destroy self.ownedNFTs
        }

        pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {

            // Remove the nft from the Collection
            let token <- self.ownedNFTs.remove(key: withdrawID) 
                ?? panic("Cannot withdraw: Token does not exist in the collection")

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

        // deposit takes a Token and adds it to the Collections dictionary
        //
        // Paramters: token: the NFT to be deposited in the collection
        //
        pub fun deposit(token: @NonFungibleToken.NFT) {
            
            // Cast the deposited token as a Eventr NFT to make sure
            // it is the correct type
            let token <- token as! @Eventr1.NFT

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

        // borrowNFT Returns a borrowed reference to a Token in the Collection
        // so that the caller can read its ID
        //
        // Parameters: id: The ID of the NFT to get the reference for
        //
        // Returns: A reference to the NFT
        //
        // Note: This only allows the caller to read the ID of the NFT,
        // not any Eventr specific data. Please use borrowToken to 
        // read Token data.
        //
        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT {
            return (&self.ownedNFTs[id] as &NonFungibleToken.NFT?)!
        }

        // borrowToken returns a borrowed reference to a Token
        // so that the caller can read data and call methods from it.
        // They can use this to read its eventID, CategoryID,
        // or any of the EventData or Pass data associated with it by
        // getting the eventID or CategoryID and reading those fields from
        // the smart contract.
        //
        // Parameters: id: The ID of the NFT to get the reference for
        //
        // Returns: A reference to the NFT
        pub fun borrowToken(id: UInt64): &Eventr1.NFT? {
            if self.ownedNFTs[id] != nil {
                let ref = (&self.ownedNFTs[id] as auth &NonFungibleToken.NFT?)!
                return ref as! &Eventr1.NFT
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
            let eventrNFT = nft as! &Eventr1.NFT
            return eventrNFT as &AnyResource{MetadataViews.Resolver}
        }
    }

    // -----------------------------------------------------------------------
    // Eventr contract-level function definitions
    // -----------------------------------------------------------------------

    pub fun createEmptyCollection(): @NonFungibleToken.Collection {
        return <-create Eventr1.Collection()
    }

    pub fun createAdmin(): @Eventr1.Admin {
        return <-create Eventr1.Admin()
    }

    // getAllEvents returns all the Event's Data in Eventr
    //
    // Returns: An array of all the EventData that have been created
    pub fun getAllEvents(): [Eventr1.EventData] {
        return Eventr1.eventDatas.values
    }

    // getEventMetaData returns all the metadata associated with a specific Event
    // 
    // Parameters: eventID: The id of the Event that is being searched
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
        if let tempEvent = Eventr1.eventDatas[eventID] {
            let eventMetadata = tempEvent.getMetadata()
            return eventMetadata[field]
        } else {
            return nil
        }
    }

    // getEventData returns the data that the specified Event
    // is associated with.
    // 
    // Parameters: eventID: The id of the Event that is being searched
    //
    // Returns: The QueryEventData struct that has all the important information about the event
    pub fun getEventData(eventID: UInt64): QueryEventData? {
        if Eventr1.events[eventID] == nil {
            return nil
        } else {
            return QueryEventData(eventID: eventID)
        }
    }
    
    pub fun getPassData(passID: UInt64): Eventr1.Pass? {
        if Eventr1.passData[passID] == nil {
            return nil
        } else {
            return Eventr1.passData[passID]
        }
    }

    pub fun getPassCategoryData(categoryID: UInt64): Eventr1.PassCategory? {

        if Eventr1.passCategoryData[categoryID] != nil {
            return Eventr1.passCategoryData[categoryID]
        }

        return nil
    }

    // getEventName returns the name that the specified Event
    // is associated with.
    // 
    // Parameters: eventID: The id of the Event that is being searched
    //
    // Returns: The name of the Event
    pub fun getEventName(eventID: UInt64): String? {
        // Don't force a revert if the eventID is invalid
        return Eventr1.eventDatas[eventID]?.eventName
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
        for event in Eventr1.eventDatas.values {
            if eventName == event.eventName {
                // If the name is found, return the ID
                eventIDs.append(event.eventID)
            }
        }

        // If the name isn't found, return nil
        // Don't force a revert if the eventName is invalid
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
     return Eventr1.passCategoryData[categoryID]?.maxEditions
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
            // If the event wasn't found return nil
            return nil
        }
    }

    // getPassCategoryEventId returns the Event Id the PassCategory belongs to
    // 
    // Parameters: categoryId: The id of the PassCategory that is being searched
    //
    // Returns: The Event Id
    pub fun getPassCategoryEventId(categoryId: UInt64): UInt64? {
        return Eventr1.passCategoryData[categoryId]?.eventID
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
        // Don't force a revert if the eventID is invalid
        return Eventr1.events[eventID]?.passCategories
    }

    // isEventLocked returns a boolean that indicates if a Event
    // is locked. If it's locked, Tokens can no longer be minted to it.
    // 
    // Parameters: eventID: The id of the Event that is being searched
    //
    // Returns: Boolean indicating if the Event is locked or not
    pub fun isEventLocked(eventID: UInt64): Bool {
        if(Eventr1.events[eventID]?.locked == true){
            return  true
        }

        return false
    }


    init() {

        self.CollectionStoragePath = /storage/EventrCollection
        self.CollectionPublicPath = /public/EventrCollection

        self.passData = {}
        self.passCategoryData = {}
        self.eventDatas = {}
        self.events <- {}
        self.nextCategoryID = 0
        self.nextPassID = 0
        self.totalSupply = 0

        emit ContractInitialized()
    }
}
 