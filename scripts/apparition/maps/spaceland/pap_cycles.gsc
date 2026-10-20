// Two permanent listeners retain native PAP history without changing its counter

create()
{
    watch = spawnstruct();
    watch.state = "Arming";
    watch.starts = 0;
    watch.completions = 0;
    watch.waiting = 0;
    return watch;
}

start()
{
    level endon("game_ended");
    if (isDefined(level.apparition_pap_cycles))
        return;
    watch = create();
    level.apparition_pap_cycles = watch;
    // Each listener confirms reaching its wait before history becomes usable
    level thread listen(watch, true);
    level thread listen(watch, false);
    deadline = getTime() + 1000;
    while (watch.waiting < 2 && getTime() < deadline)
        wait 0.05;
    if (watch.waiting == 2)
        watch.state = "Listening";
    else
    {
        watch.state = "Unavailable";
        watch notify("apparition_stop_pap_watch");
    }
    watch.waiting = undefined;
}

listen(watch, started)
{
    // A child scheduled after a failed handshake must not become an orphan
    if (watch.state != "Arming")
        return;
    level endon("game_ended");
    watch endon("apparition_stop_pap_watch");
    event = started ? "pap_used" : "pap_machine_activated";
    watch.waiting++;
    for (;;)
    {
        level waittill(event);
        observe(watch, started);
        // No wait separates event accounting from rearming the same listener
    }
}

observe(watch, started)
{
    if (started)
        watch.starts++;
    else
        watch.completions++;
}

reason(state, watch)
{
    if (!isDefined(watch) || watch.state != "Listening" || !isDefined(state.timespapused))
        return "Wait for native Pack-a-Punch history to initialize";
    // Never adopt the current counter as a baseline after missing earlier events
    if (watch.starts != state.timespapused)
        return "Pack-a-Punch history is unconfirmed; normal fuse insertion remains available";
    if (watch.completions != watch.starts)
        return "Wait for the current Pack-a-Punch cycle to finish";
    return "";
}
