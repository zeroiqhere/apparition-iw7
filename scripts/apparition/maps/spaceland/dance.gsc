// Native player-attributed deaths and current floor volumes own dance progress

sequence_reason(state)
{
    if (!isDefined(state.onzombiekilledfunc)
        || state.onzombiekilledfunc != scripts\cp\maps\cp_zmb\cp_zmb_ghost_activation::check_kill_on_dance_floor)
        return "Wait for the native dance kill callback";
    if (!isDefined(state.spawned_enemies) || !isarray(state.spawned_enemies)
        || !scripts\apparition\maps\spaceland\zombie_targets::death_path(state, "generic_zombie"))
        return "Wait for the native ordinary-zombie death path and roster";
    if (!isDefined(state.kill_order_on_dance_floor) || !isarray(state.kill_order_on_dance_floor))
        return "Wait for the native dance color sequence";
    // An empty order can be observed while the native quest thread advances
    if (state.kill_order_on_dance_floor.size > 0
        && !scripts\engine\utility::array_contains(["green", "blue", "pink", "black"], state.kill_order_on_dance_floor[0]))
        return "The next native dance color is unsupported";
    return "";
}

reason(state)
{
    if (scripts\apparition\maps\spaceland\ghosts::current_step(state) != 2)
        return "Dance assistance requires the native 1984 dance-kill stage";
    hint = sequence_reason(state);
    if (hint != "")
        return hint;
    if (!state.kill_order_on_dance_floor.size)
        return "Wait for native dance-step advancement";
    return "";
}

floor_reason(expected, actual)
{
    if (!isDefined(actual) || actual != expected)
        return "Stand on the native " + expected + " dance tile";
    return "";
}

actor_reason(player)
{
    hint = reason(level);
    if (hint != "")
        return hint;
    if (!scripts\apparition\runtime\context::living_host(player))
        return "Only the current living host can assist dance kills";
    // The same native volume test will run again inside the death callback
    actual = scripts\cp\maps\cp_zmb\cp_zmb_ghost_activation::get_dance_floor_tile_color(player.origin);
    return floor_reason(level.kill_order_on_dance_floor[0], actual);
}

running(job)
{
    return isDefined(job) && isDefined(job.state)
        && (job.state == "Active" || job.state == "Cancelling");
}

outcome(state, job, authorized, expired)
{
    if (job.state == "Cancelling")
        return "Cancelled";
    // A worker cannot inherit a newer job's reservation
    if (!isDefined(state.apparition_dance_job) || state.apparition_dance_job != job)
        return "Unavailable";
    step = scripts\apparition\maps\spaceland\ghosts::current_step(state);
    // Neither submitted damage nor an empty color array proves native completion
    if (step > 2)
        return "Completed";
    if (!authorized || step != 2 || sequence_reason(state) != "")
        return "Unavailable";
    return expired ? "Pending" : "";
}

can_submit(state, job, actual_floor, authorized)
{
    // Read the current head only after validating a nonempty native order
    return job.state == "Active" && outcome(state, job, authorized, false) == ""
        && state.kill_order_on_dance_floor.size > 0
        && floor_reason(state.kill_order_on_dance_floor[0], actual_floor) == "";
}

status(state)
{
    job = state.apparition_dance_job;
    if (!isDefined(job))
        return "Idle";
    if (job.state != "Active")
        return job.state;
    if (scripts\apparition\maps\spaceland\ghosts::current_step(state) != 2 || sequence_reason(state) != "")
        return "Native dance context changed";
    if (!state.kill_order_on_dance_floor.size)
        return "Waiting for native advance";
    return "Active";
}

start(player)
{
    if (running(level.apparition_dance_job) || actor_reason(player) != "")
        return false;
    job = spawnstruct();
    job.owner = player;
    job.state = "Active";
    // The reservation precedes worker startup and survives closing this menu
    level.apparition_dance_job = job;
    level thread scripts\apparition\maps\spaceland\dance_worker::run(job);
    return true;
}

cancel()
{
    job = level.apparition_dance_job;
    if (!running(job) || job.state == "Cancelling")
        return false;
    // Keep ownership until the worker has stopped sending further damage
    job.state = "Cancelling";
    return true;
}
