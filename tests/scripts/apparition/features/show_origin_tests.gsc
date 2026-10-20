// Coordinate display ownership tests use no real player or native HUD handles

run()
{
    only_vectors_can_supply_three_coordinate_values();
    configuration_uses_one_owned_record();
    stale_retirement_keeps_a_replacement_display();
    release_is_repeatable_and_keeps_native_position();
    rejected_actors_cannot_read_or_change_saved_configuration();
}

only_vectors_can_supply_three_coordinate_values()
{
    tests\support\checks::expect(scripts\apparition\features\show_origin::valid_position((0, 0, 0))
        && scripts\apparition\features\show_origin::valid_position((-123.5, 3456, -90)),
        "Native vectors retain zero, negative and fractional coordinate values");
    tests\support\checks::expect(!scripts\apparition\features\show_origin::valid_position(undefined),
        "An absent position cannot be sent to native numeric HUD methods");
    foreach (value in [0, "1 2 3", [1, 2, 3], spawnstruct(), ::run])
        tests\support\checks::expect(!scripts\apparition\features\show_origin::valid_position(value),
            "Scalar, text, array and object values cannot impersonate native position vectors");
}

configuration_uses_one_owned_record()
{
    player = spawnstruct();
    tests\support\checks::expect(!scripts\apparition\features\show_origin::configured(undefined)
        && !scripts\apparition\features\show_origin::configured(player),
        "Only the presence of the owned record configures the display");
    record = spawnstruct();
    player.apparition_origin_display = record;
    tests\support\checks::expect(scripts\apparition\features\show_origin::configured(player)
        && scripts\apparition\features\show_origin::is_current(player, record),
        "The exact record owns the current display without a separate enabled flag");
    tests\support\checks::expect(!scripts\apparition\features\show_origin::is_current(player, spawnstruct())
        && !scripts\apparition\features\show_origin::is_current(player, undefined),
        "A different or missing record cannot own the current worker");
}

stale_retirement_keeps_a_replacement_display()
{
    player = spawnstruct();
    replacement = spawnstruct();
    player.apparition_origin_display = replacement;
    stale = spawnstruct();
    scripts\apparition\features\show_origin::retire(player, stale);
    tests\support\checks::expect(player.apparition_origin_display == replacement,
        "Retiring an old worker leaves the replacement configured");
    scripts\apparition\features\show_origin::retire(player, replacement);
    tests\support\checks::expect(!scripts\apparition\features\show_origin::configured(player),
        "The current record can retire its own configuration");
}

release_is_repeatable_and_keeps_native_position()
{
    player = spawnstruct();
    player.origin = (-10, 20.5, 30);
    player.apparition_origin_display = spawnstruct();
    tests\support\checks::expect(scripts\apparition\features\show_origin::release(player)
        && !scripts\apparition\features\show_origin::configured(player),
        "Release consumes the configured display record");
    tests\support\checks::expect(!scripts\apparition\features\show_origin::release(player)
        && player.origin == (-10, 20.5, 30),
        "Repeated release leaves native coordinates unchanged");
    player.apparition_origin_display = 7;
    tests\support\checks::expect(scripts\apparition\features\show_origin::release(player)
        && !isDefined(player.apparition_origin_display),
        "A stale scalar record can be cleared without treating it as a HUD owner");
}

rejected_actors_cannot_read_or_change_saved_configuration()
{
    tests\support\checks::expect(!scripts\apparition\features\show_origin::toggle(undefined),
        "A missing actor is rejected before native host and HUD methods");
    owner = spawnstruct();
    owner.apparition_origin_display = spawnstruct();
    saved = owner.apparition_origin_display;
    snapshot = scripts\apparition\features\show_origin::probe(owner);
    tests\support\checks::expect(snapshot.reason != "" && !snapshot.configured,
        "Rejected actor admission cannot expose a saved display setting");
    tests\support\checks::expect(!scripts\apparition\features\show_origin::toggle(owner)
        && owner.apparition_origin_display == saved,
        "An invalid actor cannot disable a saved display through the native toggle");
}
