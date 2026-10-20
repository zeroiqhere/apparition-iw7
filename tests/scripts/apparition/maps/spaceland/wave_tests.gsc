// Countable native deaths may accelerate the wait but never replace its event

run()
{
    admission_requires_native_stage_and_death_bookkeeping();
    counter_and_pause_gates_stop_future_damage_without_claiming_completion();
    new_regular_wave_is_protected_even_before_the_listener_runs();
    event_clearing_requires_the_known_native_dispatcher();
    only_native_quest_advance_completes_the_job();
    status_tracks_submission_gates_and_reservation_lifetime();
    a_regular_wave_boundary_survives_cancel_and_restart();
}

admission_requires_native_stage_and_death_bookkeeping()
{
    state = tests\fixtures\spaceland::wave();
    tests\support\checks::expect(scripts\apparition\maps\spaceland\wave::reason(state) == "", "A registered native wait stage with known counters admits clearing");
    state._id_13F4D["ufo"][5]._id_DB5D = scripts\cp\maps\cp_zmb\cp_zmb_dj::blank;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\wave::reason(state) != "", "A replaced quest body cannot authorize wave clearing");
    state = tests\fixtures\spaceland::wave();
    state.spawnloopupdatefunc = undefined;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\wave::reason(state) != "", "Unknown death bookkeeping cannot accept menu kills");
    state = tests\fixtures\spaceland::wave();
    state.current_enemy_deaths = undefined;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\wave::reason(state) != "", "An unknown counter is unavailable rather than assumed empty");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\wave::progress(state).kills == -1, "The unknown counter is displayed separately from zero");
    state = tests\fixtures\spaceland::wave();
    state._id_13F1B["ufo"] = 6;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\wave::reason(state) != "", "Later quest stages cannot start another wave-clear job");
}

counter_and_pause_gates_stop_future_damage_without_claiming_completion()
{
    state = tests\fixtures\spaceland::wave();
    job = tests\fixtures\spaceland::wave_job(state);
    ticket = tests\fixtures\spaceland::armed_ticket();
    tests\support\checks::expect(scripts\apparition\maps\spaceland\wave::can_submit(state, job, ticket), "An armed active job can clear the initial native wave");
    state.current_enemy_deaths = state.desired_enemy_deaths_this_wave;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\wave::can_submit(state, job, ticket), "A full counter stops further packets while the native loop returns");
    state.current_enemy_deaths = 0;
    state.flag["pause_wave_progression"] = 1;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\wave::can_submit(state, job, ticket), "Paused progression cannot consume countable actors");
    state.flag["pause_wave_progression"] = 0;
    state.zombies_paused = 1;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\wave::can_submit(state, job, ticket), "Native spawn pause suspends menu packets");
    state.zombies_paused = 0;
    state.nuke_zombies_paused = 1;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\wave::can_submit(state, job, ticket), "An active native nuke pause is not disturbed");
}

new_regular_wave_is_protected_even_before_the_listener_runs()
{
    state = tests\fixtures\spaceland::wave();
    job = tests\fixtures\spaceland::wave_job(state);
    ticket = tests\fixtures\spaceland::armed_ticket();
    state.wave_num++;
    state.current_enemy_deaths = 0;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\wave::can_submit(state, job, ticket), "A new regular-wave number blocks extra hits even if its listener has not run yet");
    state.spawn_event_running = 1;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\wave::can_submit(state, job, ticket), "A known native event round may be cleared before the required next regular round");
    ticket.state = "Received";
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\wave::can_submit(state, job, ticket), "An observed regular-wave event immediately blocks all future packets");
    ticket.state = "Armed";
    job.state = "Observing native advance";
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\wave::can_submit(state, job, ticket), "The observation phase cannot reenter damage submission");
}

