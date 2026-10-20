// Native pickup owns shared Soul Key awards; observations never write profile data

context_reason(state)
{
    native = scripts\apparition\maps\spaceland\quest::progress(state);
    if (!native.finished || !isDefined(state.flag["ufo_destroyed"]) || !state.flag["ufo_destroyed"])
        return "Finish the native UFO destruction sequence before collecting its reward";
    if (!isDefined(state._id_13F4D["ufo"][11]._id_446D)
        || state._id_13F4D["ufo"][11]._id_446D != scripts\cp\maps\cp_zmb\cp_zmb_dj::complete_ufo_projectile_attack)
        return "The native final reward callback has changed";
    return "";
}

reason(state)
{
    reason = context_reason(state);
    if (reason != "")
        return reason;
    if (isDefined(state.apparition_soul_key_job) && isDefined(state.apparition_soul_key_job.submitted)
        && state.apparition_soul_key_job.submitted)
        return "Soul Key input already requested; use the normal pickup if it remains";
    return "";
}

snapshot(players)
{
    receipt = spawnstruct();
    receipt.total = players.size;
    receipt.known = 0;
    receipt.owners = 0;
    foreach (player in players)
    {
        if (!isDefined(player) || !isPlayer(player))
            continue;
        any_key = player getRankedPlayerData("cp", "haveSoulKeys", "any_soul_key");
        spaceland_key = player getRankedPlayerData("cp", "haveSoulKeys", "soul_key_1");
        // Unknown or disconnected recipients cannot silently disappear from the receipt
        if (!isDefined(any_key) || !isDefined(spaceland_key))
            continue;
        receipt.known++;
        if (any_key && spaceland_key)
            receipt.owners++;
    }
    return receipt;
}

ownership_known(receipt)
{
    return receipt.total > 0 && receipt.known == receipt.total;
}

all_owned(receipt)
{
    return ownership_known(receipt) && receipt.owners == receipt.total;
}

native_pickup()
{
    return scripts\apparition\maps\spaceland\pickup_models::select(getEntArray("script_model", "classname"), "zmb_soul_key_base", [(646, 774, 105)]);
}

outcome(state, pickup, receipt, authorized, expired)
{
    // Pre-existing ownership alone cannot confirm a surviving pickup was consumed
    if (!isDefined(pickup) && all_owned(receipt))
        return "Collected";
    if (!authorized || context_reason(state) != "")
        return "Unavailable";
    return expired ? "Pending" : "";
}

running(job)
{
    return isDefined(job) && job.state == "Collecting";
}

current_recipients()
{
    // Later joins must not change the observer's expected recipient snapshot
    recipients = [];
    if (isDefined(level.players))
    {
        foreach (player in level.players)
            recipients[recipients.size] = player;
    }
    return recipients;
}

start(player)
{
    if (running(level.apparition_soul_key_job) || reason(level) != ""
        || !scripts\apparition\runtime\context::living_host(player))
        return false;
    pickup = native_pickup();
    recipients = current_recipients();
    if (!isDefined(pickup) || !ownership_known(snapshot(recipients)))
        return false;
    job = spawnstruct();
    job.owner = player;
    job.pickup = pickup;
    job.recipients = recipients;
    job.state = "Collecting";
    // Publish one map-owned observer before submitting any native use event
    level.apparition_soul_key_job = job;
    level thread scripts\apparition\maps\spaceland\soul_key_worker::run(job);
    return true;
}
