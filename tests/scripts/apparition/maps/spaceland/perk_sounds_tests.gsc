// Perk sound aliases follow the native Spaceland machine catalog

run()
{
    native_aliases_match_the_ten_supported_perks();
    revive_quote_tracks_solo_and_coop_voice_prefixes();
    malformed_solo_inputs_keep_the_jingle_without_a_quote();
    non_revive_quotes_ignore_malformed_solo_input();
    missing_voice_prefix_keeps_jingles_without_inventing_quotes();
    malformed_voice_prefix_keeps_jingle_without_quote();
    native_registry_emits_one_row_per_id_in_catalog_order();
    missing_and_empty_perk_groups_are_omitted();
    malformed_late_groups_do_not_publish_a_partial_snapshot();
    empty_native_registry_is_a_valid_empty_snapshot();
    unsupported_perk_ids_have_no_alias_mapping();
}

native_aliases_match_the_ten_supported_perks()
{
    perks = scripts\apparition\maps\spaceland\perks::catalog();
    expected = [
        ["mus_zmb_upnatoms_purchase", "purchase_perk_upnatoms"],
        ["mus_zmb_tuffnuff_purchase", "purchase_perk_tuffnuff"],
        ["mus_zmb_bangbangs_purchase", "purchase_perk_bangbangs"],
        ["mus_zmb_quickies_purchase", "purchase_perk_quickies"],
        ["mus_zmb_racinstripes_purchase", "purchase_perk_racinstripes"],
        ["mus_zmb_bombstoppers_purchase", "purchase_perk_bombstoppers"],
        ["mus_zmb_mulemunchies_purchase", "purchase_perk_nulemunchies"],
        ["mus_zmb_bluebolts_purchase", "purchase_perk_bluebolts"],
        ["mus_zmb_trailblazer_purchase", "purchase_perk_trailblazers"],
        ["mus_zmb_slappytaffy_purchase", "purchase_perk_slappytaffy"]
    ];

    tests\support\checks::expect(perks.size == expected.size, "The shared Spaceland catalog contains exactly the ten mapped native perks");
    for (index = 0; index < expected.size; index++)
    {
        sound = scripts\apparition\maps\spaceland\perk_sounds::aliases(perks[index].id, false, "p2_");
        tests\support\checks::expect(isDefined(sound)
            && sound.jingle == expected[index][0]
            && sound.quote == "p2_" + expected[index][1],
            "Each canonical perk ID maps to its native jingle and prefixed quote alias");
    }
}

revive_quote_tracks_solo_and_coop_voice_prefixes()
{
    solo = scripts\apparition\maps\spaceland\perk_sounds::aliases("perk_machine_revive", true, "p1_");
    coop = scripts\apparition\maps\spaceland\perk_sounds::aliases("perk_machine_revive", false, "p1_");
    tests\support\checks::expect(solo.jingle == "mus_zmb_upnatoms_purchase"
        && solo.quote == "p1_purchase_perk_revive_solo",
        "Solo revive uses the native solo quote and leaves the jingle unchanged");
    tests\support\checks::expect(coop.jingle == "mus_zmb_upnatoms_purchase"
        && coop.quote == "p1_purchase_perk_upnatoms",
        "Co-op revive uses the native team quote and the same character prefix");
}

malformed_solo_inputs_keep_the_jingle_without_a_quote()
{
    expect_missing_solo_quote(undefined);
    invalid_solo_inputs = [2, -1, "solo", []];
    foreach (solo in invalid_solo_inputs)
        expect_missing_solo_quote(solo);
    expect_missing_solo_quote(spawnstruct());
}

expect_missing_solo_quote(solo)
{
    sound = scripts\apparition\maps\spaceland\perk_sounds::aliases("perk_machine_revive", solo, "p1_");
    tests\support\checks::expect(isDefined(sound)
        && sound.jingle == "mus_zmb_upnatoms_purchase"
        && !isDefined(sound.quote),
        "Missing or malformed solo input keeps the native jingle and leaves the quote unavailable");
}

