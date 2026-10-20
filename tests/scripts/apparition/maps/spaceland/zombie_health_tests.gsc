// Custom-health contracts preserve the source range and current team scan

run()
{
    health_values_accept_source_zero_and_signed_integer_maximum();
    health_values_reject_negative_fractional_and_overflow_inputs();
    calculator_caps_do_not_limit_direct_health_assignments();
    configuration_records_have_no_duplicate_enabled_flag();
    current_scan_covers_live_axis_types_and_skips_matching_maximum();
    malformed_inputs_fail_closed_without_publishing_partial_targets();
    probe_rejects_missing_owner_with_typed_fields();
    rejected_requests_preserve_the_current_configuration();
    pending_request_identity_is_read_without_mutation();
    unrelated_disconnect_does_not_retire_host_owned_state();
}

health_values_accept_source_zero_and_signed_integer_maximum()
{
    tests\support\checks::expect(scripts\apparition\maps\spaceland\zombie_health::health_value(0) == 0,
        "Zero is a valid custom health value");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\zombie_health::health_value(2147483647) == 2147483647,
        "The maximum positive signed integer is accepted without overflow");
}

health_values_reject_negative_fractional_and_overflow_inputs()
{
    foreach (invalid in [-1, -2147483648, 1.5, 2147483648, 1e30,
        "-1", "-0", "+1", "01", "1.0", "1x", "0", "2147483647", "2147483648", "-2147483649",
        undefined, [], spawnstruct()])
        tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\zombie_health::health_value(invalid)),
            "Negative, fractional, malformed or out-of-range input is rejected");
}

calculator_caps_do_not_limit_direct_health_assignments()
{
    tests\support\checks::expect(scripts\apparition\maps\spaceland\zombie_health::health_value(6100001) == 6100001,
        "Direct field assignments are not restricted by the separate calculator cap");
}

configuration_records_have_no_duplicate_enabled_flag()
{
    record = scripts\apparition\maps\spaceland\zombie_health::configuration(0);
    state = scripts\apparition\maps\spaceland\zombie_health::record_state(record);
    tests\support\checks::expect(state.reason == "" && state.configured && state.value == 0
        && !isDefined(record.enabled) && !isDefined(record.owner),
        "One value-only record represents configured zero without duplicate state flags");

    missing = scripts\apparition\maps\spaceland\zombie_health::record_state(undefined);
    tests\support\checks::expect(missing.reason == "" && !missing.configured && !isDefined(missing.value),
        "An absent record is the unconfigured state");

    malformed = spawnstruct();
    malformed.value = "100";
    state = scripts\apparition\maps\spaceland\zombie_health::record_state(malformed);
    tests\support\checks::expect(state.reason != "" && !state.configured && !isDefined(state.value),
        "Malformed saved state cannot be published as an active numeric configuration");
}

current_scan_covers_live_axis_types_and_skips_matching_maximum()
{
    state = spawnstruct();
    state.zombie_team = "axis";
    ordinary = agent("generic_zombie", "axis", 80, 100);
    clown = agent("zombie_clown", "axis", 70, 300);
    brute = agent("zombie_brute", "axis", 60, undefined);
    matching = agent("generic_zombie", "axis", 40, 500);
    dead = agent("generic_zombie", "axis", 0, 100);
    other_team = agent("generic_zombie", "allies", 90, 100);
    malformed = agent("generic_zombie", "axis", "90", 100);
    pooled = agent("generic_zombie", "axis", 90, 100);
    pooled.isactive = 0;
    result = scripts\apparition\maps\spaceland\zombie_health::inspect(state,
        [ordinary, clown, brute, matching, dead, other_team, malformed, pooled],
        scripts\apparition\maps\spaceland\zombie_health::configuration(500));
    tests\support\checks::expect(result.reason == "" && result.configured && result.value == 500
        && result.targets.size == 3,
        "The current pass includes live axis agents of different types and actors missing maximum health");
    if (result.targets.size == 3)
        tests\support\checks::expect(result.targets[0] == ordinary && result.targets[1] == clown
            && result.targets[2] == brute,
            "Current targets retain roster order and omit inactive, matching, dead, foreign-team and malformed actors");
}

