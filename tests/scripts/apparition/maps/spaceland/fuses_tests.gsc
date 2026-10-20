// Collection follows the dropped pair's native listener and inventory changes

run()
{
    collection_requires_the_final_stage_and_native_interactions();
    collection_rejects_held_or_inserted_fuses_and_unknown_inventory();
    confirmation_requires_native_inventory_cleanup_and_interaction_state();
    inserted_fuses_confirm_a_pickup_even_after_inventory_was_consumed();
    an_unconfirmed_submission_cannot_enable_a_second_menu_attempt();
    observation_does_not_complete_the_final_quest_stage();
}

collection_requires_the_final_stage_and_native_interactions()
{
    state = tests\fixtures\spaceland::fuses();
    tests\support\checks::expect(scripts\apparition\maps\spaceland\fuses::reason(state) == "", "An initialized final stage permits collecting its dropped pair");
    state._id_13F1B["ufo"] = 10;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\fuses::reason(state) != "", "The menu waits until Grey completion cleanup reaches the final stage");
    state = tests\fixtures\spaceland::fuses();
    state.interactions["pap_upgrade"].activation_func = undefined;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\fuses::reason(state) != "", "The native insertion callback must be registered before pickup enables it");
    state = tests\fixtures\spaceland::fuses();
    state.interactions["pap_upgrade"].can_use_override_func = undefined;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\fuses::reason(state) != "", "The native insertion admission callback remains a prerequisite");
    state = tests\fixtures\spaceland::fuses();
    state.struct_class_names["script_noteworthy"]["weapon_upgrade"] = [];
    tests\support\checks::expect(scripts\apparition\maps\spaceland\fuses::reason(state) != "", "Pickup cannot remove a missing native weapon-upgrade interaction");
    state = tests\fixtures\spaceland::fuses();
    state.struct_class_names["script_noteworthy"]["pap_upgrade"][1] = spawnstruct();
    tests\support\checks::expect(scripts\apparition\maps\spaceland\fuses::reason(state) != "", "An ambiguous native PAP insertion lookup is rejected");
    state = tests\fixtures\spaceland::fuses();
    state.current_interaction_structs = undefined;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\fuses::reason(state) != "", "The native interaction list must exist before pickup changes it");
}

collection_rejects_held_or_inserted_fuses_and_unknown_inventory()
{
    state = tests\fixtures\spaceland::fuses();
    state.num_fuse_in_possession = undefined;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\fuses::progress(state).held == -1, "Unknown possession is not displayed as zero");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\fuses::reason(state) != "", "An uninitialized count cannot admit collection");
    state.num_fuse_in_possession = 1;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\fuses::reason(state) != "", "The collected pair cannot be picked up twice");
    state.num_fuse_in_possession = 0;
    state.flag["fuses_inserted"] = 1;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\fuses::reason(state) != "", "Consumed insertion inventory cannot admit another pickup");
    state.flag["fuses_inserted"] = undefined;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\fuses::reason(state) != "", "The native inserted flag must be initialized");
    state.flag["fuses_inserted"] = 0;
    state.flag["ufo_quest_finished"] = 1;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\fuses::reason(state) != "", "A completed UFO quest has no new pickup action");
}

confirmation_requires_native_inventory_cleanup_and_interaction_state()
{
    state = tests\fixtures\spaceland::fuses();
    pickup = spawnstruct();
    tests\support\checks::expect(scripts\apparition\maps\spaceland\fuses::outcome(state, pickup, true, false) == "", "Unchanged native state stays under observation");
    state.num_fuse_in_possession = 1;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\fuses::outcome(state, pickup, true, false) == "", "Inventory alone does not prove model cleanup");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\fuses::outcome(state, undefined, true, false) == "", "Deletion alone cannot prove the native insertion interaction was enabled");
    state.current_interaction_structs = [scripts\apparition\maps\spaceland\fuses::spot(state, "pap_upgrade")];
    tests\support\checks::expect(scripts\apparition\maps\spaceland\fuses::outcome(state, undefined, true, true) == "Collected", "Native inventory, deletion and interaction change confirm collection even at the deadline");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\fuses::outcome(state, undefined, false, false) == "Collected", "A teammate's already completed pickup remains confirmed when the observer loses permission");
    state.current_interaction_structs[state.current_interaction_structs.size] = scripts\apparition\maps\spaceland\fuses::spot(state, "weapon_upgrade");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\fuses::outcome(state, undefined, true, false) == "", "A still-active weapon upgrade list has not completed the pickup transition");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\fuses::outcome(state, undefined, true, true) == "Pending", "An incomplete native transition reaches an unconfirmed deadline");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\fuses::outcome(state, undefined, false, false) == "Unavailable", "Lost authorization stops the observer without rolling back native changes");
}

inserted_fuses_confirm_a_pickup_even_after_inventory_was_consumed()
{
    state = tests\fixtures\spaceland::fuses();
    state.flag["fuses_inserted"] = 1;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\fuses::outcome(state, undefined, true, false) == "Collected", "A teammate's completed insertion proves the deleted pair was consumed despite a zero count");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\fuses::outcome(state, spawnstruct(), true, false) == "", "An unexpected surviving model prevents a false cleanup claim");
}

an_unconfirmed_submission_cannot_enable_a_second_menu_attempt()
{
    state = tests\fixtures\spaceland::fuses();
    job = spawnstruct();
    job.state = "Pending";
    job.submitted = true;
    state.apparition_fuse_pickup_job = job;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\fuses::reason(state) != "", "A timed-out submitted trigger cannot enable another menu attempt");
    job.state = "Unavailable";
    tests\support\checks::expect(scripts\apparition\maps\spaceland\fuses::reason(state) != "", "Lost permission after submission cannot clear the one-input reservation");
    job.submitted = false;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\fuses::reason(state) == "", "A rejected request that never submitted input may be admitted later");
}

observation_does_not_complete_the_final_quest_stage()
{
    state = tests\fixtures\spaceland::fuses();
    state.num_fuse_in_possession = 1;
    state.current_interaction_structs = [scripts\apparition\maps\spaceland\fuses::spot(state, "pap_upgrade")];
    scripts\apparition\maps\spaceland\fuses::outcome(state, undefined, true, false);
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\quest::progress(state).finished && state._id_13F1B["ufo"] == 11, "Collection observation never advances or completes the final quest stage");
}
