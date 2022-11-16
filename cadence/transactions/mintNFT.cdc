import FungibleToken from 0x9a0766d93b6608b7
import FlowToken from 0x7e60df042a9c0868
import Eventr from 0xc2bf854ac7c824f6

    transaction(_recipientAddress:Address,_ipfsHash:String,_name:String,_price:UFix64,_collectionPath:StoragePath){
      prepare(signer: AuthAccount){
        pre {
          _ipfsHash!="undefined" && _name!="undefined" : "Undefined arguments"
        }
        let collection = signer.borrow<&Eventr.Collection>(from: _collectionPath)
                            ?? panic("User collection does not exist here")
        let nftMinter = signer.getCapability(/public/MyMintNFT)
                          .borrow<&Eventr.MintNFT{Eventr.MintNFTPublic}>()
                          ?? panic("Could not borrow the user's NFTMinter")
        let _flowTokenVault = getAccount(_recipientAddress).getCapability<&FlowToken.Vault{FungibleToken.Receiver}>(/public/flowTokenReceiver)
        let payment <- signer.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault)!.withdraw(amount: _price) as! @FlowToken.Vault
        nftMinter.mint(_ipfsHash: _ipfsHash, _name: _name, _price: _price,_payment: <-payment, _collection: collection,_flowTokenVault:_flowTokenVault)
      }
      execute{
        log("NFT minted")
      }
    }