// The registered center interaction owns generator models, tones and quest flags

available(state)
{
    if (scripts\apparition\maps\spaceland\quest::current_step(state) != 7
        || (isDefined(state.spawn_event_running) && state.spawn_event_running)
        || !isDefined(state.flag) || !isDefined(state.flag["all_structs_placed"])
        || !isDefined(state.flag["all_center_positions_used"]) || state.flag["all_center_positions_used"]
        || !isDefined(state.alldjcenterstructs) || state.alldjcenterstructs.size != 4
        || !isDefined(state.djcenterstructs) || !isDefined(state.current_interaction_structs)
        || !isDefined(state.centerstructstriggered) || !isDefined(state.ufotones) || state.ufotones.size != 4
        || !isDefined(state.players) || state.players.size < 1 || state.players.size > 4)
        return false;
    unplaced = 0;
    for (index = 0; index < 4; index++)
    {
        if (!isDefined(state.ufotones[index]) || !isDefined(state.alldjcenterstructs[index]))
            return false;
        location = state.alldjcenterstructs[index];
        if (!isDefined(location.origin) || (isDefined(location.disabled) && location.disabled)
            || !scripts\engine\utility::array_contains(state.current_interaction_structs, location))
            return false;
        if (isDefined(location.placed) && location.placed)
        {
            if (!isDefined(location.model) || !isDefined(location.tone))
                return false;
        }
        else
        {
            if (!scripts\engine\utility::array_contains(state.djcenterstructs, location))
                return false;
            unplaced++;
        }
    }
    // Native placement indexes tones through the remaining-list count
    return unplaced == state.djcenterstructs.size
        && (unplaced == 0) == (state.flag["all_structs_placed"] != 0);
}

hint(state)
{
    if (isDefined(state.spawn_event_running) && state.spawn_event_running)
        return "Wait for the current spawn event to finish";
    return "Place missing generators and activate the native center positions";
}

place(player)
{
    if (!available(level) || !can_continue(player))
        return false;
    foreach (location in level.alldjcenterstructs)
    {
        if (!isDefined(location.placed) || !location.placed)
            scripts\cp\maps\cp_zmb\cp_zmb_dj::waitforplayertrigger(location, player);
    }
    // Stock completion counts distinct center structs within a one-second window
    foreach (location in level.alldjcenterstructs)
    {
        if (level.flag["all_center_positions_used"])
            return true;
        if (!can_continue(player) || scripts\apparition\maps\spaceland\quest::current_step(level) != 7
            || (isDefined(level.spawn_event_running) && level.spawn_event_running))
            return false;
        if (!scripts\engine\utility::array_contains(level.centerstructstriggered, location))
        {
            scripts\cp\maps\cp_zmb\cp_zmb_dj::waitforplayertrigger(location, player);
            wait 0.05;
        }
    }
    return level.flag["all_center_positions_used"] != 0;
}

can_continue(player)
{
    return scripts\apparition\runtime\context::can_dispatch(player, undefined, true) && isAlive(player);
}
