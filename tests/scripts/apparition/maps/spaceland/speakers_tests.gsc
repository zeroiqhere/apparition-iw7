// Native defenses retain their timer, success cleanup and wave advancement

run()
{
    admission_requires_the_current_native_defense_and_live_model();
    only_native_assigned_zombies_can_receive_assist_damage();
    pickup_requires_native_success_and_the_original_model();
    only_native_stage_advancement_completes_the_observer();
    late_pickup_requires_recorded_native_success_and_original_identity();
    pickup_claim_survives_cancellation_and_worker_reference_release();
    assist_waits_for_the_capture_listener_and_exact_current_identity();
    pickup_revalidation_rejects_intervening_physical_input_and_failure();
}

pickup_revalidation_rejects_intervening_physical_input_and_failure()
{
    state = tests\fixtures\spaceland::speaker_pickup(2);
    job = spawnstruct();
    job.defense = state.apparition_speaker_capture;
    job.state = "Awaiting pickup";
    job.defense.ticket.state = "Received";
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\speakers::claim_pickup(state, job), "Physical input during the grace period prevents a menu trigger before history sampling");
    tests\support\checks::expect(job.state == "Awaiting pickup" && !job.defense.submitted, "Rejected input cannot move the worker into its submitted phase");
    job.defense.ticket.state = "Armed";
    state.use_dj_door_func = scripts\cp\maps\cp_zmb\cp_zmb_dj::use_dj_door_after_fail_speaker_defense;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\speakers::claim_pickup(state, job), "A native failure observed after the grace period cannot be overridden by a stale ready result");
}

assist_waits_for_the_capture_listener_and_exact_current_identity()
{
    state = tests\fixtures\spaceland::speaker(2);
    tests\support\checks::expect(scripts\apparition\maps\spaceland\speakers::assist_reason(state) != "", "A native active model alone cannot bypass capture-listener readiness");
    state.apparition_speaker_capture = tests\fixtures\spaceland::speaker_capture(state);
    tests\support\checks::expect(scripts\apparition\maps\spaceland\speakers::assist_reason(state) == "", "A listening capture of the current native model admits assistance");
    state.apparition_speaker_capture.ticket.state = "Cancelled";
    tests\support\checks::expect(scripts\apparition\maps\spaceland\speakers::assist_reason(state) != "", "A canceled receipt listener cannot admit a worker");
    state.apparition_speaker_capture.ticket.state = "Armed";
    state.apparition_speaker_capture.speaker = spawnstruct();
    tests\support\checks::expect(scripts\apparition\maps\spaceland\speakers::assist_reason(state) != "", "A stale capture cannot authorize the current active model");
}

admission_requires_the_current_native_defense_and_live_model()
{
    for (step = 2; step <= 4; step++)
    {
        state = tests\fixtures\spaceland::speaker(step);
        tests\support\checks::expect(scripts\apparition\maps\spaceland\speakers::reason(state) == "", "Each registered native defense stage can admit its current active model");
    }
    state.current_speaker = undefined;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\speakers::reason(state) != "", "An unplaced or completed speaker cannot start another combat worker");
    state = tests\fixtures\spaceland::speaker(2);
    state._id_13F4D["ufo"][2]._id_DB5D = scripts\cp\maps\cp_zmb\cp_zmb_dj::blank;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\speakers::context_reason(state) != "", "A changed native body cannot authorize speaker actions");
    state = tests\fixtures\spaceland::speaker(5);
    tests\support\checks::expect(scripts\apparition\maps\spaceland\speakers::context_reason(state) != "", "The wave-wait stage cannot reuse defense actions");
    state = tests\fixtures\spaceland::speaker(2);
    state.flag["pause_wave_progression"] = 0;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\speakers::reason(state) != "", "The native wave hold must be established before combat input");
    state.flag["pause_wave_progression"] = 1;
    state.current_speaker.model = "decorative_speaker";
    tests\support\checks::expect(scripts\apparition\maps\spaceland\speakers::reason(state) != "", "An unrelated model cannot enter the assist");
}

only_native_assigned_zombies_can_receive_assist_damage()
{
    state = tests\fixtures\spaceland::speaker(2);
    enemy = spawnstruct();
    enemy.agent_type = "generic_zombie";
    enemy.species = "zombie";
    enemy.team = "axis";
    enemy.health = 100;
    enemy.origin = (1, 0, 0);
    enemy.active_speaker_attacker = 1;
    enemy.favoriteenemy = state.frequency_device_clip;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\speakers::eligible(enemy, state.frequency_device_clip), "An assigned attacker targets this exact native speaker clip");
    enemy.favoriteenemy = spawnstruct();
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\speakers::eligible(enemy, state.frequency_device_clip), "An attacker assigned to another target is left alone");
    enemy.favoriteenemy = state.frequency_device_clip;
    enemy.active_speaker_attacker = 0;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\speakers::eligible(enemy, state.frequency_device_clip), "A roaming zombie without native attacker assignment is excluded");
    enemy.active_speaker_attacker = 1;
    enemy.agent_type = "zombie_brute";
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\speakers::eligible(enemy, state.frequency_device_clip), "Native speaker assignment excludes Brutes from its attacker set");
    enemy.agent_type = "zombie_ghost";
    tests\support\checks::expect(scripts\apparition\maps\spaceland\speakers::eligible(enemy, state.frequency_device_clip), "Native species and assignment identity can include other non-Brute zombie types");
    enemy.agent_type = undefined;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\speakers::eligible(enemy, state.frequency_device_clip), "An assigned zombie without an optional type field follows the native selection rule");
    enemy.agent_type = "generic_zombie";
    enemy.health = 0;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\speakers::eligible(enemy, state.frequency_device_clip), "A dead attacker is excluded");
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\speakers::eligible(undefined, state.frequency_device_clip), "A deleted actor cannot receive input");
}

