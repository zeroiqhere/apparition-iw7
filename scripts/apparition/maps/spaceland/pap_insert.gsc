// A remote zero-cost fuse action preserves native transaction ownership

slot_blocked(slot)
{
    return isDefined(slot.triggered) || isDefined(slot.cooling_down) || isDefined(slot.apparition_fuse_insertion)
        || (isDefined(slot.in_use) && slot.in_use) || (isDefined(slot.out_of_order) && slot.out_of_order)
        || (isDefined(slot.disabled) && slot.disabled)
        || (isDefined(slot.requires_power) && slot.requires_power && (!isDefined(slot.powered_on) || !slot.powered_on));
}

reason(state)
{
    reason = scripts\apparition\maps\spaceland\fuses::context_reason(state);
    if (reason != "")
        return reason;
    native = scripts\apparition\maps\spaceland\fuses::progress(state);
    if (native.inserted)
        return "The alien fuses are already inserted";
    if (native.held <= 0)
        return "Collect the dropped alien fuses first";
    if (!isDefined(state.pap_max) || state.pap_max < 1)
        return "Wait for the native Pack-a-Punch upgrade limit";
    // A changed paid action cannot pass through this zero-cost path
    entry = state.interactions["pap_upgrade"];
    if (!isDefined(entry.name) || entry.name != "pap_upgrade" || !isDefined(entry.cost) || entry.cost != 0
        || (isDefined(entry.spend_type) && entry.spend_type != "null"))
        return "The native zero-cost fuse interaction has changed";
    if (!isDefined(state.interactions["weapon_upgrade"]) || !isDefined(state.interactions["weapon_upgrade"].activation_func)
        || state.interactions["weapon_upgrade"].activation_func != scripts\cp\zombies\interaction_weapon_upgrade::weapon_upgrade)
        return "The native weapon upgrade interaction is not registered";
    pap = scripts\apparition\maps\spaceland\fuses::spot(state, "pap_upgrade");
    weapon = scripts\apparition\maps\spaceland\fuses::spot(state, "weapon_upgrade");
    if (!scripts\engine\utility::array_contains(state.current_interaction_structs, pap)
        || slot_blocked(pap) || slot_blocked(weapon) || isDefined(pap.post_activate_update))
        return "Wait for the native Pack-a-Punch interactions to become available";
    reason = scripts\apparition\maps\spaceland\pap_cycles::reason(state, state.apparition_pap_cycles);
    if (reason != "")
        return reason;
    if (!isDefined(state.players))
        return "Wait for the native player roster";
    foreach (player in state.players)
    {
        if (isDefined(player) && isDefined(player.paping_weapon))
            return "Wait for the current weapon upgrade to finish";
    }
    // An ambiguous submitted call remains spent until the map ends
    if (isDefined(state.apparition_pap_insert_job) && isDefined(state.apparition_pap_insert_job.submitted)
        && state.apparition_pap_insert_job.submitted)
        return "Fuse insertion already requested; inspect the native machine state";
    return "";
}

actor_reason(player, pap)
{
    if (!scripts\apparition\runtime\context::living_host(player))
        return "The host must be alive, out of last stand and in a supported private session";
    // The stock gate covers carrying, grenade input, grounded state and phase
    if (!isDefined(player.disabled_interactions)
        || scripts\engine\utility::array_contains(player.disabled_interactions, pap)
        || !player scripts\cp\cp_interaction::can_use_interaction(pap))
        return "Wait until the game allows the host to use Pack-a-Punch";
    return "";
}

reserve(job)
{
    slots = [job.pap, job.weapon_slot];
    foreach (slot in slots)
    {
        if (slot_blocked(slot))
            return false;
    }
    // Validate both slots before writing either, with no wait between passes
    job.leases = [];
    foreach (slot in slots)
    {
        lease = spawnstruct();
        lease.slot = slot;
        lease.prior_in_use = slot.in_use;
        job.leases[job.leases.size] = lease;
        slot.apparition_fuse_insertion = job;
        slot.in_use = 1;
    }
    return true;
}

release(job)
{
    foreach (lease in job.leases)
    {
        slot = lease.slot;
        if (isDefined(slot.apparition_fuse_insertion) && slot.apparition_fuse_insertion == job)
        {
            // A later writer's changed admission value is left intact
            if (isDefined(slot.in_use) && slot.in_use == 1)
                slot.in_use = lease.prior_in_use;
            slot.apparition_fuse_insertion = undefined;
        }
    }
    job.leases = undefined;
}

completed(state, job)
{
    native = scripts\apparition\maps\spaceland\fuses::progress(state);
    // The early fuse flag alone does not prove delayed machine cleanup finished
    return native.inserted && native.held == job.held - 1 && isDefined(state.pap_max) && state.pap_max == job.pap_max + 1
        && isDefined(state.current_interaction_structs)
        && !scripts\engine\utility::array_contains(state.current_interaction_structs, job.pap)
        && scripts\engine\utility::array_contains(state.current_interaction_structs, job.weapon_slot);
}

running(job)
{
    return isDefined(job) && isDefined(job.state) && job.state == "Inserting";
}

start(player)
{
    if (running(level.apparition_pap_insert_job) || reason(level) != "")
        return false;
    pap = scripts\apparition\maps\spaceland\fuses::spot(level, "pap_upgrade");
    if (actor_reason(player, pap) != "" || !isDefined(getEnt("pap_machine", "targetname")))
        return false;
    job = spawnstruct();
    job.owner = player;
    job.pap = pap;
    job.weapon_slot = scripts\apparition\maps\spaceland\fuses::spot(level, "weapon_upgrade");
    job.held = level.num_fuse_in_possession;
    job.pap_max = level.pap_max;
    job.state = "Inserting";
    // Publish ownership before the level worker can yield inside native code
    level.apparition_pap_insert_job = job;
    level thread scripts\apparition\maps\spaceland\pap_insert_worker::run(job);
    return true;
}
