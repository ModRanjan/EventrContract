// get_totalSupply.cdc
import Eventr1 from "../contracts/Eventr.cdc"

// This script reads the current number of tokens that have been minted
// from the Eventr contract and returns that number to the caller
// Returns: UInt64
// Number of Tokens minted from Eventr contract
pub fun main(): UInt64 {

    return Eventr1.totalSupply
}