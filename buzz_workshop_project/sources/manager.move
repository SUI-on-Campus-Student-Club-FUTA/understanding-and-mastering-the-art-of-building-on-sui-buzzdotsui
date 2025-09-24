module buzz_workshop_project::manager;

public struct BankManagerCap has key, store {
    id: UID,
}

public fun new(ctx: &mut TxtContext): BankMangerCap {
    BankMangerCap {
        id: object::new(ctx),
    }
}

public fun transfer(cap: BankMangerCap, address: address, ctx: &mut TxContext) {
    transfer::public_transfer(
        BankManagerCap { id: object::new(ctx) },
        address,
    )
}
