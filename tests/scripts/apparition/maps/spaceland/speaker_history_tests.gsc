// Only an observed active native speaker can become a late pickup target

run()
{
    capture_uses_the_actual_active_model_clip_and_stage();
    repeated_observation_preserves_input_history();
    native_success_preserves_the_last_active_identity();
    a_new_native_model_gets_its_own_input_history();
    unknown_or_inactive_state_never_creates_a_capture();
    listener_readiness_and_received_input_survive_job_cancellation();
    retirement_keeps_a_real_trigger_receipt_before_releasing_its_ticket();
    retirement_cancels_an_unspent_listener_before_later_input();
    handshake_timeout_can_retry_only_during_the_same_unspent_active_defense();
    foreign_callbacks_and_replaced_native_identity_retire_history();
}

handshake_timeout_can_retry_only_during_the_same_unspent_active_defense()
{
    state = tests\fixtures\spaceland::speaker(2);
    capture = tests\fixtures\spaceland::speaker_capture(state);
    state.apparition_speaker_capture = capture;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\speaker_history::can_arm(state, capture), "An armed listener is reused without creating a duplicate");
    capture.ticket.state = "Cancelled";
    tests\support\checks::expect(scripts\apparition\maps\spaceland\speaker_history::can_arm(state, capture), "A readiness timeout can retry against the same unspent active model");
    capture.ticket.event = "trigger";
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\speaker_history::can_arm(state, capture), "A retained physical receipt can never be erased by rearming");
    capture.ticket.event = undefined;
    capture.submitted = true;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\speaker_history::can_arm(state, capture), "A submitted claim survives a canceled listener");
    capture.submitted = false;
    state.flag["defense_sequence_active"] = 0;
    state.current_speaker = undefined;
    state.use_dj_door_func = scripts\cp\maps\cp_zmb\cp_zmb_dj::use_dj_door_to_pick_up_analyzer;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\speaker_history::can_arm(state, capture), "A missing receipt window cannot be reopened after native success");
}

foreign_callbacks_and_replaced_native_identity_retire_history()
{
    state = tests\fixtures\spaceland::speaker_pickup(3);
    capture = state.apparition_speaker_capture;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\speaker_history::retained(state, capture), "The original successful model keeps its capture until pickup or stage advance");
    state.use_dj_door_func = scripts\cp\maps\cp_zmb\cp_zmb_dj::blank;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\speaker_history::retained(state, capture), "A foreign door callback retires a stale listener");
    state.use_dj_door_func = scripts\cp\maps\cp_zmb\cp_zmb_dj::use_dj_door_to_pick_up_analyzer;
    capture.clip = spawnstruct();
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\speaker_history::retained(state, capture), "A replaced native clip cannot keep a previous listener alive");
    capture.clip = state.frequency_device_clip;
    capture.step--;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\speaker_history::retained(state, capture), "Stage changes retire the previous defense's listener");
}

retirement_keeps_a_real_trigger_receipt_before_releasing_its_ticket()
{
    emitter = spawnstruct();
    capture = spawnstruct();
    capture.submitted = false;
    capture.ticket = scripts\apparition\runtime\events::arm(emitter, ["trigger"]);
    ticket = capture.ticket;
    emitter notify("trigger");
    wait 0.05;
    scripts\apparition\maps\spaceland\speaker_history::retire(capture);
    tests\support\checks::expect(capture.submitted && !isDefined(capture.ticket), "Retirement records actual physical-style input before releasing its listener handle");
    tests\support\checks::expect(ticket.state == "Cancelled", "The history owner cancels its spent ticket during retirement");
}

retirement_cancels_an_unspent_listener_before_later_input()
{
    emitter = spawnstruct();
    capture = spawnstruct();
    capture.submitted = false;
    capture.ticket = scripts\apparition\runtime\events::arm(emitter, ["trigger"]);
    ticket = capture.ticket;
    scripts\apparition\maps\spaceland\speaker_history::retire(capture);
    emitter notify("trigger");
    wait 0.05;
    tests\support\checks::expect(!capture.submitted && !isDefined(ticket.event), "Retired unspent history cannot observe input from a later native attempt");
}

