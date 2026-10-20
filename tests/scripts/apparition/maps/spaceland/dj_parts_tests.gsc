// Collection contracts exercise native metadata without changing game state

run()
{
    catalog_matches_the_three_native_parts();
    native_flags_produce_complete_counts_or_unknown();
    all_collected_parts_need_no_live_models();
    collection_requires_the_registered_fetch_stage();
    valid_pending_parts_publish_the_complete_target_set();
    missing_or_malformed_pending_slots_publish_no_prefix();
    duplicate_points_and_models_are_rejected();
    live_admission_rejects_nonplayers_before_native_reads();
}

catalog_matches_the_three_native_parts()
{
    parts = scripts\apparition\maps\spaceland\dj_parts::catalog();
    tests\support\checks::expect(parts.size == 3, "The native fetch quest has exactly three part slots");
    if (parts.size != 3)
        return;

    tests\support\checks::expect(parts[0].slot == 1 && parts[0].id == "dj_quest_part_1"
        && parts[0].model == "zmb_frequency_device_radio", "Slot one matches the native radio part");
    tests\support\checks::expect(parts[1].slot == 2 && parts[1].id == "dj_quest_part_2"
        && parts[1].model == "zmb_frequency_device_calculator", "Slot two matches the native calculator part");
    tests\support\checks::expect(parts[2].slot == 3 && parts[2].id == "dj_quest_part_3"
        && parts[2].model == "zmb_frequency_device_umbrella_ground", "Slot three matches the native umbrella part");
}

native_flags_produce_complete_counts_or_unknown()
{
    state = part_state(0);
    result = scripts\apparition\maps\spaceland\dj_parts::inspect(state);
    tests\support\checks::expect(result.reason == "" && result.collected == 0
        && result.total == 3 && result.targets.size == 3, "Undefined native flags mean all three parts remain pending");

    state.dj_part_1_found = 1;
    state.dj_part_2_found = 0;
    result = scripts\apparition\maps\spaceland\dj_parts::inspect(state);
    tests\support\checks::expect(result.reason == "" && result.collected == 1
        && result.targets.size == 2, "Set numeric flags remove only their matching native slots");

    state.dj_part_3_found = 2;
    result = scripts\apparition\maps\spaceland\dj_parts::inspect(state);
    tests\support\checks::expect(result.collected == 2 && result.targets.size == 1,
        "Native truthy numeric flags remain counted as collected");

    foreach (bad in ["1", [], spawnstruct(), (1, 2, 3)])
    {
        state = part_state(0);
        state.dj_part_2_found = bad;
        result = scripts\apparition\maps\spaceland\dj_parts::inspect(state);
        tests\support\checks::expect(result.collected == -1 && result.targets.size == 0,
            "A malformed defined flag makes progress unknown and publishes no target prefix");
    }
}

all_collected_parts_need_no_live_models()
{
    state = tests\fixtures\spaceland::quest(1);
    state.dj_part_1_found = 1;
    state.dj_part_2_found = 1;
    state.dj_part_3_found = 1;
    // Native pickup deletes the model references after setting each found flag
    result = scripts\apparition\maps\spaceland\dj_parts::inspect(state);
    tests\support\checks::expect(result.reason == "All native DJ parts are collected"
        && result.collected == 3 && result.total == 3 && result.targets.size == 0,
        "All-collected state is reported without requiring the selected model list");
}

collection_requires_the_registered_fetch_stage()
{
    state = part_state(0);
    result = scripts\apparition\maps\spaceland\dj_parts::inspect(state);
    tests\support\checks::expect(result.reason == "" && result.collected == 0,
        "The registered native fetch step permits part inspection");

    state._id_13F1B["ufo"] = 1;
    result = scripts\apparition\maps\spaceland\dj_parts::inspect(state);
    tests\support\checks::expect(result.reason == "DJ parts are not the current quest step"
        && result.collected == 0 && result.targets.size == 0,
        "A different known quest step blocks pending part targets");

    state = part_state(0);
    state._id_13F4D["ufo"][0].init_func = undefined;
    result = scripts\apparition\maps\spaceland\dj_parts::inspect(state);
    tests\support\checks::expect(result.reason == "Wait for the native DJ quest state"
        && result.collected == 0 && result.targets.size == 0,
        "An unrelated or incomplete quest registry leaves stage readiness unknown");
}

