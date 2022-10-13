import NonFungibleToken from 0x01

pub contract ERC721:NonFungibleToken {
    pub var totalSupply: UInt64
    
    pub event ContractInitialized()
    pub event Withdraw(id: UInt64, from: Address?)
    pub event Deposit(id: UInt64, to: Address?)
    
    pub resource NFT:NonFungibleToken.INFT{
      pub let id:UInt64
      pub let price:UFix64
      pub let ipfsHash:String
      pub var metadata:{String:String}
      init(_ipfsHash:String,_metadata:{String:String},_price:UFix64){
        self.id=ERC721.totalSupply
        ERC721.totalSupply=ERC721.totalSupply+1
        self.ipfsHash=_ipfsHash
        self.metadata=_metadata
        self.price=_price
      }
    }

    pub resource interface CollectionPublic 
    {
      pub fun borrowEntireNFT(id: UInt64): &ERC721.NFT
    }

    pub resource Collection:NonFungibleToken.Receiver,NonFungibleToken.Provider,NonFungibleToken.CollectionPublic,CollectionPublic{
      pub var ownedNFTs:@{UInt64:NonFungibleToken.NFT}
      

      pub fun deposit(token: @NonFungibleToken.NFT) {
        let myToken <- token as! @ERC721.NFT
        emit Deposit(id: myToken.id, to: self.owner?.address)
        self.ownedNFTs[myToken.id] <-! myToken
      }

      pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
        let token <- self.ownedNFTs.remove(key: withdrawID) ?? panic("This NFT does not exist")
        emit Withdraw(id: token.id, from: self.owner?.address)
        return <- token
      }

      pub fun getIDs(): [UInt64] {
        return self.ownedNFTs.keys
      }

      pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT {
        return (&self.ownedNFTs[id] as &NonFungibleToken.NFT?)!
      }

      pub fun borrowEntireNFT(id: UInt64): &ERC721.NFT {
        let reference = (&self.ownedNFTs[id] as auth &NonFungibleToken.NFT?)!
        return reference as! &ERC721.NFT
      }
      
      init(){
        self.ownedNFTs<- {}
      }
      destroy (){
        destroy self.ownedNFTs
      }

    }

    pub fun createEmptyCollection(): @Collection {
          return <- create Collection()
     }

    pub fun createToken(ipfsHash:String,metadata:{String:String},price:UFix64):@ERC721.NFT{
      return <- create NFT(_ipfsHash:ipfsHash,_metadata:metadata,_price:price)
    }

    init()
    {
      self.totalSupply=0;
    }
}
