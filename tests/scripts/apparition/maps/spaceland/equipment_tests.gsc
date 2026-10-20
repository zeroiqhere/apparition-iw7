// The selector recognizes only a complete, unambiguous native primary record

run()
{
    every_catalog_primary_id_is_selectable_from_live_native_records();
    unsupported_and_secondary_powers_are_not_refill_targets();
    selector_requires_one_complete_primary_across_all_records();
    player_and_registry_weapon_identity_must_match();
    charge_bounds_and_activity_fields_must_be_native_ready();
    permanent_and_unsaved_cleanup_policy_are_respected();
    full_and_above_cap_native_records_remain_selectable();
    temporary_native_modes_block_effect_admission();
    inspection_distinguishes_ready_full_and_above_cap_without_changing_charges();
    inspection_pauses_native_modes_before_selecting_inventory();
    inspection_prioritizes_native_mode_ownership_over_life_and_inventory();
    inspection_does_not_expose_a_target_for_unsafe_or_removed_equipment();
}

every_catalog_primary_id_is_selectable_from_live_native_records()
{
    ids = scripts\apparition\maps\spaceland\equipment::powers();
    expected = ["power_bioSpike", "power_c4", "power_clusterGrenade", "power_concussionGrenade",
        "power_frag", "power_gasGrenade", "power_semtex", "power_splashGrenade", "power_cryobomb"];
    tests\support\checks::expect(ids.size == expected.size, "The source-backed primary allowlist has nine native power IDs");
    for (index = 0; index < expected.size; index++)
        tests\support\checks::expect(ids[index] == expected[index], "The primary allowlist preserves native source order");

    foreach (id in expected)
    {
        weaponuse = "native_weapon_" + id;
        registry = tests\fixtures\equipment::registry(id, weaponuse, 3);
        permanent = id == "power_cryobomb" ? undefined : 1;
        player = tests\fixtures\equipment::player(id, weaponuse, 1, permanent);
        tests\support\checks::expect(scripts\apparition\maps\spaceland\equipment::candidate(player, registry) == id,
            "A whitelisted primary power with matching native registration is selectable");
    }
}

unsupported_and_secondary_powers_are_not_refill_targets()
{
    registry = tests\fixtures\equipment::registry("power_scu", "scu_device", 2);
    player = tests\fixtures\equipment::player("power_scu", "scu_device", 1, 0);
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\equipment::candidate(player, registry)),
        "An unlisted quest power cannot become an ordinary refill target");

    registry = tests\fixtures\equipment::registry("power_frag", "frag_grenade_zm", 3);
    player = tests\fixtures\equipment::player("power_frag", "frag_grenade_zm", 1, 1);
    player.powers["power_frag"].slot = "secondary";
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\equipment::candidate(player, registry)),
        "A secondary-slot record cannot be selected as a primary refill target");
}

selector_requires_one_complete_primary_across_all_records()
{
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\equipment::candidate(undefined, [])),
        "A missing player is unavailable");
    registry = tests\fixtures\equipment::registry("power_frag", "frag_grenade_zm", 3);
    player = tests\fixtures\equipment::player("power_frag", "frag_grenade_zm", 1, 1);
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\equipment::candidate(player, undefined)),
        "A missing native power registry is unavailable");

    player.powers["other"] = tests\fixtures\equipment::power("primary", "other_weapon", 1, 0, undefined, 1);
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\equipment::candidate(player, registry)),
        "Two primary records are ambiguous even when only one is whitelisted");

    player = tests\fixtures\equipment::player("power_frag", "frag_grenade_zm", 1, 1);
    player.powers["power_speedBoost"] = tests\fixtures\equipment::power("secondary", "speed_boost", 1, 0, undefined, 0);
    tests\support\checks::expect(scripts\apparition\maps\spaceland\equipment::candidate(player, registry) == "power_frag",
        "A separate secondary power does not make one complete primary ambiguous");
    player.powers["malformed"] = tests\fixtures\equipment::power(undefined, "unknown", 1, 0, undefined, 1);
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\equipment::candidate(player, registry)),
        "A power record without a native slot cannot be safely excluded from primary identity");

    player = tests\fixtures\equipment::player("power_frag", "frag_grenade_zm", 1, 1);
    player.powers = undefined;
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\equipment::candidate(player, registry)),
        "A missing player power table is unavailable");
}

