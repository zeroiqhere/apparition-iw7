// Fuse assist contracts leave health, quest progress and fuse removal to the game

run()
{
    admission_requires_the_native_grey_stage_and_map_callbacks();
    only_initialized_nonclone_quest_greys_are_candidates();
    a_job_started_during_regeneration_waits_for_a_new_window();
    an_exposed_fuse_must_belong_to_the_same_grey_and_native_list();
    a_deleted_or_changed_fuse_after_listener_arming_cannot_receive_input();
    a_teammate_hit_before_listener_arming_spends_the_observed_window();
    removal_confirmation_requires_more_than_an_acknowledgment();
    cancellation_and_native_advancement_have_distinct_outcomes();
}

admission_requires_the_native_grey_stage_and_map_callbacks()
{
    state = tests\fixtures\spaceland::greys();
    tests\support\checks::expect(scripts\apparition\maps\spaceland\greys::reason(state, false) == "", "A registered stage-ten context permits the assist");
    state.greygetmeleedamagedfunc = undefined;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\greys::reason(state, false) != "", "The native fuse-removal hook must be registered");
    state.greygetmeleedamagedfunc = scripts\cp\maps\cp_zmb\cp_zmb_ufo::remove_alien_fuse;
    state.greysetupfunc = scripts\cp\maps\cp_zmb\cp_zmb_ufo::remove_alien_fuse;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\greys::reason(state, false) != "", "An unrelated setup hook cannot pass the map gate");
    state = tests\fixtures\spaceland::greys();
    state.grey_on_killed_func = undefined;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\greys::reason(state, false) != "", "Native death bookkeeping remains a prerequisite");
    state = tests\fixtures\spaceland::greys();
    state.spawned_grey = undefined;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\greys::reason(state, false) != "", "The initial Grey registration must exist");
    state = tests\fixtures\spaceland::greys();
    state.flag["pause_wave_progression"] = 0;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\greys::reason(state, false) != "", "A cleared wave hold stops the assist");
    state.flag["pause_wave_progression"] = 1;
    state.flag["tones_played_successfully"] = 0;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\greys::reason(state, false) != "", "Completed tones remain a prerequisite");
    state = tests\fixtures\spaceland::greys();
    state._id_13F1B["ufo"] = 9;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\greys::reason(state, false) != "", "An earlier bomber stage cannot admit fuse hits");
}

only_initialized_nonclone_quest_greys_are_candidates()
{
    enemy = tests\fixtures\spaceland::grey();
    tests\support\checks::expect(scripts\apparition\maps\spaceland\grey_fuses::eligible(enemy), "The initialized source-created Grey is eligible");
    enemy.i_am_clone = 1;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\grey_fuses::eligible(enemy), "Clones cannot enter the regeneration assist");
    enemy.i_am_clone = 0;
    enemy.is_reserved = 0;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\grey_fuses::eligible(enemy), "An unrelated nonquest Grey is excluded");
    enemy.is_reserved = 1;
    enemy.team = "allies";
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\grey_fuses::eligible(enemy), "An allied actor is excluded");
    enemy.team = "axis";
    enemy.agent_type = "generic_zombie";
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\grey_fuses::eligible(enemy), "Wave zombies are excluded");
    enemy.agent_type = "zombie_grey";
    enemy.health = 0;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\grey_fuses::eligible(enemy), "Dead actors are excluded");
    enemy.health = 10000;
    enemy.can_do_health_regen = 0;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\grey_fuses::eligible(enemy), "An actor with regeneration disabled is left alone");
    enemy.can_do_health_regen = 1;
    enemy.current_max_health_regen_level = undefined;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\grey_fuses::eligible(enemy), "The native damage cap must be initialized");
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\grey_fuses::eligible(undefined), "A deleted actor is excluded");
}

a_job_started_during_regeneration_waits_for_a_new_window()
{
    enemy = tests\fixtures\spaceland::grey();
    enemy.is_regening_health = 1;
    enemy.actually_doing_regen = 1;
    record = scripts\apparition\maps\spaceland\grey_fuses::record(enemy);
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\grey_fuses::observe(record)), "An existing window is skipped when the job first sees an actor");
    enemy.is_regening_health = 0;
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\grey_fuses::observe(record)) && record.ready, "Observed native idle arms the next window without submitting input");
    enemy.is_regening_health = 1;
    enemy.actually_doing_regen = 0;
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\grey_fuses::observe(record)), "The early regen animation has no ready fuse input");
    enemy.actually_doing_regen = 1;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\grey_fuses::observe(record) == enemy.alien_fuse_exposed, "A fresh fully active window selects the native exposed model");
    // Submission spends this observed window before invoking native damage
    record.ready = false;
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\grey_fuses::observe(record)), "A spent window cannot submit another hit");
    enemy.alien_fuse_exposed.tag_name = "tag_back_ri";
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\grey_fuses::observe(record)), "Changing the exposed tag does not prove an idle edge");
    restarted = scripts\apparition\maps\spaceland\grey_fuses::record(enemy);
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\grey_fuses::observe(restarted)), "Cancel and restart cannot retry a still-active window");
    enemy.is_regening_health = 0;
    scripts\apparition\maps\spaceland\grey_fuses::observe(record);
    enemy.is_regening_health = 1;
    tests\support\checks::expect(isDefined(scripts\apparition\maps\spaceland\grey_fuses::observe(record)), "A later observed idle edge arms a new window");
}

