// Set Vision contracts keep the source catalog separate from IW7 profile support

run()
{
    source_vision_choices_keep_the_exact_ten_values_and_order();
    default_restores_the_current_string_override_or_an_empty_profile();
    only_the_two_verified_profiles_are_supported_source_choices();
    known_other_source_choices_remain_blocked_without_profiles();
    unknown_undefined_and_nonstring_choices_are_rejected();
    active_native_phases_and_malformed_overrides_block_set_vision();
    undefined_phase_fields_and_string_overrides_are_allowed();
    a_missing_or_fixture_owner_is_rejected_before_native_probe_reads();
    rejected_requests_do_not_reach_a_native_player_action();
}

source_vision_choices_keep_the_exact_ten_values_and_order()
{
    expected = ["Default", "zombie_last_stand", "zombie_death", "flashbang",
        "zm_bgb_candy_bluez", "zm_bgb_candy_greenz", "zm_bgb_candy_purplez",
        "zm_bgb_candy_yellowz", "zm_bgb_now_you_see_me", "zombie_noire"];
    actual = scripts\apparition\features\vision::values();
    tests\support\checks::expect(isDefined(actual) && isarray(actual)
        && actual.size == expected.size,
        "Set Vision retains the ten source choices");
    if (!isDefined(actual) || !isarray(actual) || actual.size != expected.size)
        return;

    for (index = 0; index < expected.size; index++)
    {
        tests\support\checks::expect(isstring(actual[index]) && actual[index] == expected[index],
            "Set Vision preserves each source choice and its order");
    }
}

default_restores_the_current_string_override_or_an_empty_profile()
{
    current_override = "cp_zmb_alien";
    selected = scripts\apparition\features\vision::choice("Default", current_override);
    tests\support\checks::expect(isDefined(selected) && isstruct(selected)
        && isDefined(selected.reason) && isstring(selected.reason) && selected.reason == ""
        && isDefined(selected.profile) && isstring(selected.profile)
        && selected.profile == current_override,
        "Default resolves to the current string override without changing it");

    selected = scripts\apparition\features\vision::choice("Default", undefined);
    tests\support\checks::expect(isDefined(selected) && isstruct(selected)
        && isDefined(selected.profile) && isstring(selected.profile)
        && selected.profile == "",
        "Default resolves to an empty profile when no string override is available");

    selected = scripts\apparition\features\vision::choice("Default", 17);
    tests\support\checks::expect(isDefined(selected) && isstruct(selected)
        && isDefined(selected.profile) && isstring(selected.profile)
        && selected.profile == "",
        "A malformed current override falls back to the empty profile");
}

only_the_two_verified_profiles_are_supported_source_choices()
{
    last_stand = scripts\apparition\features\vision::choice("zombie_last_stand", "");
    tests\support\checks::expect(isDefined(last_stand) && isstruct(last_stand)
        && isDefined(last_stand.reason) && isstring(last_stand.reason) && last_stand.reason == ""
        && isDefined(last_stand.profile) && isstring(last_stand.profile)
        && last_stand.profile == "last_stand_cp_zmb",
        "The source Last Stand vision maps to the verified IW7 equivalent");

    noire = scripts\apparition\features\vision::choice("zombie_noire", "");
    tests\support\checks::expect(isDefined(noire) && isstruct(noire)
        && isDefined(noire.reason) && isstring(noire.reason) && noire.reason == ""
        && isDefined(noire.profile) && isstring(noire.profile)
        && noire.profile == "cp_zmb_bw",
        "The source noire vision maps to the verified IW7 black-and-white analogue");
}

known_other_source_choices_remain_blocked_without_profiles()
{
    unsupported = ["zombie_death", "flashbang", "zm_bgb_candy_bluez",
        "zm_bgb_candy_greenz", "zm_bgb_candy_purplez", "zm_bgb_candy_yellowz",
        "zm_bgb_now_you_see_me"];
    tests\support\checks::expect(unsupported.size == 7,
        "Seven original vision choices remain explicitly unsupported in IW7");
    foreach (value in unsupported)
    {
        selected = scripts\apparition\features\vision::choice(value, "");
        tests\support\checks::expect(choice_is_blocked_without_profile(selected),
            "A known BO3-only vision choice has a reason and no IW7 profile");
    }
}

