// Complete-fight mode shares fuse handling while ordinary damage follows native readiness

run()
{
    complete_mode_requires_the_early_completed_spawn_watch();
    ordinary_damage_includes_clones_but_excludes_regeneration_and_unknown_health();
    native_completion_and_the_native_damage_gate_stop_the_relevant_inputs();
    an_empty_roster_or_spawn_return_is_not_quest_completion();
}

state()
{
    state = tests\fixtures\spaceland::greys();
    state._id_13F1B["ufo"] = 9;
    watch = scripts\apparition\maps\spaceland\grey_sequence::create();
    state.apparition_grey_sequence = watch;
    scripts\apparition\maps\spaceland\grey_sequence::install(state, watch);
    state._id_13F1B["ufo"] = 10;
    watch.state = "Ready";
    return state;
}

job(state)
{
    job = spawnstruct();
    job.full_fight = true;
    job.watch = state.apparition_grey_sequence;
    job.state = "Active";
    return job;
}

complete_mode_requires_the_early_completed_spawn_watch()
{
    state = state();
    tests\support\checks::expect(scripts\apparition\maps\spaceland\greys::reason(state, true) == "", "A completed native initial spawn loop permits full-fight mode");
    state.apparition_grey_sequence.state = "Spawning";
    tests\support\checks::expect(scripts\apparition\maps\spaceland\greys::reason(state, true) != "", "A partial initial cohort cannot receive ordinary menu damage");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\greys::reason(state, false) == "", "Fuse-only mode remains independent of body-damage spawn readiness");
    state.apparition_grey_sequence.state = "Ready";
    state.apparition_grey_sequence.entry._id_DB5D = scripts\cp\maps\cp_zmb\cp_zmb_dj::blank;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\greys::reason(state, true) != "", "Lost live hook ownership disables full-fight mode");
}

ordinary_damage_includes_clones_but_excludes_regeneration_and_unknown_health()
{
    enemy = tests\fixtures\spaceland::grey();
    tests\support\checks::expect(scripts\apparition\maps\spaceland\greys::body_eligible(enemy), "A living initialized native Grey can receive ordinary damage");
    enemy.i_am_clone = 1;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\greys::body_eligible(enemy), "Registered native clones remain part of the complete fight");
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\grey_fuses::eligible(enemy), "Clone inclusion for body damage never enables clone fuse strikes");
    enemy.is_regening_health = 1;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\greys::body_eligible(enemy), "Ordinary damage never competes with an exposed-fuse regeneration window");
    enemy.is_regening_health = 0;
    enemy.maxhealth = undefined;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\greys::body_eligible(enemy), "Uninitialized native health bounds cannot admit body damage");
    enemy = tests\fixtures\spaceland::grey();
    enemy.is_reserved = 0;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\greys::body_eligible(enemy), "Unreserved nonquest actors remain excluded");
}

native_completion_and_the_native_damage_gate_stop_the_relevant_inputs()
{
    state = state();
    job = job(state);
    tests\support\checks::expect(scripts\apparition\maps\spaceland\greys::can_submit(state, job, true), "Ready full-fight mode admits ordinary input");
    state.explosive_touch = 1;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\greys::can_submit(state, job, true), "The native explosive_touch field blocks the MOD_UNKNOWN Grey path");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\greys::can_submit(state, job, false), "The native melee path can continue while its ordinary damage gate is active");
    job.watch.state = "Ended";
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\greys::can_submit(state, job, false), "Native fight completion stops all later menu hits before the quest cleanup finishes");
    job.full_fight = false;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\greys::can_submit(state, job, true), "Fuse-only jobs cannot submit ordinary body damage");
}

an_empty_roster_or_spawn_return_is_not_quest_completion()
{
    state = state();
    job = job(state);
    tests\support\checks::expect(scripts\apparition\maps\spaceland\greys::outcome(state, job, true, false) == "", "An empty native roster is provisional while the quest remains on the fight stage");
    job.watch.state = "Ended";
    scripts\apparition\maps\spaceland\grey_sequence::restore(state, job.watch);
    tests\support\checks::expect(scripts\apparition\maps\spaceland\greys::outcome(state, job, true, false) == "", "Native completion acknowledgment still waits for actual quest advancement");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\greys::reason(state, true) == "Wait for native Grey fight cleanup to advance the quest", "A restored ended watch explains native cleanup rather than missing ownership");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\greys::outcome(state, job, true, true) == "Pending", "The observation deadline cannot fabricate advancement");
    state._id_13F1B["ufo"] = 11;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\greys::outcome(state, job, true, true) == "Completed", "Only native quest advancement completes the full fight observer");
}