malformed_inputs_fail_closed_without_publishing_partial_targets()
{
    config = scripts\apparition\maps\spaceland\zombie_health::configuration(50);
    state = spawnstruct();
    state.zombie_team = "axis";
    eligible = agent("generic_zombie", "axis", 10, 20);
    result = scripts\apparition\maps\spaceland\zombie_health::inspect("bad state", [eligible], config);
    tests\support\checks::expect(result.reason != "" && !result.configured && result.targets.size == 0,
        "A malformed state rejects the complete current snapshot");
    result = scripts\apparition\maps\spaceland\zombie_health::inspect(state, "bad agents", config);
    tests\support\checks::expect(result.reason != "" && !result.configured && result.targets.size == 0,
        "A malformed team snapshot cannot publish a valid prefix");
    state.zombie_team = "allies";
    result = scripts\apparition\maps\spaceland\zombie_health::inspect(state, [eligible], config);
    tests\support\checks::expect(result.reason != "" && result.targets.size == 0,
        "A non-axis zombie-team state cannot authorize the source team scan");
}

probe_rejects_missing_owner_with_typed_fields()
{
    result = scripts\apparition\maps\spaceland\zombie_health::probe(undefined);
    tests\support\checks::expect(result.reason == "The current host reference is unavailable"
        && !result.configured && !isDefined(result.value),
        "A denied probe returns its reason and typed empty configuration before native reads");
}

rejected_requests_preserve_the_current_configuration()
{
    previous = level.apparition_zombie_health_config;
    previous_request = level.apparition_zombie_health_request;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\zombie_health::request(undefined, -1)
        && level.apparition_zombie_health_config == previous
        && level.apparition_zombie_health_request == previous_request,
        "Invalid health cannot supersede the active record");
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\zombie_health::request(undefined, 100)
        && level.apparition_zombie_health_config == previous
        && level.apparition_zombie_health_request == previous_request,
        "A missing host cannot clear or replace the active record");
}

unrelated_disconnect_does_not_retire_host_owned_state()
{
    host = spawnstruct();
    guest = spawnstruct();
    config = scripts\apparition\maps\spaceland\zombie_health::configuration(75, host);
    pending_host = scripts\apparition\maps\spaceland\zombie_health::configuration(90, host);
    result = scripts\apparition\maps\spaceland\zombie_health::retire_records(config, pending_host, guest);
    tests\support\checks::expect(result.config == config && result.pending == pending_host,
        "A guest disconnect cannot retire custom health state owned by the host");
    result = scripts\apparition\maps\spaceland\zombie_health::retire_records(config, pending_host, host);
    tests\support\checks::expect(!isDefined(result.config) && !isDefined(result.pending),
        "The requesting host disconnect clears only its matching configuration and pending request");
    result = scripts\apparition\maps\spaceland\zombie_health::retire_records(config, pending_host, undefined);
    tests\support\checks::expect(!isDefined(result.config) && !isDefined(result.pending),
        "Global game-end cleanup retires all feature-owned health state");
}

pending_request_identity_is_read_without_mutation()
{
    current = level.apparition_zombie_health_request;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\zombie_health::is_current_request(undefined),
        "An absent request cannot authorize delayed work");
    if (isDefined(current))
        tests\support\checks::expect(scripts\apparition\maps\spaceland\zombie_health::is_current_request(current),
            "The existing request is compared by identity without changing level state");
}

agent(type, team, health, maximum)
{
    result = spawnstruct();
    result.agent_type = type;
    result.team = team;
    result.isactive = 1;
    result.health = health;
    result.maxhealth = maximum;
    return result;
}
