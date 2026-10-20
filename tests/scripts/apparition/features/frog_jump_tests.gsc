// Frog contracts separate held-jump admission, one-boost phases and owned cancellation

run()
{
    only_a_living_standing_airborne_hold_requests_a_boost();
    native_movement_gates_include_the_launch_counter_after_its_timed_marker_expires();
    a_boost_waits_for_landing_even_if_jump_is_released_or_pressed_again();
    landing_rearms_after_the_source_outer_delay();
    velocity_uses_the_full_view_forward_xy_and_fixed_vertical_speed();
    unreadable_angles_cannot_produce_velocity();
    release_cancels_only_the_expected_worker_generation();
    rejected_actors_cannot_read_or_change_configuration();
}

only_a_living_standing_airborne_hold_requests_a_boost()
{
    tests\support\checks::expect(scripts\apparition\features\frog_jump::can_boost(true, false, "stand", true),
        "The source requires held Jump, airborne movement, standing and native menu life");
    foreach (sample in [[false, false, "stand", true], [true, true, "stand", true],
        [true, false, "crouch", true], [true, false, "prone", true], [true, false, "stand", false]])
        tests\support\checks::expect(!scripts\apparition\features\frog_jump::can_boost(sample[0], sample[1], sample[2], sample[3]),
            "A missing source prerequisite cannot request a launch");
    tests\support\checks::expect(!scripts\apparition\features\frog_jump::can_boost(true, false, undefined, true),
        "Unreadable stance cannot imply standing");
}

native_movement_gates_include_the_launch_counter_after_its_timed_marker_expires()
{
    tests\support\checks::expect(scripts\apparition\features\frog_jump::may_launch("", false, false, true),
        "Clear known movement gates allow the separate source jump checks to proceed");
    foreach (sample in [["Finish the native slide, launch or rewind first", false, false, true],
        ["", true, false, true], ["", false, true, true]])
        tests\support\checks::expect(!scripts\apparition\features\frog_jump::may_launch(sample[0], sample[1], sample[2], sample[3]),
            "A known owner, link, phase or native teleport-disable counter pauses the Frog write");
    // Geyser flung may clear on a timer before its landing owner releases this counter
    tests\support\checks::expect(!scripts\apparition\features\frog_jump::may_launch("", false, false, false),
        "An expired flung marker cannot allow a boost during a still-owned native launch");
}

a_boost_waits_for_landing_even_if_jump_is_released_or_pressed_again()
{
    first = scripts\apparition\features\frog_jump::advance(false, false, true);
    tests\support\checks::expect(first.boost && first.waiting_landing && first.delay == 0.05,
        "A ready airborne request performs one boost then enters the source landing wait");
    foreach (requested in [false, true])
    {
        next = scripts\apparition\features\frog_jump::advance(first.waiting_landing, false, requested);
        tests\support\checks::expect(!next.boost && next.waiting_landing && next.delay == 0.05,
            "Further requests cannot repeat a boost before the player touches ground");
    }
}

landing_rearms_after_the_source_outer_delay()
{
    landed = scripts\apparition\features\frog_jump::advance(true, true, true);
    tests\support\checks::expect(!landed.boost && !landed.waiting_landing && landed.delay == 0.01,
        "Landing exits the inner wait and retains the source outer delay without boosting immediately");
    grounded = scripts\apparition\features\frog_jump::advance(landed.waiting_landing, true, true);
    tests\support\checks::expect(!grounded.boost && !grounded.waiting_landing && grounded.delay == 0.01,
        "A held Jump on the ground does not create an extra launch");
    next = scripts\apparition\features\frog_jump::advance(grounded.waiting_landing, false, true);
    tests\support\checks::expect(next.boost && next.waiting_landing,
        "The next airborne hold can launch after a real landing");
    idle = scripts\apparition\features\frog_jump::advance(false, false, false);
    tests\support\checks::expect(!idle.boost && !idle.waiting_landing && idle.delay == 0.01,
        "Blocked or idle airborne input stays ready at the outer poll interval");
}

velocity_uses_the_full_view_forward_xy_and_fixed_vertical_speed()
{
    foreach (sample in [[(0, 0, 0), (550, 0, 400)], [(0, 90, 0), (0, 550, 400)],
        [(0, 180, 0), (-550, 0, 400)], [(60, 0, 0), (275, 0, 400)]])
    {
        actual = scripts\apparition\features\frog_jump::velocity(sample[0]);
        tests\support\checks::expect(isDefined(actual) && distanceSquared(actual, sample[1]) < 0.001,
            "Frog Jump scales the current full view-forward XY by550 and replaces Z with400");
    }
}

unreadable_angles_cannot_produce_velocity()
{
    tests\support\checks::expect(!isDefined(scripts\apparition\features\frog_jump::velocity(undefined)),
        "Absent view angles cannot reach vector conversion");
    foreach (invalid in [0, "angles", [], spawnstruct(), ::run])
        tests\support\checks::expect(!isDefined(scripts\apparition\features\frog_jump::velocity(invalid)),
            "Non-vector view data cannot produce a native velocity command");
}

release_cancels_only_the_expected_worker_generation()
{
    tests\support\checks::expect(!scripts\apparition\features\frog_jump::configured(undefined)
        && !scripts\apparition\features\frog_jump::release(undefined),
        "Missing players have no configuration to cancel");
    player = spawnstruct();
    old = spawnstruct();
    current = spawnstruct();
    player.apparition_frog_jump = current;
    tests\support\checks::expect(!scripts\apparition\features\frog_jump::release(player, old)
        && scripts\apparition\features\frog_jump::is_current(player, current),
        "An old airborne worker cannot cancel a replacement enabled before landing");
    tests\support\checks::expect(scripts\apparition\features\frog_jump::release(player, current)
        && !scripts\apparition\features\frog_jump::configured(player),
        "The current worker clears its own configuration before sending its stop");
    tests\support\checks::expect(!scripts\apparition\features\frog_jump::release(player, current),
        "A second cancellation cannot find or restart a stopped worker");
    player.apparition_frog_jump = 7;
    tests\support\checks::expect(scripts\apparition\features\frog_jump::release(player)
        && !isDefined(player.apparition_frog_jump),
        "A malformed old configuration can be removed without a struct notification");
}

rejected_actors_cannot_read_or_change_configuration()
{
    tests\support\checks::expect(!scripts\apparition\features\frog_jump::toggle(undefined, undefined),
        "Missing actors cannot enable a Frog worker");
    owner = spawnstruct();
    target = spawnstruct();
    target.apparition_frog_jump = spawnstruct();
    saved = target.apparition_frog_jump;
    snapshot = scripts\apparition\features\frog_jump::probe(owner, target);
    tests\support\checks::expect(snapshot.reason != "" && !snapshot.configured,
        "Fixture actors cannot enter saved configuration or input receipt reads");
    tests\support\checks::expect(!scripts\apparition\features\frog_jump::toggle(owner, target)
        && target.apparition_frog_jump == saved,
        "Rejected actor admission preserves the selected player's saved record");
}
