// Bomber controls observe native counters and advance only through native deaths

run()
{
    admission_requires_the_initialized_native_bomber_stage();
    only_reserved_axis_quest_bombers_are_damage_candidates();
    cancellation_and_native_stage_advance_have_distinct_outcomes();
    a_full_counter_waits_for_native_advance_instead_of_claiming_completion();
}

state()
{
    state = tests\fixtures\spaceland::quest(9);
    state.flag["pause_wave_progression"] = 1;
    state.flag["tones_played_successfully"] = 1;
    state.num_ufo_zombies_killed = 0;
    return state;
}

candidate()
{
    enemy = spawnstruct();
    enemy.agent_type = "generic_zombie";
    enemy.team = "axis";
    enemy.is_suicide_bomber = 1;
    enemy.is_reserved = 1;
    enemy.health = 5000;
    enemy.origin = (1, 2, 3);
    return enemy;
}

admission_requires_the_initialized_native_bomber_stage()
{
    state = state();
    tests\support\checks::expect(scripts\apparition\maps\spaceland\bombers::reason(state) == "", "The initialized stage-nine sequence permits a host job");
    state.num_ufo_zombies_killed = undefined;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\bombers::reason(state) != "", "The intro cannot start a job before its native counter exists");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\bombers::progress(state).kills == -1, "An unknown counter is not displayed as zero kills");
    state.num_ufo_zombies_killed = 0;
    state.flag["pause_wave_progression"] = 0;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\bombers::reason(state) != "", "The native wave hold must be active");
    state.flag["pause_wave_progression"] = 1;
    state.flag["tones_played_successfully"] = 0;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\bombers::reason(state) != "", "The completed tone phase remains a prerequisite");
    state.flag["tones_played_successfully"] = 1;
    state._id_13F1B["ufo"] = 10;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\bombers::reason(state) != "", "The job cannot run during the Grey fight");
}

only_reserved_axis_quest_bombers_are_damage_candidates()
{
    enemy = candidate();
    tests\support\checks::expect(scripts\apparition\maps\spaceland\bombers::eligible(enemy), "The source-created reserved bomber is eligible");
    enemy.is_reserved = 0;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\bombers::eligible(enemy), "An unrelated transformed wave zombie is excluded");
    enemy.is_reserved = 1;
    enemy.is_suicide_bomber = 0;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\bombers::eligible(enemy), "An ordinary reserved zombie is excluded");
    enemy.is_suicide_bomber = 1;
    enemy.team = "allies";
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\bombers::eligible(enemy), "Allied actors are excluded");
    enemy.team = "axis";
    enemy.agent_type = "zombie_grey";
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\bombers::eligible(enemy), "The protected Grey actor type is excluded");
    enemy.agent_type = "generic_zombie";
    enemy.health = 0;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\bombers::eligible(enemy), "A dead actor is excluded");
    enemy.health = 150;
    enemy.origin = undefined;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\bombers::eligible(enemy), "Damage requires the native impact point");
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\bombers::eligible(undefined), "A deleted actor is excluded");
}

cancellation_and_native_stage_advance_have_distinct_outcomes()
{
    state = state();
    job = spawnstruct();
    job.state = "Active";
    tests\support\checks::expect(scripts\apparition\maps\spaceland\bombers::running(job), "An active worker reserves the shared job slot");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\bombers::outcome(state, job, true, false) == "", "An active native stage remains under observation");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\bombers::outcome(state, job, false, false) == "Unavailable", "Lost host, session or actor permission stops future damage");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\bombers::outcome(state, job, true, true) == "Pending", "A deadline reports unconfirmed native progression");
    state.flag["pause_wave_progression"] = 0;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\bombers::outcome(state, job, true, false) == "Unavailable", "A cleared native wave hold stops further damage during the same stage");
    state.flag["pause_wave_progression"] = 1;
    state._id_13F1B["ufo"] = 10;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\bombers::outcome(state, job, true, true) == "Completed", "Native advancement confirms completion even at the deadline");
    job.state = "Cancelling";
    tests\support\checks::expect(scripts\apparition\maps\spaceland\bombers::running(job), "Cancellation keeps the slot reserved until the worker exits");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\bombers::outcome(state, job, true, false) == "Cancelled", "An accepted cancellation cannot be overwritten by a stage change");
    foreach (terminal in ["Completed", "Cancelled", "Pending", "Unavailable"])
    {
        job.state = terminal;
        tests\support\checks::expect(!scripts\apparition\maps\spaceland\bombers::running(job), "A terminal worker releases its reservation");
    }
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\bombers::running(undefined), "A missing job does not reserve the controls");
}

a_full_counter_waits_for_native_advance_instead_of_claiming_completion()
{
    state = state();
    state.num_ufo_zombies_killed = 50;
    job = spawnstruct();
    job.state = "Active";
    state.apparition_bomber_job = job;
    progress = scripts\apparition\maps\spaceland\bombers::progress(state);
    tests\support\checks::expect(progress.kills == 50 && progress.goal == 50, "The progress view preserves the native kill count and source target");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\bombers::status(state) == "Waiting for native advance", "A full counter explains the remaining native wait");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\bombers::outcome(state, job, true, false) == "", "The native counter alone cannot complete the job or quest checkbox");
    tests\support\checks::expect(state._id_13F1B["ufo"] == 9 && state.num_ufo_zombies_killed == 50, "Observation does not mutate native progress");
}
