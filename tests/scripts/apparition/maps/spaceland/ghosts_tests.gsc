// Native state and model contracts run without changing quest or player state

run()
{
    every_native_stage_requires_its_registered_callbacks();
    absent_or_out_of_range_quest_data_is_unknown();
    malformed_quest_tables_and_stage_values_are_unknown_before_indexing();
    whole_valued_stage_numbers_are_normalized_before_array_indexing();
    malformed_progress_cannot_read_or_expose_a_previous_activation_receipt();
    last_index_and_active_arena_do_not_prove_cabinet_activation_or_victory();
    native_arena_outcomes_and_started_waves_remain_separate();
    native_initial_zero_and_a_fresh_retry_do_not_prove_failure();
    dance_hints_require_the_native_stage_and_kill_callback();
    skull_discovery_requires_one_model_at_a_source_site();
    sightline_uses_the_native_boundary_and_rejects_a_zero_aim_vector();
    face_admission_requires_the_actual_spell_stage();
}

every_native_stage_requires_its_registered_callbacks()
{
    catalog = scripts\apparition\maps\spaceland\ghosts::catalog();
    for (index = 0; index < catalog.size; index++)
    {
        state = tests\fixtures\ghosts::quest(index);
        tests\support\checks::expect(scripts\apparition\maps\spaceland\ghosts::current_step(state) == index, "A registered native Ghosts stage is recognized");
        state._id_13F4D["ghost"][index].init_func = undefined;
        tests\support\checks::expect(scripts\apparition\maps\spaceland\ghosts::current_step(state) == -1, "A missing native initializer makes stage identity unknown");
        state = tests\fixtures\ghosts::quest(index);
        state._id_13F4D["ghost"][index]._id_DB5D = undefined;
        tests\support\checks::expect(scripts\apparition\maps\spaceland\ghosts::current_step(state) == -1, "A missing native body makes stage identity unknown");
        state = tests\fixtures\ghosts::quest(index);
        state._id_13F4D["ghost"][index]._id_446D = undefined;
        tests\support\checks::expect(scripts\apparition\maps\spaceland\ghosts::current_step(state) == -1, "A missing native completion callback makes stage identity unknown");
    }
}

absent_or_out_of_range_quest_data_is_unknown()
{
    tests\support\checks::expect(scripts\apparition\maps\spaceland\ghosts::current_step(spawnstruct()) == -1, "Absent native Ghosts registration stays unknown");
    foreach (index in [-1, 7])
        tests\support\checks::expect(scripts\apparition\maps\spaceland\ghosts::current_step(tests\fixtures\ghosts::quest(index)) == -1, "An out-of-range stage cannot expose an action");
    state = tests\fixtures\ghosts::quest(1);
    state._id_13F4D["ghost"][0]._id_DB5D = undefined;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\ghosts::current_step(state) == -1, "The registered first step must identify the correct quest line");
}

malformed_quest_tables_and_stage_values_are_unknown_before_indexing()
{
    tests\support\checks::expect(scripts\apparition\maps\spaceland\ghosts::current_step(undefined) == -1,
        "A missing native state cannot enter quest-field reads");
    foreach (bad in [7, "quest", spawnstruct()])
    {
        state = tests\fixtures\ghosts::quest(0);
        state._id_13F4D = bad;
        tests\support\checks::expect(scripts\apparition\maps\spaceland\ghosts::current_step(state) == -1,
            "A nonarray quest registry is rejected before indexing its ghost line");
        state = tests\fixtures\ghosts::quest(0);
        state._id_13F4D["ghost"] = bad;
        tests\support\checks::expect(scripts\apparition\maps\spaceland\ghosts::current_step(state) == -1,
            "A nonarray ghost line is rejected before reading callback entries");
        state = tests\fixtures\ghosts::quest(0);
        state._id_13F1B = bad;
        tests\support\checks::expect(scripts\apparition\maps\spaceland\ghosts::current_step(state) == -1,
            "A nonarray native stage table is rejected before indexing the line");
        state = tests\fixtures\ghosts::quest(0);
        state._id_13F4D["ghost"][0] = bad;
        tests\support\checks::expect(scripts\apparition\maps\spaceland\ghosts::current_step(state) == -1,
            "A malformed native callback entry cannot be read as a struct");
    }
    foreach (bad in ["0", [], spawnstruct(), 0.5, 2147483648.0, -2147483649.0])
    {
        state = tests\fixtures\ghosts::quest(0);
        state._id_13F1B["ghost"] = bad;
        tests\support\checks::expect(scripts\apparition\maps\spaceland\ghosts::current_step(state) == -1,
            "A nonnumeric, fractional or unbounded stage is rejected before array indexing or integer conversion");
    }
    state = tests\fixtures\ghosts::quest(4);
    state._id_13F4D["ghost"][4] = 7;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\ghosts::current_step(state) == -1,
        "A malformed current entry cannot inherit a valid first callback");
}

