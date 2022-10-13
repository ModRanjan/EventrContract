import NonFungibleToken from 0x01
import ERC721 from 0x02
import FungibleToken from 0x03
import FlowToken from 0x04

pub contract NFTMinter {


  pub resource interface MintNFTPublic {
    pub fun mint(_ipfsHash:String,_name:String,_price:UFix64,_payment:@FlowToken.Vault,_collection: &ERC721.Collection,_flowTokenVault:Capability<&FlowToken.Vault{FungibleToken.Receiver}>)
    pub fun premint(_ipfsHash:String,_name:String,_collection: &ERC721.Collection)
  }

  pub resource MintNFT: MintNFTPublic {
    pub fun premint(_ipfsHash:String,_name:String,_collection: &ERC721.Collection){
      let nft<-ERC721.createToken(ipfsHash: _ipfsHash, metadata: {"name":_name}, price:0.0)
      _collection.deposit(token: <-nft)
    }
    pub fun mint(_ipfsHash:String,_name:String,_price:UFix64,_payment:@FlowToken.Vault,_collection: &ERC721.Collection,_flowTokenVault:Capability<&FlowToken.Vault{FungibleToken.Receiver}>){
      pre{
        _price == _payment.balance : "NFT price and vault balance should be same"
      }
      let nft<-ERC721.createToken(ipfsHash: _ipfsHash, metadata: {"name":_name}, price:_price)
      _flowTokenVault.borrow()!.deposit(from: <- _payment)
      _collection.deposit(token: <-nft)
    } 
  }

  pub fun createNFTMinter(): @MintNFT {
    return <- create MintNFT()
  }
}