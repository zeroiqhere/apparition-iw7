// Native-shaped data contracts submit no damage and change no quest registration

run()
{
    admission_requires_the_exact_native_skull_stage_and_destroyed_ufo();
    a_submitted_hit_blocks_replay_even_after_the_observer_stops();
    target_selection_accepts_only_the_native_asset_and_motion_path();
    ambiguous_or_dead_models_cannot_receive_the_input();
    only_known_later_native_progress_confirms_completion();
    authority_context_and_reservation_loss_stop_observation();
}

admission_requires_the_exact_native_skull_stage_and_destroyed_ufo()
{
    state = tests\fixtures\ghosts::floating();
    tests\support\checks::expect(scripts\apparition\maps\spaceland\floating_skull::reason(state) == "", "The actual skull stage after native UFO destruction admits readiness checks");
    state.flag["ufo_destroyed"] = false;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\floating_skull::reason(state) != "", "A selected stage alone cannot skip the native UFO wait");
    state.flag = undefined;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\floating_skull::reason(state) != "", "An unknown native flag registry is unavailable");
    state = tests\fixtures\ghosts::floating();
    state._id_13F1B["ghost"] = 3;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\floating_skull::reason(state) != "", "The arcade critical-shot stage cannot receive a laser hit");
    state = tests\fixtures\ghosts::floating();
    state._id_13F4D["ghost"][4]._id_DB5D = scripts\cp\maps\cp_zmb\cp_zmb_ghost_activation::blank;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\floating_skull::reason(state) != "", "An unfamiliar body cannot inherit source-specific target admission");
}

a_submitted_hit_blocks_replay_even_after_the_observer_stops()
{
    state = tests\fixtures\ghosts::floating();
    job = state.apparition_floating_skull_job;
    job.submitted = true;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\floating_skull::reason(state) != "", "A submitted native hit cannot be repeated during observation");
    job.state = "Pending";
    tests\support\checks::expect(scripts\apparition\maps\spaceland\floating_skull::reason(state) != "", "Timeout keeps ambiguous input history");
    job.state = "Unavailable";
    tests\support\checks::expect(scripts\apparition\maps\spaceland\floating_skull::reason(state) != "", "Owner or context loss cannot rearm a submitted request");
    job.submitted = undefined;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\floating_skull::reason(state) == "", "A pre-input rejection leaves a later attempt available");
}

target_selection_accepts_only_the_native_asset_and_motion_path()
{
    model = tests\fixtures\ghosts::floating_model();
    tests\support\checks::expect(scripts\apparition\maps\spaceland\floating_skull::select([model]) == model, "The native starting model is accepted");
    model.origin = (287, 621, 901);
    tests\support\checks::expect(scripts\apparition\maps\spaceland\floating_skull::select([model]) == model, "The sixth native leftward move remains in range");
    model.origin = (648.5, 621, 901);
    tests\support\checks::expect(scripts\apparition\maps\spaceland\floating_skull::select([model]) == model, "A moving model can occupy an intermediate x coordinate");
    foreach (origin in [(286, 621, 901), (1008, 621, 901), (648, 620, 901), (648, 621, 900)])
    {
        model.origin = origin;
        tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\floating_skull::select([model])), "A same-asset model outside the native path is rejected");
    }
    model = tests\fixtures\ghosts::floating_model();
    model.model = "zmb_8_bit_price";
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\floating_skull::select([model])), "A different Ghosts skull asset is not this damage target");
}

ambiguous_or_dead_models_cannot_receive_the_input()
{
    first = tests\fixtures\ghosts::floating_model();
    second = tests\fixtures\ghosts::floating_model();
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\floating_skull::select([first, second])), "Two matching live models are ambiguous across the complete scan");
    second.origin = (0, 0, 0);
    tests\support\checks::expect(scripts\apparition\maps\spaceland\floating_skull::select([second, first]) == first, "An unrelated remote same-asset model does not replace the valid target");
    first.health = 0;
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\floating_skull::select([first])), "A zero-health model cannot receive this request");
    first.health = undefined;
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\floating_skull::select([undefined, first])), "Missing models and uninitialized native health are unavailable");
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\floating_skull::select([])), "An empty scan does not invent a target");
}

only_known_later_native_progress_confirms_completion()
{
    state = tests\fixtures\ghosts::floating();
    job = state.apparition_floating_skull_job;
    job.submitted = true;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\floating_skull::outcome(state, job, true, false) == "", "A submitted hit alone is not completed");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\floating_skull::outcome(state, job, true, true) == "Pending", "The local observer bound leaves completion unconfirmed");
    state._id_13F1B["ghost"] = 5;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\floating_skull::outcome(state, job, true, false) == "Completed", "A source-identified later native quest stage confirms advancement");
    state._id_13F4D["ghost"][5]._id_DB5D = undefined;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\floating_skull::outcome(state, job, true, false) == "Unavailable", "An unknown later-stage body cannot prove native completion");
}

authority_context_and_reservation_loss_stop_observation()
{
    state = tests\fixtures\ghosts::floating();
    job = state.apparition_floating_skull_job;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\floating_skull::outcome(state, job, false, false) == "Unavailable", "Owner death, disconnect or lost host authority stops this observer");
    state.flag["ufo_destroyed"] = false;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\floating_skull::outcome(state, job, true, false) == "Unavailable", "Changed native prerequisites cannot retain permission");
    state = tests\fixtures\ghosts::floating();
    job = state.apparition_floating_skull_job;
    state.apparition_floating_skull_job = spawnstruct();
    state._id_13F1B["ghost"] = 5;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\floating_skull::outcome(state, job, true, false) == "Unavailable", "A replaced reservation cannot claim another job's progress");
}
