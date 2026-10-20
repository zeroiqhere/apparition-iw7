// Data contracts validate policy without spawning actors or submitting damage

run()
{
    admission_requires_the_exact_initial_cabinet_step_and_native_roster();
    submitted_history_survives_timeout_and_owner_loss();
    target_selection_requires_one_exact_native_named_trigger();
    attacker_policy_requires_a_living_axis_brute_type();
    native_step_advance_is_the_only_completion_receipt();
    lost_authority_or_replaced_reservation_cannot_claim_progress();
    initial_scope_reports_its_native_line_and_route();
    unknown_submitted_history_cannot_silently_rearm();
    observed_reactivation_scope_requires_its_owned_native_attempt();
    a_new_settled_native_attempt_can_accept_a_fresh_input();
    normal_quest_completion_cannot_complete_reactivation_work();
    first_native_registration_admits_the_reactivation_route();
}

admission_requires_the_exact_initial_cabinet_step_and_native_roster()
{
    state = tests\fixtures\ghosts::cabinet();
    tests\support\checks::expect(scripts\apparition\maps\spaceland\brute_cabinet::reason(state) == "", "The source-identified initial Brute cabinet stage admits live probes");
    state._id_13F1B["ghost"] = 4;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\brute_cabinet::reason(state) != "", "The preceding floating skull cannot receive cabinet input");
    state = tests\fixtures\ghosts::cabinet();
    state._id_13F4D["ghost"][5]._id_DB5D = scripts\cp\maps\cp_zmb\cp_zmb_ghost_activation::blank;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\brute_cabinet::reason(state) != "", "An altered native body cannot inherit this target policy");
    state = tests\fixtures\ghosts::cabinet();
    state.agentarray = undefined;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\brute_cabinet::reason(state) != "", "The native live-agent helper requires its roster to exist");
}

submitted_history_survives_timeout_and_owner_loss()
{
    state = tests\fixtures\ghosts::cabinet();
    job = state.apparition_brute_cabinet_job;
    job.submitted = true;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\brute_cabinet::reason(state) != "", "An observing request cannot submit a second cabinet hit");
    job.state = "Pending";
    tests\support\checks::expect(scripts\apparition\maps\spaceland\brute_cabinet::reason(state) != "", "Timeout leaves ambiguous input spent");
    job.state = "Unavailable";
    tests\support\checks::expect(scripts\apparition\maps\spaceland\brute_cabinet::reason(state) != "", "Owner loss cannot reset submitted history");
    job.submitted = undefined;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\brute_cabinet::reason(state) == "", "A pre-input rejection remains retryable");
}

target_selection_requires_one_exact_native_named_trigger()
{
    target = tests\fixtures\ghosts::cabinet_trigger();
    tests\support\checks::expect(scripts\apparition\maps\spaceland\brute_cabinet::target([target]) == target, "A unique initialized named cabinet trigger is accepted");
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\brute_cabinet::target([])), "A missing native trigger is unavailable");
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\brute_cabinet::target([target, tests\fixtures\ghosts::cabinet_trigger()])), "Duplicate named native targets are ambiguous");
    target.targetname = "another_cabinet";
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\brute_cabinet::target([target])), "A different target cannot inherit cabinet damage");
    target = tests\fixtures\ghosts::cabinet_trigger();
    target.origin = undefined;
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\brute_cabinet::target([target])), "An unknown damage position cannot be submitted");
}

attacker_policy_requires_a_living_axis_brute_type()
{
    attacker = tests\fixtures\ghosts::brute();
    tests\support\checks::expect(scripts\apparition\maps\spaceland\brute_cabinet::eligible(attacker), "Native Brute fields admit the later real-entity checks");
    attacker.agent_type = "generic_zombie";
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\brute_cabinet::eligible(attacker), "Ordinary zombies cannot satisfy native Brute credit");
    attacker = tests\fixtures\ghosts::brute();
    attacker.team = "allies";
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\brute_cabinet::eligible(attacker), "A converted friendly Brute is outside the live axis query");
    attacker = tests\fixtures\ghosts::brute();
    attacker.health = 0;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\brute_cabinet::eligible(attacker), "A dead Brute cannot supply the requested input");
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\brute_cabinet::eligible(undefined), "A missing attacker cannot receive native credit");
}

native_step_advance_is_the_only_completion_receipt()
{
    state = tests\fixtures\ghosts::cabinet();
    job = state.apparition_brute_cabinet_job;
    job.submitted = true;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\brute_cabinet::outcome(state, job, true, false) == "", "Submission alone leaves native advancement unconfirmed");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\brute_cabinet::outcome(state, job, true, true) == "Pending", "The observation deadline does not invent completion");
    state._id_13F1B["ghost"] = 6;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\brute_cabinet::outcome(state, job, true, false) == "Completed", "A validated native Activate Cabinet stage confirms advancement");
    state._id_13F4D["ghost"][6]._id_DB5D = undefined;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\brute_cabinet::outcome(state, job, true, false) == "Unavailable", "An unknown later registration cannot prove progress");
}

lost_authority_or_replaced_reservation_cannot_claim_progress()
{
    state = tests\fixtures\ghosts::cabinet();
    job = state.apparition_brute_cabinet_job;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\brute_cabinet::outcome(state, job, false, false) == "Unavailable", "Owner death, laststand, disconnect or lost host status stops observation");
    state.apparition_brute_cabinet_job = spawnstruct();
    state._id_13F1B["ghost"] = 6;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\brute_cabinet::outcome(state, job, true, false) == "Unavailable", "A replaced reservation cannot claim a later worker's progress");
}