capture_uses_the_actual_active_model_clip_and_stage()
{
    state = tests\fixtures\spaceland::speaker(2);
    capture = scripts\apparition\maps\spaceland\speaker_history::observe(state);
    tests\support\checks::expect(capture == state.apparition_speaker_capture, "The observer publishes one canonical captured identity");
    tests\support\checks::expect(capture.speaker == state.current_speaker && capture.clip == state.frequency_device_clip, "Capture retains native entity identities rather than searching by appearance");
    tests\support\checks::expect(capture.step == 2 && !capture.submitted, "A newly observed model starts without prior input history");
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\speaker_history::listening(capture), "A captured identity stays unavailable until its history-owned listener arms");
}

listener_readiness_and_received_input_survive_job_cancellation()
{
    state = tests\fixtures\spaceland::speaker_pickup(3);
    capture = state.apparition_speaker_capture;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\speaker_history::listening(capture), "The history-owned armed ticket can serve another worker after cancellation");
    scripts\apparition\maps\spaceland\speaker_history::record_trigger(capture);
    tests\support\checks::expect(!capture.submitted, "An armed listener alone cannot spend a pickup");
    capture.ticket.state = "Received";
    tests\support\checks::expect(scripts\apparition\maps\spaceland\speakers::pickup_reason(state, capture) != "", "A physical receipt blocks new input before the next history sample");
    scripts\apparition\maps\spaceland\speaker_history::record_trigger(capture);
    tests\support\checks::expect(capture.submitted, "Physical input becomes durable history even with no menu worker present");
    capture.ticket = undefined;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\speaker_history::listening(capture) && capture.submitted, "Retiring a ticket cannot erase a recorded input");
}

repeated_observation_preserves_input_history()
{
    state = tests\fixtures\spaceland::speaker(3);
    capture = scripts\apparition\maps\spaceland\speaker_history::observe(state);
    capture.submitted = true;
    again = scripts\apparition\maps\spaceland\speaker_history::observe(state);
    tests\support\checks::expect(again == capture && again.submitted, "Another sample of the same native defense cannot reset a submitted claim");
}

native_success_preserves_the_last_active_identity()
{
    state = tests\fixtures\spaceland::speaker(4);
    capture = scripts\apparition\maps\spaceland\speaker_history::observe(state);
    state.current_speaker = undefined;
    state.flag["defense_sequence_active"] = 0;
    state.use_dj_door_func = scripts\cp\maps\cp_zmb\cp_zmb_dj::use_dj_door_to_pick_up_analyzer;
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\speaker_history::observe(state)), "An inactive success state cannot invent a new captured model");
    tests\support\checks::expect(state.apparition_speaker_capture == capture && isDefined(capture.speaker), "The last actual model remains available after native current_speaker is cleared");
}

a_new_native_model_gets_its_own_input_history()
{
    state = tests\fixtures\spaceland::speaker(2);
    prior = scripts\apparition\maps\spaceland\speaker_history::observe(state);
    prior.submitted = true;
    state.current_speaker = tests\fixtures\spaceland::speaker(2).current_speaker;
    current = scripts\apparition\maps\spaceland\speaker_history::observe(state);
    tests\support\checks::expect(current != prior && current.speaker == state.current_speaker && !current.submitted, "A native retry with a new model receives a distinct unsent capture");
    tests\support\checks::expect(prior.submitted, "Replacing the current capture cannot erase an older observer's claim");
}

unknown_or_inactive_state_never_creates_a_capture()
{
    state = tests\fixtures\spaceland::speaker_pickup(2);
    state.apparition_speaker_capture = undefined;
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\speaker_history::observe(state)), "Loading after success without an earlier capture leaves ordinary pickup available");
    tests\support\checks::expect(!isDefined(state.apparition_speaker_capture), "An absent capture cannot be replaced by guessing a model");
    state = tests\fixtures\spaceland::speaker(2);
    state.use_dj_door_func = scripts\cp\maps\cp_zmb\cp_zmb_dj::blank;
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\speaker_history::observe(state)), "A foreign callback cannot populate a trusted native capture");
}
