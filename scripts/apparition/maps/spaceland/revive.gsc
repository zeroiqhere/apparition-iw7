// Admit only a current ordinary Spaceland laststand revive trigger

context_reason(state, solo)
{
    // Missing mode context cannot prove which native wait path is active
    if (!isDefined(state) || !isDefined(solo) || !isnumber(solo))
        return "The native Spaceland revive context is unavailable";

    if (isDefined(state.gameended) && state.gameended)
        return "The game has ended";

    // A replaced callback may wait on a different event or bypass revive cleanup
    if (!isDefined(state.wait_to_be_revived_func)
        || state.wait_to_be_revived_func != scripts\cp\maps\cp_zmb\cp_zmb::cp_zmb_wait_to_be_revived_func)
        return "The native Spaceland revive wait callback is unavailable";

    // The solo Hoff branch waits on its trigger instead of revive_success
    if ((solo || (isDefined(state.only_one_player) && state.only_one_player))
        && (isDefined(state.the_hoff_revive) && state.the_hoff_revive))
        return "The solo Hoff revive wait is active";

    return "";
}

probe(player, entities)
{
    result = spawnstruct();
    result.reason = "No selected player is available";

    if (!isDefined(player))
        return result;

    // Only a live playing actor in native laststand can use this helper
    result.reason = "The selected player is not in an ordinary laststand";
    if (!isDefined(player.inlaststand) || !isnumber(player.inlaststand) || !player.inlaststand
        || !isDefined(player.sessionstate) || !isstring(player.sessionstate) || player.sessionstate != "playing"
        || !isDefined(player.health) || !isnumber(player.health) || player.health <= 0)
        return result;

    // These native modes own their own laststand exit and cleanup
    foreach (field in ["spectating", "in_afterlife_arcade", "playing_ghosts_n_skulls", "playing_game",
        "linked_to_coaster", "self_revive"])
    {
        if (isDefined(player[field]) && player[field])
        {
            result.reason = "The selected player is in a native temporary state";
            return result;
        }
    }

    // The kill-trigger route has a separate native progression and is excluded
    if (isDefined(player.kill_trigger_event_processed) && player.kill_trigger_event_processed)
    {
        result.reason = "The selected player's kill-trigger laststand is unsupported";
        return result;
    }

    // Native instant revive clears an existing on-world progress bar
    if (isDefined(player.being_revived) && player.being_revived
        && (!isDefined(player.reviver) || !isDefined(player.revive_progress_bar_id)
            || !isnumber(player.revive_progress_bar_id)
            || (player.revive_progress_bar_id != 1 && player.revive_progress_bar_id != 2)))
    {
        result.reason = "The native active-revive progress record is not ready";
        return result;
    }

    // The stock wait creates this exact entity before registering revive events
    result.reason = "The native revive trigger is not ready";
    if (!isDefined(player.reviveent) || !isDefined(entities) || !isarray(entities))
        return result;

    trigger = undefined;
    foreach (entity in entities)
    {
        if (!isDefined(entity) || entity != player.reviveent
            || !isDefined(entity.owner) || entity.owner != player
            || !isDefined(entity.targetname) || !isstring(entity.targetname)
            || entity.targetname != "revive_trigger")
            continue;

        // The player's current native pointer selects one exact live model
        trigger = entity;
        break;
    }

    if (!isDefined(trigger))
    {
        result.reason = "The selected player's current native revive trigger is unavailable";
        return result;
    }

    // One submitted request belongs to this native down until exit is observed
    if (isDefined(trigger.apparition_revive_submitted) && trigger.apparition_revive_submitted)
    {
        result.reason = "Revive submitted; native laststand exit is unconfirmed";
        return result;
    }

    result.reason = "";
    result.entity = trigger;
    return result;
}