player_and_registry_weapon_identity_must_match()
{
    registry = tests\fixtures\equipment::registry("power_frag", "frag_grenade_zm", 3);
    player = tests\fixtures\equipment::player("power_frag", "frag_grenade_zm", 1, 1);
    player.powerprimarygrenade = "different_weapon";
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\equipment::candidate(player, registry)),
        "The player primary assignment must match the live power record");

    player.powerprimarygrenade = "frag_grenade_zm";
    player.powers["power_frag"].weaponuse = "different_weapon";
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\equipment::candidate(player, registry)),
        "The player record must match the native registry weapon");

    player.powers["power_frag"].weaponuse = "frag_grenade_zm";
    registry["power_frag"].weaponuse = "different_weapon";
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\equipment::candidate(player, registry)),
        "A replaced registry weapon cannot authorize the stale player weapon");

    registry = [];
    player = tests\fixtures\equipment::player("power_frag", "frag_grenade_zm", 1, 1);
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\equipment::candidate(player, registry)),
        "A missing native entry cannot be inferred from player state");

    registry = tests\fixtures\equipment::registry("power_frag", "frag_grenade_zm", 3);
    player.powerprimarygrenade = undefined;
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\equipment::candidate(player, registry)),
        "An absent native primary assignment cannot prove the current weapon");

    player = tests\fixtures\equipment::player("power_frag", "frag_grenade_zm", 1, 1);
    player.powers["power_frag"].weaponuse = "";
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\equipment::candidate(player, registry)),
        "An empty player weapon name is not a usable identity");
    player.powers["power_frag"].weaponuse = "frag_grenade_zm";
    registry["power_frag"].weaponuse = undefined;
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\equipment::candidate(player, registry)),
        "An absent registry weapon name is not a usable identity");
}

charge_bounds_and_activity_fields_must_be_native_ready()
{
    registry = tests\fixtures\equipment::registry("power_frag", "frag_grenade_zm", 3);
    player = tests\fixtures\equipment::player("power_frag", "frag_grenade_zm", 1, 1);
    player.powers["power_frag"].charges = undefined;
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\equipment::candidate(player, registry)),
        "An uninitialized charge count is unavailable");

    player.powers["power_frag"].charges = -1;
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\equipment::candidate(player, registry)),
        "A negative native charge count is rejected");

    player.powers["power_frag"].charges = 0;
    registry["power_frag"].maxcharges = undefined;
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\equipment::candidate(player, registry)),
        "An uninitialized native maximum cannot authorize charge adjustment");

    registry["power_frag"].maxcharges = 0;
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\equipment::candidate(player, registry)),
        "A zero native charge capacity is not a refill target");
    registry["power_frag"].maxcharges = 3;
    player.powers["power_frag"].charges = "1";
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\equipment::candidate(player, registry)),
        "A nonnumeric charge field cannot reach numeric native comparisons");
    player.powers["power_frag"].charges = 0;
    registry["power_frag"].maxcharges = "3";
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\equipment::candidate(player, registry)),
        "A nonnumeric native maximum cannot authorize charge adjustment");
    registry["power_frag"].maxcharges = 3;
    player.powers["power_frag"].active = undefined;
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\equipment::candidate(player, registry)),
        "Missing active state cannot be treated as inactive");

    player.powers["power_frag"].active = 1;
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\equipment::candidate(player, registry)),
        "An active power cannot be refilled during its native action");
    player.powers["power_frag"].active = 0;
    player.powers["power_frag"]._id_55AB = "locked";
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\equipment::candidate(player, registry)),
        "A malformed native lock counter is not treated as clear");
    player.powers["power_frag"]._id_55AB = 1;
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\equipment::candidate(player, registry)),
        "A native locked power cannot be refilled while in use");
    player.powers["power_frag"]._id_55AB = 0;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\equipment::candidate(player, registry) == "power_frag",
        "A defined inactive unlocked entry remains selectable");
}

permanent_and_unsaved_cleanup_policy_are_respected()
{
    registry = tests\fixtures\equipment::registry("power_frag", "frag_grenade_zm", 3);
    player = tests\fixtures\equipment::player("power_frag", "frag_grenade_zm", 0, 0);
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\equipment::candidate(player, registry)),
        "A defined false permanent field may have a queued native zero-charge removal");

    player.powers["power_frag"].permanent = 1;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\equipment::candidate(player, registry) == "power_frag",
        "A native permanent power has no queued zero-charge removal worker");

    player.powers["power_frag"].permanent = undefined;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\equipment::candidate(player, registry) == "power_frag",
        "An undefined permanent field does not start the guarded removal worker");
}

full_and_above_cap_native_records_remain_selectable()
{
    registry = tests\fixtures\equipment::registry("power_frag", "frag_grenade_zm", 3);
    player = tests\fixtures\equipment::player("power_frag", "frag_grenade_zm", 3, 1);
    tests\support\checks::expect(scripts\apparition\maps\spaceland\equipment::candidate(player, registry) == "power_frag",
        "A full native entry remains selectable so the effect layer can decide whether to act");
    player.powers["power_frag"].charges = 5;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\equipment::candidate(player, registry) == "power_frag",
        "An above-cap charge count remains selectable without silently downgrading it");
}

temporary_native_modes_block_effect_admission()
{
    player = spawnstruct();
    tests\support\checks::expect(scripts\apparition\maps\spaceland\equipment::blocked(undefined),
        "A missing player is blocked");
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\equipment::blocked(player),
        "No active native temporary-mode flag permits the ordinary effect layer");
    foreach (field in ["inlaststand", "in_afterlife_arcade", "playing_ghosts_n_skulls", "playing_game", "linked_to_coaster", "disable_consumables"])
    {
        player[field] = 1;
        tests\support\checks::expect(scripts\apparition\maps\spaceland\equipment::blocked(player),
            "Any active native temporary-mode flag blocks equipment effects");
        player[field] = 0;
    }
}