event_clearing_requires_the_known_native_dispatcher()
{
    state = tests\fixtures\spaceland::wave();
    job = tests\fixtures\spaceland::wave_job(state);
    ticket = tests\fixtures\spaceland::armed_ticket();
    state.spawn_event_running = 1;
    state.available_event_func = scripts\cp\maps\cp_zmb\cp_zmb_dj::blank;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\wave::can_submit(state, job, ticket), "An unknown event selector suspends clearing rather than guessing its target set");
    state.available_event_func = undefined;
    state.special_zombie_spawn_func = scripts\cp\maps\cp_zmb\cp_zmb_dj::blank;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\wave::can_submit(state, job, ticket), "A changed special-wave spawner cannot inherit the default native policy");
    state.special_zombie_spawn_func = undefined;
    state.event_funcs_start = scripts\cp\maps\cp_zmb\cp_zmb_dj::blank;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\wave::can_submit(state, job, ticket), "An unknown event-start hook pauses inputs");
    state.event_funcs_start = undefined;
    state.event_funcs_init = scripts\cp\maps\cp_zmb\cp_zmb_dj::blank;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\wave::can_submit(state, job, ticket), "An unknown event initializer cannot inherit the native event policy");
    state.event_funcs_init = undefined;
    state.event_funcs_end = scripts\cp\maps\cp_zmb\cp_zmb_dj::blank;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\wave::can_submit(state, job, ticket), "An unknown event-end hook pauses inputs");
    state.event_funcs_end = undefined;
    state.goon_spawner_patch_func = scripts\cp\maps\cp_zmb\cp_zmb_dj::blank;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\wave::can_submit(state, job, ticket), "A foreign spawner patch cannot inherit the normal Spaceland policy");
    state.goon_spawner_patch_func = scripts\cp\maps\cp_zmb\cp_zmb::cp_zmb_goon_spawner_patch_func;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\wave::can_submit(state, job, ticket), "The native Spaceland patch only moves the known clown spawners");
    state.event_funcs["goon"] = scripts\cp\maps\cp_zmb\cp_zmb_dj::blank;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\wave::can_submit(state, job, ticket), "A replaced event callback cannot inherit the native clown-wave policy");
    state.event_funcs["goon"] = scripts\cp\zombies\zombies_spawning::goon_spawn_event_func;
    state.agent_funcs["zombie_clown"]["on_killed"] = scripts\cp\maps\cp_zmb\cp_zmb_dj::blank;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\wave::can_submit(state, job, ticket), "A changed clown death path makes event clearing unavailable instead of silently skipping every target");
}

only_native_quest_advance_completes_the_job()
{
    state = tests\fixtures\spaceland::wave();
    job = tests\fixtures\spaceland::wave_job(state);
    state.current_enemy_deaths = state.desired_enemy_deaths_this_wave;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\wave::outcome(state, job, true, false) == "", "A full counter is not quest completion");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\wave::outcome(state, job, true, true) == "Pending", "The deadline cannot substitute for native advancement");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\wave::outcome(state, job, false, false) == "Unavailable", "Lost living private-host permission stops future inputs");
    state.wave_num = job.wave - 1;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\wave::outcome(state, job, true, false) == "Unavailable", "A rewound wave cannot reuse a previous clearing reservation");
    state.wave_num = job.wave;
    state._id_13F1B["ufo"] = 6;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\wave::outcome(state, job, true, true) == "Completed", "Only the native next quest stage confirms completion");
    job.state = "Cancelling";
    tests\support\checks::expect(scripts\apparition\maps\spaceland\wave::outcome(state, job, true, true) == "Cancelled", "Accepted cancellation wins over simultaneous progression");
}

status_tracks_submission_gates_and_reservation_lifetime()
{
    state = tests\fixtures\spaceland::wave();
    job = tests\fixtures\spaceland::wave_job(state);
    state.apparition_wave_job = job;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\wave::running(job), "The active worker reserves Start until its level thread exits");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\wave::status(state) == "Clearing eligible wave enemies", "A ready normal wave reports its actual submission phase");
    state.spawn_event_running = 1;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\wave::status(state) == "Clearing native event round", "The known native clown round is shown separately");
    state.current_enemy_deaths = state.desired_enemy_deaths_this_wave;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\wave::status(state) == "Waiting for the next regular-wave event", "An event round at quota cannot still advertise clearing");
    job.state = "Observing native advance";
    tests\support\checks::expect(scripts\apparition\maps\spaceland\wave::running(job), "A received regular-wave event holds the reservation until native quest confirmation");
    job.state = "Cancelling";
    tests\support\checks::expect(scripts\apparition\maps\spaceland\wave::running(job) && scripts\apparition\maps\spaceland\wave::status(state) == "Cancelling", "Accepted cancellation retains ownership through cleanup");
    foreach (terminal in ["Completed", "Cancelled", "Pending", "Unavailable"])
    {
        job.state = terminal;
        tests\support\checks::expect(!scripts\apparition\maps\spaceland\wave::running(job), "Terminal outcomes release the reservation for a future attempt");
    }
}

a_regular_wave_boundary_survives_cancel_and_restart()
{
    state = tests\fixtures\spaceland::wave();
    job = tests\fixtures\spaceland::wave_job(state);
    job.state = "Cancelled";
    state.apparition_wave_job = job;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\wave::reason(state) == "", "Cancellation before a native wave boundary permits another attempt in the same wave");
    job.regular_event = "regular_wave_starting";
    tests\support\checks::expect(scripts\apparition\maps\spaceland\wave::reason(state) != "", "A received regular-wave event remains spent after ticket cleanup and cancellation");
    job.regular_event = undefined;
    state.wave_num++;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\wave::reason(state) != "", "Restart cannot replace the original wave boundary during new-regular-wave listener lag");
    state.spawn_event_running = 1;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\wave::reason(state) == "", "A later known native event round can still resume an unconfirmed clear");
    state.available_event_func = scripts\cp\maps\cp_zmb\cp_zmb_dj::blank;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\wave::reason(state) != "", "Restart cannot bypass an unknown later event selector");
}