unknown_undefined_and_nonstring_choices_are_rejected()
{
    unknown = scripts\apparition\features\vision::choice("not_a_source_vision", "");
    tests\support\checks::expect(choice_is_blocked_without_profile(unknown),
        "An unknown vision name is rejected without an IW7 profile");

    missing = scripts\apparition\features\vision::choice(undefined, "");
    tests\support\checks::expect(choice_is_blocked_without_profile(missing),
        "An undefined vision choice is rejected without an IW7 profile");

    foreach (invalid in [17, true, [], spawnstruct(), (1, 2, 3)])
    {
        selected = scripts\apparition\features\vision::choice(invalid, "");
        tests\support\checks::expect(choice_is_blocked_without_profile(selected),
            "A scalar, array, struct, or vector vision choice is rejected");
    }
}

active_native_phases_and_malformed_overrides_block_set_vision()
{
    tests\support\checks::expect(scripts\apparition\features\vision::phase_reason(1,
        undefined, undefined, undefined, undefined, undefined) != "",
        "Last Stand blocks a Set Vision change");
    tests\support\checks::expect(scripts\apparition\features\vision::phase_reason(undefined,
        1, undefined, undefined, undefined, undefined) != "",
        "Afterlife blocks a Set Vision change");
    tests\support\checks::expect(scripts\apparition\features\vision::phase_reason(undefined,
        undefined, 1, undefined, undefined, undefined) != "",
        "The native Ghosts N Skulls phase blocks a Set Vision change");
    tests\support\checks::expect(scripts\apparition\features\vision::phase_reason(undefined,
        undefined, undefined, 1, undefined, undefined) != "",
        "A player's active Ghosts N Skulls phase blocks a Set Vision change");
    tests\support\checks::expect(scripts\apparition\features\vision::phase_reason(undefined,
        undefined, undefined, undefined, 1, undefined) != "",
        "Native glasses state blocks a Set Vision change");

    foreach (invalid_override in [17, true, [], spawnstruct()])
    {
        tests\support\checks::expect(scripts\apparition\features\vision::phase_reason(undefined,
            undefined, undefined, undefined, undefined, invalid_override) != "",
            "A defined nonstring vision override blocks a Set Vision change");
    }
}

undefined_phase_fields_and_string_overrides_are_allowed()
{
    tests\support\checks::expect(scripts\apparition\features\vision::phase_reason(undefined,
        undefined, undefined, undefined, undefined, undefined) == "",
        "Unavailable phase flags and an absent override do not block Set Vision");
    tests\support\checks::expect(scripts\apparition\features\vision::phase_reason(0,
        0, 0, 0, 0, "") == "",
        "Cleared phase flags and a string override allow Set Vision");
}

a_missing_or_fixture_owner_is_rejected_before_native_probe_reads()
{
    target = spawnstruct();
    target.sentinel = "preserved";

    result = scripts\apparition\features\vision::probe(undefined, target);
    tests\support\checks::expect(probe_has_rejection_reason(result),
        "An undefined owner is rejected before native player or level reads");

    foreach (invalid_owner in [17, "owner", false, [], spawnstruct()])
    {
        result = scripts\apparition\features\vision::probe(invalid_owner, target);
        tests\support\checks::expect(probe_has_rejection_reason(result),
            "A nonplayer owner is rejected before native player or level reads");
    }
    tests\support\checks::expect(target.sentinel == "preserved",
        "Rejected owner probes leave fixture target data unchanged");
}

rejected_requests_do_not_reach_a_native_player_action()
{
    // Real admission rejects these fixtures before any native state is accessed
    foreach (value in ["Default", "zombie_last_stand", "zombie_noire", "flashbang", undefined, 17])
    {
        tests\support\checks::expect(!scripts\apparition\features\vision::request(undefined,
            spawnstruct(), value),
            "A rejected owner cannot submit a native vision change for any selector");
    }
}

choice_is_blocked_without_profile(selected)
{
    if (!isDefined(selected) || !isstruct(selected)
        || !isDefined(selected.reason) || !isstring(selected.reason) || selected.reason == "")
        return false;
    return !isDefined(selected.profile)
        || (isstring(selected.profile) && selected.profile == "");
}

probe_has_rejection_reason(result)
{
    return isDefined(result) && isstruct(result)
        && isDefined(result.reason) && isstring(result.reason) && result.reason != "";
}