non_revive_quotes_ignore_malformed_solo_input()
{
    sound = scripts\apparition\maps\spaceland\perk_sounds::aliases("perk_machine_tough", spawnstruct(), "p1_");
    tests\support\checks::expect(isDefined(sound)
        && sound.jingle == "mus_zmb_tuffnuff_purchase"
        && sound.quote == "p1_purchase_perk_tuffnuff",
        "Perk aliases unrelated to solo retain their native quote with malformed solo input");
}

missing_voice_prefix_keeps_jingles_without_inventing_quotes()
{
    perks = scripts\apparition\maps\spaceland\perks::catalog();
    expect_missing_quote(perks[1].id, "");
    expect_missing_quote(perks[1].id, undefined);

    snapshot = scripts\apparition\maps\spaceland\perk_sounds::inspect(native_state(), false, undefined);
    tests\support\checks::expect(snapshot.reason == "" && snapshot.entries.size == 10,
        "A complete native machine registry remains inspectable without a voice prefix");
    tests\support\checks::expect(!isDefined(snapshot.entries[0].quote)
        && snapshot.entries[0].jingle == "mus_zmb_upnatoms_purchase",
        "Snapshot rows do not invent character-specific quote aliases");
}

malformed_voice_prefix_keeps_jingle_without_quote()
{
    invalid_prefixes = [1, [], spawnstruct()];
    foreach (prefix in invalid_prefixes)
        expect_missing_quote("perk_machine_tough", prefix);
}

expect_missing_quote(id, prefix)
{
    sound = scripts\apparition\maps\spaceland\perk_sounds::aliases(id, false, prefix);
    tests\support\checks::expect(isDefined(sound)
        && sound.jingle == "mus_zmb_tuffnuff_purchase"
        && !isDefined(sound.quote),
        "Missing or malformed voice prefix keeps the jingle without guessing a quote");
}

native_registry_emits_one_row_per_id_in_catalog_order()
{
    state = native_state();
    perks = scripts\apparition\maps\spaceland\perks::catalog();
    first = state.struct_class_names["script_noteworthy"][perks[0].id][0];
    duplicate = native_machine(perks[0].id);
    state.struct_class_names["script_noteworthy"][perks[0].id] = [duplicate, first];
    snapshot = scripts\apparition\maps\spaceland\perk_sounds::inspect(state, false, "p4_");

    tests\support\checks::expect(snapshot.reason == "" && snapshot.entries.size == perks.size,
        "Multiple placed machines of one perk produce one canonical sound row");
    for (index = 0; index < perks.size; index++)
    {
        tests\support\checks::expect(snapshot.entries[index].id == perks[index].id
            && snapshot.entries[index].label == perks[index].label,
            "Rows keep the shared perk catalog ID, label, and order");
        tests\support\checks::expect(!isDefined(snapshot.entries[index].point)
            && !isDefined(snapshot.entries[index].native_machine),
            "Snapshots retain no native machine reference");
    }
    tests\support\checks::expect(snapshot.entries[0].jingle == "mus_zmb_upnatoms_purchase"
        && snapshot.entries[0].quote == "p4_purchase_perk_upnatoms",
        "Snapshot rows carry the source-backed sound pair without retaining the machine");
}

missing_and_empty_perk_groups_are_omitted()
{
    state = native_state();
    perks = scripts\apparition\maps\spaceland\perks::catalog();
    state.struct_class_names["script_noteworthy"][perks[2].id] = undefined;
    state.struct_class_names["script_noteworthy"][perks[4].id] = [];
    snapshot = scripts\apparition\maps\spaceland\perk_sounds::inspect(state, false, "p3_");

    tests\support\checks::expect(snapshot.reason == "" && snapshot.entries.size == perks.size - 2,
        "Absent or empty native groups are omitted without invalidating other registered perks");
    foreach (entry in snapshot.entries)
        tests\support\checks::expect(entry.id != perks[2].id && entry.id != perks[4].id,
            "No row is emitted for a perk with no native machine group");
}

