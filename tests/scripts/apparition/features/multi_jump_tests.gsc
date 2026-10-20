// Multi-Jump contracts cover saved intent and the input phase reducer

run()
{
    missing_and_false_flags_are_disabled();
    a_truthy_saved_flag_is_configured_without_mutation();
    a_grounded_press_is_consumed_after_becoming_airborne();
    the_first_airborne_release_is_consumed();
    a_later_airborne_release_requests_one_boost();
    held_input_does_not_request_a_boost();
    pending_release_keeps_the_source_landing_behavior();
    a_grounded_idle_sample_resets_the_jump_phase();
    a_missing_actor_cannot_toggle_multi_jump();
}

missing_and_false_flags_are_disabled()
{
    tests\support\checks::expect(!scripts\apparition\features\multi_jump::configured(undefined),
        "A missing player has no configured Multi-Jump flag");
    player = spawnstruct();
    tests\support\checks::expect(!scripts\apparition\features\multi_jump::configured(player),
        "An undefined Multi-Jump flag is disabled");

    player.MultiJump = 0;
    tests\support\checks::expect(!scripts\apparition\features\multi_jump::configured(player),
        "A zero-valued Multi-Jump flag is disabled");
}

a_truthy_saved_flag_is_configured_without_mutation()
{
    player = spawnstruct();
    player.MultiJump = 1;
    player.unrelated_value = "preserved";

    configured = scripts\apparition\features\multi_jump::configured(player);
    tests\support\checks::expect(configured,
        "A truthy original player flag reports configured Multi-Jump");
    tests\support\checks::expect(player.MultiJump == 1 && player.unrelated_value == "preserved",
        "Reading saved Multi-Jump intent does not change player state");
}

a_grounded_press_is_consumed_after_becoming_airborne()
{
    // A normal jump can start on the ground and stay held during takeoff
    result = scripts\apparition\features\multi_jump::advance("ready", true, true);
    tests\support\checks::expect(result.phase == "first" && !result.boost,
        "A grounded press resets the first-jump phase without boosting");
    result = scripts\apparition\features\multi_jump::advance(result.phase, false, true);
    tests\support\checks::expect(result.phase == "first_held" && !result.boost,
        "The same held press is consumed once the player becomes airborne");
    result = scripts\apparition\features\multi_jump::advance(result.phase, false, false);
    tests\support\checks::expect(result.phase == "ready" && !result.boost,
        "Releasing the normal takeoff jump arms a later boost");
}

the_first_airborne_release_is_consumed()
{
    result = scripts\apparition\features\multi_jump::advance("first", false, true);
    tests\support\checks::expect(isDefined(result) && isstruct(result)
        && result.phase == "first_held" && !result.boost,
        "The first airborne press waits for release without requesting a boost");

    result = scripts\apparition\features\multi_jump::advance(result.phase, false, false);
    tests\support\checks::expect(result.phase == "ready" && !result.boost,
        "Releasing the first airborne press arms a later jump");
}

a_later_airborne_release_requests_one_boost()
{
    result = scripts\apparition\features\multi_jump::advance("ready", false, true);
    tests\support\checks::expect(result.phase == "boost_held" && !result.boost,
        "A later airborne press waits before applying its impulse");

    result = scripts\apparition\features\multi_jump::advance(result.phase, false, false);
    tests\support\checks::expect(result.phase == "ready" && result.boost,
        "Releasing a later airborne press requests one additive boost");

    result = scripts\apparition\features\multi_jump::advance(result.phase, false, false);
    tests\support\checks::expect(result.phase == "ready" && !result.boost,
        "One release cannot repeat its boost on a later sample");
}

held_input_does_not_request_a_boost()
{
    result = scripts\apparition\features\multi_jump::advance("boost_held", false, true);
    tests\support\checks::expect(result.phase == "boost_held" && !result.boost,
        "A held later jump does not request a boost before release");
}

pending_release_keeps_the_source_landing_behavior()
{
    first_release = scripts\apparition\features\multi_jump::advance("first_held", true, true);
    tests\support\checks::expect(first_release.phase == "first_held" && !first_release.boost,
        "A pending first press remains pending across a grounded sample");
    first_release = scripts\apparition\features\multi_jump::advance(first_release.phase, true, false);
    tests\support\checks::expect(first_release.phase == "ready" && !first_release.boost,
        "Landing during the first hold does not turn its release into a boost");

    boost_release = scripts\apparition\features\multi_jump::advance("boost_held", true, true);
    tests\support\checks::expect(boost_release.phase == "boost_held" && !boost_release.boost,
        "A pending later press remains pending across a grounded sample");
    boost_release = scripts\apparition\features\multi_jump::advance(boost_release.phase, true, false);
    tests\support\checks::expect(boost_release.phase == "ready" && boost_release.boost,
        "A later release after landing keeps the original post-wait impulse behavior");
}

a_grounded_idle_sample_resets_the_jump_phase()
{
    result = scripts\apparition\features\multi_jump::advance("ready", true, false);
    tests\support\checks::expect(result.phase == "first" && !result.boost,
        "A grounded idle sample resets the next jump to its first-airborne phase");
    result = scripts\apparition\features\multi_jump::advance("first", false, false);
    tests\support\checks::expect(result.phase == "first" && !result.boost,
        "Airborne idle time does not consume or boost a jump");
}

a_missing_actor_cannot_toggle_multi_jump()
{
    tests\support\checks::expect(!scripts\apparition\features\multi_jump::toggle(undefined),
        "A missing actor cannot change Multi-Jump or start a worker");
}
