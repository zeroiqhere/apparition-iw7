// Data contracts inspect native admission without actors, damage or quest events

run()
{
    admission_requires_the_native_stage_and_registered_kill_path();
    native_sequence_must_exist_and_have_a_known_next_color();
    matching_floor_is_required_for_each_submission();
    external_kills_change_the_required_floor_without_cached_progress();
    empty_sequence_stops_damage_and_waits_for_native_advance();
    only_later_native_stage_confirms_completion();
    cancellation_timeout_and_lost_authority_stop_submissions();
    status_and_running_follow_the_owned_job();
    targets_use_the_shared_native_death_policy_without_a_ufo_stage_gate();
}

admission_requires_the_native_stage_and_registered_kill_path()
{
    state = tests\fixtures\ghosts::dance();
    tests\support\checks::expect(scripts\apparition\maps\spaceland\dance::reason(state) == "", "The registered native dance stage admits the assist");
    state._id_13F1B["ghost"] = 1;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\dance::reason(state) != "", "Another Ghosts stage cannot admit dance kills");
    state = tests\fixtures\ghosts::dance();
    state._id_13F4D["ghost"][2]._id_DB5D = scripts\cp\maps\cp_zmb\cp_zmb_ghost_activation::blank;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\dance::reason(state) != "", "Changed native quest work cannot inherit the assist");
    state = tests\fixtures\ghosts::dance();
    state.onzombiekilledfunc = undefined;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\dance::reason(state) != "", "A missing native dance kill callback blocks admission");
    state = tests\fixtures\ghosts::dance();
    state.agent_funcs["generic_zombie"]["gametype_on_killed"] = undefined;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\dance::reason(state) != "", "An unverified generic death callback cannot receive assist damage");
    state = tests\fixtures\ghosts::dance();
    state.spawned_enemies = undefined;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\dance::reason(state) != "", "A missing live native roster is not an empty ready roster");
}

native_sequence_must_exist_and_have_a_known_next_color()
{
    state = tests\fixtures\ghosts::dance();
    state.kill_order_on_dance_floor = undefined;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\dance::reason(state) != "", "An absent native order is unavailable");
    state.kill_order_on_dance_floor = ["red"];
    tests\support\checks::expect(scripts\apparition\maps\spaceland\dance::reason(state) != "", "An unknown next color cannot authorize damage");
    foreach (color in ["green", "blue", "pink", "black"])
    {
        state.kill_order_on_dance_floor = [color];
        tests\support\checks::expect(scripts\apparition\maps\spaceland\dance::reason(state) == "", "Each actual native tile color is recognized");
    }
}

matching_floor_is_required_for_each_submission()
{
    state = tests\fixtures\ghosts::dance();
    job = state.apparition_dance_job;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\dance::can_submit(state, job, "green", true), "A current active authorized job can submit from the matching floor");
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\dance::can_submit(state, job, "blue", true), "A different floor blocks submission");
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\dance::can_submit(state, job, undefined, true), "Standing outside native tile volumes blocks submission");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\dance::floor_reason("green", undefined) != "", "An unknown floor gives a visible movement instruction");
}

external_kills_change_the_required_floor_without_cached_progress()
{
    state = tests\fixtures\ghosts::dance();
    job = state.apparition_dance_job;
    state.kill_order_on_dance_floor = ["blue", "pink", "black"];
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\dance::can_submit(state, job, "green", true), "An external native kill invalidates the old floor immediately");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\dance::can_submit(state, job, "blue", true), "The next native color authorizes the newly matching host position");
    tests\support\checks::expect(state.kill_order_on_dance_floor.size == 3 && state.kill_order_on_dance_floor[0] == "blue", "Admission never advances or copies back the native sequence");
}

empty_sequence_stops_damage_and_waits_for_native_advance()
{
    state = tests\fixtures\ghosts::dance();
    job = state.apparition_dance_job;
    state.kill_order_on_dance_floor = [];
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\dance::can_submit(state, job, "black", true), "Zero remaining kills blocks further packets before the quest thread advances");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\dance::outcome(state, job, true, false) == "", "An empty native list alone is not completed");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\dance::status(state) == "Waiting for native advance", "The status distinguishes observation from completion");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\dance::reason(state) != "", "An empty sequence cannot start another damage assist");
}

only_later_native_stage_confirms_completion()
{
    state = tests\fixtures\ghosts::dance();
    job = state.apparition_dance_job;
    state._id_13F1B["ghost"] = 3;
    state.onzombiekilledfunc = undefined;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\dance::outcome(state, job, true, false) == "Completed", "Only a source-identified later quest stage confirms native completion");
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\dance::can_submit(state, job, "green", true), "A later stage cannot receive another dance packet");
    state._id_13F4D["ghost"][3]._id_DB5D = undefined;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\dance::outcome(state, job, true, false) == "Unavailable", "An unknown later-stage identity cannot prove completion");
}

cancellation_timeout_and_lost_authority_stop_submissions()
{
    state = tests\fixtures\ghosts::dance();
    job = state.apparition_dance_job;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\dance::outcome(state, job, false, false) == "Unavailable", "Death, disconnect or host loss ends authorization");
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\dance::can_submit(state, job, "green", false), "An unauthorized owner cannot submit a packet");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\dance::outcome(state, job, true, true) == "Pending", "A timeout leaves native completion unconfirmed");
    job.state = "Cancelling";
    tests\support\checks::expect(scripts\apparition\maps\spaceland\dance::outcome(state, job, true, false) == "Cancelled", "Cancellation has its own terminal result");
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\dance::can_submit(state, job, "green", true), "A cancelling job cannot submit another packet");
    job.state = "Active";
    state.apparition_dance_job = spawnstruct();
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\dance::can_submit(state, job, "green", true), "A replaced reservation cannot keep submitting");
}

status_and_running_follow_the_owned_job()
{
    state = tests\fixtures\ghosts::dance();
    job = state.apparition_dance_job;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\dance::running(job), "An active reservation is running");
    job.state = "Cancelling";
    tests\support\checks::expect(scripts\apparition\maps\spaceland\dance::running(job), "Cancellation retains its reservation until the worker exits");
    job.state = "Pending";
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\dance::running(job), "A terminal observation does not retain an active reservation");
    state.apparition_dance_job = undefined;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\dance::status(state) == "Idle", "No job has an idle status");
}

targets_use_the_shared_native_death_policy_without_a_ufo_stage_gate()
{
    state = tests\fixtures\ghosts::dance();
    enemy = tests\fixtures\spaceland::wave_enemy(state);
    tests\support\checks::expect(scripts\apparition\maps\spaceland\zombie_targets::eligible(state, enemy), "Native death eligibility is reusable without a UFO quest line");
    enemy.is_reserved = true;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\zombie_targets::eligible(state, enemy), "Quest-reserved actors remain excluded from dance assistance");
}
