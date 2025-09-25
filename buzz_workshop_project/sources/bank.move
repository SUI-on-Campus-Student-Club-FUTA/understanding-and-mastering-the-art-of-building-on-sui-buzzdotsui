module workshop_project::bank;

use sui::balance;
use sui::coin;
use sui::object::{Self, UID};
use sui::table::{Self, Table};
use sui::transfer;
use sui::tx_context::{Self, TxContext};
use workshop_project::account_move::{
    Account,
    AccountCap,
    new,
    get_balance_valuation,
    get_balance_part,
    add_balance
};
use workshop_project::manager::{Self, BankManagerCap};

// Error code for when an account is not found in the bank.
const EAccountNotFound: u64 = 100;
// Error code for when a withdrawal or transfer amount exceeds the available balance.
const EAmountExceedsBalance: u64 = 101;
// Error code for when a user account is not found during a transfer.
const EUserAccountNotFound: u64 = 102;
// Error code for when an account for the given address already exists.
const EAccountAlreadyExists: u64 = 103;

// The Bank struct represents the main bank object.
// It stores all user accounts.
public struct Bank has key, store {
    // Unique identifier for the bank object.
    id: UID,
    // Table mapping addresses to Account structs.
    accounts: Table<address, Account>,
    // The 'value' field has been removed as it was not being used and could be misleading.
}

// Initializes the bank and gives the manager capability to the sender.
// This function is now removed.
/*
        fun init(ctx: &mut TxContext) {
            // Create the Bank object and transfer ownership to the sender of the transaction.
            transfer::public_transfer(
                Bank {
                    id: object::new(ctx),
                    accounts: table::new(ctx),
                    value: 0,
                },
                tx_context::sender(ctx),
            );

            // Create the BankManagerCap and transfer it to the sender.
            manager::create_and_transfer(tx_context::sender(ctx), ctx);
        }
    */

// Creates an account for a user in the bank.
// Only callable by someone with the BankManagerCap.
// Parameters:
//   - _: Reference to the BankManagerCap (not used, just for access control).
//   - bank: Mutable reference to the Bank object.
//   - recipient: The address of the recipient for the new account.
//   - ctx: The transaction context.
public fun create_account(
    _: &BankManagerCap,
    bank: &mut Bank,
    recipient: address,
    ctx: &mut TxContext,
) {
    // Add a check to ensure an account for this recipient does not already exist.
    assert!(!bank.accounts.contains(&recipient), EAccountAlreadyExists);

    // Creates a new account for the recipient and stores it in the bank's table.
    let (account, account_cap) = new(recipient, ctx);
    table::add(&mut bank.accounts, recipient, account);
    transfer::public_transfer(account_cap, recipient);
}

// Deposits a coin into a user's account in the bank.
// Parameters:
//   - bank: Mutable reference to the Bank object.
//   - coin: The coin to deposit.
//   - recipient: The address of the account to deposit to.
public fun deposit(bank: &mut Bank, coin: coin::Coin<sui::sui::SUI>, recipient: address) {
    // Get a mutable reference to the recipient's account from the bank's table.
    let account = table::borrow_mut(&mut bank.accounts, recipient);
    // Deposit the coin into the account's balance.
    add_balance(account, coin::into_balance(coin));
}

// Withdraws a specified amount of SUI from the sender's account in the bank.
// Only callable by someone with the AccountCap.
// Parameters:
//   - _: Reference to the AccountCap (not used, just for access control).
//   - bank: Mutable reference to the Bank object.
//   - amount: The amount to withdraw.
//   - ctx: The transaction context.
public fun withdraw(_: &AccountCap, bank: &mut Bank, amount: u64, ctx: &mut TxContext) {
    // Get a mutable reference to the sender's account from the bank's table.
    let account = table::borrow_mut(&mut bank.accounts, ctx.sender());

    // Use get_balance_part to safely check and split the amount at the same time.
    // The function will abort if the balance is insufficient.
    let amount_to_be_withdrawn = get_balance_part(account, amount);

    // Convert the balance to a coin and transfer it to the sender.
    transfer::public_transfer(
        coin::from_balance(amount_to_be_withdrawn, ctx),
        ctx.sender(),
    )
}

// Transfers a specified amount of SUI from the sender's account to another user's account in the bank.
// Only callable by someone with the AccountCap.
// Parameters:
//   - _: Reference to the AccountCap (not used, just for access control).
//   - bank: Mutable reference to the Bank object.
//   - amount: The amount to transfer.
//   - recipient: The address of the recipient account.
//   - ctx: The transaction context.
public fun transfer(
    _: &AccountCap,
    bank: &mut Bank,
    amount: u64,
    recipient: address,
    ctx: &mut TxContext,
) {
    // Check if the recipient account exists in the bank; abort if not found.
    if (!table::contains(&bank.accounts, recipient)) {
        abort EUserAccountNotFound;
    };

    // Split the requested amount from the sender's account balance.
    let balance_to_send = get_balance_part(
        table::borrow_mut(&mut bank.accounts, ctx.sender()),
        amount,
    );
    // Add the split balance to the recipient's account.
    add_balance(table::borrow_mut(&mut bank.accounts, recipient), balance_to_send);
}
