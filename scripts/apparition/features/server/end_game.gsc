// The native host-end wrapper owns the normal score, intermission and exit flow

metadata_reason(state, session_state)
{
    if (!isDefined(state) || !isDefined(session_state) || !isstring(session_state)
        || session_state != "playing")
        return "Wait for a playing native game";
    if (!isDefined(state.gameended) || !isnumber(state.gameended) || state.gameended != 0)
        return "The native game is ended or its terminal state is unavailable";

    // Match the registered wrapper rather than calling an unknown replacement
    if (!isDefined(state._id_72BF)
        || state._id_72BF != scripts\cp\cp_gamelogic::_id_72BF)
        return "The native host-end callback is unavailable or changed";
    if (!isDefined(state.end_game_string_index) || !isarray(state.end_game_string_index)
        || !isDefined(state.end_game_string_index["host_end"])
        || !isnumber(state.end_game_string_index["host_end"])
        || state.end_game_string_index["host_end"] != 5)
        return "Wait for the native host-end reason";

    // Stock end-game code iterates this registry and calculates elapsed game time
    if (!isDefined(state.agentarray) || !isarray(state.agentarray)
        || !isDefined(state.starttime) || !isnumber(state.starttime))
        return "Wait for the native game-over dependencies";
    return "";
}

reason(owner)
{
    reason = scripts\apparition\features\server\context::reason(owner);
    if (reason != "")
        return reason;

    // Authority and the complete player roster are admitted before native data
    return metadata_reason(level, game["state"]);
}

request(owner)
{
    if (reason(owner) != "")
        return false;

    // Level ownership keeps native cleanup independent of the menu or requester
    level thread [[level._id_72BF]]();
    return true;
}
