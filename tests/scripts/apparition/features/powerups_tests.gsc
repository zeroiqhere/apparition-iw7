// Power-up contracts cover saved location intent and guarded native requests

run()
{
    location_choices_are_exact_and_strict();
    configured_location_is_safe_and_read_only();
    invalid_location_and_missing_actor_cannot_write();
    valid_surface_trace_is_accepted_without_mutation();
    malformed_or_unusable_traces_are_rejected();
    probe_rejects_missing_and_nonplayer_actors_before_native_queries();
    request_rejects_unknown_ids_and_invalid_actors();
}

location_choices_are_exact_and_strict()
{
    expected = ["Crosshairs", "Self"];
    actual = scripts\apparition\features\powerups::locations();
    tests\support\checks::expect(isDefined(actual) && isarray(actual)
        && actual.size == expected.size, "Power-up spawn location choices match the original menu");
    if (!isDefined(actual) || !isarray(actual) || actual.size != expected.size)
        return;

    for (index = 0; index < expected.size; index++)
    {
        tests\support\checks::expect(isstring(actual[index]) && actual[index] == expected[index],
            "Spawn locations retain their original names and order");
        tests\support\checks::expect(scripts\apparition\features\powerups::valid_location(actual[index]),
            "Every supported spawn location is accepted");
    }

    tests\support\checks::expect(!scripts\apparition\features\powerups::valid_location(undefined),
        "An undefined spawn location is rejected");
    tests\support\checks::expect(!scripts\apparition\features\powerups::valid_location(0),
        "A numeric spawn location is rejected");
    tests\support\checks::expect(!scripts\apparition\features\powerups::valid_location("self"),
        "A differently cased spawn location is rejected");
    tests\support\checks::expect(!scripts\apparition\features\powerups::valid_location("Anywhere"),
        "An unsupported spawn location is rejected");
}

configured_location_is_safe_and_read_only()
{
    tests\support\checks::expect(scripts\apparition\features\powerups::configured_location(undefined)
        == "Crosshairs", "A missing player uses the original default location");

    player = spawnstruct();
    player.unrelated_value = "preserved";
    tests\support\checks::expect(scripts\apparition\features\powerups::configured_location(player)
        == "Crosshairs", "An unset location uses the original default");
    player.PowerUpSpawnLocation = "Crosshairs";
    tests\support\checks::expect(scripts\apparition\features\powerups::configured_location(player)
        == "Crosshairs", "An explicit Crosshairs setting is preserved");
    player.PowerUpSpawnLocation = "Self";
    tests\support\checks::expect(scripts\apparition\features\powerups::configured_location(player)
        == "Self", "An explicit Self setting is preserved");
    player.PowerUpSpawnLocation = "invalid";
    tests\support\checks::expect(scripts\apparition\features\powerups::configured_location(player)
        == "Crosshairs", "An unsupported saved value falls back to the original default");
    player.PowerUpSpawnLocation = 1;
    tests\support\checks::expect(scripts\apparition\features\powerups::configured_location(player)
        == "Crosshairs", "A numeric saved value falls back to the original default");
    tests\support\checks::expect(player.PowerUpSpawnLocation == 1
        && player.unrelated_value == "preserved", "Reading saved location intent changes no player fields");
}

invalid_location_and_missing_actor_cannot_write()
{
    player = spawnstruct();
    player.PowerUpSpawnLocation = "Self";
    player.unrelated_value = 27;
    tests\support\checks::expect(!scripts\apparition\features\powerups::set_location(player, "invalid"),
        "An unsupported location cannot be saved");
    tests\support\checks::expect(!scripts\apparition\features\powerups::set_location(undefined, "Self"),
        "A missing player cannot save a location");
    tests\support\checks::expect(player.PowerUpSpawnLocation == "Self"
        && player.unrelated_value == 27, "Rejected location changes preserve all existing fields");
}

