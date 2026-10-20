// DJ admission checks use the actual native quest callback identities

run()
{
    a_pending_speaker_request_is_available_only_at_its_native_stage();
    an_already_requested_defense_cannot_be_requested_again();
    later_speaker_stages_allow_a_new_request_with_the_retained_native_flag();
    tone_generator_admission_requires_its_own_callback();
    an_unselected_or_busy_dj_blocks_requests();
    a_missing_native_request_reports_why_it_is_unavailable();
    an_invalid_owner_is_rejected_before_native_state_is_read();
    ready_probes_identify_the_native_request_kind();
}

a_pending_speaker_request_is_available_only_at_its_native_stage()
{
    state = dj_state(2, scripts\cp\maps\cp_zmb\cp_zmb_dj::use_dj_door_to_request_defense);
    tests\support\checks::expect(scripts\apparition\maps\spaceland\dj::request_kind(state) == "defense", "A native pending defense callback is recognized");
    state._id_13F1B["ufo"] = 5;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\dj::request_kind(state) == "", "The same callback outside speaker stages is rejected");
}

an_already_requested_defense_cannot_be_requested_again()
{
    state = dj_state(3, scripts\cp\maps\cp_zmb\cp_zmb_dj::use_dj_door_to_request_defense);
    state.flag["dj_request_defense_done"] = 1;
    state.apparition_dj_requested_step = 3;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\dj::request_kind(state) == "", "A pending native defense cannot duplicate its team effects");
    state.flag["dj_request_defense_done"] = 0;
    state.use_dj_door_func = scripts\cp\maps\cp_zmb\cp_zmb_dj::use_dj_door_after_fail_speaker_defense;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\dj::request_kind(state) == "defense", "The native failed-defense retry callback is recognized");
}

later_speaker_stages_allow_a_new_request_with_the_retained_native_flag()
{
    state = dj_state(3, scripts\cp\maps\cp_zmb\cp_zmb_dj::use_dj_door_to_request_defense);
    state.flag["dj_request_defense_done"] = 1;
    state.apparition_dj_requested_step = 2;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\dj::request_kind(state) == "defense", "Stage three can request after stage two retained the native flag");
    state._id_13F1B["ufo"] = 4;
    state.apparition_dj_requested_step = 3;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\dj::request_kind(state) == "defense", "Stage four can request after stage three retained the native flag");
}

tone_generator_admission_requires_its_own_callback()
{
    state = dj_state(6, scripts\cp\maps\cp_zmb\cp_zmb_dj::use_dj_door_to_get_tone_generator);
    tests\support\checks::expect(scripts\apparition\maps\spaceland\dj::request_kind(state) == "tone", "The native tone-generator request is recognized");
    state.use_dj_door_func = scripts\cp\maps\cp_zmb\cp_zmb_dj::use_dj_door_after_getting_tone_generator;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\dj::request_kind(state) == "", "A no-op callback cannot advertise an action");
}

an_unselected_or_busy_dj_blocks_requests()
{
    state = dj_state(2, scripts\cp\maps\cp_zmb\cp_zmb_dj::use_dj_door_to_request_defense);
    tests\support\checks::expect(request_reason(state, 500) == "", "An idle selected DJ can receive the request");
    state.selected_dj_door.selected = 0;
    tests\support\checks::expect(request_reason(state, 500) == "Wait for the selected native DJ door", "An unselected DJ door explains the blocked request");
    state.selected_dj_door.selected = 1;
    state.dj.current_state = "mic_loop";
    tests\support\checks::expect(request_reason(state, 500) == "Wait for the DJ to finish speaking", "The stock mic-loop denial explains the busy DJ");
    state.dj.current_state = "idle";
    state.apparition_dj_next_request = 1000;
    tests\support\checks::expect(request_reason(state, 999) == "Wait for the current DJ request cooldown", "The shared request cooldown explains its delay");
    tests\support\checks::expect(request_reason(state, 1000) == "", "The cooldown opens at its deadline");
}

a_missing_native_request_reports_why_it_is_unavailable()
{
    tests\support\checks::expect(request_reason(undefined, 500) == "Wait for native DJ quest data", "Missing native state stays unavailable with a reason");
    state = dj_state(6, scripts\cp\maps\cp_zmb\cp_zmb_dj::use_dj_door_to_get_tone_generator);
    state.dj = undefined;
    tests\support\checks::expect(request_reason(state, 500) == "Wait for the native DJ to be ready", "A missing DJ cannot advertise a ready request");
    state.dj = spawnstruct();
    tests\support\checks::expect(request_reason(state, 500) == "Wait for the native DJ to be ready", "An unknown native DJ state remains unavailable");
    state.dj.current_state = "idle";
    state.use_dj_door_func = scripts\cp\maps\cp_zmb\cp_zmb_dj::use_dj_door_after_getting_tone_generator;
    tests\support\checks::expect(request_reason(state, 500) == "Wait for the native DJ quest request", "A no-op native callback explains its pending state");
    state.use_dj_door_func = scripts\cp\maps\cp_zmb\cp_zmb_dj::use_dj_door_to_get_tone_generator;
    state.flag["tone_generators_given"] = 1;
    tests\support\checks::expect(request_reason(state, 500) == "Wait for the native DJ quest request", "An already accepted native request stays unavailable");
}

an_invalid_owner_is_rejected_before_native_state_is_read()
{
    result = scripts\apparition\maps\spaceland\dj::probe_owner(undefined);
    tests\support\checks::expect(result.reason != "" && result.kind == "", "An absent owner cannot reach the native DJ state");
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\dj::request(undefined), "An absent owner cannot commit native DJ effects");
}

dj_state(step, callback)
{
    state = tests\fixtures\spaceland::quest(step);
    state.flag["dj_request_defense_done"] = 0;
    state.flag["tone_generators_given"] = 0;
    state.selected_dj_door = spawnstruct();
    state.selected_dj_door.selected = 1;
    state.dj = spawnstruct();
    state.dj.current_state = "idle";
    state.use_dj_door_func = callback;
    return state;
}

request_reason(state, now)
{
    result = scripts\apparition\maps\spaceland\dj::probe(state, now);
    return result.reason;
}

ready_probes_identify_the_native_request_kind()
{
    state = dj_state(2, scripts\cp\maps\cp_zmb\cp_zmb_dj::use_dj_door_to_request_defense);
    result = scripts\apparition\maps\spaceland\dj::probe(state, 500);
    tests\support\checks::expect(result.reason == "" && result.kind == "defense",
        "A ready defense snapshot identifies the current native request");
    state = dj_state(6, scripts\cp\maps\cp_zmb\cp_zmb_dj::use_dj_door_to_get_tone_generator);
    result = scripts\apparition\maps\spaceland\dj::probe(state, 500);
    tests\support\checks::expect(result.reason == "" && result.kind == "tone",
        "A ready generator snapshot cannot be confused with a speaker request");
}
