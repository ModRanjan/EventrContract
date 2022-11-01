// NFT standard contract for flow blockchain
import NonFungibleToken from 0xc2bf854ac7c824f6
// ERC20 type standard contract for flow blockchain
import FungibleToken from 0x9a0766d93b6608b7
// implementation of FungibleToken standards
import FlowToken from 0x7e60df042a9c0868

// implementation of NFT smart contract according to our requirements
pub contract Eventr:NonFungibleToken {
    // The total number of tokens of this type in existence
    pub var totalSupply: UInt64
    
    // Event that emitted when the NFT contract is initialized
    pub event ContractInitialized()

    /**
    @dev event Withdraw
    @param id {UInt64} id of token which is withdrawn
    @param from {Address} address of account from which token is removed
    */
    pub event Withdraw(id: UInt64, from: Address?)

    /**
    @dev event Deposit
    @param id {UInt64} id of token which is deposited
    @param to {Address} address of account in which token is deposited
    */
    pub event Deposit(id: UInt64, to: Address?)
    
    // NFT resource which implements NFT standard interface
    pub resource NFT:NonFungibleToken.INFT{
      pub let id:UInt64
      pub let price:UFix64
      pub let ipfsHash:String
      pub var metadata:{String:String}
      init(_ipfsHash:String,_metadata:{String:String},_price:UFix64){
        self.id=Eventr.totalSupply
        Eventr.totalSupply=Eventr.totalSupply+1
        self.ipfsHash=_ipfsHash
        self.metadata=_metadata
        self.price=_price
      }
    }


    pub resource interface CollectionPublic 
    {
      pub fun borrowEntireNFT(id: UInt64): &Eventr.NFT
    }

    // Collection resource which can be termd as event in our project
    pub resource Collection:NonFungibleToken.Receiver,NonFungibleToken.Provider,NonFungibleToken.CollectionPublic,CollectionPublic{
      // mapping that maps NFT resources to their ids for particular collection
      pub var ownedNFTs:@{UInt64:NonFungibleToken.NFT}
      
      /**
      @dev function deposit
      @param token {@NonFungibleToken.NFT} NFT resource that should be deposited
      */
      pub fun deposit(token: @NonFungibleToken.NFT) {
        let myToken <- token as! @Eventr.NFT
        emit Deposit(id: myToken.id, to: self.owner?.address)
        self.ownedNFTs[myToken.id] <-! myToken

      }

      /**
      @dev function withdraw
      @param withdrawID {UInt64} id of the token which should be removed
      @returns token {@NonFungibleToken.NFT} that should be withdrawn
      */
      pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
        let token <- self.ownedNFTs.remove(key: withdrawID) ?? panic("This NFT does not exist")
        emit Withdraw(id: token.id, from: self.owner?.address)
        return <- token
      }

      /**
      @dev function getIDs
      @returns array {UInt64} containing ids of all resources in this collection
      */
      pub fun getIDs(): [UInt64] {
        return self.ownedNFTs.keys
      }

      /**
      @dev function borrowNFT
      @param id {UInt64} id of the NFT resource to be borrowed
      @returns reference {&NonFungibleToken.NFT} to the NFT resource 
      */
      pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT {
        return (&self.ownedNFTs[id] as &NonFungibleToken.NFT?)!
      }

      /**
      @dev function borrowEntireNFT
      @param id {UInt64} id of the NFT resource to be borrowed
      @returns reference {&NonFungibleToken.NFT} to the NFT resource 
      */
      pub fun borrowEntireNFT(id: UInt64): &Eventr.NFT {
        let reference = (&self.ownedNFTs[id] as auth &NonFungibleToken.NFT?)!
        return reference as! &Eventr.NFT
      }
      
      init(){
        self.ownedNFTs<- {}
      }
      destroy (){
        destroy self.ownedNFTs
      }

    }

    /**
    @dev function createEmptyCollection
    @returns {@Collection} newly created Collection resource
    */
    pub fun createEmptyCollection(): @Collection {
          return <- create Collection()
     }

    /**
    @dev function createToken
    @param ipfsHash {String}
    @param metadata {String:String} any type of metadata to be associated with NFT
    @param price {UFix64}
    @returns {@Eventr.NFT} newly created NFT resource
    */
    pub fun createToken(ipfsHash:String,metadata:{String:String},price:UFix64):@Eventr.NFT{
      return <- create NFT(_ipfsHash:ipfsHash,_metadata:metadata,_price:price)
    }

    pub resource interface MintNFTPublic {
    pub fun mint(_ipfsHash:String,_name:String,_price:UFix64,_payment:@FlowToken.Vault,_collection: &Eventr.Collection,_flowTokenVault:Capability<&FlowToken.Vault{FungibleToken.Receiver}>)
    pub fun premint(_ipfsHash:String,_name:String,_collection: &Eventr.Collection)
  }

  // Minting resource having implementation for minting and preminting functionalities
  pub resource MintNFT: MintNFTPublic {

    /**
    @dev function premint
    @param _ipfsHash {String}
    @param _name {String}
    @param _collection {&Eventr.Collection} collection reference in which NFT would be stored
    */
    pub fun premint(_ipfsHash:String,_name:String,_collection: &Eventr.Collection){
      let nft<-Eventr.createToken(ipfsHash: _ipfsHash, metadata: {"name":_name}, price:0.0)
      _collection.deposit(token: <-nft)
    }

    /**
    @dev function mint
    @param _ipfsHash {String}
    @param _name {String}
    @param _price {UFix64}
    @param _payment {@FlowToken.Vault} Vault from which flow tokens would be withdrawn
    @param _collection {&Eventr.Collection} collection reference in which NFT would be stored
    @param _flowTokenVault {Capability<&FlowToken.Vault{FungibleToken.Receiver}>} capability to use deposit method of FlowToken
    */
    pub fun mint(_ipfsHash:String,_name:String,_price:UFix64,_payment:@FlowToken.Vault,_collection: &Eventr.Collection,_flowTokenVault:Capability<&FlowToken.Vault{FungibleToken.Receiver}>){
      pre{
        _price == _payment.balance : "NFT price and vault balance should be same"
      }
      let nft<-Eventr.createToken(ipfsHash: _ipfsHash, metadata: {"name":_name}, price:_price)
      
      _flowTokenVault.borrow()!.deposit(from: <- _payment)
      _collection.deposit(token: <-nft)
    } 
  }

  /**
  @dev function createNFTMinter
  @returns newly created NFTMinter resource
  */
  pub fun createNFTMinter(): @MintNFT {
    return <- create MintNFT()
  }
    init()
    {
      self.totalSupply=0;
    }
}
 