malformed_late_groups_do_not_publish_a_partial_snapshot()
{
    state = native_state();
    perks = scripts\apparition\maps\spaceland\perks::catalog();
    state.struct_class_names["script_noteworthy"][perks[9].id] = 7;
    expect_unavailable(state, "A non-array native perk group makes the full snapshot unavailable");

    state = native_state();
    malformed = [];
    malformed[0] = native_machine(perks[9].id);
    malformed[2] = native_machine(perks[9].id);
    state.struct_class_names["script_noteworthy"][perks[9].id] = malformed;
    expect_unavailable(state, "A sparse late group cannot publish earlier valid rows");

    state = native_state();
    state.struct_class_names["script_noteworthy"][perks[9].id] = [undefined];
    expect_unavailable(state, "An undefined native registry entry invalidates the whole snapshot");

    foreach (bad in [7, "machine", spawnstruct()])
    {
        state = native_state();
        state.struct_class_names["script_noteworthy"][perks[9].id] = [bad];
        expect_unavailable(state, "A malformed native registry entry invalidates the whole snapshot");
    }

    state = native_state();
    wrong = native_machine(perks[8].id);
    state.struct_class_names["script_noteworthy"][perks[9].id] = [wrong];
    expect_unavailable(state, "A group entry whose native ID changed cannot be classified under its old key");

    wrong_type = spawnstruct();
    wrong_type.script_noteworthy = 7;
    state = native_state();
    state.struct_class_names["script_noteworthy"][perks[9].id] = [wrong_type];
    expect_unavailable(state, "A non-string native entry ID invalidates the whole snapshot");

    expect_unavailable(undefined, "A missing native registry root reports no partial rows");
    state = spawnstruct();
    expect_unavailable(state, "A root without struct_class_names reports no partial rows");

    state = spawnstruct();
    state.struct_class_names = [];
    expect_unavailable(state, "A root without script_noteworthy reports no partial rows");

    state.struct_class_names["script_noteworthy"] = 7;
    expect_unavailable(state, "A non-array script_noteworthy registry reports no partial rows");

    state = spawnstruct();
    state.struct_class_names = 7;
    expect_unavailable(state, "A malformed native registry root reports no partial rows");
}

empty_native_registry_is_a_valid_empty_snapshot()
{
    state = spawnstruct();
    state.struct_class_names = [];
    state.struct_class_names["script_noteworthy"] = [];
    snapshot = scripts\apparition\maps\spaceland\perk_sounds::inspect(state, false, "p1_");
    tests\support\checks::expect(snapshot.reason == "" && snapshot.entries.size == 0,
        "A valid empty machine registry produces an available empty snapshot");
}

unsupported_perk_ids_have_no_alias_mapping()
{
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\perk_sounds::aliases(undefined, false, "p1_")),
        "An undefined perk ID has no native alias mapping");
    foreach (id in ["", "perk_machine_deadeye", "perk_machine_change", 7])
        tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\perk_sounds::aliases(id, false, "p1_")),
            "Only IDs in the shared Spaceland perk catalog receive source-backed sound aliases");
}

expect_unavailable(state, message)
{
    snapshot = scripts\apparition\maps\spaceland\perk_sounds::inspect(state, false, "p2_");
    tests\support\checks::expect(snapshot.reason != "" && snapshot.entries.size == 0, message);
}

native_state()
{
    state = spawnstruct();
    state.struct_class_names = [];
    state.struct_class_names["script_noteworthy"] = [];
    foreach (perk in scripts\apparition\maps\spaceland\perks::catalog())
        state.struct_class_names["script_noteworthy"][perk.id] = [native_machine(perk.id)];
    return state;
}

native_machine(id)
{
    machine = spawnstruct();
    machine.script_noteworthy = id;
    return machine;
}
