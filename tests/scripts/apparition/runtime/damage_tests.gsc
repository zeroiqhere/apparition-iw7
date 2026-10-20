// The production router is exercised with a recording GSC callback
// No game damage callback is installed or changed by these cases

run()
{
    disabled_god_mode_forwards_every_damage_argument_once();
    enabled_god_mode_does_not_forward_damage();
    an_unsupported_session_forwards_even_with_a_god_mode_flag();
    enabled_explosive_protection_blocks_native_grenade_splash();
    enabled_explosive_protection_forwards_melee_with_its_arguments();
    disabled_explosive_protection_forwards_grenade_splash();
    an_unsupported_session_forwards_with_explosive_protection();
    an_undefined_means_value_is_forwarded_without_classification();
    demi_god_blocks_damage_and_sends_the_exact_direction_to_its_receiver();
    demi_god_without_a_vector_blocks_damage_without_playing_random_feedback();
    an_unsupported_session_forwards_demi_god_damage_without_feedback();
    simultaneous_god_flags_keep_the_source_demi_feedback_rule();
    a_missing_feedback_callback_does_not_restore_damage();
}

demi_god_blocks_damage_and_sends_the_exact_direction_to_its_receiver()
{
    player = spawnstruct();
    player.PlayerDemiGod = true;
    player.health = 71;
    player.recorded_damage_calls = 0;
    player.recorded_feedback_calls = 0;
    scripts\apparition\runtime\damage::route(player, ::record_damage,
        undefined, undefined, 120, 0, "MOD_GRENADE_SPLASH", "test_grenade",
        (3, 2, 1), (0.25, -0.5, 0.75), "none", 0, 67, 89, true, ::record_feedback);
    tests\support\checks::expect(player.recorded_damage_calls == 0,
        "Demi-God suppresses the complete native damage packet");
    tests\support\checks::expect(player.recorded_feedback_calls == 1
        && player.recorded_feedback_direction == (0.25, -0.5, 0.75),
        "Feedback receives the victim and the exact native direction once");
    tests\support\checks::expect(player.health == 71 && player.PlayerDemiGod,
        "Routing changes neither health nor the configured Demi-God flag");
}

demi_god_without_a_vector_blocks_damage_without_playing_random_feedback()
{
    player = spawnstruct();
    player.PlayerDemiGod = true;
    player.recorded_damage_calls = 0;
    player.recorded_feedback_calls = 0;
    // Undefined is passed directly so array enumeration cannot omit this case
    scripts\apparition\runtime\damage::route(player, ::record_damage,
        undefined, undefined, 37, 0, "MOD_MELEE", "test_weapon",
        (0, 0, 0), undefined, "none", 0, undefined, undefined, true, ::record_feedback);
    tests\support\checks::expect(player.recorded_damage_calls == 0
        && player.recorded_feedback_calls == 0,
        "An absent direction blocks damage without choosing random feedback");

    foreach (direction in ["right", 17])
    {
        player = spawnstruct();
        player.PlayerDemiGod = true;
        player.recorded_damage_calls = 0;
        player.recorded_feedback_calls = 0;
        scripts\apparition\runtime\damage::route(player, ::record_damage,
            undefined, undefined, 37, 0, "MOD_MELEE", "test_weapon",
            (0, 0, 0), direction, "none", 0, undefined, undefined, true, ::record_feedback);
        tests\support\checks::expect(player.recorded_damage_calls == 0
            && player.recorded_feedback_calls == 0,
            "Missing or malformed directions block damage without inventing a hit direction");
    }
}

a_missing_feedback_callback_does_not_restore_damage()
{
    player = spawnstruct();
    player.PlayerDemiGod = true;
    player.recorded_damage_calls = 0;
    scripts\apparition\runtime\damage::route(player, ::record_damage,
        undefined, undefined, 37, 0, "MOD_MELEE", "test_weapon",
        (0, 0, 0), (1, 0, 0), "none", 0, undefined, undefined, true);
    tests\support\checks::expect(player.recorded_damage_calls == 0 && player.PlayerDemiGod,
        "A missing feedback callback neither forwards damage nor clears saved intent");
}

an_unsupported_session_forwards_demi_god_damage_without_feedback()
{
    player = spawnstruct();
    player.PlayerDemiGod = true;
    player.recorded_damage_calls = 0;
    player.recorded_feedback_calls = 0;
    scripts\apparition\runtime\damage::route(player, ::record_damage,
        undefined, undefined, 37, 5, "MOD_MELEE", "test_weapon",
        (1, 2, 3), (4, 5, 6), "torso_upper", 17, 67, 89, false, ::record_feedback);
    tests\support\checks::expect(player.recorded_damage_calls == 1
        && player.recorded_feedback_calls == 0,
        "Unsupported sessions delegate damage and never play menu hit feedback");
    tests\support\checks::expect(player.recorded_damage[2] == 37
        && player.recorded_damage[7] == (4, 5, 6)
        && player.recorded_damage[10] == 67 && player.recorded_damage[11] == 89,
        "Demi-God outside its session preserves damage direction and both trailing arguments");
}

