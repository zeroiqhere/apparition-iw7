// Keep the actual native model identity after success clears current_speaker

observe(state)
{
    // Only a live native defense can establish a trusted pickup target
    if (scripts\apparition\maps\spaceland\speakers::reason(state) != "")
        return undefined;
    step = scripts\apparition\maps\spaceland\quest::current_step(state);
    capture = state.apparition_speaker_capture;
    if (isDefined(capture) && capture.speaker == state.current_speaker
        && capture.clip == state.frequency_device_clip && capture.step == step)
        return capture;
    capture = spawnstruct();
    capture.speaker = state.current_speaker;
    capture.clip = state.frequency_device_clip;
    capture.step = step;
    capture.submitted = false;
    // New native models get new history; repeated samples preserve prior input
    state.apparition_speaker_capture = capture;
    return capture;
}

listening(capture)
{
    return isDefined(capture) && isDefined(capture.ticket)
        && (capture.ticket.state == "Armed" || capture.ticket.state == "Received");
}

record_trigger(capture)
{
    if (isDefined(capture.ticket) && capture.ticket.state == "Received")
        capture.submitted = true;
}

retained(state, capture)
{
    // Native failure and foreign callbacks cannot leave a trusted pickup listener
    return scripts\apparition\maps\spaceland\speakers::context_reason(state) == ""
        && scripts\apparition\maps\spaceland\speakers::model_valid(capture.speaker)
        && capture.clip == state.frequency_device_clip
        && capture.step == scripts\apparition\maps\spaceland\quest::current_step(state)
        && isDefined(state.use_dj_door_func)
        && (state.use_dj_door_func == scripts\cp\maps\cp_zmb\cp_zmb_dj::use_dj_door_during_speaker_defense
            || state.use_dj_door_func == scripts\cp\maps\cp_zmb\cp_zmb_dj::use_dj_door_to_pick_up_analyzer);
}

can_arm(state, capture)
{
    if (capture.submitted || state.apparition_speaker_capture != capture
        || scripts\apparition\maps\spaceland\speakers::reason(state) != ""
        || state.current_speaker != capture.speaker || state.frequency_device_clip != capture.clip
        || scripts\apparition\maps\spaceland\quest::current_step(state) != capture.step)
        return false;
    // A timed-out handshake can retry only before native success opens pickup
    return !isDefined(capture.ticket)
        || (capture.ticket.state == "Cancelled" && !isDefined(capture.ticket.event));
}

retire(capture)
{
    // Receipt history must survive canceling its listener and releasing its handle
    record_trigger(capture);
    if (isDefined(capture.ticket))
        scripts\apparition\runtime\events::cancel(capture.ticket);
    capture.ticket = undefined;
}

start()
{
    level endon("game_ended");
    for (;;)
    {
        previous = level.apparition_speaker_capture;
        if (scripts\apparition\maps\spaceland\quest::current_step(level) > 4)
        {
            if (isDefined(previous))
                retire(previous);
            level.apparition_speaker_capture = undefined;
            return;
        }
        observe(level);
        capture = level.apparition_speaker_capture;
        if (isDefined(previous) && previous != capture)
            // A same-stage native retry still has a different model identity
            retire(previous);
        if (isDefined(capture))
        {
            if (!retained(level, capture))
            {
                retire(capture);
                level.apparition_speaker_capture = undefined;
            }
            else
            {
                // Only this history owner arms and retires the shared listener
                if (can_arm(level, capture))
                    capture.ticket = scripts\apparition\runtime\events::arm(capture.speaker, ["trigger"]);
                record_trigger(capture);
            }
        }
        // Native defenses last 60/90/120 seconds; no HUD needs to be open to capture them
        wait 0.25;
    }
}