pickup_requires_native_success_and_the_original_model()
{
    state = tests\fixtures\spaceland::speaker(3);
    job = tests\fixtures\spaceland::speaker_job(state);
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\speakers::pickup_ready(state, job), "An active native timer cannot receive pickup input");
    state.flag["defense_sequence_active"] = 0;
    state.current_speaker = undefined;
    state.use_dj_door_func = scripts\cp\maps\cp_zmb\cp_zmb_dj::use_dj_door_to_pick_up_analyzer;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\speakers::pickup_ready(state, job), "Native success and exit readiness authorize the captured model only");
    job.state = "Collecting";
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\speakers::pickup_ready(state, job), "A submitted pickup phase cannot request another trigger");
    job.state = "Defending";
    state.frequency_device_clip = spawnstruct();
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\speakers::pickup_ready(state, job), "A replaced native clip invalidates the original defense identity");
    state.frequency_device_clip = job.defense.clip;
    state.use_dj_door_func = scripts\cp\maps\cp_zmb\cp_zmb_dj::use_dj_door_after_fail_speaker_defense;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\speakers::pickup_ready(state, job), "Native failure cannot be mistaken for pickup readiness");
}

only_native_stage_advancement_completes_the_observer()
{
    state = tests\fixtures\spaceland::speaker(4);
    job = tests\fixtures\spaceland::speaker_job(state);
    tests\support\checks::expect(scripts\apparition\maps\spaceland\speakers::outcome(state, job, true, false) == "", "An active native defense remains pending");
    job.state = "Observing native advance";
    job.defense.speaker = undefined;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\speakers::outcome(state, job, true, true) == "Pending", "Model removal alone cannot invent quest advancement");
    state._id_13F1B["ufo"] = 5;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\speakers::outcome(state, job, true, true) == "Completed", "Only the native next stage confirms completion");
    job.state = "Cancelling";
    tests\support\checks::expect(scripts\apparition\maps\spaceland\speakers::outcome(state, job, true, true) == "Cancelled", "Accepted cancellation wins over simultaneous progression");
    job.state = "Defending";
    state._id_13F1B["ufo"] = 4;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\speakers::outcome(state, job, false, false) == "Unavailable", "Lost host or actor permission stops further inputs");
    state.flag["defense_sequence_active"] = 0;
    state.use_dj_door_func = scripts\cp\maps\cp_zmb\cp_zmb_dj::use_dj_door_after_fail_speaker_defense;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\speakers::outcome(state, job, true, false) == "Failed", "The native retry callback identifies a failed defense");
}

late_pickup_requires_recorded_native_success_and_original_identity()
{
    for (step = 2; step <= 4; step++)
    {
        state = tests\fixtures\spaceland::speaker_pickup(step);
        capture = state.apparition_speaker_capture;
        tests\support\checks::expect(scripts\apparition\maps\spaceland\speakers::pickup_reason(state, capture) == "", "Each successful native defense permits its actual recorded model to be collected late");
    }
    tests\support\checks::expect(scripts\apparition\maps\spaceland\speakers::pickup_reason(state, undefined) != "", "A successful callback without an observed model cannot authorize a world scan");
    state.current_speaker = capture.speaker;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\speakers::pickup_reason(state, capture) != "", "A still-active native model cannot be collected early");
    state.current_speaker = undefined;
    state.flag["defense_sequence_active"] = 1;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\speakers::pickup_reason(state, capture) != "", "Native success must reach the inactive pickup boundary");
    state.flag["defense_sequence_active"] = 0;
    state.use_dj_door_func = scripts\cp\maps\cp_zmb\cp_zmb_dj::use_dj_door_after_fail_speaker_defense;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\speakers::pickup_reason(state, capture) != "", "Failure cannot authorize a late pickup");
    state.use_dj_door_func = scripts\cp\maps\cp_zmb\cp_zmb_dj::use_dj_door_to_pick_up_analyzer;
    capture.clip = spawnstruct();
    tests\support\checks::expect(scripts\apparition\maps\spaceland\speakers::pickup_reason(state, capture) != "", "A replaced clip invalidates the recorded defense");
    capture.clip = state.frequency_device_clip;
    capture.step--;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\speakers::pickup_reason(state, capture) != "", "A previous stage cannot reuse the surviving model identity");
    capture.step++;
    capture.speaker = undefined;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\speakers::pickup_reason(state, capture) != "", "A model already collected by a teammate cannot receive another trigger");
}

pickup_claim_survives_cancellation_and_worker_reference_release()
{
    state = tests\fixtures\spaceland::speaker_pickup(3);
    capture = state.apparition_speaker_capture;
    job = spawnstruct();
    job.defense = capture;
    job.state = "Awaiting pickup";
    tests\support\checks::expect(scripts\apparition\maps\spaceland\speakers::running(job), "Late pickup shares the active job reservation and cancel control");
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\speakers::can_attack(state, job), "A pickup-only job never enters combat assistance");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\speakers::claim_pickup(state, job), "Fresh native success admits one pickup claim");
    tests\support\checks::expect(capture.submitted && job.state == "Collecting", "The durable claim and collecting phase are stored before input");
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\speakers::claim_pickup(state, job), "A claimed model cannot submit another menu pickup");
    job.state = "Cancelled";
    job.defense = undefined;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\speakers::pickup_reason(state, state.apparition_speaker_capture) != "", "Cancellation and worker reference release cannot erase submitted history");
}
