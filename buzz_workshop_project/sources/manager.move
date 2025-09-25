module workshop_project::manager;

use sui::transfer;
use sui::tx_context::{Self, TxContext};

// The BankManagerCap struct represents a capability for managing the bank.
// It is a key object that allows privileged operations.
public struct BankManagerCap has key, store {
    // Unique identifier for the capability object.
    id: UID,
}

// This is a special function that is executed only once when the module is published.
// It creates a single BankManagerCap and transfers it to the account that published the module.
fun init(ctx: &mut TxContext) {
    // Create a new BankManagerCap and transfer it to the publisher's address.
    transfer::public_transfer(
        BankManagerCap {
            id: object::new(ctx),
        },
        tx_context::sender(ctx),
    )
}

// Creates a new BankManagerCap and transfers it to the specified address.
// This function is now removed because we want to create only one manager cap.
/*
    public fun create_and_transfer(
        _: &BankManagerCap,
        address: address,
        ctx: &mut TxContext
    ) {
        transfer::public_transfer(
            BankManagerCap {
                id: object::new(ctx),
            },
            address,
        )
    }
    */

// Transfers an existing BankManagerCap to another address.
// Parameters:
//   - cap: The BankManagerCap object to transfer.
//   - address: The address to transfer the capability to.
public fun transfer(cap: BankManagerCap, address: address) {
    // Transfer the capability to the specified address.
    transfer::public_transfer(
        cap,
        address,
    )
}

// Deletes a BankManagerCap object, removing its capability.
// Parameters:
//   - cap: The BankManagerCap object to delete.
public fun delete(cap: BankManagerCap) {
    // Destructure the cap to get its id and delete the id object.
    let BankManagerCap { id } = cap;
    id.delete();
}
