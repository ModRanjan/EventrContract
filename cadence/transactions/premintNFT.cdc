import FungibleToken from 0x03
import FlowToken from 0x04
import ERC721 from 0x02

transaction(_ipfsHash:String,_name:String,_collectionPath:StoragePath){
    prepare(signer: AuthAccount){
        pre {
        _ipfsHash!="undefined" && _name!="undefined" : "Undefined arguments"
        }
        let collection = signer.borrow<&ERC721.Collection>(from: _collectionPath)
                            ?? panic("User collection does not exist here")
        let nftMinter = signer.getCapability(/public/MyMintNFT)
                        .borrow<&ERC721.MintNFT{ERC721.MintNFTPublic}>()
                        ?? panic("Could not borrow the user's NFTMinter")

        nftMinter.premint(_ipfsHash: _ipfsHash, _name: _name,_collection: collection)
    }
    execute{
        log("NFT minted")
    }
}