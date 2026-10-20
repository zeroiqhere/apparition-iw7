// Health display contracts use isolated state and never allocate native HUD elements

run()
{
    normal_and_tough_health_keep_the_source_width_formula();
    zero_and_last_stand_health_do_not_invent_a_visible_pixel();
    missing_and_invalid_health_cannot_publish_dimensions();
    native_integer_range_checks_precede_bounded_pixel_conversion();
    one_record_is_the_only_configured_state();
    stale_retirement_keeps_a_replacement_record();
    release_clears_configuration_without_a_respawn_preference();
    rejected_actors_cannot_enable_or_remove_a_bar();
}

normal_and_tough_health_keep_the_source_width_formula()
{
    foreach (sample in [[100, 100, 102, 100], [50, 100, 102, 50],
        [150, 150, 152, 150], [200, 200, 152, 150], [100, 200, 152, 75],
        [199, 200, 152, 149], [150, 300, 152, 75]])
    {
        shape = scripts\apparition\features\health_bar::measure(sample[0], sample[1]);
        tests\support\checks::expect(shape.reason == ""
            && shape.background_width == sample[2] && shape.fill_width == sample[3],
            "The source keeps raw widths through 150 maximum health and truncates a proportional larger bar");
    }
}

zero_and_last_stand_health_do_not_invent_a_visible_pixel()
{
    foreach (sample in [[0, 100, 102, 0], [1, 100, 102, 1], [1, 200, 152, 0], [2, 200, 152, 1]])
    {
        shape = scripts\apparition\features\health_bar::measure(sample[0], sample[1]);
        tests\support\checks::expect(shape.reason == ""
            && shape.background_width == sample[2] && shape.fill_width == sample[3],
            "Zero fill remains distinct from a one-pixel fill, including valid last-stand health one");
    }
}

missing_and_invalid_health_cannot_publish_dimensions()
{
    // Absence is checked directly because foreach may skip undefined entries
    expect_unreadable(undefined, 100);
    expect_unreadable(100, undefined);
    foreach (invalid in ["100", [], spawnstruct(), (1, 2, 3), ::run])
    {
        expect_unreadable(invalid, 100);
        expect_unreadable(100, invalid);
    }
    foreach (sample in [[-1, 100], [1, 0], [0, -1], [101, 100], [1, 0.5]])
        expect_unreadable(sample[0], sample[1]);
}

native_integer_range_checks_precede_bounded_pixel_conversion()
{
    expect_unreadable(1, 1e30);
    shape = scripts\apparition\features\health_bar::measure(1000000, 2000000);
    tests\support\checks::expect(shape.reason == "" && shape.background_width == 152 && shape.fill_width == 75,
        "A larger admitted native health value is scaled before conversion to small HUD dimensions");
}

expect_unreadable(health, maximum)
{
    shape = scripts\apparition\features\health_bar::measure(health, maximum);
    tests\support\checks::expect(shape.reason == "Wait for valid native health and maximum health"
        && !isDefined(shape.background_width) && !isDefined(shape.fill_width),
        "An unreadable health pair cannot expose native shader dimensions");
}

one_record_is_the_only_configured_state()
{
    tests\support\checks::expect(!scripts\apparition\features\health_bar::configured(undefined),
        "A missing player has no health bar configuration");
    player = spawnstruct();
    tests\support\checks::expect(!scripts\apparition\features\health_bar::configured(player),
        "An absent record is the disabled state");
    record = spawnstruct();
    player.apparition_health_bar = record;
    tests\support\checks::expect(scripts\apparition\features\health_bar::configured(player)
        && scripts\apparition\features\health_bar::is_current(player, record),
        "The owned record supplies configured state without a separate enabled bit");
    tests\support\checks::expect(!scripts\apparition\features\health_bar::is_current(player, spawnstruct())
        && !scripts\apparition\features\health_bar::is_current(player, undefined),
        "A distinct or absent record does not own the current configuration");
}

stale_retirement_keeps_a_replacement_record()
{
    player = spawnstruct();
    replacement = spawnstruct();
    player.apparition_health_bar = replacement;
    stale = spawnstruct();
    scripts\apparition\features\health_bar::retire(player, stale);
    tests\support\checks::expect(player.apparition_health_bar == replacement,
        "An older worker cannot clear a replacement bar");
    scripts\apparition\features\health_bar::retire(player, replacement);
    tests\support\checks::expect(!scripts\apparition\features\health_bar::configured(player),
        "Retiring the exact current record clears its configuration");
}

release_clears_configuration_without_a_respawn_preference()
{
    player = spawnstruct();
    player.health = 17;
    player.maxhealth = 100;
    player.apparition_health_bar = spawnstruct();
    tests\support\checks::expect(scripts\apparition\features\health_bar::release(player)
        && !scripts\apparition\features\health_bar::configured(player),
        "Release removes the current record instead of retaining a respawn preference");
    tests\support\checks::expect(!scripts\apparition\features\health_bar::release(player)
        && player.health == 17 && player.maxhealth == 100,
        "Repeated release leaves native health and maximum health unchanged");
    player.apparition_health_bar = 7;
    tests\support\checks::expect(scripts\apparition\features\health_bar::release(player)
        && !isDefined(player.apparition_health_bar),
        "A stale scalar configuration can be cleared without a HUD call or struct notification");
}

rejected_actors_cannot_enable_or_remove_a_bar()
{
    tests\support\checks::expect(!scripts\apparition\features\health_bar::toggle(undefined, undefined),
        "Missing actors are rejected before native HUD allocation");
    owner = spawnstruct();
    target = spawnstruct();
    target.apparition_health_bar = spawnstruct();
    saved = target.apparition_health_bar;
    current = scripts\apparition\features\health_bar::probe(owner, target);
    tests\support\checks::expect(current.reason != "" && !current.configured && !isDefined(current.shape),
        "Fixture actors cannot read saved configuration or health through readiness probing");
    tests\support\checks::expect(!scripts\apparition\features\health_bar::toggle(owner, target)
        && target.apparition_health_bar == saved,
        "Rejected actor admission cannot even remove an existing target record");
}
