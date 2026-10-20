// Power contracts cover source metadata without simulating native actors

run()
{
    valid_generator_snapshots_preserve_native_order_and_counts();
    powered_generators_do_not_require_unused_target_assets();
    malformed_pending_points_never_publish_a_partial_snapshot();
    sparse_duplicate_and_invalid_generator_lists_fail_closed();
    native_generator_registration_must_match_the_zero_cost_callback();
    pending_points_must_be_current_and_unblocked();
    live_probe_rejects_missing_and_nonplayer_owners_before_native_reads();
}

valid_generator_snapshots_preserve_native_order_and_counts()
{
    first = generator("one", 0);
    second = generator("two", 1);
    third = generator("three", 0);
    state = power_state([first, second, third]);

    result = scripts\apparition\maps\spaceland\power::inspect(state);
    tests\support\checks::expect(result.reason == "" && result.total == 3 && result.powered == 1
        && result.targets.size == 2,
        "A complete registry reports native counts and only pending generators");
    if (result.targets.size == 2)
        tests\support\checks::expect(result.targets[0] == first && result.targets[1] == third,
            "Remote requests retain native generator order and exact point identity");
}

powered_generators_do_not_require_unused_target_assets()
{
    point = generator("already_on", 1);
    point.target = undefined;
    point.script_parameters = undefined;
    point.handle = undefined;
    point._id_2F12 = undefined;
    state = power_state([point]);

    result = scripts\apparition\maps\spaceland\power::inspect(state);
    tests\support\checks::expect(result.reason == "All native generators are powered"
        && result.total == 1 && result.powered == 1 && result.targets.size == 0,
        "A fully powered registry needs no handles or callback readiness");

    state.interactions = undefined;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\power::inspect(state).reason
        == "All native generators are powered",
        "A completed native snapshot remains readable after callback metadata is gone");
}

malformed_pending_points_never_publish_a_partial_snapshot()
{
    good = generator("good", 0);
    bad = generator("bad", 0);
    bad.script_parameters = "";
    result = scripts\apparition\maps\spaceland\power::inspect(power_state([good, bad]));
    expect_invalid_snapshot(result, "A malformed later generator cannot expose an earlier valid target");

    state = power_state([generator("missing_target", 0)]);
    state.generators[0].target = undefined;
    expect_invalid_snapshot(scripts\apparition\maps\spaceland\power::inspect(state),
        "An unpowered generator without its native target is unavailable");

    state = power_state([generator("missing_handle", 0)]);
    state.generators[0].handle = undefined;
    expect_invalid_snapshot(scripts\apparition\maps\spaceland\power::inspect(state),
        "An unpowered generator without its initialized handle is unavailable");

    state = power_state([generator("invalid_power", 0)]);
    state.generators[0].powered_on = "yes";
    expect_invalid_snapshot(scripts\apparition\maps\spaceland\power::inspect(state),
        "A nonnumeric native power field cannot be interpreted as an activation state");
}

sparse_duplicate_and_invalid_generator_lists_fail_closed()
{
    point = generator("sparse", 0);
    sparse = [];
    sparse[1] = point;
    expect_invalid_snapshot(scripts\apparition\maps\spaceland\power::inspect(power_state(sparse)),
        "A sparse generator registry cannot silently change native order");

    point = generator("duplicate", 0);
    expect_invalid_snapshot(scripts\apparition\maps\spaceland\power::inspect(power_state([point, point])),
        "A duplicated native point cannot produce two activation requests");

    expect_invalid_snapshot(scripts\apparition\maps\spaceland\power::inspect(power_state([7])),
        "A scalar registry entry cannot be read as a generator struct");

    point = generator("wrong_kind", 0);
    point.script_noteworthy = "perk_machine_revive";
    expect_invalid_snapshot(scripts\apparition\maps\spaceland\power::inspect(power_state([point])),
        "A point from another interaction type cannot enter the power list");

    expect_invalid_snapshot(scripts\apparition\maps\spaceland\power::inspect(power_state([])),
        "An empty early registry is not reported as a successful power state");
}

