// Native damage owns node activation and the final projectile sequence

run(job, watch)
{
    level endon("game_ended");
    result = perform(job, watch);
    owner = job.owner;
    job.owner = undefined;
    job.state = result;
    if (!isDefined(owner))
        return;
    if (result == "Destroyed")
        owner iPrintLn("Native UFO destruction confirmed");
    else
        owner iPrintLn("Final-node inputs stopped; native progress remains visible");
}

perform(job, watch)
{
    deadline = getTime() + 60000;
    for (;;)
    {
        result = poll(job, watch, deadline);
        if (result != "")
            return result;
        if (!watch.cycle_spent)
        {
            for (index = 0; index < watch.nodes.size; index++)
            {
                result = poll(job, watch, deadline);
                if (result != "")
                    return result;
                if (watch.cycle_spent)
                    break;
                node = watch.nodes[index];
                if (scripts\apparition\maps\spaceland\nodes::activated(node))
                    continue;
                if (isDefined(watch.menu_inputs[index]))
                    return "Pending";
                if (scripts\apparition\maps\spaceland\nodes::actor_reason(job.owner) != ""
                    || scripts\apparition\maps\spaceland\nodes::live_reason(watch) != "")
                    return "Unavailable";
                weapon = job.owner getCurrentWeapon();
                // Revalidate the exact weapon and first-match mapping immediately before input
                if (!scripts\cp\maps\cp_zmb\cp_zmb_ufo::can_charge_power_nodes(weapon, job.owner)
                    || scripts\cp\maps\cp_zmb\cp_zmb_ufo::get_power_node_struct(node.origin) != node
                    || !scripts\apparition\maps\spaceland\node_history::claim(watch, index))
                    return "Unavailable";
                watch.trigger doDamage(1, node.origin, job.owner, job.owner, "MOD_UNKNOWN", weapon);
                result = wait_for_node(job, watch, node, deadline);
                if (result != "")
                    return result;
            }
        }
        // A spent input cycle only observes; it never sends a second firing sequence
        wait 0.05;
    }
}

wait_for_node(job, watch, node, deadline)
{
    response_deadline = getTime() + 1500;
    for (;;)
    {
        result = poll(job, watch, deadline);
        if (result != "")
            return result;
        if (watch.cycle_spent || scripts\apparition\maps\spaceland\nodes::activated(node))
            return "";
        if (getTime() >= response_deadline)
            return "Pending";
        wait 0.05;
    }
}

poll(job, watch, deadline)
{
    allowed = scripts\apparition\runtime\context::living_host(job.owner);
    return scripts\apparition\maps\spaceland\nodes::outcome(level, watch, job, allowed, getTime() >= deadline);
}
