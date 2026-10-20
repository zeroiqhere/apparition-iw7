// The input observer rejects extra notes instead of assuming exclusive control

run()
{
    an_expected_note_is_observed_once();
    unsolicited_notes_interrupt_a_listening_job();
    playback_inputs_do_not_interrupt_the_next_fresh_round();
    only_active_placed_interactions_can_send_notes();
    an_ack_requires_the_expected_note_and_no_native_failure();
    both_response_tickets_must_be_armed_before_a_native_note();
    a_cancelled_job_does_not_require_a_valid_actor_to_stop();
}

an_expected_note_is_observed_once()
{
    state = listening_state();
    job = expecting_note(state);
    location = state.alldjcenterstructs[2];
    scripts\apparition\maps\spaceland\tone_worker::observe(job, state, "03", location);
    tests\support\checks::expect(job.received_expected && !job.interference, "The expected native key and struct are accepted");
    scripts\apparition\maps\spaceland\tone_worker::observe(job, state, "03", location);
    tests\support\checks::expect(job.interference, "A duplicate note cannot be counted as a second expected input");
}

unsolicited_notes_interrupt_a_listening_job()
{
    state = listening_state();
    job = expecting_note(state);
    scripts\apparition\maps\spaceland\tone_worker::observe(job, state, "01", state.alldjcenterstructs[0]);
    tests\support\checks::expect(job.interference, "Another note interrupts the planned native sequence");
    job = expecting_note(state);
    scripts\apparition\maps\spaceland\tone_worker::observe(job, state, undefined, undefined);
    tests\support\checks::expect(job.interference, "The native slow-play timeout also interrupts the job");
}

playback_inputs_do_not_interrupt_the_next_fresh_round()
{
    state = listening_state();
    state.flag["ufo_listening"] = 0;
    job = expecting_note(state);
    scripts\apparition\maps\spaceland\tone_worker::observe(job, state, "01", state.alldjcenterstructs[0]);
    tests\support\checks::expect(!job.interference && !job.received_expected, "Inputs outside listening do not become pending notes for the fresh round");
}

only_active_placed_interactions_can_send_notes()
{
    state = listening_state();
    location = state.alldjcenterstructs[0];
    tests\support\checks::expect(scripts\apparition\maps\spaceland\tone_worker::location_enabled(state, location), "A placed active native interaction can play a note");
    location.disabled = 1;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\tone_worker::location_enabled(state, location), "Native deactivation prevents tone input");
    location.disabled = undefined;
    location.placed = 0;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\tone_worker::location_enabled(state, location), "A changed placement cannot fall through into native model spawning");
    location.placed = 1;
    location.model = undefined;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\tone_worker::location_enabled(state, location), "A removed model cannot receive native scriptable changes");
    state = listening_state();
    location = state.alldjcenterstructs[0];
    state.current_interaction_structs = [];
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\tone_worker::location_enabled(state, location), "An interaction outside the current native list cannot be invoked");
}

an_ack_requires_the_expected_note_and_no_native_failure()
{
    job = expecting_note(listening_state());
    job.ack = spawnstruct();
    job.failure = spawnstruct();
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\tone_worker::ack_result(job, "correct_tone_played")), "A missing response remains pending");
    job.ack.event = "correct_tone_played";
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\tone_worker::ack_result(job, "correct_tone_played")), "An unkeyed ack alone cannot accept a note");
    job.received_expected = true;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\tone_worker::ack_result(job, "correct_tone_played") == "", "An expected note and matching native ack allow the next input");
    job.failure.event = "incorrect_tone_played";
    tests\support\checks::expect(scripts\apparition\maps\spaceland\tone_worker::ack_result(job, "correct_tone_played") == "Native tone rejected", "A level-side rejection takes priority over a simultaneous success ack");
    job.failure.event = undefined;
    job.ack.event = "completed_tone_match";
    tests\support\checks::expect(scripts\apparition\maps\spaceland\tone_worker::ack_result(job, "correct_tone_played") == "Native tone rejected", "Round completion cannot substitute for an intermediate note ack");
    job.ack.event = "correct_tone_played";
    job.interference = true;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\tone_worker::ack_result(job, "correct_tone_played") == "Interrupted by tone input", "Observable interference prevents further notes even with an ack");
}

both_response_tickets_must_be_armed_before_a_native_note()
{
    job = expecting_note(listening_state());
    job.ack = spawnstruct();
    job.failure = spawnstruct();
    job.ack.state = "Armed";
    job.failure.state = "Arming";
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\tone_worker::ready_to_play(job), "An unfinished failure listener prevents native input");
    job.failure.state = "Armed";
    tests\support\checks::expect(scripts\apparition\maps\spaceland\tone_worker::ready_to_play(job), "Two ready listeners with no intervening input allow the note");
    job.ack.state = "Received";
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\tone_worker::ready_to_play(job), "An event captured during arming prevents a second input");
    job.ack.state = "Armed";
    job.received_expected = true;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\tone_worker::ready_to_play(job), "An identical note observed during arming cannot be sent again");
    job.received_expected = false;
    job.interference = true;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\tone_worker::ready_to_play(job), "Mismatched input during arming prevents native input");
}

a_cancelled_job_does_not_require_a_valid_actor_to_stop()
{
    job = spawnstruct();
    job.state = "Cancelling";
    job.interference = false;
    job.received_expected = false;
    level thread scripts\apparition\maps\spaceland\tone_worker::run(job);
    wait 0.05;
    tests\support\checks::expect(job.state == "Cancelled" || job.state == "Complete", "A queued cancellation is not overwritten before the worker checks it");
}

listening_state()
{
    state = tests\fixtures\spaceland::tones();
    state.flag["ufo_listening"] = 1;
    return state;
}

expecting_note(state)
{
    job = spawnstruct();
    job.expected_key = "03";
    job.expected_location = state.alldjcenterstructs[2];
    job.received_expected = false;
    job.interference = false;
    return job;
}