whole_valued_stage_numbers_are_normalized_before_array_indexing()
{
    foreach (stage in [0.0, 3.0, 6.0])
    {
        state = tests\fixtures\ghosts::quest(stage);
        tests\support\checks::expect(scripts\apparition\maps\spaceland\ghosts::current_step(state) == int(stage),
            "A bounded whole-valued number becomes an integer key before reading registered callbacks");
    }
}

malformed_progress_cannot_read_or_expose_a_previous_activation_receipt()
{
    foreach (field in ["registry", "line", "stages", "entry"])
    {
        state = tests\fixtures\ghosts::quest(6);
        watch = spawnstruct();
        watch.observed = false;
        state.apparition_ghost_history = watch;
        scripts\apparition\maps\spaceland\ghost_history::install(state, watch);
        watch.observed = true;
        if (field == "registry")
            state._id_13F4D = 7;
        else if (field == "line")
            state._id_13F4D["ghost"] = 7;
        else if (field == "stages")
            state._id_13F1B = 7;
        else
            state._id_13F4D["ghost"][6] = 7;
        // A retained receipt cannot validate a replaced or malformed quest line
        progress = scripts\apparition\maps\spaceland\ghosts::progress(state);
        tests\support\checks::expect(progress.step == -1 && !progress.activated,
            "Invalid quest shape stops activation-history reads and keeps prior completion unconfirmed");
    }
}

last_index_and_active_arena_do_not_prove_cabinet_activation_or_victory()
{
    state = tests\fixtures\ghosts::quest(6);
    state.gns_active = 1;
    progress = scripts\apparition\maps\spaceland\ghosts::progress(state);
    tests\support\checks::expect(progress.active && !progress.activated && progress.last_result == "Unconfirmed", "Arena activity does not invent an original activation receipt or a win");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\ghosts::stage_completed(progress, 5), "Earlier native stages are complete when the final stage is selected");
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\ghosts::stage_completed(progress, 6), "The final selected index alone is not completed");
}

native_arena_outcomes_and_started_waves_remain_separate()
{
    state = tests\fixtures\ghosts::quest(6);
    state.ghostskulls_complete_status = 1;
    state.ghostskulls_total_waves = 5;
    progress = scripts\apparition\maps\spaceland\ghosts::progress(state);
    tests\support\checks::expect(progress.last_result == "Won" && progress.waves == 5, "Native win and started-wave observations keep their own meaning");
    tests\support\checks::expect(!progress.activated, "A win from another activation route does not invent the original quest receipt");
    state.ghostskulls_complete_status = 0;
    state.processing_ghost_wave_failing = 1;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\ghosts::progress(state).last_result == "Failed", "Native zero needs the actual failure-processing marker before reporting failure");
    state.ghostskulls_complete_status = undefined;
    state.ghostskulls_total_waves = undefined;
    progress = scripts\apparition\maps\spaceland\ghosts::progress(state);
    tests\support\checks::expect(progress.last_result == "Unconfirmed" && progress.waves == -1, "Missing native observations remain unknown rather than zero or failure");
}