simultaneous_god_flags_keep_the_source_demi_feedback_rule()
{
    player = spawnstruct();
    player.PlayerDemiGod = true;
    player.playerGodmode = true;
    player.recorded_damage_calls = 0;
    player.recorded_feedback_calls = 0;
    scripts\apparition\runtime\damage::route(player, ::record_damage,
        undefined, undefined, 37, 0, "MOD_MELEE", "test_weapon",
        (0, 0, 0), (1, 0, 0), "none", 0, undefined, undefined, true, ::record_feedback);
    tests\support\checks::expect(player.recorded_damage_calls == 0
        && player.recorded_feedback_calls == 1,
        "A corrupt pair of saved flags still follows the source Demi-God feedback branch");
}

record_feedback(player, direction)
{
    player.recorded_feedback_calls++;
    player.recorded_feedback_direction = direction;
}

disabled_god_mode_forwards_every_damage_argument_once()
{
    player = spawnstruct();
    player.recorded_damage_calls = 0;
    inflictor = spawnstruct();
    attacker = spawnstruct();
    native_tail = spawnstruct();

    scripts\apparition\runtime\damage::route(player, ::record_damage,
        inflictor, attacker, 37, 5, "MOD_MELEE", "test_weapon",
        (1, 2, 3), (4, 5, 6), "torso_upper", 17, native_tail, 0, true);

    tests\support\checks::expect(player.recorded_damage_calls == 1, "Unblocked damage is forwarded exactly once");
    tests\support\checks::expect(player.recorded_damage[0] == inflictor, "Inflictor identity is preserved");
    tests\support\checks::expect(player.recorded_damage[1] == attacker, "Attacker identity is preserved");
    tests\support\checks::expect(player.recorded_damage[2] == 37, "Damage amount is preserved");
    tests\support\checks::expect(player.recorded_damage[3] == 5, "Damage flags are preserved");
    tests\support\checks::expect(player.recorded_damage[4] == "MOD_MELEE", "Means of death is preserved");
    tests\support\checks::expect(player.recorded_damage[5] == "test_weapon", "Weapon is preserved");
    tests\support\checks::expect(player.recorded_damage[6] == (1, 2, 3), "Damage point is preserved");
    tests\support\checks::expect(player.recorded_damage[7] == (4, 5, 6), "Damage direction is preserved");
    tests\support\checks::expect(player.recorded_damage[8] == "torso_upper", "Hit location is preserved");
    tests\support\checks::expect(player.recorded_damage[9] == 17, "Time offset is preserved");
    tests\support\checks::expect(player.recorded_damage[10] == native_tail, "The first trailing native argument preserves its identity");
    tests\support\checks::expect(isDefined(player.recorded_damage[11]) && player.recorded_damage[11] == 0, "The second trailing native argument preserves zero");
}

enabled_god_mode_does_not_forward_damage()
{
    player = spawnstruct();
    player.playerGodmode = true;
    player.recorded_damage_calls = 0;

    scripts\apparition\runtime\damage::route(player, ::record_damage,
        undefined, undefined, 37, 0, "MOD_MELEE", "test_weapon",
        (0, 0, 0), (0, 0, 0), "none", 0, undefined, undefined, true);

    tests\support\checks::expect(player.recorded_damage_calls == 0, "God mode blocks the original damage callback");
}

an_unsupported_session_forwards_even_with_a_god_mode_flag()
{
    player = spawnstruct();
    player.playerGodmode = true;
    player.recorded_damage_calls = 0;
    scripts\apparition\runtime\damage::route(player, ::record_damage,
        undefined, undefined, 37, 0, "MOD_MELEE", "test_weapon",
        (0, 0, 0), (0, 0, 0), "none", 0, 67, 89, false);
    tests\support\checks::expect(player.recorded_damage_calls == 1, "Unsupported sessions preserve native damage");
    tests\support\checks::expect(player.recorded_damage[10] == 67 && player.recorded_damage[11] == 89, "Unsupported sessions preserve both trailing native arguments");
}

enabled_explosive_protection_blocks_native_grenade_splash()
{
    player = spawnstruct();
    player.NoExplosiveDamage = true;
    player.recorded_damage_calls = 0;
    // The actual IW builtin classifies this native damage kind
    scripts\apparition\runtime\damage::route(player, ::record_damage,
        undefined, undefined, 120, 0, "MOD_GRENADE_SPLASH", "test_grenade",
        (0, 0, 0), (1, 0, 0), "none", 0, undefined, undefined, true);
    tests\support\checks::expect(player.recorded_damage_calls == 0, "Explosive protection blocks native grenade splash");
    tests\support\checks::expect(player.NoExplosiveDamage, "Damage routing does not spend the configured setting");
}