initial_scope_reports_its_native_line_and_route()
{
    state = tests\fixtures\ghosts::cabinet();
    selected = scripts\apparition\maps\spaceland\brute_cabinet::scope(state);
    tests\support\checks::expect(selected.reason == "" && selected.line == "ghost" && selected.route == "Initial Unlock", "The normal native stage identifies its own input route");
    tests\support\checks::expect(!isDefined(selected.attempt), "Initial unlock does not invent a repeatable reactivation attempt");
}

unknown_submitted_history_cannot_silently_rearm()
{
    state = tests\fixtures\ghosts::cabinet();
    job = state.apparition_brute_cabinet_job;
    job.submitted = true;
    job.line = undefined;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\brute_cabinet::reason(state) != "", "A submitted record with unknown native line cannot be replayed");
    job.line = "reactivateghost";
    tests\support\checks::expect(scripts\apparition\maps\spaceland\brute_cabinet::reason(state) != "", "A reactivation record without an observed attempt is ambiguous");
}

observed_reactivation_scope_requires_its_owned_native_attempt()
{
    state = tests\fixtures\ghosts::reactivation_cabinet();
    selected = scripts\apparition\maps\spaceland\brute_cabinet::scope(state);
    tests\support\checks::expect(selected.reason == "" && selected.line == "reactivateghost" && selected.route == "Reactivation", "An observed native restart selects the separate reactivation line");
    tests\support\checks::expect(selected.attempt == state.apparition_reactivation_history.attempt, "The selected scope carries its actual observed attempt identity");
    state.apparition_reactivation_history.attempt.ready = false;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\brute_cabinet::reason(state) != "", "An unresolved overlapping restart cannot admit new input");
    state.apparition_reactivation_history.attempt.ready = true;
    state.ghost_n_skull_reactivate_func = scripts\cp\maps\cp_zmb\cp_zmb_ghost_activation::blank;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\brute_cabinet::reason(state) != "", "Lost callback ownership cannot preserve an old reactivation receipt");
}

a_new_settled_native_attempt_can_accept_a_fresh_input()
{
    state = tests\fixtures\ghosts::reactivation_cabinet();
    job = state.apparition_brute_cabinet_job;
    job.submitted = true;
    job.state = "Pending";
    tests\support\checks::expect(scripts\apparition\maps\spaceland\brute_cabinet::reason(state) != "", "The same attempt cannot replay an unconfirmed submitted input");
    state._id_13F1B["reactivateghost"] = 1;
    watch = state.apparition_reactivation_history;
    state scripts\apparition\maps\spaceland\reactivation_history::route(state, watch, ::restart_native_line, ::supported_fixture);
    tests\support\checks::expect(watch.attempt != job.attempt && watch.attempt.ready, "A native callback after completed Brute progress creates a distinct attempt");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\brute_cabinet::reason(state) == "", "An earlier spent request does not block the newly observed settled restart");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\brute_cabinet::outcome(state, job, true, false) == "Unavailable", "An old worker cannot inherit the new native attempt");
}

normal_quest_completion_cannot_complete_reactivation_work()
{
    state = tests\fixtures\ghosts::reactivation_cabinet();
    job = state.apparition_brute_cabinet_job;
    job.submitted = true;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\brute_cabinet::outcome(state, job, true, false) == "", "The earlier normal stage-six baseline is not reactivation completion");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\brute_cabinet::outcome(state, job, true, true) == "Pending", "The same unresolved native reactivation still times out unconfirmed");
    state._id_13F1B["reactivateghost"] = 1;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\brute_cabinet::outcome(state, job, true, false) == "Completed", "Only native step one within the captured reactivation attempt confirms progress");
    state._id_13F4D["reactivateghost"][1]._id_DB5D = undefined;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\brute_cabinet::outcome(state, job, true, false) == "Unavailable", "Changed native reactivation callbacks cannot prove completion");
}

restart_native_line()
{
    // Simulate the native child reaching its first step on an isolated fixture
    self._id_13F1B["reactivateghost"] = 0;
}

supported_fixture()
{
    return true;
}

first_native_registration_admits_the_reactivation_route()
{
    state = tests\fixtures\ghosts::reactivation_cabinet();
    watch = state.apparition_reactivation_history;
    watch.attempt = undefined;
    state._id_13F4D["reactivateghost"] = undefined;
    state._id_13F1B["reactivateghost"] = undefined;
    state.apparition_brute_cabinet_job = undefined;
    state scripts\apparition\maps\spaceland\reactivation_history::route(state, watch, ::first_native_registration, ::supported_fixture);
    selected = scripts\apparition\maps\spaceland\brute_cabinet::scope(state);
    tests\support\checks::expect(selected.reason == "" && selected.route == "Reactivation", "First native registration followed by its first step admits the menu route");
    tests\support\checks::expect(selected.attempt == watch.attempt && selected.attempt.ready, "The first menu route carries the newly captured native callback receipt");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\brute_cabinet::reason(state) == "", "No prior request blocks this newly registered attempt");
}

first_native_registration()
{
    // Represent native registration and a child thread reaching its first step
    self._id_13F4D["reactivateghost"] = [tests\fixtures\reactivation::first_entry(), tests\fixtures\reactivation::activation_entry()];
    self._id_13F1B["reactivateghost"] = 0;
}
