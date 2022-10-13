import FungibleToken from 0x03
import FlowToken from 0x04
import NFTMinter from 0x05
import ERC721 from 0x02

    transaction(_recipientAddress:Address,_ipfsHash:String,_name:String,_price:UFix64){
      prepare(signer: AuthAccount){
        pre {
          _ipfsHash!="undefined" && _name!="undefined" : "Undefined arguments"
        }
        let collection = signer.borrow<&ERC721.Collection>(from: /storage/MyNFTCollection)
                            ?? panic("User collection does not exist here")
        let nftMinter = signer.getCapability(/public/MyMintNFT)
                          .borrow<&NFTMinter.MintNFT{NFTMinter.MintNFTPublic}>()
                          ?? panic("Could not borrow the user's NFTMinter")
        let _flowTokenVault = getAccount(_recipientAddress).getCapability<&FlowToken.Vault{FungibleToken.Receiver}>(/public/flowTokenReceiver)
        let payment <- signer.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault)!.withdraw(amount: _price) as! @FlowToken.Vault
        nftMinter.mint(_ipfsHash: _ipfsHash, _name: _name, _price: _price,_payment: <-payment, _collection: collection,_flowTokenVault:_flowTokenVault)
      }
      execute{
        log("NFT minted")
      }
    }