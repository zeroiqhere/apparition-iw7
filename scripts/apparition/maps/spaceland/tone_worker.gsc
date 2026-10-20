// One background worker follows fresh native rounds without restarting the quest

run(job)
{
    level endon("game_ended");
    level thread watch_input(job);
    for (;;)
    {
        // Preserve a cancellation queued before this round begins
        if (job.state != "Cancelling")
            job.state = "Waiting for fresh round";
        outcome = wait_for_round(job);
        if (outcome != "")
        {
            finish(job, outcome);
            return;
        }
        ordered = scripts\apparition\maps\spaceland\tones::plan(level);
        if (!isDefined(ordered))
        {
            finish(job, "Unavailable");
            return;
        }
        job.state = "Playing tones";
        outcome = play_round(job, ordered);
        if (outcome != "")
        {
            finish(job, outcome);
            return;
        }
    }
}

guard(job)
{
    allowed = scripts\apparition\runtime\context::can_dispatch(job.owner, undefined, true)
        && isAlive(job.owner);
    return scripts\apparition\maps\spaceland\tones::checkpoint(job, level, allowed);
}

wait_for_round(job)
{
    // Existing listening input may already be partway through a native round
    need_clear = scripts\apparition\maps\spaceland\tones::listening(level);
    deadline = getTime() + 120000;
    for (;;)
    {
        outcome = guard(job);
        if (outcome != "")
            return outcome;
        if (getTime() >= deadline)
            return "Round wait timed out";
        if (!scripts\apparition\maps\spaceland\tones::listening(level))
        {
            need_clear = false;
            job.interference = false;
        }
        else if (!need_clear)
        {
            if (job.interference)
                return "Interrupted by tone input";
            return "";
        }
        wait 0.05;
    }
}

play_round(job, ordered)
{
    for (index = 0; index < ordered.size; index++)
    {
        outcome = guard(job);
        if (outcome != "")
            return outcome;
        if (job.interference)
            return "Interrupted by tone input";
        location = ordered[index];
        if (!scripts\apparition\maps\spaceland\tones::listening(level) || !location_enabled(level, location))
            return "Native interaction unavailable";
        job.expected_key = scripts\apparition\maps\spaceland\tones::tone_key(location.tone);
        job.expected_location = location;
        job.received_expected = false;
        // Arm before the callback so an immediate native response remains observable
        job.ack = scripts\apparition\runtime\events::arm(level.ufo,
            ["correct_tone_played", "completed_tone_match", "incorrect_tone_played", "ufo_timed_out", "played_tones_too_slowly"]);
        // Wrong-note rejection arrives on level before the UFO reports a failed round
        job.failure = scripts\apparition\runtime\events::arm(level, ["incorrect_tone_played", "played_tones_too_slowly"]);
        // Arming can yield, so recheck cancellation, native state and intervening input
        outcome = guard(job);
        if (outcome != "")
            return outcome;
        if (!ready_to_play(job) || !scripts\apparition\maps\spaceland\tones::listening(level)
            || !location_enabled(level, location))
            return "Native input changed while arming";
        scripts\cp\maps\cp_zmb\cp_zmb_dj::waitforplayertrigger(location, job.owner);
        expected = index == ordered.size - 1 ? "completed_tone_match" : "correct_tone_played";
        outcome = wait_for_ack(job, expected);
        scripts\apparition\runtime\events::cancel(job.ack);
        scripts\apparition\runtime\events::cancel(job.failure);
        job.ack = undefined;
        job.failure = undefined;
        job.expected_key = undefined;
        job.expected_location = undefined;
        if (outcome != "")
            return outcome;
    }
    return "";
}

ready_to_play(job)
{
    return job.ack.state == "Armed" && job.failure.state == "Armed"
        && !job.interference && !job.received_expected;
}

wait_for_ack(job, expected)
{
    // This budget is below the native 2.5-second co-op inter-note deadline
    deadline = getTime() + 1500;
    for (;;)
    {
        outcome = guard(job);
        if (outcome != "")
            return outcome;
        result = ack_result(job, expected);
        if (isDefined(result))
            return result;
        if (getTime() >= deadline)
            return "Tone ack timed out";
        wait 0.05;
    }
}

ack_result(job, expected)
{
    if (job.interference)
        return "Interrupted by tone input";
    if (isDefined(job.failure.event))
        return "Native tone rejected";
    if (!isDefined(job.ack.event))
        return undefined;
    if (job.ack.event != expected)
        return "Native tone rejected";
    // The key/struct observer and processed ack are both needed before advancing
    return job.received_expected ? "" : undefined;
}

location_enabled(state, location)
{
    // Recheck placement after every wait before calling the native dual-purpose action
    return isDefined(location) && isDefined(location.placed) && location.placed
        && isDefined(location.model) && isDefined(location.origin)
        && isDefined(scripts\apparition\maps\spaceland\tones::tone_key(location.tone))
        && (!isDefined(location.disabled) || !location.disabled)
        && isDefined(state.current_interaction_structs)
        && scripts\engine\utility::array_contains(state.current_interaction_structs, location);
}

watch_input(job)
{
    job endon("apparition_tones_stop");
    level endon("game_ended");
    for (;;)
    {
        level waittill("tone_played", key, location);
        observe(job, level, key, location);
    }
}

observe(job, state, key, location)
{
    if (scripts\apparition\maps\spaceland\quest::current_step(state) != 8
        || !scripts\apparition\maps\spaceland\tones::listening(state))
        return;
    if (!isDefined(key) || !isDefined(location) || !isDefined(job.expected_key)
        || !isDefined(job.expected_location) || key != job.expected_key
        || location != job.expected_location || job.received_expected)
    {
        job.interference = true;
        return;
    }
    job.received_expected = true;
}

finish(job, outcome)
{
    job notify("apparition_tones_stop");
    if (isDefined(job.ack))
        scripts\apparition\runtime\events::cancel(job.ack);
    if (isDefined(job.failure))
        scripts\apparition\runtime\events::cancel(job.failure);
    job.ack = undefined;
    job.failure = undefined;
    job.expected_key = undefined;
    job.expected_location = undefined;
    job.owner = undefined;
    job.state = outcome;
}
