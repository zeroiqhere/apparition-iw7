// Native generator callbacks are committed one at a time and never cancelled

run(job)
{
    level endon("game_ended");
    perform(job);
    if (level.apparition_power_job == job)
        level.apparition_power_job = undefined;
    // The level keeps no finished request or stale actor and point references
    job.owner = undefined;
    job.targets = undefined;
}

perform(job)
{
    if (scripts\apparition\maps\spaceland\power::job_reason(job) != "")
        return;

    for (index = 0; index < job.targets.size; index++)
    {
        if (scripts\apparition\maps\spaceland\power::job_reason(job) != "")
            return;

        owner = job.owner;
        point = job.targets[index];
        live = scripts\apparition\maps\spaceland\power::probe(owner, job);
        if (live.reason != "")
            return;

        // The snapshot is fresh and the selected native point is still in it
        if (!scripts\engine\utility::array_contains(level.generators, point))
            return;
        if (isDefined(point.powered_on) && point.powered_on != 0)
            continue;
        if (!scripts\engine\utility::array_contains(live.targets, point))
            return;

        receipt = spawnstruct();
        receipt.returned = false;
        commit(owner, point, level.interactions["generator"], receipt);
        await_return(receipt);
    }
}

commit(owner, point, registration, receipt)
{
    // The validated point and actor are committed without a yielding gap
    point.triggered = 1;
    point thread scripts\cp\cp_interaction::delayed_trigger_unset();
    owner thread scripts\cp\cp_interaction::interaction_post_activate_delay(point);
    level notify("interaction", "purchase", registration, owner);
    owner thread scripts\cp\cp_interaction::take_player_money(0, "generator");
    level childthread invoke_native(point, owner, receipt);
    owner scripts\cp\cp_interaction::interaction_post_activate_update(point);
    wait 0.1;
    point.triggered = undefined;
}

invoke_native(point, owner, receipt)
{
    // The stock activation is a level callback and runs synchronously here
    level scripts\cp\zombies\zombie_power::generic_generator(point, owner);
    receipt.returned = true;
    level notify("apparition_power_returned");
}

await_return(receipt)
{
    // The flag covers a callback that returned before this wait began
    while (!receipt.returned)
        level waittill("apparition_power_returned");
}
