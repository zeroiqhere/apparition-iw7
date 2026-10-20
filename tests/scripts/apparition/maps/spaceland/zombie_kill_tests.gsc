// Countable native zombies receive one bounded host-attributed Death request

run()
{
    source_modes_remain_ordered_and_only_death_is_supported();
    pure_snapshot_keeps_current_roster_without_ufo_stage_gate();
    repeated_native_roster_entries_produce_one_request_target();
    snapshot_filters_native_protection_and_malformed_targets();
    damage_amount_preserves_source_bonus_with_safe_integer_bounds();
    scalar_and_array_inputs_fail_closed_before_field_reads();
    malformed_native_tables_fail_closed_without_mutation();
    live_probe_and_request_guards_reject_missing_actors_and_modes();
}

source_modes_remain_ordered_and_only_death_is_supported()
{
    modes = scripts\apparition\maps\spaceland\zombie_kill::modes();
    expected_modes = ["Death", "Head Gib", "Flame", "Delete"];
    tests\support\checks::expect(modes.size == expected_modes.size,
        "The original Kill slider retains all four choices");
    if (modes.size == expected_modes.size)
    {
        for (index = 0; index < expected_modes.size; index++)
            tests\support\checks::expect(modes[index] == expected_modes[index],
                "The original Kill slider choice remains at its source position");
    }

    tests\support\checks::expect(!scripts\apparition\maps\spaceland\zombie_kill::request(undefined, "Head Gib"),
        "Unported head-gib mode rejects before any player or native effect query");
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\zombie_kill::request(undefined, "Flame"),
        "Unported flame mode rejects before any player or native effect query");
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\zombie_kill::request(undefined, "Delete"),
        "Delete mode cannot bypass native death callbacks");
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\zombie_kill::request(undefined, true),
        "Nonstring mode input rejects before any player or native effect query");
}

pure_snapshot_keeps_current_roster_without_ufo_stage_gate()
{
    state = tests\fixtures\spaceland::wave();
    enemy = tests\fixtures\spaceland::wave_enemy(state);
    state._id_13F1B["ufo"] = 0;
    original_health = enemy.health;
    original_wave = state.wave_num;

    result = scripts\apparition\maps\spaceland\zombie_kill::inspect(state, state.spawned_enemies);
    tests\support\checks::expect(result.reason == "" && result.targets.size == 1 && result.targets[0] == enemy,
        "A countable native zombie can be selected outside the UFO stage-five wave wait");
    tests\support\checks::expect(isDefined(result.hint) && isstring(result.hint),
        "The snapshot supplies a user-facing current-pass hint");
    tests\support\checks::expect(result.hint == "One-time Death request for 1 countable native zombies on this pass; reserved and protected actors are skipped, and native protection may still reject damage",
        "The hint explains that the request covers this pass and skips protected actors");
    tests\support\checks::expect(enemy.health == original_health && state.wave_num == original_wave,
        "Inspecting a kill pass does not change native health or wave state");

    state.spawned_enemies = [];
    result = scripts\apparition\maps\spaceland\zombie_kill::inspect(state, []);
    tests\support\checks::expect(result.reason == "" && result.targets.size == 0,
        "An initialized native roster with no eligible actors remains a valid empty snapshot");
}

snapshot_filters_native_protection_and_malformed_targets()
{
    state = tests\fixtures\spaceland::wave();
    ordinary = tests\fixtures\spaceland::wave_enemy(state);

    clown = tests\fixtures\spaceland::wave_enemy(state);
    clown.agent_type = "zombie_clown";
    clown.is_suicide_bomber = 1;

    reserved = tests\fixtures\spaceland::wave_enemy(state);
    reserved.is_reserved = 1;

    respawning = tests\fixtures\spaceland::wave_enemy(state);
    respawning.died_poorly = 1;

    protected = tests\fixtures\spaceland::wave_enemy(state);
    protected.dont_scriptkill = 0;

    malformed_health = tests\fixtures\spaceland::wave_enemy(state);
    malformed_health.health = "500";

    fractional_health = tests\fixtures\spaceland::wave_enemy(state);
    fractional_health.health = 500.5;

    malformed_origin = tests\fixtures\spaceland::wave_enemy(state);
    malformed_origin.origin = "1 2 3";

    result = scripts\apparition\maps\spaceland\zombie_kill::inspect(state, state.spawned_enemies);
    tests\support\checks::expect(result.reason == "" && result.targets.size == 2
        && result.targets[0] == ordinary && result.targets[1] == clown,
        "Only typed countable generic zombies and clowns survive native protection gates");

    state.agent_funcs["zombie_clown"]["on_killed"] = scripts\cp\maps\cp_zmb\cp_zmb_dj::blank;
    result = scripts\apparition\maps\spaceland\zombie_kill::inspect(state, state.spawned_enemies);
    tests\support\checks::expect(result.reason == "" && result.targets.size == 1 && result.targets[0] == ordinary,
        "A changed clown handler excludes that actor while preserving the verified generic path");
}

