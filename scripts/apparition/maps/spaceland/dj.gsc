// DJ requests use the selected native door and the current quest callback

request_kind(state)
{
    if (!isDefined(state.use_dj_door_func))
        return "";
    step = scripts\apparition\maps\spaceland\quest::current_step(state);
    if (step >= 2 && step <= 4 && isDefined(state.flag) && isDefined(state.flag["dj_request_defense_done"]))
    {
        if (state.use_dj_door_func == scripts\cp\maps\cp_zmb\cp_zmb_dj::use_dj_door_after_fail_speaker_defense
            && pending(state, "dj_request_defense_done"))
            return "defense";
        // Successful defenses retain the native flag across stages three and four
        if (state.use_dj_door_func == scripts\cp\maps\cp_zmb\cp_zmb_dj::use_dj_door_to_request_defense
            && (step > 2 || pending(state, "dj_request_defense_done"))
            && (!isDefined(state.apparition_dj_requested_step) || state.apparition_dj_requested_step != step))
            return "defense";
    }
    if (step == 6 && pending(state, "tone_generators_given")
        && state.use_dj_door_func == scripts\cp\maps\cp_zmb\cp_zmb_dj::use_dj_door_to_get_tone_generator)
        return "tone";
    return "";
}

pending(state, flag)
{
    return isDefined(state.flag) && isDefined(state.flag[flag]) && !state.flag[flag];
}

probe(state, now)
{
    result = spawnstruct();
    result.kind = "";
    result.reason = "Wait for native DJ quest data";
    if (!isDefined(state))
        return result;
    // The first unmet native gate supplies the row's disabled explanation
    if (!isDefined(state.selected_dj_door) || !isDefined(state.selected_dj_door.selected)
        || state.selected_dj_door.selected != 1)
        result.reason = "Wait for the selected native DJ door";
    else if (!isDefined(state.dj) || !isDefined(state.dj.current_state))
        result.reason = "Wait for the native DJ to be ready";
    else if (state.dj.current_state == "mic_loop")
        result.reason = "Wait for the DJ to finish speaking";
    else if (isDefined(state.apparition_dj_next_request) && now < state.apparition_dj_next_request)
        result.reason = "Wait for the current DJ request cooldown";
    else
    {
        result.kind = request_kind(state);
        result.reason = result.kind == "" ? "Wait for the native DJ quest request" : "";
    }
    return result;
}

probe_owner(player)
{
    // Reject nonactors before native host or life queries and before level reads
    if (scripts\apparition\runtime\context::actor_reason([player]) == ""
        && scripts\apparition\runtime\context::can_dispatch(player, undefined, true) && isAlive(player))
        return probe(level, getTime());
    result = spawnstruct();
    result.kind = "";
    result.reason = "Only the current living host can request the native DJ";
    return result;
}

request(player)
{
    // Dispatch samples current authority and native readiness instead of a menu snapshot
    result = probe_owner(player);
    if (result.reason != "")
        return false;
    step = scripts\apparition\maps\spaceland\quest::current_step(level);
    level.apparition_dj_next_request = getTime() + 1000;
    // The normal door callback owns flags, VO, team inventory and analytics
    scripts\cp\maps\cp_zmb\cp_zmb_dj::use_dj_door(level.selected_dj_door, player);
    if (result.kind == "defense")
    {
        level.apparition_dj_requested_step = step;
        return isDefined(level.flag["dj_request_defense_done"]) && level.flag["dj_request_defense_done"];
    }
    return isDefined(level.flag["tone_generators_given"]) && level.flag["tone_generators_given"];
}
