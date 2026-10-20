// Native cycle history must account for every use before the machine is considered idle

run()
{
    no_native_uses_and_two_ready_listeners_establish_idle();
    unmatched_events_and_unseen_native_uses_cannot_establish_idle();
    completion_and_next_start_counts_do_not_depend_on_handler_order();
    a_listener_that_starts_after_failed_arming_exits_without_waiting();
}

no_native_uses_and_two_ready_listeners_establish_idle()
{
    state = spawnstruct();
    state.timespapused = 0;
    watch = scripts\apparition\maps\spaceland\pap_cycles::create();
    tests\support\checks::expect(scripts\apparition\maps\spaceland\pap_cycles::reason(state, watch) != "", "An arming listener pair cannot prove native cycle history");
    watch.state = "Listening";
    tests\support\checks::expect(scripts\apparition\maps\spaceland\pap_cycles::reason(state, watch) == "", "A ready observer and zero native uses establish idle");
    state.timespapused = undefined;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\pap_cycles::reason(state, watch) != "", "A missing native use counter cannot establish history");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\pap_cycles::reason(state, undefined) != "", "A missing observer cannot admit a transaction");
}

unmatched_events_and_unseen_native_uses_cannot_establish_idle()
{
    state = spawnstruct();
    state.timespapused = 1;
    watch = scripts\apparition\maps\spaceland\pap_cycles::create();
    watch.state = "Listening";
    tests\support\checks::expect(scripts\apparition\maps\spaceland\pap_cycles::reason(state, watch) != "", "An event missed before observer startup keeps native history unknown");
    scripts\apparition\maps\spaceland\pap_cycles::observe(watch, true);
    tests\support\checks::expect(scripts\apparition\maps\spaceland\pap_cycles::reason(state, watch) != "", "An observed start without completion remains busy");
    scripts\apparition\maps\spaceland\pap_cycles::observe(watch, false);
    tests\support\checks::expect(scripts\apparition\maps\spaceland\pap_cycles::reason(state, watch) == "", "All observed native cycles have completed");
    state.timespapused = 2;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\pap_cycles::reason(state, watch) != "", "A native counter increment before its start event blocks insertion");
    state.timespapused = 1;
    scripts\apparition\maps\spaceland\pap_cycles::observe(watch, false);
    tests\support\checks::expect(scripts\apparition\maps\spaceland\pap_cycles::reason(state, watch) != "", "Extra completion events cannot erase unknown cycle history");
}

completion_and_next_start_counts_do_not_depend_on_handler_order()
{
    state = spawnstruct();
    state.timespapused = 2;
    watch = scripts\apparition\maps\spaceland\pap_cycles::create();
    watch.state = "Listening";
    scripts\apparition\maps\spaceland\pap_cycles::observe(watch, true);
    scripts\apparition\maps\spaceland\pap_cycles::observe(watch, true);
    scripts\apparition\maps\spaceland\pap_cycles::observe(watch, false);
    tests\support\checks::expect(scripts\apparition\maps\spaceland\pap_cycles::reason(state, watch) != "", "A next start processed before the prior completion still leaves one active cycle");
    scripts\apparition\maps\spaceland\pap_cycles::observe(watch, false);
    tests\support\checks::expect(scripts\apparition\maps\spaceland\pap_cycles::reason(state, watch) == "", "Matching totals establish idle after both completions");
}

a_listener_that_starts_after_failed_arming_exits_without_waiting()
{
    watch = scripts\apparition\maps\spaceland\pap_cycles::create();
    watch.state = "Unavailable";
    probe = spawnstruct();
    probe.finished = false;
    level thread late_listener(watch, probe);
    deadline = getTime() + 1000;
    while (!probe.finished && getTime() < deadline)
        wait 0.05;
    // The local stop event bounds a broken listener without emitting native PAP events
    watch notify("apparition_stop_pap_watch");
    tests\support\checks::expect(probe.finished && watch.waiting == 0, "A late listener cannot survive a failed handshake or alter its counters");
}

late_listener(watch, probe)
{
    scripts\apparition\maps\spaceland\pap_cycles::listen(watch, true);
    probe.finished = true;
}
