// Runtime travel gates and job admission leave native transport ownership intact

actor_reason(player)
{
    if (!scripts\apparition\runtime\context::can_dispatch(player, undefined, true))
        return "Only the host can use private Spaceland travel controls";
    if (!isAlive(player) || !isDefined(player.inlaststand) || player.inlaststand)
        return "The host must be alive and out of last stand";
    if (player isInPhase() || player isLinked())
        return "Finish the host's phase or linked movement first";
    if ((isDefined(player.is_fast_traveling) && player.is_fast_traveling)
        || (isDefined(player.is_in_pap) && player.is_in_pap))
        return "The host already has a native portal trip underway";
    // Native travel keeps this permission closed until its completion callback runs
    if (!player scripts\cp\utility::isteleportenabled())
        return "Wait until the game allows the host to travel";
    return "";
}

path_ready(hidden)
{
    // Only the assets consumed by the selected native route are required
    names = hidden ? ["hidden_travel_tube_start", "hidden_travel_tube_end", "hidden_room_portal", "center_portal"]
        : ["fast_travel_tube_start", "fast_travel_tube_end"];
    foreach (name in names)
    {
        entity = getEnt(name, "targetname");
        if (!isDefined(entity) || !isDefined(entity.origin) || !isDefined(entity.angles))
            return false;
    }
    if (!hidden)
        return isDefined(level._effect) && isDefined(level._effect["vfx_zmb_portal_exit_burst"]);
    if (!isDefined(level.struct_class_names) || !isDefined(level.struct_class_names["targetname"]))
        return false;
    spots = level.struct_class_names["targetname"]["hidden_room_spot"];
    return isDefined(spots) && spots.size == 1 && isDefined(spots[0])
        && isDefined(spots[0].origin) && isDefined(spots[0].angles);
}

enter(player)
{
    if (running(level.apparition_portal_job)
        || scripts\apparition\maps\spaceland\portals::entry_reason(level) != ""
        || actor_reason(player) != "" || !path_ready(true))
        return "Unavailable";
    spot = level.fast_travel_spots[level.end_portal_name];
    scripts\cp\zombies\zombie_fast_travel::run_fast_travel_logic(spot, player);
    // This observer reports facts without taking over the native room timer or exit
    deadline = getTime() + 5000;
    for (;;)
    {
        allowed = scripts\apparition\runtime\context::can_dispatch(player, undefined, true) && isAlive(player);
        outcome = scripts\apparition\maps\spaceland\portals::entry_outcome(level, player, allowed, getTime() >= deadline);
        if (outcome != "")
            return outcome;
        wait 0.05;
    }
}

start_visit(player, area)
{
    if (running(level.apparition_portal_job)
        || scripts\apparition\maps\spaceland\portals::side_reason(level, area) != ""
        || actor_reason(player) != "" || !path_ready(false))
        return false;
    job = spawnstruct();
    job.owner = player;
    job.area = area;
    job.state = "Opening";
    level.apparition_portal_job = job;
    // The level worker can release listeners even after its actor disconnects
    level thread scripts\apparition\maps\spaceland\portal_worker::run(job);
    return true;
}

running(job)
{
    // A terminal observation releases the slot without changing a native trip
    return isDefined(job) && isDefined(job.state) && (job.state == "Opening" || job.state == "Travelling");
}

status(state)
{
    if (!isDefined(state.apparition_portal_job))
        return "Idle";
    job = state.apparition_portal_job;
    // Display order and native area identity come from the same four-entry catalog
    areas = scripts\apparition\maps\spaceland\portals::areas();
    for (index = 0; index < areas.size; index++)
    {
        if (job.area == areas[index])
            return "Side Portal " + (index + 1) + ": " + job.state;
    }
    return job.state;
}