valid_pending_parts_publish_the_complete_target_set()
{
    state = part_state(0);
    result = scripts\apparition\maps\spaceland\dj_parts::inspect(state);
    tests\support\checks::expect(result.reason == "" && result.targets.size == 3,
        "All three valid pending native records are returned in native slot order");
    if (result.targets.size == 3)
    {
        parts = scripts\apparition\maps\spaceland\dj_parts::catalog();
        for (index = 0; index < 3; index++)
            tests\support\checks::expect(result.targets[index] == state.selected_dj_parts[parts[index].slot],
                "Targets retain the exact selected native record identity");
    }

    state.dj_part_2_found = 1;
    state.selected_dj_parts[2] = undefined;
    result = scripts\apparition\maps\spaceland\dj_parts::inspect(state);
    tests\support\checks::expect(result.reason == "" && result.collected == 1
        && result.targets.size == 2, "A collected slot needs no model record after native deletion");
}

missing_or_malformed_pending_slots_publish_no_prefix()
{
    state = part_state(0);
    state.selected_dj_parts[2] = undefined;
    result = scripts\apparition\maps\spaceland\dj_parts::inspect(state);
    tests\support\checks::expect(result.reason != "" && result.collected == 0 && result.targets.size == 0,
        "A missing middle slot rejects the whole target list and preserves known progress");

    state = part_state(0);
    state.selected_dj_parts[3].groupname = "";
    result = scripts\apparition\maps\spaceland\dj_parts::inspect(state);
    tests\support\checks::expect(result.reason != "" && result.collected == 0 && result.targets.size == 0,
        "A malformed final slot cannot leave a usable earlier prefix");

    state = part_state(0);
    state.selected_dj_parts[3].part_model = undefined;
    result = scripts\apparition\maps\spaceland\dj_parts::inspect(state);
    tests\support\checks::expect(result.reason != "" && result.collected == 0 && result.targets.size == 0,
        "A pending part without its native model reference is unavailable");

    state = part_state(0);
    state.selected_dj_parts[3].script_noteworthy = "dj_quest_part_2";
    result = scripts\apparition\maps\spaceland\dj_parts::inspect(state);
    tests\support\checks::expect(result.reason != "" && result.collected == 0 && result.targets.size == 0,
        "A later slot with the wrong native part id rejects the whole target set");

    state = part_state(0);
    state.selected_dj_parts = "invalid";
    result = scripts\apparition\maps\spaceland\dj_parts::inspect(state);
    tests\support\checks::expect(result.reason != "" && result.collected == 0 && result.targets.size == 0,
        "A malformed native part registry publishes no targets");
}

duplicate_points_and_models_are_rejected()
{
    state = part_state(0);
    state.selected_dj_parts[2] = state.selected_dj_parts[1];
    result = scripts\apparition\maps\spaceland\dj_parts::inspect(state);
    tests\support\checks::expect(result.reason != "" && result.targets.size == 0,
        "One native point cannot stand in for two part slots");

    state = part_state(0);
    state.selected_dj_parts[2].part_model = state.selected_dj_parts[1].part_model;
    result = scripts\apparition\maps\spaceland\dj_parts::inspect(state);
    tests\support\checks::expect(result.reason != "" && result.targets.size == 0,
        "Two selected native points cannot share one part model entity");
}

live_admission_rejects_nonplayers_before_native_reads()
{
    result = scripts\apparition\maps\spaceland\dj_parts::probe(undefined);
    tests\support\checks::expect(result.reason != "" && result.collected == -1
        && result.targets.size == 0, "An absent actor is rejected before level part state is read");
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\dj_parts::collect(undefined),
        "Collection cannot invoke the native callback for an absent actor");

    owner = spawnstruct();
    result = scripts\apparition\maps\spaceland\dj_parts::probe(owner);
    tests\support\checks::expect(result.reason != "" && result.collected == -1
        && result.targets.size == 0, "A nonplayer actor is rejected before level part state is read");
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\dj_parts::collect(owner),
        "Collection cannot invoke the native callback for a nonplayer actor");
}

part_state(step)
{
    state = tests\fixtures\spaceland::quest(step);
    state.selected_dj_parts = [];
    state.current_interaction_structs = [];
    parts = scripts\apparition\maps\spaceland\dj_parts::catalog();
    foreach (part in parts)
    {
        point = spawnstruct();
        point.script_noteworthy = part.id;
        point.groupname = "area_" + part.slot;
        point.part_model = spawnstruct();
        point.part_model.model = part.model;
        point.part_model.origin = (part.slot, 2, 3);
        state.selected_dj_parts[part.slot] = point;
        state.current_interaction_structs[state.current_interaction_structs.size] = point;
    }
    return state;
}
