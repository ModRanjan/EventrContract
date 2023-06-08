chmod +X fileName.sh

## Deploy Contracts

```bash
flow accounts update-contract \_name> <filename> [<argument> <argument>...] [flags]
```

> Example: flow accounts update-contract ./cadence/contracts/Eventr.cdc --network=testnet --signer="testnet-account"

---

## Update Existing Contract

```bash
flow accounts update-contract \_name> <filename> [<argument> <argument>...] [flags]
```

> Example: flow accounts update-contract ./cadence/contracts/Eventr.cdc --network=testnet --signer="testnet-account"

---

## Run Transation (Emulator):

- tgh passing argument in bash
  ```bash
  > flow transactions send <code filename> [<argument> <argument>...] [flags]
  ```
- tgh passing argument in json file

  ```bash
  > flow transactions send <file-path> --args-json "$(cat <args.json>)"

  ```

### to create Event:

```bash
> flow transactions send ./transactions/Eventr/Admin/create_event.cdc --args-json "$(cat create_event.json)" --signer ""
```

- ### Run Script:

```bash
> flow scripts execute <filename> [<argument> <argument>...] [flags]
```

1. get_collection_ids.cdc
   > flow scripts execute ./cadence/scripts/collection/get_collection_ids.cdc "0xeb179c27144f783c"
2. check balance
   > flow scripts execute ./cadence/scripts/check_balance.cdc "0xeb179c27144f783c"
   > flow scripts execute ./cadence/scripts/check_balance.cdc "0xf8d6e0586b0a20c7"
3. Get an Account with the Flow CLI
   > flow accounts get 0xf8d6e0586b0a20c7

# Eventr

## Introduction

This repository contains the smart contracts and transactions that implement the core functionality of Eventr.

The smart contracts are written in Cadence, a new resource oriented smart contract programming language designed for the Flow Blockchain.

### What is Eventr

...

### What is Flow?

