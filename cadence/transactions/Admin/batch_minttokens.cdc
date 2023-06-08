// batch_mint_token.cdc
import Eventr1 from "../../contracts/Eventr.cdc"
import FungibleToken from 0xee82856bf20e2aa6
import FlowToken from 0x0ae53cb6e3f42a79

// This transaction mints multiple tokns 
// from a single Category 
// Parameters:
//
// eventID: the ID of the event to be minted from
// categoryID: the ID of the PassCategory from which the Tokens are minted 
// quantity: the quantity of Tokens to be minted
// recipientAddr: the Flow address of the account receiving the collection of minted tokens
transaction(eventID: UInt64, categoryID: UInt64, quantity: UInt32, price: UFix64, ownerAddr: Address, recipientAddr: Address) {

    let eventOwnerCapability: &AnyResource{Eventr1.NFTMinterPublic}

    prepare(signer: AuthAccount) {
    
        let adminPublicPath = PublicPath(identifier: "EventrAdminEventId".concat(eventID.toString()))
            ?? panic("does not specify a public path")

        let senderFlowTokenVault = signer.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault)
        ?? panic("Could not borrow Provider reference to the Vault")
        
        let eventOwnerAccount = getAccount(ownerAddr)
        
        // borrow a reference to the Admin resource in storage
        self.eventOwnerCapability =  eventOwnerAccount.getCapability(adminPublicPath).borrow<&{Eventr1.NFTMinterPublic}>()
            ?? panic("Cannot borrow a reference to the Admin's <MintNFTPublic> resource")
        
        let flowTokenVaultReceiverCapability: Capability<&FlowToken.Vault{FungibleToken.Receiver}> = eventOwnerAccount.getCapability<&FlowToken.Vault{FungibleToken.Receiver}>(/public/flowTokenReceiver)

        // get the Collection reference for the receiving eventr
        let collectionRef = signer.getCapability(Eventr1.CollectionPublicPath).borrow<&{Eventr1.CollectionPublic}>()
            ?? panic("Cannot borrow a reference to the Eventr Collection from recipient")
        
        self.eventOwnerCapability.batchMintToken(eventID: eventID, categoryID: categoryID, quantity: quantity,  collection: collectionRef, ownerFlowTokenVault: flowTokenVaultReceiverCapability, buyerFlowTokenVault: senderFlowTokenVault)
       
    }
}