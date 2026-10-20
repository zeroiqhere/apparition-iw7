// End-game contracts inspect native metadata without ending a match

run()
{
    ready_native_metadata_accepts_the_host_end_path();
    missing_or_terminal_game_state_is_rejected();
    replaced_native_wrapper_is_rejected();
    missing_or_changed_host_end_marker_is_rejected();
    native_agent_registry_and_clock_must_be_initialized();
    invalid_requesters_cannot_read_or_submit_native_end_game();
}

ready_native_metadata_accepts_the_host_end_path()
{
    state = ready_state();
    tests\support\checks::expect(scripts\apparition\features\server\end_game::metadata_reason(state, "playing") == "",
        "The registered native wrapper and host-end marker admit a playing game");
    tests\support\checks::expect(state.agentarray.size == 0 && state.gameended == 0,
        "An initialized empty agent registry is valid and inspection does not change game state");
}

missing_or_terminal_game_state_is_rejected()
{
    tests\support\checks::expect(scripts\apparition\features\server\end_game::metadata_reason(undefined, "playing") != "",
        "Missing level metadata cannot admit end game");
    state = ready_state();
    tests\support\checks::expect(scripts\apparition\features\server\end_game::metadata_reason(state, undefined) != "",
        "A missing native game state cannot admit end game");
    foreach (session in [17, "", "postgame", "intermission"])
        tests\support\checks::expect(scripts\apparition\features\server\end_game::metadata_reason(state, session) != "",
            "Only the native playing state admits a new terminal request");

    state.gameended = undefined;
    tests\support\checks::expect(scripts\apparition\features\server\end_game::metadata_reason(state, "playing") != "",
        "An uninitialized terminal flag cannot admit end game");
    foreach (ended in [1, -1, "0"])
    {
        state.gameended = ended;
        tests\support\checks::expect(scripts\apparition\features\server\end_game::metadata_reason(state, "playing") != "",
            "An ended or malformed terminal flag cannot admit a new request");
    }
}

replaced_native_wrapper_is_rejected()
{
    state = ready_state();
    state._id_72BF = undefined;
    tests\support\checks::expect(scripts\apparition\features\server\end_game::metadata_reason(state, "playing") != "",
        "A missing native host-end callback cannot be invoked");
    state._id_72BF = ::run;
    tests\support\checks::expect(scripts\apparition\features\server\end_game::metadata_reason(state, "playing") != "",
        "A replacement callback is rejected instead of receiving a guessed call");
}

missing_or_changed_host_end_marker_is_rejected()
{
    state = ready_state();
    state.end_game_string_index = undefined;
    tests\support\checks::expect(scripts\apparition\features\server\end_game::metadata_reason(state, "playing") != "",
        "A missing native reason table cannot admit end game");
    state.end_game_string_index = spawnstruct();
    tests\support\checks::expect(scripts\apparition\features\server\end_game::metadata_reason(state, "playing") != "",
        "A nonarray native reason table cannot be indexed");
    state.end_game_string_index = [];
    tests\support\checks::expect(scripts\apparition\features\server\end_game::metadata_reason(state, "playing") != "",
        "A missing host-end marker cannot admit the native wrapper");
    foreach (marker in [4, 0, "5"])
    {
        state.end_game_string_index["host_end"] = marker;
        tests\support\checks::expect(scripts\apparition\features\server\end_game::metadata_reason(state, "playing") != "",
            "The native host-end marker must retain its registered numeric value");
    }
}

native_agent_registry_and_clock_must_be_initialized()
{
    state = ready_state();
    state.agentarray = undefined;
    tests\support\checks::expect(scripts\apparition\features\server\end_game::metadata_reason(state, "playing") != "",
        "A missing native agent registry cannot enter the terminal sequence");
    state.agentarray = 17;
    tests\support\checks::expect(scripts\apparition\features\server\end_game::metadata_reason(state, "playing") != "",
        "A malformed native agent registry cannot enter the terminal sequence");
    state.agentarray = [];
    state.starttime = undefined;
    tests\support\checks::expect(scripts\apparition\features\server\end_game::metadata_reason(state, "playing") != "",
        "A missing native start clock cannot reach the elapsed-time calculation");
    state.starttime = "0";
    tests\support\checks::expect(scripts\apparition\features\server\end_game::metadata_reason(state, "playing") != "",
        "A string native start clock cannot reach elapsed-time arithmetic");
}

invalid_requesters_cannot_read_or_submit_native_end_game()
{
    tests\support\checks::expect(scripts\apparition\features\server\end_game::reason(undefined) != "",
        "A missing requester is rejected before native end-game metadata is read");
    tests\support\checks::expect(!scripts\apparition\features\server\end_game::request(undefined),
        "A missing requester cannot submit the native terminal callback");
    actor = spawnstruct();
    tests\support\checks::expect(scripts\apparition\features\server\end_game::reason(actor) != "",
        "A plain struct cannot act as the native host");
    tests\support\checks::expect(!scripts\apparition\features\server\end_game::request(actor),
        "A nonplayer requester cannot submit the native terminal callback");
}

ready_state()
{
    state = spawnstruct();
    state.gameended = 0;
    state._id_72BF = scripts\cp\cp_gamelogic::_id_72BF;
    state.end_game_string_index = [];
    state.end_game_string_index["host_end"] = 5;
    state.agentarray = [];
    state.starttime = 0;
    return state;
}
