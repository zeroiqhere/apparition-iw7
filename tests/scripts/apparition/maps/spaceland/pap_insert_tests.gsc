// Fuse insertion reserves ordinary PAP admission while the native callback owns the transaction

run()
{
    admission_requires_collected_inventory_native_slots_and_complete_cycle_history();
    native_interaction_busy_and_power_states_block_insertion();
    a_blocked_slot_rejects_both_leases_without_partial_changes();
    dual_slot_leases_restore_only_their_owned_prior_values();
    transaction_confirmation_requires_native_inventory_limit_and_restored_interactions();
    a_submitted_unconfirmed_call_cannot_be_repeated();
}

state()
{
    state = tests\fixtures\spaceland::fuses();
    state.num_fuse_in_possession = 1;
    state.pap_max = 2;
    state.timespapused = 0;
    state.apparition_pap_cycles = scripts\apparition\maps\spaceland\pap_cycles::create();
    state.apparition_pap_cycles.state = "Listening";
    state.interactions["pap_upgrade"].cost = 0;
    entry = spawnstruct();
    entry.activation_func = scripts\cp\zombies\interaction_weapon_upgrade::weapon_upgrade;
    state.interactions["weapon_upgrade"] = entry;
    state.current_interaction_structs = [scripts\apparition\maps\spaceland\fuses::spot(state, "pap_upgrade")];
    state.players = [spawnstruct()];
    return state;
}

job(state)
{
    job = spawnstruct();
    job.held = state.num_fuse_in_possession;
    job.pap_max = state.pap_max;
    job.pap = scripts\apparition\maps\spaceland\fuses::spot(state, "pap_upgrade");
    job.weapon_slot = scripts\apparition\maps\spaceland\fuses::spot(state, "weapon_upgrade");
    return job;
}

admission_requires_collected_inventory_native_slots_and_complete_cycle_history()
{
    state = state();
    tests\support\checks::expect(scripts\apparition\maps\spaceland\pap_insert::reason(state) == "", "Collected native fuses and known idle PAP state permit insertion");
    state.num_fuse_in_possession = 0;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\pap_insert::reason(state) != "", "Empty inventory cannot be decremented");
    state = state();
    state.pap_max = undefined;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\pap_insert::reason(state) != "", "The native upgrade limit must be initialized before it is raised");
    state = state();
    state.current_interaction_structs = [];
    tests\support\checks::expect(scripts\apparition\maps\spaceland\pap_insert::reason(state) != "", "An inactive insertion slot cannot be invoked directly");
    state = state();
    state.timespapused = 1;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\pap_insert::reason(state) != "", "Unknown PAP cycle history blocks remote insertion");
    state = state();
    state.players[0].paping_weapon = "iw7_nrg_zm";
    tests\support\checks::expect(scripts\apparition\maps\spaceland\pap_insert::reason(state) != "", "A live ordinary weapon transaction blocks insertion");
    state = state();
    state.interactions["pap_upgrade"].cost = 100;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\pap_insert::reason(state) != "", "A changed paid interaction cannot be bypassed by a zero-cost adapter");
}

native_interaction_busy_and_power_states_block_insertion()
{
    foreach (name in ["pap_upgrade", "weapon_upgrade"])
    {
        state = state();
        slot = scripts\apparition\maps\spaceland\fuses::spot(state, name);
        slot.triggered = 0;
        tests\support\checks::expect(scripts\apparition\maps\spaceland\pap_insert::reason(state) != "", "Even a defined zero trigger is reserved by native admission");
        slot.triggered = undefined;
        slot.in_use = 1;
        tests\support\checks::expect(scripts\apparition\maps\spaceland\pap_insert::reason(state) != "", "A busy native slot cannot be taken over");
        slot.in_use = 0;
        slot.cooling_down = 0;
        tests\support\checks::expect(scripts\apparition\maps\spaceland\pap_insert::reason(state) != "", "A defined cooldown remains native-owned");
        slot.cooling_down = undefined;
        slot.requires_power = 1;
        slot.powered_on = 0;
        tests\support\checks::expect(scripts\apparition\maps\spaceland\pap_insert::reason(state) != "", "Required power cannot be bypassed");
    }
}

