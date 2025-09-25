module workshop_project::account_move;

use sui::balance;
use sui::coin;
use sui::object::{Self, UID};
use sui::transfer;
use sui::tx_context::{Self, TxContext};

// Error code for insufficient funds. Used in assertions to signal not enough balance.
const EInsufficientFunds: u64 = 101;

// The Account struct represents a user account with an owner and a SUI balance.
public struct Account has store {
    // The address of the account owner.
    owner: address,
    // The balance of SUI tokens held by this account.
    balance: balance::Balance<sui::sui::SUI>,
}

// The AccountCap struct is a capability object for account management.
// It is used to control access to account operations.
public struct AccountCap has key, store {
    // Unique identifier for the capability object.
    id: UID,
}

// Creates a new Account and its associated AccountCap.
// Only callable within the package.
// Parameters:
//   - owner: The address that will own the new account.
//   - ctx: The transaction context, required for creating new objects.
// Returns: A tuple of (Account, AccountCap).
public(package) fun new(owner: address, ctx: &mut TxContext): (Account, AccountCap) {
    // Initialize the Account struct with the given owner and a zero SUI balance.
    let account = Account {
        owner,
        balance: balance::zero(),
    };

    // Create a new AccountCap with a unique ID for the owner.
    let account_cap = AccountCap {
        id: object::new(ctx),
    };

    // Return both the new Account and AccountCap.
    (account, account_cap)
}

// Returns the current value of the account's balance.
// Parameters:
//   - account: Reference to the Account struct.
// Returns: The value of the balance as a u64.
public(package) fun get_balance_valuation(account: &Account): u64 {
    // Return the value of the account's balance.
    balance::value(&account.balance)
}

// Splits a specified amount from the account's balance and returns it as a new Balance object.
// Only callable within the package.
// Parameters:
//   - account: Mutable reference to the Account struct.
//   - value: The amount to split from the balance.
// Returns: A Balance object containing the split amount.
public(package) fun get_balance_part(
    account: &mut Account,
    value: u64,
): balance::Balance<sui::sui::SUI> {
    // Ensure the account has enough funds before splitting. Abort if not.
    assert!(balance::value(&account.balance) >= value, EInsufficientFunds);
    // Split the specified value from the account's balance.
    balance::split(&mut account.balance, value)
}

// Adds the given Balance object to the account's balance.
// Only callable within the package.
// Parameters:
//   - account: Mutable reference to the Account struct.
//   - balance: The Balance object to add.
public(package) fun add_balance(account: &mut Account, balance: balance::Balance<sui::sui::SUI>) {
    // Join (add) the provided balance to the account's balance.
    balance::join(&mut account.balance, balance);
}