native_initial_zero_and_a_fresh_retry_do_not_prove_failure()
{
    state = tests\fixtures\ghosts::quest(0);
    // Native analytics initializes both fields before any arena attempt
    state.ghostskulls_complete_status = 0;
    state.ghostskulls_total_waves = 0;
    progress = scripts\apparition\maps\spaceland\ghosts::progress(state);
    tests\support\checks::expect(progress.last_result == "Unconfirmed" && progress.waves == 0, "The native zero baseline is not an arena failure");
    state.gns_active = 1;
    state.processing_ghost_wave_failing = 0;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\ghosts::progress(state).last_result == "Unconfirmed", "The first active arena has no completed failure evidence");
    state.processing_ghost_wave_failing = 1;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\ghosts::progress(state).last_result == "Failed", "The native failure path supplies distinct evidence even during its exit delay");
    state.processing_ghost_wave_failing = 0;
    state.ghostskulls_total_waves = 9;
    progress = scripts\apparition\maps\spaceland\ghosts::progress(state);
    tests\support\checks::expect(progress.last_result == "Unconfirmed" && progress.waves == 9, "A retry clears failure evidence while retaining the map-wide started-wave count");
}

dance_hints_require_the_native_stage_and_kill_callback()
{
    state = tests\fixtures\ghosts::quest(2);
    state.onzombiekilledfunc = scripts\cp\maps\cp_zmb\cp_zmb_ghost_activation::check_kill_on_dance_floor;
    state.kill_order_on_dance_floor = ["blue", "blue", "pink", "black"];
    progress = scripts\apparition\maps\spaceland\ghosts::progress(state);
    tests\support\checks::expect(progress.next_floor == "blue" && progress.remaining_kills == 4, "Dance hints read the native next color and remaining kills");
    state.onzombiekilledfunc = undefined;
    progress = scripts\apparition\maps\spaceland\ghosts::progress(state);
    tests\support\checks::expect(progress.next_floor == "" && progress.remaining_kills == -1, "An absent native kill callback hides stale floor data");
    state.onzombiekilledfunc = scripts\cp\maps\cp_zmb\cp_zmb_ghost_activation::check_kill_on_dance_floor;
    state._id_13F1B["ghost"] = 3;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\ghosts::progress(state).next_floor == "", "Another stage cannot display the previous stage's floor instruction");
}

skull_discovery_requires_one_model_at_a_source_site()
{
    sites = scripts\apparition\maps\spaceland\ghosts::skull_sites();
    foreach (site in sites)
    {
        skull = tests\fixtures\models::model("zmb_8_bit_price", site);
        tests\support\checks::expect(scripts\apparition\maps\spaceland\ghosts::skull([skull]) == skull, "Each native random skull site can be discovered");
    }
    first = tests\fixtures\models::model("zmb_8_bit_price", sites[0]);
    second = tests\fixtures\models::model("zmb_8_bit_price", sites[1]);
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\ghosts::skull([first, second])), "Two source-site skulls are ambiguous");
    unrelated = tests\fixtures\models::model("zmb_8_bit_price", (0, 0, 0));
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\ghosts::skull([unrelated])), "A matching asset outside native skull sites is rejected");
}

sightline_uses_the_native_boundary_and_rejects_a_zero_aim_vector()
{
    eye = (0, 0, 20);
    target = (0, 0, 0);
    tests\support\checks::expect(scripts\apparition\maps\spaceland\ghosts::sight_reason(eye, target, (80, 0, 0)) == "", "The native squared-distance boundary of 6400 is inclusive");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\ghosts::sight_reason(eye, target, (81, 0, 0)) != "", "A trace past the native allowance blocks the face action");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\ghosts::sight_reason(eye, target, undefined) != "", "An unavailable trace cannot rotate the view");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\ghosts::sight_reason(target, target, target) != "", "A zero aim vector is rejected before native vector-to-angles");
}

face_admission_requires_the_actual_spell_stage()
{
    tests\support\checks::expect(scripts\apparition\maps\spaceland\ghosts::look_reason(tests\fixtures\ghosts::quest(1)) == "", "The native spell stage exposes face assistance");
    foreach (index in [0, 2, 3, 4, 5, 6])
        tests\support\checks::expect(scripts\apparition\maps\spaceland\ghosts::look_reason(tests\fixtures\ghosts::quest(index)) != "", "Other native stages cannot expose skull-facing input");
}
