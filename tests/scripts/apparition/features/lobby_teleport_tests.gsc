// Lobby teleport contracts keep the exact source choices and reject invalid actors early

run()
{
    source_modes_keep_their_exact_order();
    mode_validation_accepts_only_exact_source_strings();
    crosshairs_moves_an_included_requester_to_the_end_without_mutating_selection();
    crosshairs_keeps_original_order_when_requester_is_first_or_last_or_absent();
    self_and_sky_preserve_the_original_recipient_order();
    missing_and_nonplayer_owners_fail_before_lobby_reads();
    invalid_modes_are_rejected_before_owner_admission();
}

source_modes_keep_their_exact_order()
{
    actual = scripts\apparition\features\lobby_teleport::modes();
    expected = ["Self", "Crosshairs", "Sky"];
    tests\support\checks::expect(isDefined(actual) && isarray(actual)
        && actual.size == expected.size, "Lobby Teleport keeps the three source choices");
    if (!isDefined(actual) || !isarray(actual) || actual.size != expected.size)
        return;

    for (index = 0; index < expected.size; index++)
    {
        tests\support\checks::expect(isstring(actual[index]) && actual[index] == expected[index],
            "Lobby Teleport choices retain source spelling and order");
        tests\support\checks::expect(scripts\apparition\features\lobby_teleport::valid_mode(expected[index]),
            "Each exact source choice is valid");
    }
}

mode_validation_accepts_only_exact_source_strings()
{
    tests\support\checks::expect(!scripts\apparition\features\lobby_teleport::valid_mode(undefined),
        "A missing lobby teleport mode is rejected");
    foreach (invalid in ["self", "Crosshair", "Sky ", "", 0, [], spawnstruct()])
    {
        tests\support\checks::expect(!scripts\apparition\features\lobby_teleport::valid_mode(invalid),
            "A non-string or non-catalog choice is rejected");
    }
}

crosshairs_moves_an_included_requester_to_the_end_without_mutating_selection()
{
    first = spawnstruct();
    owner = spawnstruct();
    last = spawnstruct();
    selected = [first, owner, last];
    ordered = scripts\apparition\features\lobby_teleport::ordered_targets(selected, owner, "Crosshairs");
    tests\support\checks::expect(ordered.size == 3 && ordered[0] == first
        && ordered[1] == last && ordered[2] == owner,
        "Crosshairs moves an included requester after all other recipients");
    tests\support\checks::expect(selected[0] == first && selected[1] == owner && selected[2] == last,
        "Recipient ordering does not mutate the authority snapshot");
}

crosshairs_keeps_original_order_when_requester_is_first_or_last_or_absent()
{
    owner = spawnstruct();
    first = spawnstruct();
    middle = spawnstruct();
    last = spawnstruct();

    ordered = scripts\apparition\features\lobby_teleport::ordered_targets(
        [owner, first, middle, last], owner, "Crosshairs");
    tests\support\checks::expect(ordered.size == 4 && ordered[0] == first
        && ordered[1] == middle && ordered[2] == last && ordered[3] == owner,
        "An initially first requester moves last without reordering other players");

    ordered = scripts\apparition\features\lobby_teleport::ordered_targets(
        [first, middle, last, owner], owner, "Crosshairs");
    tests\support\checks::expect(ordered.size == 4 && ordered[0] == first
        && ordered[1] == middle && ordered[2] == last && ordered[3] == owner,
        "An already last requester remains last");

    ordered = scripts\apparition\features\lobby_teleport::ordered_targets(
        [first, middle, last], owner, "Crosshairs");
    tests\support\checks::expect(ordered.size == 3 && ordered[0] == first
        && ordered[1] == middle && ordered[2] == last,
        "A requester absent from the selection leaves its order unchanged");
}

self_and_sky_preserve_the_original_recipient_order()
{
    first = spawnstruct();
    owner = spawnstruct();
    last = spawnstruct();
    selected = [first, owner, last];
    foreach (mode in ["Self", "Sky"])
    {
        ordered = scripts\apparition\features\lobby_teleport::ordered_targets(selected, owner, mode);
        tests\support\checks::expect(ordered.size == 3 && ordered[0] == first
            && ordered[1] == owner && ordered[2] == last,
            "Only Crosshairs defers the requester");
    }
}

missing_and_nonplayer_owners_fail_before_lobby_reads()
{
    missing = scripts\apparition\features\lobby_teleport::probe(undefined);
    tests\support\checks::expect(isDefined(missing) && isstruct(missing)
        && isDefined(missing.reason) && isstring(missing.reason) && missing.reason != ""
        && isDefined(missing.owner_reason) && isstring(missing.owner_reason) && missing.owner_reason != ""
        && isDefined(missing.targets) && isarray(missing.targets) && missing.targets.size == 0,
        "A missing owner receives blocked lobby and owner reasons without native reads");

    fixture = scripts\apparition\features\lobby_teleport::probe(spawnstruct());
    tests\support\checks::expect(isDefined(fixture.reason) && fixture.reason != ""
        && isDefined(fixture.owner_reason) && fixture.owner_reason != ""
        && isDefined(fixture.targets) && isarray(fixture.targets) && fixture.targets.size == 0,
        "A non-player fixture is rejected before session, host, or player-field access");
    tests\support\checks::expect(!scripts\apparition\features\lobby_teleport::request(undefined, "Self"),
        "A missing owner cannot submit a lobby teleport");
    tests\support\checks::expect(!scripts\apparition\features\lobby_teleport::request(spawnstruct(), "Sky"),
        "A non-player owner cannot reach a native destination writer");
}

invalid_modes_are_rejected_before_owner_admission()
{
    tests\support\checks::expect(!scripts\apparition\features\lobby_teleport::request(undefined, "invalid"),
        "An invalid mode is rejected before a missing owner is inspected");
    tests\support\checks::expect(!scripts\apparition\features\lobby_teleport::request(spawnstruct(), undefined),
        "An undefined mode is rejected before non-player owner access");
}