Flow is a new blockchain for open worlds. Read more about it [here](https://www.onflow.org/).

## Eventr Contract Addresses

`Eventr.cdc`: This is the main Eventr smart contract that defines the core functionality of the NFT.

| Network  | Contract Address     |
| -------- | -------------------- |
| Testnet  | `0x877931736ee77cff` |
| Emulator | `0xf8d6e0586b0a20c7` |

### Non Fungible Token Standard

The Eventr contracts utilize the [Flow NFT standard](https://github.com/onflow/flow-nft)
which is equivalent to ERC-721 or ERC-1155 on Ethereum.

## Eventr Contract Overview

Each Eventr NFT represents a PassCategory from a pass in the Event.

PassCategories are grouped into events which usually have some overarching theme, like price, maxLimit or the type of the pass.

A Event can have only one Pass in it and one or more PassCategories in it {depending upon the pasType}.

Multiple Tokens can be minted from the one Event and each receives a tokenID that indicates where in the events it was minted.

Each Token is a resource object with roughly the following structure:

```cadence
pub resource Moment {

    // global unique Moment ID
    pub let id: UInt64

    // the ID of the Set that the Moment comes from
    pub let setID: UInt32

    // the ID of the Play that the Moment references
    pub let playID: UInt32

    // the place in the edition that this Moment was minted
    // Otherwise known as the serial number
    pub let serialNumber: UInt32
}
```

The other types that are defined in `Eventr` are as follows:

- `Play`: A struct type that holds most of the metadata for the Moments.
  All plays in Top Shot will be stored and modified in the main contract.
- `SetData`: A struct that contains constant information about sets in Top Shot
  like the name, the series, the id, and such.
- `Set`: A resource that contains variable data for sets
  and the functionality to modify sets,
  like adding and retiring plays, locking the set, and minting Moments from
  the set.
- `MomentData`: A struct that contains the metadata associated with a Moment.
  instances of it will be stored in each Moment.
- `NFT`: A resource type that is the NFT that represents the Moment
  highlight a user owns. It stores its unique ID and other metadata. This
  is the collectible object that the users store in their accounts.
- `Collection`: Similar to the `NFTCollection` resource from the NFT
  example, this resource is a repository for a user's Moments. Users can
  withdraw and deposit from this collection and get information about the
  contained Moments.
- `Admin`: This is a resource type that can be used by admins to perform
  various actions in the smart contract like starting a new series,
  creating a new play or set, and getting a reference to an existing set.
- `QuerySetData`: A struct that contains the metadata associated with a set.
  This is currently the only way to access the metadata of a set.
  Can be accessed by calling the public function in the `TopShot` smart contract called `getSetData(setID)`

Metadata structs associated with plays and sets are stored in the main smart contract
and can be queried by anyone. For example, If a player wanted to find out the
name of the team that the player represented in their Moment plays for, they
would call a public function in the `TopShot` smart contract
called `getPlayMetaDataByField`, providing, from their owned Moment,
the play and field that they want to query.
They can do the same with information about sets by calling `getSetData` with the setID.

The power to create new plays, sets, and Moments rests
with the owner of the `Admin` resource.

Admins create plays and sets which are stored in the main smart contract,
Admins can add plays to sets to create editions, which Moments can be minted from.

Admins also can restrict the abilities of sets and editions to be further expanded.
A set begins as being unlocked, which means plays can be added to it,
but when an admin locks the set, plays can no longer be added to it.
This cannot be reversed.

The same applies to editions. Editions start out open, and an admin can mint as
many Moments they want from the edition. When an admin retires the edition,
Moments can no longer be minted from that edition. This cannot be reversed.

These rules are in place to ensure the scarcity of sets and editions
once they are closed.

Once a user owns a Moment object, that Moment is stored directly
in their account storage via their `Collection` object. The collection object
contains a dictionary that stores the Moments and gives utility functions
to move them in and out and to read data about the collection and its Moments.

As you can see, whenever we want to call a function, read a field, or use a type that is defined in a smart contract, we simply import that contract from the address it is defined in and then use the imported
contract to access those type definitions and fields.

After the contracts have been deployed, you can run the sample transactions
to interact with the contracts. The sample transactions are meant to be used
in an automated context, so they use transaction arguments and string template
fields. These make it easier for a program to use and interact with them.
If you are running these transactions manually in the Flow Playground or
vscode extension, you will need to remove the transaction arguments and
hard code the values that they are used for.

You also need to replace the `ADDRESS` placeholders with the actual Flow
addresses that you want to import from.

## How to Run Transactions Against the Top Shot Contract

This repository contains sample transactions that can be executed against the Top Shot contract either via Flow CLI or using VSCode. This section will describe how to create a new Top Shot set on the Flow emulator.

## Instructions for creating passCategory and minting Tokens

A common order of creating new Tokens would be

1. Creating new plays with `transactions/admin/create_play.cdc`.
2. Creating new sets with `transactions/admin/create_set.cdc`.
3. Adding plays to the sets to create editions
   with `transactions/admin/add_plays_to_set.cdc`.
4. Minting Moments from those editions with
   `transactions/admin/batch_mint_moment.cdc`.

## Eventr Events

The smart contract and its various resources will emit certain events that show when specific actions are taken, like transferring an NFT. This
is a list of events that can be emitted, and what each event means.

- `pub event ContractInitialized()`
  This event is emitted when the `Eventr` contract is created.

#### Events for plays

- `pub event PlayCreated(id: UInt32, metadata: {String:String})`

  Emitted when a new play has been created and added to the smart contract by an admin.

#### Events for set-Related actions

- `pub event SetCreated(setID: UInt32, series: UInt32)`
  Emitted when a new set is created.
- `pub event PlayAddedToSet(setID: UInt32, playID: UInt32)`
  Emitted when a new play is added to a set.
- `pub event PlayRetiredFromSet(setID: UInt32, playID: UInt32, numMoments: UInt32)`

  Emitted when a play is retired from a set. Indicates that
  that play/set combination and cannot be used to mint moments any more.

- `pub event SetLocked(setID: UInt32)`

  Emitted when a set is locked, meaning plays cannot be added.

- `pub event MomentMinted(momentID: UInt64, playID: UInt32, setID: UInt32, serialNumber: UInt32)`

  Emitted when a Moment is minted from a set. The `momentID` is the global unique identifier that differentiates a Moment from all other Top Shot Moments in existence. The `serialNumber` is the identifier that differentiates the Moment within an Edition. It corresponds to the place in that edition where it was minted.

#### Events for Collection-related actions

- `pub event Withdraw(id: UInt64, from: Address?)`

  Emitted when a Token is withdrawn from a collection. `id` refers to the global Token ID. If the collection was in an account's storage when it was withdrawn, `from` will show the address of the account that it was withdrawn from. If the collection was not in storage when the Token was withdrawn, `from` will be `nil`.

- `pub event Deposit(id: UInt64, to: Address?)`

  Emitted when a Token is deposited into a collection. `id` refers to the global Token ID. If the collection was in an account's storage when it was deposited, `to` will show the address of the account that it was deposited to. If the collection was not in storage when the Token was deposited, `to` will be `nil`.

### Eventr Metadata

- `metadata` :{String: String}

  - `description`: String
  - `startTimeStamp`: UFix64
  - `endTimeStamp`: UFix64
  - `url`: String

NFT metadata is represented in a flexible and modular way using the [standard proposed in FLIP-0636](https://github.com/onflow/flow/blob/master/flips/20210916-nft-metadata.md). The Top Shot contract implements the [`MetadataViews.Resolver`](https://github.com/onflow/flow-nft/blob/master/contracts/MetadataViews.cdc#L21) interface, which standardizes the display of Top Shot NFT in accordance with FLIP-0636. The Top Shot contract also defines a custom view of moment play data called TopShotMomentMetadataView.

## NBA Top Shot Marketplace

The `contracts/MarketTopShot.cdc` contract allows users to create a sale object
in their account to sell their Moments.

When a user wants to sell their Moment, they create a sale collection
in their account and specify a beneficiary of a cut of the sale if they wish.

A Top Shot Sale Collection contains a capability to the owner's moment collection
that allows the sale to withdraw the moment when it is purchased.

When another user wants to buy the Moment that is for sale, they simply send
their fungible tokens to the `purchase` function
and if they sent the correct amount, they get the Moment back.

#### Events for Market-related actions

- `pub event MomentListed(id: UInt64, price: UFix64, seller: Address?)`

  Emitted when a user lists a Moment for sale in their SaleCollection.

- `pub event MomentPriceChanged(id: UInt64, newPrice: UFix64, seller: Address?)`

  Emitted when a user changes the price of their Moment.

- `pub event MomentPurchased(id: UInt64, price: UFix64, seller: Address?)`

  Emitted when a user purchases a Moment that is for sale.

- `pub event MomentWithdrawn(id: UInt64, owner: Address?)`

  Emitted when a seller withdraws their Moment from their SaleCollection.

- `pub event CutPercentageChanged(newPercent: UFix64, seller: Address?)`

  Emitted when a seller changes the percentage cut that is taken
  from their sales and sent to a beneficiary.

### Available functions

#### lockNFT

`pub fun lockNFT(nft: @NonFungibleToken.NFT, expiryTimestamp: UFix64): @NonFungibleToken.NFT`  
Takes a TopShot.NFT resource and sets it in the lockedNFTs dictionary, the value of the entry is the expiry timestamp  
Params:  
`nft` - a `NonFungibleToken.NFT` resource, but must conform to `TopShot.NFT` asserted at runtime  
`expiryTimestamp` - the unix timestamp in seconds at which this nft can be unlocked

Example:

```cadence
let collectionRef = acct.borrow<&TopShot.Collection>(from: /storage/MomentCollection)
            ?? panic("Could not borrow from MomentCollection in storage")

let ONE_YEAR_IN_SECONDS: UFix64 = UFix64(31536000)
collectionRef.lock(id: 1, duration: ONE_YEAR_IN_SECONDS)
```

#### unlockNFT

`pub fun unlockNFT(nft: @NonFungibleToken.NFT): @NonFungibleToken.NFT`  
Takes a `NonFungibleToken.NFT` resource and attempts to remove it from the lockedNFTs dictionary.
This function will panic if the nft lock has not expired or been overridden by an admin.
Params:  
`nft` - a `NonFungibleToken.NFT` resource

Example:

```cadence
let collectionRef = acct.borrow<&TopShot.Collection>(from: /storage/MomentCollection)
            ?? panic("Could not borrow from MomentCollection in storage")

collectionRef.unlock(id: 1)
```

#### isLocked

`pub fun isLocked(nftRef: &NonFungibleToken.NFT): Bool`  
Returns true if the moment is locked

#### getLockExpiry

`pub fun getLockExpiry(nftRef: &NonFungibleToken.NFT): UFix64`  
Returns the unix timestamp when the nft is eligible for unlock

### Admin Functions

#### markNFTUnlockable

`pub fun markNFTUnlockable(nftRef: &NonFungibleToken.NFT)`  
Places the nft id in an unlockableNFTs dictionary. This dictionary is checked in the `unlockNFT` function and bypasses the `expiryTimestamp`
Params:  
`nftRef` - a reference to an `NonFungibleToken.NFT` resource

Example:

```cadence
let adminRef: &NFTLocking.Admin

prepare(acct: AuthAccount) {
    // Set TopShotLocking admin ref
    self.adminRef = acct.borrow<&NFTLocking.Admin>(from: /storage/TopShotLockingAdmin)!
}

execute {
    // Set Top Shot NFT Owner collection ref
    let owner = getAccount(0x179b6b1cb6755e31)
    let collectionRef = owner.getCapability(/public/MomentCollection).borrow<&{TopShot.MomentCollectionPublic}>()
        ?? panic("Could not reference owner's moment collection")

    let nftRef = collectionRef.borrowNFT(id: 1)
    self.adminRef.markNFTUnlockable(nftRef: nftRef)
}
```

# General View

## Event

- eventId
- name
- description
- thumbnail
- startTimeStamp
- endTimeStamp

## Pass (ERC721/ERC1155)

- passId
- passType (ERC721 / ERC1155)
- maxLimit

      ERC721
          has no maxLimit

      ERC1155
          has maxLimit

## PassCastegory / NFT

- name
- price
- metadata
  - eventId
  - eventName
  - url
  - passType
  -

---

## we have 3 functionality

### mint:

- event creator/owner has the right to lock/stop minting
- end-user has right to mint (on-demand minting)
- NFT has some price user have to pay while purchase

### pre-mint:

- NFTs are already minted by Event Creator/Owner
- user can purchase them (transfer of nft happens from: eventOwner to: user)
- NFT has some price user have to pay while purchase

### claim:

---

# Contract Overview

## Collection: refrence

_Collection_ is a `resource` for storing the NFTs in user's account

```cadence

pub resource Collection: SetAndSeriesCollectionPublic, NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic {}

```

### fields

- `ownedNFTs`: @{UInt64: NonFungibleToken.NFT}
  dictionary of NFT conforming tokens NFT is a resource type with an UInt64 ID field

### functions

- `withdraw(withdrawID: UInt64): @NonFungibleToken.NFT`

  _withdraw_ Removes an NFT from the collection and moves it to the caller

- `batchWithdraw(ids: [UInt64]): @NonFungibleToken.Collection`

  _batchWithdraw_ withdraws multiple NFTs and returns them as a Collection

  - Parameters: ids: An array of IDs to withdraw
  - Returns: @NonFungibleToken.Collection: The collection of withdrawn tokens

- `deposit(token: @NonFungibleToken.NFT)`

  _deposit_ takes a NFT and adds it to the collections dictionary and adds the ID to the id array

- `batchDeposit(tokens: @NonFungibleToken.Collection)`

  _batchDeposit_ takes a Collection object as an argument and deposits each contained NFT into this Collection

- `getIDs(): [UInt64]`

  _getIDs_ Returns an array of the IDs that are in the collection

- `borrowNFT(id: UInt64): &NonFungibleToken.NFT`

  _borrowNFT_ Returns a borrowed reference to a Moment in the Collection so that the caller can read its ID

  - Parameters: id: The ID of the NFT to get the reference for
  - Returns: A reference to the NFT (&NonFungibleToken.NFT)

  > Note: This only allows the caller to read the ID of the NFT, not any Event specific data. Please use borrowMoment to read Moment data.

- `borrowMoment(id: UInt64): &Eventr.NFT?`

  _borrowMoment_ returns a borrowed reference to a Moment so that the caller can read data and call methods from it. They can use this to read its setID, playID, serialNumber, or any of the setData or Play data associated with it by getting the setID or playID and reading those fields from the smart contract.

  - Parameters: id: The ID of the NFT to get the reference for
  - Returns: A reference to the NFT

- `borrowViewResolver(id: UInt64): &AnyResource{MetadataViews.Resolver}`

- `destroy()`  
  If a transaction destroys the Collection object, All the NFTs contained within are also destroyed!.

## Event: struct

- `eventID`: UInt32
- `eventName`: String
- `metadata` :{String: String}

  - `description`: String
  - `startTimeStamp`: UFix64
  - `endTimeStamp`: UFix64
  - `url`: String

- functions
  - getMetadata(): {String: String}

## Pass

- fields
  - `passID`: UInt32
  - `passType`: PassType
  - `dropType`: DropType

## PassCategory

- field
  - `categoryID`: UInt64
  - `passID`: UInt32
  - `price`: UFix64
  - `maxEditions`: UInt32

## Series / Set: refrence

- fields
  - `eventID`: UInt32
  - `passes`: [UInt32]
  - `locked`: Bool
  - `numberMintedPerPass`: {UInt32: UInt32}
- functions
  - addPass(passID: UInt32)
  - lock()
  - mintToken(passID: UInt32): @NFT
  - batchMintToken(passID: UInt32, quantity: UInt64): @Collection
  - getPasses(): [UInt32]
  - getNumMintedPerPass(): {UInt32: UInt32}

---

## contract-level functions

### createEmptyCollection(): @NonFungibleToken.Collection

- creates a new, empty Collection object so that a user can store it in their account storage.
- Once they have a Collection in their storage, they are able to receive NFTs in transactions.

### getAllTokens(): [Eventr.Pass]

- getAllPlays is for getting all the passes in Eventr
- Returns: An array of all the passes that have been created

### getEventMetaDataByField(passID: UInt32, field: String): String?

_getEventMetaDataByField_ returns the metadata associated with a specific field of the metadata

- Parameters: playID: The id of the Play that is being searched field: The field to search for
- Returns: The metadata field as a String Optional

### getSetData(eventID: UInt32): QuerySetData? {

- Description: getSetData returns the data that the specified Set is associated with.
- Parameters: setID: The id of the Set that is being searched
- Returns: The QuerySetData struct that has all the important information about the set

### getEventName(eventID: UInt32): String?

- Description: getEventName returns the name that the specified Set/Event is associated with.
- Parameters: eventID: The id of the Set/Event that is being searched
- Returns: The name of the Set

### getEventIDsByName(eventName: String): [UInt32]?

- Description: getEventIDsByName returns the IDs that the specified Set/Event name is associated with.
- Parameters: eventName: The name of the Set/Event that is being searched
- Returns: An array of the IDs of the Set if it exists, or nil if doesn't

### getCategoriesInPass(setID: UInt32): [UInt32]?

- Description: getPlaysInSet returns the list of categories IDs that are in the Set/Event
- Parameters: `setID`: The id of the Set that is being searched
- Returns: An array of Play IDs

### pub fun isEventLocked(setID: UInt32): Bool?

- Description:

  - It returns a boolean that indicates if a Event/Set
    is locked. If it's locked, new Categories can no longer be added to it, but Moments can still be minted.

- Parameters: `eventID`: The id of the Set/Event that is being searched
- Returns: Boolean indicating if the Set/Event is locked or not
