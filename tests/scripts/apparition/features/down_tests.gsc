// Down requests use native damage while retaining ownership of stock protections

run()
{
    modes_keep_down_before_the_unmapped_kill_choice();
    damage_amount_preserves_source_margin_without_integer_overflow();
    state_admission_requires_a_playing_upright_player_and_live_vectors();
    clearing_menu_protection_leaves_native_protection_untouched();
    invalid_selections_cannot_clear_flags_or_submit_damage();
    lobby_requests_reject_missing_or_nonplayer_owners_without_mutation();
}

modes_keep_down_before_the_unmapped_kill_choice()
{
    modes = scripts\apparition\features\down::modes();
    tests\support\checks::expect(modes.size == 2 && modes[0] == "Down" && modes[1] == "Kill",
        "The personal Death slider retains its source Down and Kill preview order");
}

damage_amount_preserves_source_margin_without_integer_overflow()
{
    tests\support\checks::expect(scripts\apparition\features\down::damage_amount(150) == 1149,
        "A normal Down request adds the source 999 damage margin");
    tests\support\checks::expect(scripts\apparition\features\down::damage_amount(1) == 1000,
        "One positive health point still produces a lethal native request");
    tests\support\checks::expect(scripts\apparition\features\down::damage_amount(2147482648) == 2147483647,
        "The largest admitted health value reaches the signed integer limit exactly");
    tests\support\checks::expect(!isDefined(scripts\apparition\features\down::damage_amount(undefined)),
        "Missing health is not converted into damage");
    foreach (invalid in [0, -1, 1.5, 2147482649, "150", [], spawnstruct(), (1, 2, 3)])
        tests\support\checks::expect(!isDefined(scripts\apparition\features\down::damage_amount(invalid)),
            "Nonpositive, fractional, overflowing or nonnumeric health cannot produce a request");
}

state_admission_requires_a_playing_upright_player_and_live_vectors()
{
    player = player();
    tests\support\checks::expect(scripts\apparition\features\down::state_reason(player) == "",
        "A playing upright actor with known positive health and origin passes field admission");
    player.inlaststand = 1;
    tests\support\checks::expect(scripts\apparition\features\down::state_reason(player) != "",
        "An already downed actor cannot receive another Down request");
    player = player();
    player.sessionstate = "spectator";
    tests\support\checks::expect(scripts\apparition\features\down::state_reason(player) != "",
        "Spectator state cannot authorize native damage");
    player = player();
    player.origin = "origin";
    tests\support\checks::expect(scripts\apparition\features\down::state_reason(player) != "",
        "Missing native origin is not replaced with the BO3 world-zero literal");
    player = player();
    player.health = 2147483647;
    tests\support\checks::expect(scripts\apparition\features\down::state_reason(player) != "",
        "Damage arithmetic must be admitted before menu flags change");
    foreach (invalid in [7, "player", [], (1, 2, 3)])
        tests\support\checks::expect(scripts\apparition\features\down::state_reason(invalid) != "",
            "Scalar and unrelated values cannot be read as actor state");
}

clearing_menu_protection_leaves_native_protection_untouched()
{
    player = player();
    player.playerGodmode = true;
    player.PlayerDemiGod = true;
    player.ability_invulnerable = 1;
    player.damageshieldexpiretime = 100000;
    player.is_fast_traveling = 1;
    player.NoExplosiveDamage = true;
    scripts\apparition\features\down::clear_menu_protection(player);
    tests\support\checks::expect(!isDefined(player.playerGodmode) && !isDefined(player.PlayerDemiGod),
        "Only this menu's blocking God and Demi-God settings are cleared");
    tests\support\checks::expect(player.ability_invulnerable == 1
        && player.damageshieldexpiretime == 100000 && player.is_fast_traveling == 1
        && player.NoExplosiveDamage && player.health == 150 && player.inlaststand == 0,
        "Native shields, travel, health and laststand remain untouched");

    player.playerGodmode = false;
    scripts\apparition\features\down::clear_menu_protection(player);
    tests\support\checks::expect(isDefined(player.playerGodmode) && !player.playerGodmode,
        "An already false setting keeps its representation without being toggled on");
}

invalid_selections_cannot_clear_flags_or_submit_damage()
{
    player = player();
    player.playerGodmode = true;
    tests\support\checks::expect(!scripts\apparition\features\down::request([player]),
        "An isolated struct is not an actual native player and cannot receive damage");
    tests\support\checks::expect(player.playerGodmode,
        "Rejected actor admission preserves the existing God Mode setting");
    tests\support\checks::expect(!scripts\apparition\features\down::request([])
        && !scripts\apparition\features\down::request(undefined),
        "Empty and missing selections never report a handled native request");
    tests\support\checks::expect(!scripts\apparition\features\down::request([7]),
        "Actual-player admission rejects a scalar before any target field or native damage call");
}

lobby_requests_reject_missing_or_nonplayer_owners_without_mutation()
{
    actor = player();
    actor.playerGodmode = true;
    tests\support\checks::expect(!scripts\apparition\features\down::request_lobby(undefined),
        "A missing requester cannot submit a lobby Down request");
    tests\support\checks::expect(!scripts\apparition\features\down::request_lobby(actor),
        "A fixture requester cannot submit a lobby Down request");
    tests\support\checks::expect(actor.playerGodmode && actor.health == 150 && actor.inlaststand == 0,
        "Rejected lobby admission preserves target settings and native life fields");
}

player()
{
    actor = spawnstruct();
    actor.inlaststand = 0;
    actor.sessionstate = "playing";
    actor.health = 150;
    actor.origin = (10, 20, 30);
    return actor;
}