damage_amount_preserves_source_bonus_with_safe_integer_bounds()
{
    enemy = spawnstruct();
    enemy.agent_type = "generic_zombie";
    enemy.team = "axis";
    enemy.health = 500;
    enemy.maxhealth = 1000;
    enemy.origin = (1, 2, 3);
    enemy.died_poorly = 0;

    tests\support\checks::expect(scripts\apparition\maps\spaceland\zombie_kill::damage_amount(enemy) == 1166,
        "The Death request preserves the original health-plus-666 damage amount");

    enemy.health = 150.0;
    enemy.maxhealth = 1000.5;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\zombie_kill::damage_amount(enemy) == 816,
        "Whole-valued numeric health produces exact integer damage without requiring an integer cap");

    enemy.health = 2147482981;
    enemy.maxhealth = 2147483647;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\zombie_kill::damage_amount(enemy) == 2147483647,
        "The largest source-bounded health value converts to a safe signed integer packet");

    enemy.health = 2147482982;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\zombie_kill::damage_amount(enemy) == -1,
        "Health above the signed-integer-plus-666 bound is rejected before conversion");

    enemy.health = 2147483008.0;
    enemy.maxhealth = 2147483647;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\zombie_kill::damage_amount(enemy) == -1,
        "A rounded near-bound health value cannot overflow the final integer addition");

    enemy.health = 500.5;
    enemy.maxhealth = 1000;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\zombie_kill::damage_amount(enemy) == -1,
        "Fractional native health cannot be rounded into a damage packet");

    enemy.health = 500;
    enemy.maxhealth = "1000";
    tests\support\checks::expect(scripts\apparition\maps\spaceland\zombie_kill::damage_amount(enemy) == -1,
        "Malformed maximum-health data cannot authorize a damage packet");

    enemy.maxhealth = 499;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\zombie_kill::damage_amount(enemy) == -1,
        "A current health value above the native cap cannot be assumed lethal");
}

scalar_and_array_inputs_fail_closed_before_field_reads()
{
    tests\support\checks::expect(scripts\apparition\maps\spaceland\zombie_kill::damage_amount(7) == -1,
        "A numeric scalar cannot be read as a native zombie struct");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\zombie_kill::damage_amount("not an actor") == -1,
        "A string cannot be read as a native zombie struct");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\zombie_kill::damage_amount([]) == -1,
        "An array cannot be read as a native zombie struct");

    result = scripts\apparition\maps\spaceland\zombie_kill::inspect("not a state", []);
    tests\support\checks::expect(result.reason != "" && result.targets.size == 0,
        "A string cannot be read as a native level-state struct");
    result = scripts\apparition\maps\spaceland\zombie_kill::inspect([], []);
    tests\support\checks::expect(result.reason != "" && result.targets.size == 0,
        "An array cannot be read as a native level-state struct");
}

malformed_native_tables_fail_closed_without_mutation()
{
    result = scripts\apparition\maps\spaceland\zombie_kill::inspect(undefined, []);
    tests\support\checks::expect(result.reason != "" && result.targets.size == 0,
        "A missing native state cannot produce eligible actors");

    state = tests\fixtures\spaceland::wave();
    enemy = tests\fixtures\spaceland::wave_enemy(state);
    original_health = enemy.health;
    original_origin = enemy.origin;
    state.agent_funcs["generic_zombie"]["on_killed"] = scripts\cp\maps\cp_zmb\cp_zmb_dj::blank;
    result = scripts\apparition\maps\spaceland\zombie_kill::inspect(state, state.spawned_enemies);
    tests\support\checks::expect(result.reason != "" && result.targets.size == 0,
        "Unknown generic-zombie death callbacks keep the snapshot unavailable");
    tests\support\checks::expect(enemy.health == original_health && enemy.origin == original_origin,
        "Callback validation leaves native actor fields untouched");

    state = tests\fixtures\spaceland::wave();
    enemy = tests\fixtures\spaceland::wave_enemy(state);
    result = scripts\apparition\maps\spaceland\zombie_kill::inspect(state, "not an array");
    tests\support\checks::expect(result.reason != "" && result.targets.size == 0,
        "A malformed actor snapshot cannot be interpreted as an empty valid roster");

    state = tests\fixtures\spaceland::wave();
    enemy = tests\fixtures\spaceland::wave_enemy(state);
    state.agent_funcs["generic_zombie"] = "not an array";
    result = scripts\apparition\maps\spaceland\zombie_kill::inspect(state, state.spawned_enemies);
    tests\support\checks::expect(result.reason != "" && result.targets.size == 0,
        "A malformed native callback table cannot authorize a Death request");
}

live_probe_and_request_guards_reject_missing_actors_and_modes()
{
    result = scripts\apparition\maps\spaceland\zombie_kill::probe(undefined);
    tests\support\checks::expect(result.reason != "" && result.targets.size == 0,
        "A missing host reference rejects before native entity or damage calls");
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\zombie_kill::request(undefined, "Death"),
        "A valid Death mode still rejects when no authorized host actor exists");
}

repeated_native_roster_entries_produce_one_request_target()
{
    state = tests\fixtures\spaceland::wave();
    enemy = tests\fixtures\spaceland::wave_enemy(state);
    result = scripts\apparition\maps\spaceland\zombie_kill::inspect(state, [enemy, enemy]);
    tests\support\checks::expect(result.reason == "" && result.targets.size == 1 && result.targets[0] == enemy,
        "A duplicated native roster reference cannot produce two requests for the same actor on one pass");
}
