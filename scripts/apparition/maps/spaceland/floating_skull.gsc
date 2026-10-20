// A direct laser-type hit leaves native glasses and quest checks in control

context_reason(state)
{
    if (scripts\apparition\maps\spaceland\ghosts::current_step(state) != 4)
        return "Hit Floating Skull requires its native Ghosts N Skulls stage";
    // The native body waits for UFO destruction before creating this target
    if (!isDefined(state.flag) || !isDefined(state.flag["ufo_destroyed"]) || !state.flag["ufo_destroyed"])
        return "Wait for native UFO destruction and the floating skull";
    return "";
}

reason(state)
{
    hint = context_reason(state);
    if (hint != "")
        return hint;
    job = state.apparition_floating_skull_job;
    // Submitted history survives owner loss and the observation deadline
    if (isDefined(job) && isDefined(job.submitted) && job.submitted)
        return "A skull hit was already submitted; normal sign-laser shots remain available";
    return "";
}

on_path(origin)
{
    // Native movement makes six 120-unit X moves from its starting position
    return origin[0] >= 1007 - 6 * 120 && origin[0] <= 1007
        && origin[1] == 621 && origin[2] == 901;
}

select(models)
{
    selected = undefined;
    foreach (model in models)
    {
        if (!isDefined(model) || !isDefined(model.model) || model.model != "zmb_pixel_skull"
            || !isDefined(model.origin) || !on_path(model.origin)
            || !isDefined(model.health) || model.health <= 0)
            continue;
        // Ambiguity applies across the entire native model scan
        if (isDefined(selected))
            return undefined;
        selected = model;
    }
    return selected;
}

probe(player)
{
    result = spawnstruct();
    result.reason = reason(level);
    if (result.reason != "")
        return result;
    if (!scripts\apparition\runtime\context::living_host(player))
    {
        result.reason = "Only the current living host can submit the skull hit";
        return result;
    }
    result.reason = scripts\apparition\runtime\context::actor_reason(level.players);
    if (result.reason != "")
        return result;
    // Use the same native predicate as the skull's real damage listener
    if (!scripts\cp\maps\cp_zmb\cp_zmb_ghost_activation::can_floating_skull_be_destroyed("iw7_spaceland_wmd"))
    {
        result.reason = "At least one current player must wear the native glasses";
        return result;
    }
    result.target = select(getEntArray("script_model", "classname"));
    if (!isDefined(result.target))
        result.reason = "Wait for one living native floating skull on its source path";
    return result;
}

outcome(state, job, authorized, expired)
{
    if (!isDefined(state.apparition_floating_skull_job) || state.apparition_floating_skull_job != job)
        return "Unavailable";
    // Model removal and a submitted request cannot replace native quest advance
    if (scripts\apparition\maps\spaceland\ghosts::current_step(state) > 4)
        return "Completed";
    if (!authorized || context_reason(state) != "")
        return "Unavailable";
    return expired ? "Pending" : "";
}

start(player)
{
    if (scripts\apparition\maps\spaceland\ghost_hit_observer::running(level.apparition_floating_skull_job))
        return false;
    live = probe(player);
    if (live.reason != "")
        return false;
    job = spawnstruct();
    job.owner = player;
    job.target = live.target;
    job.state = "Observing";
    // Publish the reservation before its level worker can submit input
    level.apparition_floating_skull_job = job;
    level thread scripts\apparition\maps\spaceland\floating_skull_worker::run(job);
    return true;
}
