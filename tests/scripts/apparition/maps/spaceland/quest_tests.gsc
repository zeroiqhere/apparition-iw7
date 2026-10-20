// Quest stage and final completion use fields read by native routines

run()
{
    current_stage_requires_the_native_spaceland_registry();
    malformed_quest_registry_and_stage_shapes_are_unknown_before_indexing();
    whole_valued_native_stages_are_normalized_before_array_lookup();
    final_stage_requires_the_native_finished_flag();
    malformed_final_flag_containers_do_not_confirm_completion();
}

current_stage_requires_the_native_spaceland_registry()
{
    state = spawnstruct();
    tests\support\checks::expect(scripts\apparition\maps\spaceland\quest::current_step(state) == -1, "An uninitialized quest has no current stage");
    state = tests\fixtures\spaceland::quest(4);
    tests\support\checks::expect(scripts\apparition\maps\spaceland\quest::current_step(state) == 4, "The registered native current index is read");
    state._id_13F1B["ufo"] = 12;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\quest::current_step(state) == -1, "An out-of-range current index is rejected");
    state._id_13F1B["ufo"] = 4;
    state._id_13F4D["ufo"][0].init_func = undefined;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\quest::current_step(state) == -1, "An unrelated registry cannot establish Spaceland readiness");
}

malformed_quest_registry_and_stage_shapes_are_unknown_before_indexing()
{
    tests\support\checks::expect(scripts\apparition\maps\spaceland\quest::current_step(undefined) == -1,
        "An absent map state cannot enter quest-field reads");
    foreach (bad in [7, "quest", (1, 2, 3), spawnstruct()])
    {
        state = tests\fixtures\spaceland::quest(4);
        state._id_13F4D = bad;
        tests\support\checks::expect(scripts\apparition\maps\spaceland\quest::current_step(state) == -1,
            "A nonarray native registry is rejected before the UFO line lookup");
        state = tests\fixtures\spaceland::quest(4);
        state._id_13F4D["ufo"] = bad;
        tests\support\checks::expect(scripts\apparition\maps\spaceland\quest::current_step(state) == -1,
            "A nonarray UFO line is rejected before step-zero lookup");
        state = tests\fixtures\spaceland::quest(4);
        state._id_13F1B = bad;
        tests\support\checks::expect(scripts\apparition\maps\spaceland\quest::current_step(state) == -1,
            "A nonarray current-stage table is rejected before line indexing");
    }
    foreach (bad in [7, "entry", (1, 2, 3), []])
    {
        state = tests\fixtures\spaceland::quest(4);
        state._id_13F4D["ufo"][0] = bad;
        tests\support\checks::expect(scripts\apparition\maps\spaceland\quest::current_step(state) == -1,
            "The native first-step initializer is read only from a struct entry");
        state = tests\fixtures\spaceland::quest(4);
        state._id_13F4D["ufo"][4] = bad;
        tests\support\checks::expect(scripts\apparition\maps\spaceland\quest::current_step(state) == -1,
            "A malformed selected native entry cannot establish a current stage");
    }
    foreach (bad in ["4", [], spawnstruct(), 0.5, 4.5, -1, 12, 2147483648.0, -2147483649.0])
    {
        state = tests\fixtures\spaceland::quest(4);
        state._id_13F1B["ufo"] = bad;
        tests\support\checks::expect(scripts\apparition\maps\spaceland\quest::current_step(state) == -1,
            "A nonnumeric, fractional, negative or out-of-range stage is rejected before array indexing");
    }
}

whole_valued_native_stages_are_normalized_before_array_lookup()
{
    foreach (stage in [0.0, 4.0, 11.0])
    {
        state = tests\fixtures\spaceland::quest(stage);
        tests\support\checks::expect(scripts\apparition\maps\spaceland\quest::current_step(state) == int(stage),
            "A bounded whole-valued native stage is converted to an integer before callback lookup");
    }
}

final_stage_requires_the_native_finished_flag()
{
    state = tests\fixtures\spaceland::quest(11);
    progress = scripts\apparition\maps\spaceland\quest::progress(state);
    tests\support\checks::expect(scripts\apparition\maps\spaceland\quest::stage_completed(progress, 10), "An earlier stage has returned before the next stage starts");
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\quest::stage_completed(progress, 11), "Entering the last stage does not imply finishing it");
    state.flag["ufo_quest_finished"] = 1;
    progress = scripts\apparition\maps\spaceland\quest::progress(state);
    tests\support\checks::expect(scripts\apparition\maps\spaceland\quest::stage_completed(progress, 11), "The native finished flag confirms the final stage");
}

malformed_final_flag_containers_do_not_confirm_completion()
{
    state = tests\fixtures\spaceland::quest(11);
    foreach (bad in [7, "flags", (1, 2, 3), spawnstruct()])
    {
        state.flag = bad;
        progress = scripts\apparition\maps\spaceland\quest::progress(state);
        tests\support\checks::expect(!progress.finished
            && !scripts\apparition\maps\spaceland\quest::stage_completed(progress, 11),
            "A nonarray native flag container cannot establish UFO quest completion");
    }
    state.flag = [];
    state.flag["ufo_quest_finished"] = 1;
    progress = scripts\apparition\maps\spaceland\quest::progress(state);
    tests\support\checks::expect(progress.finished
        && scripts\apparition\maps\spaceland\quest::stage_completed(progress, 11),
        "The native array flag record still confirms final-stage completion");
}
