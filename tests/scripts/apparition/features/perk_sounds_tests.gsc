// Sound contracts reject invalid requests without buying perks or invoking playback

run()
{
    only_catalog_perks_and_exact_sound_kinds_are_selectable();
    unknown_and_malformed_selectors_are_rejected();
    missing_and_malformed_aliases_are_unavailable_before_native_lookup();
    probe_rejects_missing_and_nonplayer_actors();
    requests_reject_unknown_selectors_and_nonplayer_actors();
}

only_catalog_perks_and_exact_sound_kinds_are_selectable()
{
    foreach (perk in scripts\apparition\maps\spaceland\perks::catalog())
    {
        tests\support\checks::expect(scripts\apparition\features\perk_sounds::valid_selection(perk.id, "Jingle"),
            "Every placed-catalog perk can select its jingle by stable ID");
        tests\support\checks::expect(scripts\apparition\features\perk_sounds::valid_selection(perk.id, "Quote"),
            "Every placed-catalog perk can select its quote by stable ID");
    }
}

unknown_and_malformed_selectors_are_rejected()
{
    tests\support\checks::expect(!scripts\apparition\features\perk_sounds::valid_selection(undefined, "Jingle")
        && !scripts\apparition\features\perk_sounds::valid_selection("perk_machine_revive", undefined),
        "Missing perk and kind selectors cannot inherit a sound");
    foreach (id in ["", "perk_machine_deadeye", "perk_machine_change", "mus_zmb_upnatoms_purchase",
        "PERK_MACHINE_REVIVE", 1, [], spawnstruct()])
        tests\support\checks::expect(!scripts\apparition\features\perk_sounds::valid_selection(id, "Jingle"),
            "Unknown perk IDs and raw aliases cannot bypass the shared catalog");
    foreach (kind in ["", "jingle", "quote", "Both", "Play", 1, [], spawnstruct()])
        tests\support\checks::expect(!scripts\apparition\features\perk_sounds::valid_selection("perk_machine_revive", kind),
            "Only exact Jingle and Quote selectors can request audio");
}

missing_and_malformed_aliases_are_unavailable_before_native_lookup()
{
    tests\support\checks::expect(scripts\apparition\features\perk_sounds::alias_reason(undefined)
        == "Native sound alias is unavailable",
        "A missing character quote remains unavailable without an alias lookup");
    foreach (alias in ["", 0, 1, [], spawnstruct(), (1, 2, 3), ::run])
        tests\support\checks::expect(scripts\apparition\features\perk_sounds::alias_reason(alias)
            == "Native sound alias is unavailable",
            "Only a nonempty string may reach the native sound registry");
}

probe_rejects_missing_and_nonplayer_actors()
{
    owner = spawnstruct();
    target = spawnstruct();

    snapshot = scripts\apparition\features\perk_sounds::probe(owner, target);
    tests\support\checks::expect(snapshot.reason != "" && snapshot.entries.size == 0,
        "Fixture actors receive an unavailable sound snapshot without native entries");

    snapshot = scripts\apparition\features\perk_sounds::probe(undefined, undefined);
    tests\support\checks::expect(snapshot.reason != "" && snapshot.entries.size == 0,
        "Absent actors receive an empty unavailable sound snapshot");
}

requests_reject_unknown_selectors_and_nonplayer_actors()
{
    owner = spawnstruct();
    target = spawnstruct();

    tests\support\checks::expect(!scripts\apparition\features\perk_sounds::request(owner, target,
        "perk_machine_revive", "Jingle"),
        "A valid selector cannot submit a sound for rejected actors");
    tests\support\checks::expect(!scripts\apparition\features\perk_sounds::request(undefined, undefined,
        "perk_machine_revive", "Quote"),
        "A quote request cannot run without actual current actors");
    tests\support\checks::expect(!scripts\apparition\features\perk_sounds::request(owner, target,
        "raw_alias", "Jingle") && !scripts\apparition\features\perk_sounds::request(owner, target,
        "perk_machine_revive", "Both"),
        "Unknown perk or kind requests stop without falling back to either sound");
}