a_blocked_slot_rejects_both_leases_without_partial_changes()
{
    foreach (name in ["pap_upgrade", "weapon_upgrade"])
    {
        state = state();
        job = job(state);
        blocked = scripts\apparition\maps\spaceland\fuses::spot(state, name);
        blocked.in_use = 1;
        tests\support\checks::expect(!scripts\apparition\maps\spaceland\pap_insert::reserve(job), "Either busy slot rejects the whole reservation");
        tests\support\checks::expect(!isDefined(job.leases), "Rejected admission does not leave partial lease records");
        tests\support\checks::expect(!isDefined(job.pap.apparition_fuse_insertion) && !isDefined(job.weapon_slot.apparition_fuse_insertion), "Neither interaction receives an ownership token on rejection");
        tests\support\checks::expect(blocked.in_use == 1, "Rejected admission preserves the existing native busy value");
    }
}

dual_slot_leases_restore_only_their_owned_prior_values()
{
    state = state();
    job = job(state);
    tests\support\checks::expect(scripts\apparition\maps\spaceland\pap_insert::reserve(job), "An idle canonical weapon slot can be reserved");
    tests\support\checks::expect(job.weapon_slot.in_use && job.weapon_slot.apparition_fuse_insertion == job, "The native admission flag and app lease identify this transaction");
    tests\support\checks::expect(job.pap.in_use && job.pap.apparition_fuse_insertion == job, "The PAP insertion slot is leased together with ordinary weapon admission");
    scripts\apparition\maps\spaceland\pap_insert::release(job);
    tests\support\checks::expect(!isDefined(job.weapon_slot.in_use) && !isDefined(job.weapon_slot.apparition_fuse_insertion), "An originally undefined admission flag is restored and its lease removed");
    tests\support\checks::expect(!isDefined(job.pap.in_use) && !isDefined(job.pap.apparition_fuse_insertion), "The insertion lease is also released after native cleanup");
    job.weapon_slot.in_use = 0;
    scripts\apparition\maps\spaceland\pap_insert::reserve(job);
    scripts\apparition\maps\spaceland\pap_insert::release(job);
    tests\support\checks::expect(isDefined(job.weapon_slot.in_use) && !job.weapon_slot.in_use, "An originally defined false flag remains defined false");
    scripts\apparition\maps\spaceland\pap_insert::reserve(job);
    job.weapon_slot.in_use = 2;
    scripts\apparition\maps\spaceland\pap_insert::release(job);
    tests\support\checks::expect(job.weapon_slot.in_use == 2 && !isDefined(job.weapon_slot.apparition_fuse_insertion), "A later changed admission value survives release of this lease");
    job.weapon_slot.in_use = 0;
    scripts\apparition\maps\spaceland\pap_insert::reserve(job);
    job.weapon_slot.apparition_fuse_insertion = spawnstruct();
    scripts\apparition\maps\spaceland\pap_insert::release(job);
    tests\support\checks::expect(job.weapon_slot.in_use && isDefined(job.weapon_slot.apparition_fuse_insertion), "A replaced lease is not released by its former owner");
}

transaction_confirmation_requires_native_inventory_limit_and_restored_interactions()
{
    state = state();
    job = job(state);
    state.flag["fuses_inserted"] = 1;
    state.num_fuse_in_possession = 0;
    state.pap_max = 3;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\pap_insert::completed(state, job), "An inserted flag before native list restoration does not complete the worker");
    state.current_interaction_structs = [job.weapon_slot];
    tests\support\checks::expect(scripts\apparition\maps\spaceland\pap_insert::completed(state, job), "Native consumption, limit increment and interaction restoration confirm insertion");
    state.pap_max = 2;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\pap_insert::completed(state, job), "The inserted flag alone cannot replace a native upgrade-limit increment");
    tests\support\checks::expect(!state.flag["ufo_quest_finished"], "PAP insertion does not complete the UFO quest");
}

a_submitted_unconfirmed_call_cannot_be_repeated()
{
    state = state();
    job = job(state);
    job.submitted = true;
    job.state = "Pending";
    state.apparition_pap_insert_job = job;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\pap_insert::reason(state) != "", "An unconfirmed native insertion call cannot be resubmitted");
    job.submitted = false;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\pap_insert::reason(state) == "", "An admission failure before native input remains retryable");
}