enabled_explosive_protection_forwards_melee_with_its_arguments()
{
    player = spawnstruct();
    player.NoExplosiveDamage = true;
    player.recorded_damage_calls = 0;
    inflictor = spawnstruct();
    attacker = spawnstruct();
    scripts\apparition\runtime\damage::route(player, ::record_damage,
        inflictor, attacker, 37, 5, "MOD_MELEE", "test_weapon",
        (1, 2, 3), (4, 5, 6), "torso_upper", 17, 67, 89, true);
    tests\support\checks::expect(player.recorded_damage_calls == 1, "Explosive protection forwards melee exactly once");
    tests\support\checks::expect(player.recorded_damage[0] == inflictor && player.recorded_damage[1] == attacker, "Melee forwarding preserves actor identities");
    tests\support\checks::expect(player.recorded_damage[2] == 37 && player.recorded_damage[3] == 5, "Melee forwarding preserves amount and flags");
    tests\support\checks::expect(player.recorded_damage[4] == "MOD_MELEE" && player.recorded_damage[5] == "test_weapon", "Melee forwarding preserves the damage and weapon kinds");
    tests\support\checks::expect(player.recorded_damage[6] == (1, 2, 3) && player.recorded_damage[7] == (4, 5, 6), "Melee forwarding preserves both vectors");
    tests\support\checks::expect(player.recorded_damage[8] == "torso_upper" && player.recorded_damage[9] == 17, "Melee forwarding preserves hit location and time offset");
    tests\support\checks::expect(player.recorded_damage[10] == 67 && player.recorded_damage[11] == 89, "Nonexplosive forwarding preserves both native trailing arguments");
}

disabled_explosive_protection_forwards_grenade_splash()
{
    player = spawnstruct();
    player.NoExplosiveDamage = false;
    player.recorded_damage_calls = 0;
    scripts\apparition\runtime\damage::route(player, ::record_damage,
        undefined, undefined, 120, 0, "MOD_GRENADE_SPLASH", "test_grenade",
        (0, 0, 0), (1, 0, 0), "none", 0, undefined, undefined, true);
    tests\support\checks::expect(player.recorded_damage_calls == 1, "A false explosive setting preserves grenade damage");
    tests\support\checks::expect(player.recorded_damage[2] == 120, "Unblocked explosive amount is unchanged");
    tests\support\checks::expect(!isDefined(player.recorded_damage[10]) && !isDefined(player.recorded_damage[11]), "Undefined trailing native values remain undefined");
}

an_unsupported_session_forwards_with_explosive_protection()
{
    player = spawnstruct();
    player.NoExplosiveDamage = true;
    player.recorded_damage_calls = 0;
    scripts\apparition\runtime\damage::route(player, ::record_damage,
        undefined, undefined, 120, 0, "MOD_GRENADE_SPLASH", "test_grenade",
        (0, 0, 0), (1, 0, 0), "none", 0, 67, 89, false);
    tests\support\checks::expect(player.recorded_damage_calls == 1, "Unsupported sessions preserve explosive damage");
}

an_undefined_means_value_is_forwarded_without_classification()
{
    player = spawnstruct();
    player.NoExplosiveDamage = true;
    player.recorded_damage_calls = 0;
    // Native call sites also admit an absent means-of-death value
    scripts\apparition\runtime\damage::route(player, ::record_damage,
        undefined, undefined, 37, 0, undefined, "test_weapon",
        (0, 0, 0), (0, 0, 0), "none", 0, undefined, undefined, true);
    tests\support\checks::expect(player.recorded_damage_calls == 1, "An absent means value is forwarded without native classification");
    tests\support\checks::expect(!isDefined(player.recorded_damage[4]), "Forwarding keeps the absent means value unchanged");
}

record_damage(inflictor, attacker, amount, flags, means, weapon, point, direction, location, time_offset, native_arg_10, native_arg_11)
{
    self.recorded_damage_calls++;
    self.recorded_damage = [];
    self.recorded_damage[0] = inflictor;
    self.recorded_damage[1] = attacker;
    self.recorded_damage[2] = amount;
    self.recorded_damage[3] = flags;
    self.recorded_damage[4] = means;
    self.recorded_damage[5] = weapon;
    self.recorded_damage[6] = point;
    self.recorded_damage[7] = direction;
    self.recorded_damage[8] = location;
    self.recorded_damage[9] = time_offset;
    self.recorded_damage[10] = native_arg_10;
    self.recorded_damage[11] = native_arg_11;
}
