// Private-session classification follows cp_zmb's public-match condition

run()
{
    actor_admission_requires_every_numeric_slot_in_the_selected_list();
    current_host_rejects_invalid_rosters_before_native_host_reads();
    lobby_targets_preserve_native_order_and_exclude_the_host();
    tests\support\checks::expect(scripts\apparition\runtime\context::actor_reason([]) == "No current players are available", "An empty actor roster cannot configure a player setting");
    tests\support\checks::expect(scripts\apparition\runtime\context::actor_reason(undefined) == "No current players are available", "An unavailable actor roster cannot configure a player setting");
    tests\support\checks::expect(scripts\apparition\runtime\context::actor_reason(spawnstruct()) == "Wait for a valid player roster", "A non-array actor selection is rejected before size and iteration");
    tests\support\checks::expect(scripts\apparition\runtime\context::actor_reason("invalid") == "Wait for a valid player roster", "Text cannot substitute for an actor selection");
    tests\support\checks::expect(scripts\apparition\runtime\context::private_session(false, false), "Offline solo is allowed");
    tests\support\checks::expect(scripts\apparition\runtime\context::private_session(true, true), "Online private co-op is allowed");
    tests\support\checks::expect(!scripts\apparition\runtime\context::private_session(true, false), "Public online matchmaking is rejected");
    tests\support\checks::expect(scripts\apparition\runtime\context::target_allowed(false, true, false), "A guest can target the same player");
    tests\support\checks::expect(!scripts\apparition\runtime\context::target_allowed(false, false, true), "A guest cannot target another player");
    tests\support\checks::expect(scripts\apparition\runtime\context::target_allowed(true, false, true), "The host can target another current player");
    tests\support\checks::expect(!scripts\apparition\runtime\context::target_allowed(true, false, false), "A host cannot dispatch to a stale remote actor");
    player = spawnstruct();
    departed = spawnstruct();
    tests\support\checks::expect(scripts\apparition\runtime\context::in_roster([player], player), "A current roster member is found");
    tests\support\checks::expect(!scripts\apparition\runtime\context::in_roster([player], departed), "A departed actor is absent");
    tests\support\checks::expect(!scripts\apparition\runtime\context::in_roster([], player), "An empty roster has no member");
    tests\support\checks::expect(!scripts\apparition\runtime\context::in_roster(undefined, player), "A missing roster cannot be iterated");
    foreach (invalid in ["invalid", 1, spawnstruct()])
        tests\support\checks::expect(!scripts\apparition\runtime\context::in_roster(invalid, player),
            "A non-array roster is rejected before membership iteration");
}

actor_admission_requires_every_numeric_slot_in_the_selected_list()
{
    // Use one real player reference while keeping every proposed list local
    player = tests\support\actors::first_player();
    tests\support\checks::expect(isDefined(player),
        "Actor admission contracts require one current native player in the opt-in game suite");
    if (!isDefined(player))
        return;

    tests\support\checks::expect(scripts\apparition\runtime\context::actor_reason([player]) == "",
        "A dense list containing an actual player remains admitted");
    tests\support\checks::expect(scripts\apparition\runtime\context::actor_reason([player, player]) == "",
        "Owner and target may be the same actual player in a dense personal request");

    missing_first = [];
    missing_first[1] = player;
    tests\support\checks::expect(scripts\apparition\runtime\context::actor_reason(missing_first)
        == "Wait for a valid player roster",
        "A sparse list cannot hide its missing first slot behind a valid player reference");

    missing_middle = [];
    missing_middle[0] = player;
    missing_middle[2] = player;
    tests\support\checks::expect(scripts\apparition\runtime\context::actor_reason(missing_middle)
        == "Wait for a valid player roster",
        "A missing middle slot rejects the complete list even when both present references are valid");

    named = [];
    named["member"] = player;
    tests\support\checks::expect(scripts\apparition\runtime\context::actor_reason(named)
        == "Wait for a valid player roster",
        "An associative player map cannot replace the dense numeric request list");
    tests\support\checks::expect(scripts\apparition\runtime\context::actor_reason([player, spawnstruct()])
        == "Wait for a valid player roster",
        "A later nonplayer rejects the selection after a valid first actor");
}

lobby_targets_preserve_native_order_and_exclude_the_host()
{
    host = spawnstruct();
    first = spawnstruct();
    second = spawnstruct();
    result = scripts\apparition\runtime\context::other_players([first, host, second], host);
    tests\support\checks::expect(result.size == 2 && result[0] == first && result[1] == second,
        "The shared lobby selection excludes only the current host and keeps every other actor in roster order");
    result = scripts\apparition\runtime\context::other_players([host], host);
    tests\support\checks::expect(result.size == 0,
        "Solo lobby selection has no other player and cannot target the host");
    result = scripts\apparition\runtime\context::other_players([first, second], host);
    tests\support\checks::expect(result.size == 0,
        "A missing host identity cannot turn every roster entry into a target");
    result = scripts\apparition\runtime\context::other_players(undefined, host);
    tests\support\checks::expect(result.size == 0,
        "An unavailable roster has no inferred targets");
    result = scripts\apparition\runtime\context::other_players(7, host);
    tests\support\checks::expect(result.size == 0,
        "A malformed roster is rejected by the selector before iteration");

}

current_host_rejects_invalid_rosters_before_native_host_reads()
{
    tests\support\checks::expect(!isDefined(scripts\apparition\runtime\context::current_host(undefined)),
        "Missing host-selection state is rejected before roster access");
    state = spawnstruct();
    tests\support\checks::expect(!isDefined(scripts\apparition\runtime\context::current_host(state)),
        "A missing roster cannot identify a current native host");
    state.players = [];
    tests\support\checks::expect(!isDefined(scripts\apparition\runtime\context::current_host(state)),
        "An empty roster cannot identify a current native host");
    state.players = [spawnstruct()];
    tests\support\checks::expect(!isDefined(scripts\apparition\runtime\context::current_host(state)),
        "A nonplayer roster is rejected before the native host method");
    state.players = [];
    state.players[1] = spawnstruct();
    tests\support\checks::expect(!isDefined(scripts\apparition\runtime\context::current_host(state)),
        "A sparse roster cannot identify a current native host");
}
