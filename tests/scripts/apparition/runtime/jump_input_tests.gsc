// Shared jump input tests cover receipt admission and read-only readiness

run()
{
    input_readiness_requires_a_bound_receipt();
    input_readiness_is_a_pure_receipt_check();
}

input_readiness_requires_a_bound_receipt()
{
    tests\support\checks::expect(!scripts\apparition\runtime\jump_input::input_ready(undefined),
        "A missing player has no ready jump input observer");
    player = spawnstruct();
    tests\support\checks::expect(!scripts\apparition\runtime\jump_input::input_ready(player),
        "A player without an input receipt is not ready");

    player.apparition_jump_input = [];
    tests\support\checks::expect(!scripts\apparition\runtime\jump_input::input_ready(player),
        "An array cannot impersonate an input receipt");
    receipt = spawnstruct();
    receipt.held = false;
    receipt.bound = false;
    player.apparition_jump_input = receipt;
    tests\support\checks::expect(!scripts\apparition\runtime\jump_input::input_ready(player),
        "An unbound input receipt is not ready");
    receipt.bound = true;
    receipt.held = undefined;
    tests\support\checks::expect(!scripts\apparition\runtime\jump_input::input_ready(player),
        "A receipt without its held state is not ready");
}

input_readiness_is_a_pure_receipt_check()
{
    player = spawnstruct();
    receipt = spawnstruct();
    receipt.held = false;
    receipt.bound = true;
    player.apparition_jump_input = receipt;
    player.MultiJump = true;

    tests\support\checks::expect(scripts\apparition\runtime\jump_input::input_ready(player),
        "A bound receipt with a held state is ready");
    tests\support\checks::expect(!receipt.held && receipt.bound && player.MultiJump,
        "Checking readiness leaves the receipt and saved flag unchanged");

    receipt.held = true;
    tests\support\checks::expect(scripts\apparition\runtime\jump_input::input_ready(player),
        "Readiness does not depend on whether the command is currently held");
    tests\support\checks::expect(receipt.held && receipt.bound,
        "Checking a held receipt does not rewrite its event state");
}
