// Pure ownership and roster checks do not alter any native enemy

run()
{
    one_current_record_defines_the_configuration();
    native_roster_readiness_requires_axis_and_an_array();
    invalid_actors_cannot_probe_or_toggle_global_state();
}

one_current_record_defines_the_configuration()
{
    state = spawnstruct();
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\zombie_visibility::configured(undefined)
        && !scripts\apparition\maps\spaceland\zombie_visibility::configured(state),
        "An absent record leaves invisibility unconfigured");
    record = spawnstruct();
    state.apparition_zombie_visibility = record;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\zombie_visibility::configured(state)
        && scripts\apparition\maps\spaceland\zombie_visibility::owns(state, record),
        "One exact record owns the global configuration");
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\zombie_visibility::owns(state, spawnstruct())
        && !scripts\apparition\maps\spaceland\zombie_visibility::owns(state, undefined),
        "A stale or missing record cannot own a replacement worker");
    state.apparition_zombie_visibility = 7;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\zombie_visibility::configured(state),
        "A malformed older setting remains configured so it can be cleared");
}

native_roster_readiness_requires_axis_and_an_array()
{
    state = spawnstruct();
    state.zombie_team = "axis";
    state.agentarray = [];
    tests\support\checks::expect(scripts\apparition\maps\spaceland\zombie_visibility::roster_reason(state) == "",
        "An empty native roster still permits a setting for later spawns");
    foreach (value in [undefined, "allies", "", 1, [], spawnstruct()])
    {
        state.zombie_team = value;
        tests\support\checks::expect(scripts\apparition\maps\spaceland\zombie_visibility::roster_reason(state) != "",
            "Only the established Axis zombie team admits a native query");
    }
    state.zombie_team = "axis";
    foreach (value in [undefined, "agents", 1, spawnstruct()])
    {
        state.agentarray = value;
        tests\support\checks::expect(scripts\apparition\maps\spaceland\zombie_visibility::roster_reason(state) != "",
            "Missing or malformed roster data cannot reach the native team helper");
    }
    tests\support\checks::expect(scripts\apparition\maps\spaceland\zombie_visibility::roster_reason(undefined) != "",
        "Missing state is rejected before native fields are read");
}

invalid_actors_cannot_probe_or_toggle_global_state()
{
    foreach (owner in [undefined, spawnstruct()])
    {
        snapshot = scripts\apparition\maps\spaceland\zombie_visibility::probe(owner);
        tests\support\checks::expect(isDefined(snapshot.reason) && snapshot.reason != "" && !snapshot.configured,
            "Actor admission precedes saved configuration and native enemy queries");
        tests\support\checks::expect(!scripts\apparition\maps\spaceland\zombie_visibility::toggle(owner),
            "A non-player cannot start a visibility worker or request Show");
    }
}
