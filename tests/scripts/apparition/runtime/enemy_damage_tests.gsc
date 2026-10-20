// Hook contracts keep native callback ownership explicit and avoid live slot writes

run()
{
    undefined_hook_is_available();
    this_callback_may_keep_its_own_binding();
    a_foreign_callback_blocks_installation();
    the_callback_accepts_the_native_twelve_argument_packet();
    println("Apparition enemy damage hook contracts completed");
}

undefined_hook_is_available()
{
    tests\support\checks::expect(scripts\apparition\runtime\enemy_damage::binding_reason(undefined) == "",
        "An undefined native damage slot is available for lazy installation");
}

this_callback_may_keep_its_own_binding()
{
    tests\support\checks::expect(scripts\apparition\runtime\enemy_damage::binding_reason(
        scripts\apparition\runtime\enemy_damage::on_damage) == "",
        "The provider accepts a slot already bound to its callback");
}

a_foreign_callback_blocks_installation()
{
    tests\support\checks::expect(scripts\apparition\runtime\enemy_damage::binding_reason(::foreign_callback) != "",
        "A callback owned by another feature blocks installation");
}

foreign_callback()
{
}

the_callback_accepts_the_native_twelve_argument_packet()
{
    enemy = spawnstruct();
    packet_tail = spawnstruct();
    original_amount = 37;
    returned_amount = enemy scripts\apparition\runtime\enemy_damage::on_damage(
        undefined, undefined, original_amount, 5, "MOD_MELEE", "weapon_test",
        (1, 2, 3), (4, 5, 6), "torso_upper", 17, packet_tail, 0);
    tests\support\checks::expect(returned_amount == original_amount,
        "An unconfigured non-agent packet returns its original amount");
}