native_generator_registration_must_match_the_zero_cost_callback()
{
    state = power_state([generator("pending", 0)]);
    tests\support\checks::expect(scripts\apparition\maps\spaceland\power::registration_reason(state) == "",
        "The native enabled zero-cost generator registration is accepted");

    entry = state.interactions["generator"];
    entry.name = "different";
    tests\support\checks::expect(scripts\apparition\maps\spaceland\power::registration_reason(state) != "",
        "A renamed registration cannot receive the generator callback");
    entry.name = "generator";
    entry.enabled = 0;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\power::registration_reason(state) != "",
        "A disabled native registration is not dispatched");
    entry.enabled = 1;
    entry.spend_type = "quest";
    tests\support\checks::expect(scripts\apparition\maps\spaceland\power::registration_reason(state) != "",
        "A changed spend type cannot pass the zero-cost wrapper");
    entry.spend_type = "generator";
    entry.cost = 1;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\power::registration_reason(state) != "",
        "A changed price cannot pass through a zero-cost request");
    entry.cost = 0;
    entry.requires_power = 1;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\power::registration_reason(state) != "",
        "An unexpected power prerequisite disables remote activation");
    entry.requires_power = 0;
    entry.activation_func = scripts\cp\maps\cp_zmb\cp_zmb_dj::blank;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\power::registration_reason(state) != "",
        "A foreign callback is never invoked or overwritten");
    entry.activation_func = scripts\cp\zombies\zombie_power::generic_generator;
    entry.can_use_override_func = scripts\cp\maps\cp_zmb\cp_zmb_dj::blank;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\power::registration_reason(state) != "",
        "An unexpected custom admission callback makes the interaction unavailable");

    state.interactions["generator"] = 7;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\power::registration_reason(state) != "",
        "A scalar registration cannot be read as native callback metadata");
}

pending_points_must_be_current_and_unblocked()
{
    point = generator("current", 0);
    state = power_state([point]);
    tests\support\checks::expect(scripts\apparition\maps\spaceland\power::point_reason(state, point) == "",
        "An unblocked point in the native current interaction list is eligible");

    point.in_use = 0;
    point.out_of_order = 0;
    point.disabled = 0;
    point.requires_power = 0;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\power::point_reason(state, point) == "",
        "Zero-valued native blockers do not hide an available generator");
    point.in_use = undefined;
    point.out_of_order = undefined;
    point.disabled = undefined;
    point.requires_power = undefined;

    state.current_interaction_structs = [];
    tests\support\checks::expect(scripts\apparition\maps\spaceland\power::point_reason(state, point) != "",
        "A point removed from the native active list is not dispatched");
    state.current_interaction_structs = [point];

    point.triggered = 0;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\power::point_reason(state, point) != "",
        "Any native trigger reservation blocks a second activation");
    point.triggered = undefined;
    point.in_use = 1;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\power::point_reason(state, point) != "",
        "A native in-use point is not dispatched");
    point.in_use = undefined;
    point.out_of_order = 1;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\power::point_reason(state, point) != "",
        "A native cooldown point is not dispatched");
    point.out_of_order = undefined;
    point.cooling_down = 0;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\power::point_reason(state, point) != "",
        "A defined native cooling marker blocks a point");
    point.cooling_down = undefined;
    point.disabled = 1;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\power::point_reason(state, point) != "",
        "A disabled native point cannot be remotely activated");
    point.disabled = undefined;
    point.requires_power = 1;
    point.powered_on = 0;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\power::point_reason(state, point) != "",
        "An unmet native power requirement blocks an unpowered interaction");
}

live_probe_rejects_missing_and_nonplayer_owners_before_native_reads()
{
    missing = scripts\apparition\maps\spaceland\power::probe(undefined);
    tests\support\checks::expect(isDefined(missing.reason) && missing.reason != ""
        && missing.total == 0 && missing.targets.size == 0,
        "A missing owner is rejected before native generator or player reads");

    nonplayer = scripts\apparition\maps\spaceland\power::probe(spawnstruct());
    tests\support\checks::expect(isDefined(nonplayer.reason) && nonplayer.reason != ""
        && nonplayer.total == 0 && nonplayer.targets.size == 0,
        "A nonplayer cannot reach native generator or host methods");
}

power_state(generators)
{
    state = spawnstruct();
    state.generators = generators;
    state.interactions = [];
    state.interactions["generator"] = registration();
    state.current_interaction_structs = generators;
    return state;
}

generator(name, powered)
{
    point = spawnstruct();
    point.script_noteworthy = "generator";
    point.powered_on = powered;
    point.target = "generator_target_" + name;
    point.script_parameters = "hidden_room,moon,front_gate,underground_route";
    point.handle = spawnstruct();
    point.handle.model = "icbm_electricpanel_switch_02";
    point.handle.script_noteworthy = "pitch";
    return point;
}

registration()
{
    entry = spawnstruct();
    entry.name = "generator";
    entry.spend_type = "generator";
    entry.enabled = 1;
    entry.cost = 0;
    entry.requires_power = 0;
    entry.activation_func = scripts\cp\zombies\zombie_power::generic_generator;
    entry.can_use_override_func = undefined;
    return entry;
}

expect_invalid_snapshot(result, message)
{
    tests\support\checks::expect(result.reason != "" && result.total == 0
        && result.powered == 0 && result.targets.size == 0, message);
}
