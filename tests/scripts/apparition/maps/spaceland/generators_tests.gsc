// Generator admission follows native placement lists and interaction state

run()
{
    a_registered_placement_stage_is_available();
    another_stage_or_completed_activation_is_rejected();
    missing_or_disabled_native_structs_block_placement();
    an_inconsistent_remaining_list_is_rejected();
    previously_placed_generators_remain_available_for_activation();
    a_spawn_event_delays_center_activation();
}

a_registered_placement_stage_is_available()
{
    tests\support\checks::expect(scripts\apparition\maps\spaceland\generators::available(placement_state()), "Four active unplaced native structs allow placement");
}

another_stage_or_completed_activation_is_rejected()
{
    state = placement_state();
    state._id_13F1B["ufo"] = 8;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\generators::available(state), "Tone matching cannot rerun generator placement");
    state._id_13F1B["ufo"] = 7;
    state.flag["all_center_positions_used"] = 1;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\generators::available(state), "An activated center cannot be activated again");
}

missing_or_disabled_native_structs_block_placement()
{
    state = placement_state();
    state.alldjcenterstructs[0].disabled = 1;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\generators::available(state), "A disabled native interaction is not bypassed");
    state = placement_state();
    state.alldjcenterstructs[0].origin = undefined;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\generators::available(state), "A missing native spawn position is rejected");
}

an_inconsistent_remaining_list_is_rejected()
{
    state = placement_state();
    state.djcenterstructs = [];
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\generators::available(state), "The remaining placement list must match unplaced structs");
}

previously_placed_generators_remain_available_for_activation()
{
    state = placement_state();
    state.djcenterstructs = [];
    for (index = 0; index < 4; index++)
    {
        state.alldjcenterstructs[index].placed = 1;
        state.alldjcenterstructs[index].model = spawnstruct();
        state.alldjcenterstructs[index].tone = state.ufotones[index];
    }
    state.flag["all_structs_placed"] = 1;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\generators::available(state), "Existing native generators can finish center activation without respawning models");
}

a_spawn_event_delays_center_activation()
{
    state = placement_state();
    state.spawn_event_running = 1;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\generators::available(state), "A spawn event cannot silently bypass center aggregation");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\generators::hint(state) == "Wait for the current spawn event to finish", "The unavailable action explains the native spawn-event gate");
}

placement_state()
{
    state = tests\fixtures\spaceland::quest(7);
    state.flag["all_structs_placed"] = 0;
    state.flag["all_center_positions_used"] = 0;
    state.ufotones = ["speaker_tone_playback_01", "speaker_tone_playback_02", "speaker_tone_playback_03", "speaker_tone_playback_04"];
    state.alldjcenterstructs = [];
    state.djcenterstructs = [];
    state.current_interaction_structs = [];
    state.centerstructstriggered = [];
    state.players = [spawnstruct()];
    for (index = 0; index < 4; index++)
    {
        location = spawnstruct();
        location.origin = (index, 0, 0);
        state.alldjcenterstructs[index] = location;
        state.djcenterstructs[index] = location;
        state.current_interaction_structs[index] = location;
    }
    return state;
}
