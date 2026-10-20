// The level owns the committed native callback until its full cleanup returns

run(job)
{
    level endon("game_ended");
    result = perform(job);
    owner = job.owner;
    job.owner = undefined;
    job.pap = undefined;
    job.weapon_slot = undefined;
    job.state = result;
    if (!isDefined(owner))
        return;
    if (result == "Inserted")
        owner iPrintLn("Native fuse insertion and Pack-a-Punch cleanup confirmed");
    else
        owner iPrintLn("Fuse insertion not confirmed; current native progress remains visible");
}

perform(job)
{
    if (scripts\apparition\maps\spaceland\pap_insert::completed(level, job))
        return "Inserted";
    if (scripts\apparition\maps\spaceland\pap_insert::reason(level) != ""
        || scripts\apparition\maps\spaceland\pap_insert::actor_reason(job.owner, job.pap) != ""
        || scripts\apparition\maps\spaceland\fuses::spot(level, "pap_upgrade") != job.pap
        || scripts\apparition\maps\spaceland\fuses::spot(level, "weapon_upgrade") != job.weapon_slot
        || !isDefined(getEnt("pap_machine", "targetname")))
        return "Unavailable";
    if (!scripts\cp\cp_interaction::interaction_is_valid(job.pap, job.owner)
        || !scripts\cp\maps\cp_zmb\cp_zmb_ufo::can_use_pap_upgrade(job.pap, job.owner)
        || !scripts\apparition\maps\spaceland\pap_insert::reserve(job))
        return "Unavailable";
    // Native wrapper effects and both leases are committed before the callback yields
    job.submitted = true;
    job.owner thread scripts\cp\cp_interaction::interaction_post_activate_delay(job.pap);
    level notify("interaction", "purchase", level.interactions["pap_upgrade"], job.owner);
    job.owner thread scripts\cp\cp_interaction::take_player_money(0, "null");
    scripts\cp\maps\cp_zmb\cp_zmb_ufo::upgrade_pap(job.pap, job.owner);
    // Owner death, host loss or menu closure cannot cancel this native transaction
    scripts\apparition\maps\spaceland\pap_insert::release(job);
    return scripts\apparition\maps\spaceland\pap_insert::completed(level, job) ? "Inserted" : "Pending";
}
