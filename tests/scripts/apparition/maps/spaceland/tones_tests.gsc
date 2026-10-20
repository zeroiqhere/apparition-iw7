// Tone planning maps the live native sequence to placed interaction structs

run()
{
    the_plan_follows_the_native_sequence_order();
    missing_or_duplicate_native_tones_are_rejected();
    an_unplaced_or_uninitialized_generator_cannot_be_played();
    admission_requires_the_initialized_tone_stage();
    job_status_distinguishes_running_and_terminal_states();
    completion_and_cancellation_stop_the_job_without_a_fake_stage_write();
}

the_plan_follows_the_native_sequence_order()
{
    state = tests\fixtures\spaceland::tones();
    plan = scripts\apparition\maps\spaceland\tones::plan(state);
    tests\support\checks::expect(isDefined(plan) && plan.size == 4, "Four native notes produce a complete plan");
    if (isDefined(plan) && plan.size == 4)
    {
        tests\support\checks::expect(plan[0] == state.alldjcenterstructs[2], "The first plan entry follows key 03");
        tests\support\checks::expect(plan[1] == state.alldjcenterstructs[0], "The second plan entry follows key 01");
    }
    state.ufo.tone_array = ["04", "02", "01", "03"];
    plan = scripts\apparition\maps\spaceland\tones::plan(state);
    tests\support\checks::expect(isDefined(plan) && plan[0] == state.alldjcenterstructs[3], "A new round is planned from the new native order");
}

missing_or_duplicate_native_tones_are_rejected()
{
    state = tests\fixtures\spaceland::tones();
    state.ufo.tone_array[3] = "99";
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\tones::plan(state)), "An unmapped native sequence key cannot be played");
    state = tests\fixtures\spaceland::tones();
    state.alldjcenterstructs[3].tone = state.alldjcenterstructs[0].tone;
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\tones::plan(state)), "Duplicate generator tone identities are rejected");
    state = tests\fixtures\spaceland::tones();
    state.ufo.tone_array[3] = state.ufo.tone_array[0];
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\tones::plan(state)), "Duplicate sequence keys cannot masquerade as a full round");
    state = tests\fixtures\spaceland::tones();
    state.alldjcenterstructs[0].tone = "unexpected_format";
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\tones::plan(state)), "An unsupported native tone format is rejected");
}

an_unplaced_or_uninitialized_generator_cannot_be_played()
{
    state = tests\fixtures\spaceland::tones();
    state.alldjcenterstructs[0].placed = 0;
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\tones::plan(state)), "An unplaced struct cannot trigger placement during tone matching");
    state = tests\fixtures\spaceland::tones();
    state.alldjcenterstructs[0].model = undefined;
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\tones::plan(state)), "A missing model cannot enter native scriptable playback");
}

admission_requires_the_initialized_tone_stage()
{
    state = tests\fixtures\spaceland::tones();
    tests\support\checks::expect(scripts\apparition\maps\spaceland\tones::available(state), "A ready native tone stage can start a job");
    state.flag["ufo_listening"] = 1;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\tones::available(state), "Starting during listening is allowed because the worker waits for a fresh window");
    state._id_13F1B["ufo"] = 7;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\tones::available(state), "Generator placement cannot start the tone worker early");
    state._id_13F1B["ufo"] = 8;
    state.flag["ufo_intro_reach_center_portal"] = 0;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\tones::available(state), "The native intro must finish before matching starts");
}

job_status_distinguishes_running_and_terminal_states()
{
    job = spawnstruct();
    job.state = "Waiting for fresh round";
    tests\support\checks::expect(scripts\apparition\maps\spaceland\tones::running(job), "A waiting worker prevents another job");
    job.state = "Cancelling";
    tests\support\checks::expect(scripts\apparition\maps\spaceland\tones::running(job), "Cancellation reserves the job until cleanup finishes");
    job.state = "Complete";
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\tones::running(job), "A completed worker does not reserve another job");
}

completion_and_cancellation_stop_the_job_without_a_fake_stage_write()
{
    state = tests\fixtures\spaceland::tones();
    job = spawnstruct();
    job.state = "Playing tones";
    tests\support\checks::expect(scripts\apparition\maps\spaceland\tones::checkpoint(job, state, true) == "", "An authorized live stage continues");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\tones::checkpoint(job, state, false) == "Unavailable", "Lost authorization stops the worker");
    job.state = "Cancelling";
    tests\support\checks::expect(scripts\apparition\maps\spaceland\tones::checkpoint(job, state, true) == "Cancelled", "Cancellation stops future input");
    state.flag["tones_played_successfully"] = 1;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\tones::checkpoint(job, state, true) == "Complete", "Native completion remains authoritative even as cancellation arrives");
    tests\support\checks::expect(state._id_13F1B["ufo"] == 8, "The checkpoint never changes the native current index");
}
