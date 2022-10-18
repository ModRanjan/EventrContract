import FungibleToken from 0x03
import FlowToken from 0x04
import ERC721 from 0x02

    transaction(_recipientAddress:Address,_ipfsHash:String,_name:String,_price:UFix64,_collectionPath:StoragePath){
      prepare(signer: AuthAccount){
        pre {
          _ipfsHash!="undefined" && _name!="undefined" : "Undefined arguments"
        }
        let collection = signer.borrow<&ERC721.Collection>(from: _collectionPath)
                            ?? panic("User collection does not exist here")
        let nftMinter = signer.getCapability(/public/MyMintNFT)
                          .borrow<&ERC721.MintNFT{ERC721.MintNFTPublic}>()
                          ?? panic("Could not borrow the user's NFTMinter")
        let _flowTokenVault = getAccount(_recipientAddress).getCapability<&FlowToken.Vault{FungibleToken.Receiver}>(/public/flowTokenReceiver)
        let payment <- signer.borrow<&FlowToken.Vault>(from: /storage/Vault)!.withdraw(amount: _price) as! @FlowToken.Vault
        nftMinter.mint(_ipfsHash: _ipfsHash, _name: _name, _price: _price,_payment: <-payment, _collection: collection,_flowTokenVault:_flowTokenVault)
      }
      execute{
        log("NFT minted")
      }
    }