an_exposed_fuse_must_belong_to_the_same_grey_and_native_list()
{
    enemy = tests\fixtures\spaceland::grey();
    enemy.is_regening_health = 1;
    enemy.actually_doing_regen = 1;
    fuse = enemy.alien_fuse_exposed;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\grey_fuses::exposed(enemy) == fuse, "A registered back fuse is selected");
    fuse.owner = spawnstruct();
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\grey_fuses::exposed(enemy)), "A foreign owner's model is excluded");
    fuse.owner = enemy;
    fuse.tag_name = "j_head";
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\grey_fuses::exposed(enemy)), "An unrelated model tag is excluded");
    fuse.tag_name = "tag_back_ri";
    fuse.origin = undefined;
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\grey_fuses::exposed(enemy)), "The native hit point must exist");
    fuse.origin = (1, 2, 3);
    enemy.available_fuse = [];
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\grey_fuses::exposed(enemy)), "A stale exposed reference outside the native list is excluded");
}

a_deleted_or_changed_fuse_after_listener_arming_cannot_receive_input()
{
    enemy = tests\fixtures\spaceland::grey();
    record = scripts\apparition\maps\spaceland\grey_fuses::record(enemy);
    scripts\apparition\maps\spaceland\grey_fuses::observe(record);
    enemy.is_regening_health = 1;
    enemy.actually_doing_regen = 1;
    fuse = enemy.alien_fuse_exposed;
    ticket = tests\fixtures\spaceland::armed_ticket();
    tests\support\checks::expect(scripts\apparition\maps\spaceland\grey_fuses::ready_to_strike(record, ticket, fuse), "An armed listener and unchanged fresh fuse permit submission");
    ticket.state = "Received";
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\grey_fuses::ready_to_strike(record, ticket, fuse), "An intervening native stop event suppresses menu input");
    ticket.state = "Cancelled";
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\grey_fuses::ready_to_strike(record, ticket, fuse), "A failed listener handshake cannot submit input");
    ticket.state = "Armed";
    enemy.alien_fuse_exposed = undefined;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\grey_fuses::ready_to_strike(record, ticket, undefined), "Two undefined fuse references cannot authorize a deleted model's hit point");
    enemy.alien_fuse_exposed = fuse;
    record.ready = false;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\grey_fuses::ready_to_strike(record, ticket, fuse), "A spent window remains ineligible after listener arming");
    record.ready = true;
    enemy.is_regening_health = 0;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\grey_fuses::ready_to_strike(record, ticket, fuse), "A regeneration window that closed during arming cannot receive input");
    enemy.is_regening_health = 1;
    replacement = tests\fixtures\spaceland::grey().alien_fuse_exposed;
    replacement.owner = enemy;
    enemy.available_fuse = [replacement];
    enemy.alien_fuse_exposed = replacement;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\grey_fuses::ready_to_strike(record, ticket, fuse), "A different valid exposed fuse cannot reuse an earlier armed submission");
}

a_teammate_hit_before_listener_arming_spends_the_observed_window()
{
    enemy = tests\fixtures\spaceland::grey();
    record = scripts\apparition\maps\spaceland\grey_fuses::record(enemy);
    scripts\apparition\maps\spaceland\grey_fuses::observe(record);
    enemy.is_regening_health = 1;
    enemy.actually_doing_regen = 1;
    fuse = enemy.alien_fuse_exposed;
    ticket = tests\fixtures\spaceland::armed_ticket();
    // Native accepted damage lowers the cap before sending its stop event
    enemy.current_max_health_regen_level = 6700;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\grey_fuses::ready_to_strike(record, ticket, fuse), "An earlier teammate hit is rejected even when its event was missed and regen flags remain active");
    enemy.is_regening_health = 0;
    scripts\apparition\maps\spaceland\grey_fuses::observe(record);
    enemy.is_regening_health = 1;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\grey_fuses::ready_to_strike(record, ticket, fuse), "The next observed idle captures the new cap for a later legitimate window");
}

removal_confirmation_requires_more_than_an_acknowledgment()
{
    enemy = tests\fixtures\spaceland::grey();
    fuse = enemy.alien_fuse_exposed;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\grey_fuses::removed(enemy, fuse), "A still-attached fuse remains unconfirmed after any event");
    enemy.available_fuse = [];
    tests\support\checks::expect(scripts\apparition\maps\spaceland\grey_fuses::removed(enemy, fuse), "Native list removal confirms this particular fuse");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\grey_fuses::removed(enemy, undefined), "Native deletion also confirms removal");
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\grey_fuses::removed(undefined, fuse), "A missing actor alone does not confirm a surviving fuse's removal");
}

cancellation_and_native_advancement_have_distinct_outcomes()
{
    state = tests\fixtures\spaceland::greys();
    job = spawnstruct();
    job.state = "Active";
    tests\support\checks::expect(scripts\apparition\maps\spaceland\greys::outcome(state, job, true, false) == "", "The current native stage remains active even with an empty tracked list");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\greys::outcome(state, job, true, true) == "Pending", "A stalled fight reaches a bounded unconfirmed result");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\greys::outcome(state, job, false, false) == "Unavailable", "Lost host or actor permission stops input");
    state._id_13F1B["ufo"] = 11;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\greys::outcome(state, job, true, true) == "Completed", "Only native quest advancement confirms the fight's completion");
    job.state = "Cancelling";
    tests\support\checks::expect(scripts\apparition\maps\spaceland\greys::running(job), "Cancellation retains the reservation until cleanup");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\greys::outcome(state, job, true, false) == "Cancelled", "Accepted cancellation wins over simultaneous progression");
    job.state = "Pending";
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\greys::running(job), "A terminal job releases the menu reservation");
}
