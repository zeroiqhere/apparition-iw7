// Early mapped-hit history excludes a second remote cycle while a projectile may be pending

create(nodes, trigger)
{
    watch = spawnstruct();
    watch.state = "Arming";
    watch.nodes = nodes;
    watch.trigger = trigger;
    watch.waiting = false;
    watch.seen = [];
    watch.menu_inputs = [];
    watch.cycle_spent = false;
    return watch;
}

start()
{
    level endon("game_ended");
    if (isDefined(level.apparition_node_history))
        return;
    watch = create(undefined, undefined);
    level.apparition_node_history = watch;
    deadline = getTime() + 10000;
    for (;;)
    {
        step = scripts\apparition\maps\spaceland\quest::current_step(level);
        if (step == 11 || getTime() >= deadline)
        {
            watch.state = "Unavailable";
            return;
        }
        nodes = scripts\apparition\maps\spaceland\nodes::registry(level);
        triggers = getEntArray("main_gate_powernode_damage_trigger", "targetname");
        if (step >= 0 && isDefined(nodes) && triggers.size == 1)
            break;
        wait 0.05;
    }
    watch.nodes = nodes;
    watch.trigger = triggers[0];
    level thread listen(watch);
    deadline = getTime() + 1000;
    while (!watch.waiting && getTime() < deadline)
        wait 0.05;
    // Readiness after the final stage began cannot establish earlier hit history
    step = scripts\apparition\maps\spaceland\quest::current_step(level);
    if (watch.waiting && step >= 0 && step < 11)
        watch.state = "Listening";
    else
    {
        watch.state = "Unavailable";
        watch notify("apparition_stop_node_history");
    }
}

listen(watch)
{
    if (watch.state != "Arming")
        return;
    level endon("game_ended");
    watch endon("apparition_stop_node_history");
    watch.waiting = true;
    for (;;)
    {
        watch.trigger waittill("damage", damage, attacker, arg3, point);
        if (scripts\apparition\maps\spaceland\quest::current_step(level) != 11 || !isDefined(point))
            continue;
        mapped = scripts\cp\maps\cp_zmb\cp_zmb_ufo::get_power_node_struct(point);
        index = scripts\apparition\maps\spaceland\nodes::index(watch.nodes, mapped);
        // Count possible inputs without rereading mutable attacker weapon state
        observe(watch, index);
        // No timed wait separates accounting from the next native damage wait
    }
}

observe(watch, index)
{
    if (index < 0 || watch.cycle_spent)
        return;
    watch.seen[index] = true;
    // This latch excludes input and never claims that native charging succeeded
    for (index = 0; index < watch.nodes.size; index++)
    {
        if (!isDefined(watch.seen[index]))
            return;
    }
    watch.cycle_spent = true;
}

claim(watch, index)
{
    if (watch.cycle_spent || isDefined(watch.menu_inputs[index]))
        return false;
    // Keep submitted input history through cancel, timeout and owner loss
    watch.menu_inputs[index] = true;
    return true;
}
