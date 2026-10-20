// Lobby timer contracts inspect choices and records without running a countdown

run()
{
    source_choices_and_minute_validation_are_exact();
    configured_minutes_default_only_when_absent();
    deadlines_reject_invalid_and_overflowing_values();
    only_the_current_record_owns_the_lobby_timer();
    invalid_requesters_receive_no_timer_state_or_mutation();
}

source_choices_and_minute_validation_are_exact()
{
    values = scripts\apparition\features\server\lobby_timer::values();
    tests\support\checks::expect(isDefined(values) && isarray(values) && values.size == 30
        && values[0] == 1 && values[9] == 10 && values[29] == 30,
        "The timer choice catalog contains each source minute from 1 through 30");

    foreach (minutes in [1, 10, 30])
        tests\support\checks::expect(scripts\apparition\features\server\lobby_timer::valid_minutes(minutes),
            "Whole timer values inside the source range are accepted");
    foreach (minutes in [0, 31, 1.5, "10", false])
        tests\support\checks::expect(!scripts\apparition\features\server\lobby_timer::valid_minutes(minutes),
            "Out-of-range or nonnumeric timer values are rejected");
    tests\support\checks::expect(!scripts\apparition\features\server\lobby_timer::valid_minutes(undefined),
        "A missing timer value is rejected");
}

configured_minutes_default_only_when_absent()
{
    state = spawnstruct();
    tests\support\checks::expect(scripts\apparition\features\server\lobby_timer::configured_minutes(state) == 10,
        "An absent stored duration uses the original ten-minute default");

    state.apparition_lobby_minutes = 17;
    tests\support\checks::expect(scripts\apparition\features\server\lobby_timer::configured_minutes(state) == 17,
        "A valid stored duration remains the configured value");

    foreach (minutes in [0, 31, 1.5, "10", false])
    {
        state.apparition_lobby_minutes = minutes;
        tests\support\checks::expect(!isDefined(
            scripts\apparition\features\server\lobby_timer::configured_minutes(state)),
            "A defined invalid duration is not silently replaced by the default");
    }
    state.apparition_lobby_minutes = undefined;
    tests\support\checks::expect(scripts\apparition\features\server\lobby_timer::configured_minutes(state) == 10,
        "An explicitly cleared duration follows the absent-field default");
}

deadlines_reject_invalid_and_overflowing_values()
{
    tests\support\checks::expect(scripts\apparition\features\server\lobby_timer::deadline(0, 1) == 60000
        && scripts\apparition\features\server\lobby_timer::deadline(123456, 10) == 723456,
        "A valid deadline adds whole minutes in milliseconds");
    tests\support\checks::expect(scripts\apparition\features\server\lobby_timer::deadline(2147423647, 1) == 2147483647,
        "The maximum representable deadline remains valid");
    tests\support\checks::expect(!isDefined(
        scripts\apparition\features\server\lobby_timer::deadline(2147483647, 1)),
        "A deadline past the signed millisecond limit is rejected");
    tests\support\checks::expect(!isDefined(
        scripts\apparition\features\server\lobby_timer::deadline(2147423648, 1)),
        "The first clock value beyond the representable deadline boundary is rejected");

    tests\support\checks::expect(!isDefined(scripts\apparition\features\server\lobby_timer::deadline(-1, 1))
        && !isDefined(scripts\apparition\features\server\lobby_timer::deadline(1.5, 1))
        && !isDefined(scripts\apparition\features\server\lobby_timer::deadline("0", 1)),
        "Negative, fractional and nonnumeric clock values are rejected");
    tests\support\checks::expect(!isDefined(scripts\apparition\features\server\lobby_timer::deadline(0, 0))
        && !isDefined(scripts\apparition\features\server\lobby_timer::deadline(0, 1.5))
        && !isDefined(scripts\apparition\features\server\lobby_timer::deadline(0, 31)),
        "Invalid durations cannot produce a deadline");
    tests\support\checks::expect(!isDefined(scripts\apparition\features\server\lobby_timer::deadline(2147303680.0, 3)),
        "A float rounded above the integer deadline limit is rejected before addition");
    tests\support\checks::expect(!isDefined(scripts\apparition\features\server\lobby_timer::deadline(undefined, 1)),
        "A missing clock value cannot produce a deadline");
}

only_the_current_record_owns_the_lobby_timer()
{
    state = spawnstruct();
    current = spawnstruct();
    replacement = spawnstruct();

    tests\support\checks::expect(!scripts\apparition\features\server\lobby_timer::owns(undefined, current)
        && !scripts\apparition\features\server\lobby_timer::owns(state, undefined),
        "Missing timer state or worker record cannot claim ownership");
    state.apparition_lobby_timer = current;
    tests\support\checks::expect(scripts\apparition\features\server\lobby_timer::owns(state, current)
        && !scripts\apparition\features\server\lobby_timer::owns(state, replacement),
        "Only the current timer record owns the worker");

    state.apparition_lobby_timer = replacement;
    tests\support\checks::expect(!scripts\apparition\features\server\lobby_timer::owns(state, current)
        && scripts\apparition\features\server\lobby_timer::owns(state, replacement),
        "Replacing the timer record retires the previous worker identity");
    state.apparition_lobby_timer = undefined;
    tests\support\checks::expect(!scripts\apparition\features\server\lobby_timer::owns(state, replacement),
        "Clearing the timer record retires its current worker identity");
}

invalid_requesters_receive_no_timer_state_or_mutation()
{
    probe = scripts\apparition\features\server\lobby_timer::probe(undefined);
    expect_denied_probe(probe);
    tests\support\checks::expect(!scripts\apparition\features\server\lobby_timer::toggle(undefined)
        && !scripts\apparition\features\server\lobby_timer::configure(undefined, 10)
        && !scripts\apparition\features\server\lobby_timer::configure(undefined, 0),
        "A missing requester cannot toggle or configure the timer");

    requester = spawnstruct();
    probe = scripts\apparition\features\server\lobby_timer::probe(requester);
    expect_denied_probe(probe);
    tests\support\checks::expect(!scripts\apparition\features\server\lobby_timer::toggle(requester)
        && !scripts\apparition\features\server\lobby_timer::configure(requester, 10)
        && !scripts\apparition\features\server\lobby_timer::configure(requester, 31),
        "A nonplayer requester cannot start, stop or configure the timer");
}

expect_denied_probe(probe)
{
    tests\support\checks::expect(isDefined(probe) && isstruct(probe)
        && isDefined(probe.reason) && isstring(probe.reason) && probe.reason != ""
        && isDefined(probe.configured) && probe.configured == false
        && isDefined(probe.native_reason) && probe.native_reason == ""
        && isDefined(probe.time_reason) && probe.time_reason == ""
        && isDefined(probe.phase) && probe.phase == "Off"
        && isDefined(probe.error) && probe.error == ""
        && !isDefined(probe.minutes),
        "An invalid requester receives an empty denied timer snapshot");
}