valid_surface_trace_is_accepted_without_mutation()
{
    trace = [];
    trace["position"] = (100, 200, 300);
    trace["surfacetype"] = "concrete";
    tests\support\checks::expect(scripts\apparition\features\powerups::trace_reason(trace) == "",
        "A positioned trace on a real surface is usable");
    tests\support\checks::expect(trace["position"] == (100, 200, 300)
        && trace["surfacetype"] == "concrete", "Trace validation leaves native trace data unchanged");
}

malformed_or_unusable_traces_are_rejected()
{
    tests\support\checks::expect(scripts\apparition\features\powerups::trace_reason(undefined) != "",
        "A missing trace is unusable");
    tests\support\checks::expect(scripts\apparition\features\powerups::trace_reason("trace") != "",
        "A non-array trace is unusable");

    trace = [];
    tests\support\checks::expect(scripts\apparition\features\powerups::trace_reason(trace) != "",
        "A trace without a position or surface is unusable");

    trace["position"] = "not a vector";
    trace["surfacetype"] = "concrete";
    tests\support\checks::expect(scripts\apparition\features\powerups::trace_reason(trace) != "",
        "A trace with a malformed position is unusable");

    trace["position"] = (1, 2, 3);
    trace["surfacetype"] = "none";
    tests\support\checks::expect(scripts\apparition\features\powerups::trace_reason(trace) != "",
        "A trace that misses a surface is unusable");
    trace["surfacetype"] = "default";
    tests\support\checks::expect(scripts\apparition\features\powerups::trace_reason(trace) != "",
        "A default surface result is unusable");
    trace["surfacetype"] = "surftype_none";
    tests\support\checks::expect(scripts\apparition\features\powerups::trace_reason(trace) != "",
        "The native no-surface alias is unusable");
    trace["surfacetype"] = "surftype_default";
    tests\support\checks::expect(scripts\apparition\features\powerups::trace_reason(trace) != "",
        "The native default-surface alias is unusable");
    trace["surfacetype"] = "";
    tests\support\checks::expect(scripts\apparition\features\powerups::trace_reason(trace) != "",
        "An empty surface result is unusable");
}

probe_rejects_missing_and_nonplayer_actors_before_native_queries()
{
    result = scripts\apparition\features\powerups::probe(undefined);
    tests\support\checks::expect(isDefined(result) && isstruct(result)
        && isDefined(result.reason) && result.reason != "",
        "A missing player receives a blocked power-up probe");
    tests\support\checks::expect(isDefined(result.actor_reason) && result.actor_reason != "",
        "A missing player keeps its actor admission reason separate");
    tests\support\checks::expect(!isDefined(result.origin),
        "A blocked probe does not expose a spawn origin");

    player = spawnstruct();
    player.PowerUpSpawnLocation = "Self";
    player.unrelated_value = "preserved";
    result = scripts\apparition\features\powerups::probe(player);
    tests\support\checks::expect(isDefined(result.actor_reason) && result.actor_reason != "",
        "A nonplayer value is rejected before native actor queries");
    tests\support\checks::expect(!isDefined(result.origin),
        "A nonplayer value cannot produce a spawn origin");
    tests\support\checks::expect(player.PowerUpSpawnLocation == "Self"
        && player.unrelated_value == "preserved", "A rejected probe leaves its input unchanged");
}

request_rejects_unknown_ids_and_invalid_actors()
{
    tests\support\checks::expect(!scripts\apparition\features\powerups::request(undefined, "not_supported"),
        "An unknown power-up ID is rejected");
    tests\support\checks::expect(!scripts\apparition\features\powerups::request(undefined, undefined),
        "An undefined power-up ID is rejected");

    entries = scripts\apparition\maps\spaceland\powerups::catalog();
    if (!isDefined(entries) || !isarray(entries) || !entries.size)
        return;
    player = spawnstruct();
    player.unrelated_value = "preserved";
    tests\support\checks::expect(!scripts\apparition\features\powerups::request(player, entries[0].id),
        "A nonplayer actor cannot reach the native loot drop");
    tests\support\checks::expect(player.unrelated_value == "preserved",
        "A rejected request does not change actor fields");
}