inspection_distinguishes_ready_full_and_above_cap_without_changing_charges()
{
    registry = tests\fixtures\equipment::registry("power_frag", "frag_grenade_zm", 3);
    player = tests\fixtures\equipment::player("power_frag", "frag_grenade_zm", 0, 1);
    result = scripts\apparition\maps\spaceland\equipment::inspect(player, registry, true);
    tests\support\checks::expect(result.state == "Ready" && result.id == "power_frag",
        "An owned refill-safe primary below its cap is eligible for a refill");
    tests\support\checks::expect(player.powers["power_frag"].charges == 0,
        "Reading readiness does not perform a native refill");

    player.powers["power_frag"].charges = 3;
    result = scripts\apparition\maps\spaceland\equipment::inspect(player, registry, true);
    tests\support\checks::expect(result.state == "Full" && result.id == "power_frag",
        "An exact-cap primary is full rather than waiting for a refill");
    player.powers["power_frag"].charges = 5;
    result = scripts\apparition\maps\spaceland\equipment::inspect(player, registry, true);
    tests\support\checks::expect(result.state == "Full" && player.powers["power_frag"].charges == 5,
        "An above-cap primary is reported full and its extra charges remain intact");
    tests\support\checks::expect(registry["power_frag"].maxcharges == 3 && player.powerprimarygrenade == "frag_grenade_zm",
        "Inspection preserves the native cap and primary weapon assignment");
}

inspection_pauses_native_modes_before_selecting_inventory()
{
    registry = tests\fixtures\equipment::registry("power_frag", "frag_grenade_zm", 3);
    foreach (field in ["inlaststand", "in_afterlife_arcade", "playing_ghosts_n_skulls", "playing_game", "linked_to_coaster", "disable_consumables"])
    {
        player = tests\fixtures\equipment::player("power_frag", "frag_grenade_zm", 1, 1);
        player[field] = 1;
        result = scripts\apparition\maps\spaceland\equipment::inspect(player, registry, true);
        tests\support\checks::expect(result.state == "Paused" && !isDefined(result.id),
            "A native inventory-owning mode pauses the refill without exposing a target");
        tests\support\checks::expect(player[field] == 1 && player.powers["power_frag"].charges == 1,
            "Inspection does not clear a native mode or change its charges");
    }
    // Missing inventory cannot turn an active native mode into refill readiness
    player = spawnstruct();
    player.playing_game = 1;
    result = scripts\apparition\maps\spaceland\equipment::inspect(player, undefined, true);
    tests\support\checks::expect(result.state == "Paused" && !isDefined(result.id),
        "Native mode ownership takes precedence over unavailable inventory");
}

inspection_does_not_expose_a_target_for_unsafe_or_removed_equipment()
{
    registry = tests\fixtures\equipment::registry("power_frag", "frag_grenade_zm", 3);
    player = tests\fixtures\equipment::player("power_frag", "frag_grenade_zm", 0, 0);
    result = scripts\apparition\maps\spaceland\equipment::inspect(player, registry, true);
    tests\support\checks::expect(result.state == "Unavailable" && !isDefined(result.id),
        "A queued-removal policy never receives a refill-ready status");
    player.powers["power_frag"] = undefined;
    result = scripts\apparition\maps\spaceland\equipment::inspect(player, registry, true);
    tests\support\checks::expect(result.state == "Unavailable" && !isDefined(result.id),
        "A removed primary is unavailable and is never reconstructed");
    player = tests\fixtures\equipment::player("power_frag", "frag_grenade_zm", 1, 1);
    player.powers["power_frag"].active = 1;
    result = scripts\apparition\maps\spaceland\equipment::inspect(player, registry, true);
    tests\support\checks::expect(result.state == "Unavailable" && !isDefined(result.id),
        "An active native power cannot be described as ready");
}

inspection_prioritizes_native_mode_ownership_over_life_and_inventory()
{
    registry = tests\fixtures\equipment::registry("power_frag", "frag_grenade_zm", 3);
    player = tests\fixtures\equipment::player("power_frag", "frag_grenade_zm", 1, 1);
    result = scripts\apparition\maps\spaceland\equipment::inspect(player, registry, false);
    tests\support\checks::expect(result.state == "Waiting" && !isDefined(result.id),
        "A dead or spectator actor waits without exposing an otherwise eligible primary");
    player.playing_game = 1;
    result = scripts\apparition\maps\spaceland\equipment::inspect(player, registry, false);
    tests\support\checks::expect(result.state == "Paused" && !isDefined(result.id),
        "Native inventory ownership is the clearer reason when the actor also fails the life check");
    player.playing_game = 0;
    player.powers = undefined;
    result = scripts\apparition\maps\spaceland\equipment::inspect(player, registry, false);
    tests\support\checks::expect(result.state == "Waiting" && !isDefined(result.id),
        "Life admission precedes inventory selection when no native mode owns it");
    result = scripts\apparition\maps\spaceland\equipment::inspect(player, registry, undefined);
    tests\support\checks::expect(result.state == "Waiting" && !isDefined(result.id),
        "Missing life evidence cannot imply refill readiness");
}
