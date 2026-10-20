// Placement uses the unique active native interaction and an owned admission lease

run()
{
    only_one_active_registered_native_spot_can_be_selected();
    active_events_and_changed_cost_or_callbacks_reject_placement();
    only_the_current_job_can_ignore_its_own_admission_reservation();
    slot_reservation_restores_only_owned_unchanged_state();
}

state()
{
    state = tests\fixtures\spaceland::speaker(2);
    state.current_speaker = undefined;
    state.flag["defense_sequence_active"] = 0;
    state.flag["pause_wave_progression"] = 0;
    state.current_interaction_structs = [tests\fixtures\spaceland::speaker_spot()];
    return state;
}

only_one_active_registered_native_spot_can_be_selected()
{
    state = state();
    spot = state.current_interaction_structs[0];
    tests\support\checks::expect(scripts\apparition\maps\spaceland\speaker_placement::spot(state) == spot && scripts\apparition\maps\spaceland\speaker_placement::reason(state) == "", "The single native active speaker location is selected");
    state.current_interaction_structs[state.current_interaction_structs.size] = tests\fixtures\spaceland::speaker_spot();
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\speaker_placement::spot(state)), "Multiple active locations are ambiguous and never guessed");
    state.current_interaction_structs = [];
    tests\support\checks::expect(scripts\apparition\maps\spaceland\speaker_placement::reason(state) != "", "An unselected native location cannot receive placement");
}

active_events_and_changed_cost_or_callbacks_reject_placement()
{
    state = state();
    state.flag["defense_sequence_active"] = 1;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\speaker_placement::reason(state) != "", "An active defense cannot be placed again");
    state.flag["defense_sequence_active"] = 0;
    state.spawn_event_running = 1;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\speaker_placement::reason(state) != "", "A special wave leaves normal speaker placement inactive");
    state.spawn_event_running = 0;
    state.interactions["dj_quest_speaker"].cost = 10;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\speaker_placement::reason(state) != "", "A changed paid interaction cannot use the native zero-cost action");
    state.interactions["dj_quest_speaker"].cost = 0;
    state.interactions["dj_quest_speaker"].activation_func = scripts\cp\maps\cp_zmb\cp_zmb_dj::blank;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\speaker_placement::reason(state) != "", "A foreign activation callback is never invoked or overwritten");
}

slot_reservation_restores_only_owned_unchanged_state()
{
    spot = tests\fixtures\spaceland::speaker_spot();
    lease = scripts\apparition\maps\spaceland\speaker_placement::reserve(spot);
    tests\support\checks::expect(isDefined(lease) && spot.in_use == 1 && spot.apparition_speaker_placement == lease, "The native admission slot is held before activation can yield");
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\speaker_placement::reserve(spot)), "A second action cannot reserve the same placement");
    scripts\apparition\maps\spaceland\speaker_placement::release(lease);
    tests\support\checks::expect(spot.in_use == 0 && !isDefined(spot.apparition_speaker_placement), "Owned unchanged admission restores its original false value");
    spot.in_use = undefined;
    lease = scripts\apparition\maps\spaceland\speaker_placement::reserve(spot);
    scripts\apparition\maps\spaceland\speaker_placement::release(lease);
    tests\support\checks::expect(!isDefined(spot.in_use), "An originally absent admission value remains absent after cleanup");
    lease = scripts\apparition\maps\spaceland\speaker_placement::reserve(spot);
    spot.in_use = 0;
    scripts\apparition\maps\spaceland\speaker_placement::release(lease);
    tests\support\checks::expect(spot.in_use == 0, "A later writer's changed admission value is preserved");
    lease = scripts\apparition\maps\spaceland\speaker_placement::reserve(spot);
    later_owner = spawnstruct();
    spot.apparition_speaker_placement = later_owner;
    scripts\apparition\maps\spaceland\speaker_placement::release(lease);
    tests\support\checks::expect(spot.apparition_speaker_placement == later_owner && spot.in_use == 1, "Lease cleanup never releases a slot now owned by another action");
}

only_the_current_job_can_ignore_its_own_admission_reservation()
{
    state = state();
    job = spawnstruct();
    job.state = "Placing";
    state.apparition_speaker_placement = job;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\speaker_placement::reason(state) != "", "The published job blocks another menu placement before its worker starts");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\speaker_placement::reason(state, job) == "", "Only the exact published job can revalidate without dropping its reservation");
    foreign = spawnstruct();
    tests\support\checks::expect(scripts\apparition\maps\spaceland\speaker_placement::reason(state, foreign) != "", "A foreign job cannot bypass the placement reservation");
}
