// Native movement mode contracts cover only initialized Spaceland actors

run()
{
    original_choices_keep_order_and_map_only_native_modes();
    movement_policy_accepts_only_supported_ordinary_actor_state();
    movement_policy_rejects_blocking_or_malformed_flags();
    movement_snapshot_requires_native_tables_and_detaches_unique_targets();
    movement_snapshot_rejects_malformed_tables_without_actor_mutation();
    live_requests_reject_unsupported_modes_and_missing_host_before_native_calls();
}

original_choices_keep_order_and_map_only_native_modes()
{
    expected = ["Walk", "Run", "Sprint", "Super Sprint"];
    actual = scripts\apparition\maps\spaceland\zombie_movement::modes();
    tests\support\checks::expect(isDefined(actual) && isarray(actual)
        && actual.size == expected.size, "The original four movement choices keep their order");
    if (!isDefined(actual) || !isarray(actual) || actual.size != expected.size)
        return;

    for (index = 0; index < expected.size; index++)
        tests\support\checks::expect(actual[index] == expected[index],
            "Each movement choice remains at its original slider position");

    tests\support\checks::expect(scripts\apparition\maps\spaceland\zombie_movement::native_mode("Walk") == "walk",
        "Walk maps to the native walk request");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\zombie_movement::native_mode("Run") == "run",
        "Run maps to the native run request");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\zombie_movement::native_mode("Sprint") == "sprint",
        "Sprint maps to the native sprint request");
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\zombie_movement::native_mode("Super Sprint")),
        "Super Sprint stays unsupported without a native mapping");
    tests\support\checks::expect(!isDefined(scripts\apparition\maps\spaceland\zombie_movement::native_mode("walk"))
        && !isDefined(scripts\apparition\maps\spaceland\zombie_movement::native_mode(1))
        && !isDefined(scripts\apparition\maps\spaceland\zombie_movement::native_mode(undefined)),
        "Unknown and mistyped choices cannot become a native request");
}

movement_policy_accepts_only_supported_ordinary_actor_state()
{
    foreach (invalid in [7, "not an actor", []])
        tests\support\checks::expect(!scripts\apparition\maps\spaceland\zombie_movement::eligible(invalid),
            "Scalar and array values cannot supply native movement fields");

    enemy = movement_agent();
    tests\support\checks::expect(scripts\apparition\maps\spaceland\zombie_movement::eligible(enemy),
        "An initialized ordinary Spaceland zombie is eligible for a movement request");

    enemy.agent_type = "zombie_clown";
    tests\support\checks::expect(scripts\apparition\maps\spaceland\zombie_movement::eligible(enemy),
        "A native clown with the same ordinary movement fields is eligible");

    foreach (type in ["zombie_brute", "zombie_grey", "zombie_ghost", "alien_goon", "skater"])
    {
        enemy.agent_type = type;
        tests\support\checks::expect(!scripts\apparition\maps\spaceland\zombie_movement::eligible(enemy),
            "Unverified special and quest actor types are excluded");
    }

    enemy = movement_agent();
    enemy.team = "allies";
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\zombie_movement::eligible(enemy),
        "Allied agents are not movement targets");
    enemy = movement_agent();
    enemy.health = 0;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\zombie_movement::eligible(enemy),
        "Dead agents are not movement targets");
    enemy = movement_agent();
    enemy.health = "500";
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\zombie_movement::eligible(enemy),
        "Malformed health cannot qualify an agent");
    enemy = movement_agent();
    enemy.movemode = "fly";
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\zombie_movement::eligible(enemy),
        "Unknown current native movement modes fail closed");
    enemy = movement_agent();
    enemy.asm.cur_move_mode = "fly";
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\zombie_movement::eligible(enemy),
        "Unknown active ASM movement modes fail closed");
    enemy = movement_agent();
    enemy.asm.cur_move_mode = undefined;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\zombie_movement::eligible(enemy),
        "An absent active ASM mode can use the initialized native actor mode fallback");
    enemy = movement_agent();
    enemy.aistate = "traverse";
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\zombie_movement::eligible(enemy),
        "Agents traversing a scripted path are left to native movement");
    enemy = movement_agent();
    enemy.aistate = 7;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\zombie_movement::eligible(enemy),
        "Malformed native AI state cannot qualify for a direct movement request");
    enemy = movement_agent();
    enemy.statelocked = 1;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\zombie_movement::eligible(enemy),
        "Scripted state locks block direct movement requests");
    enemy = movement_agent();
    enemy.isfrozen = 0;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\zombie_movement::eligible(enemy),
        "A defined frozen-state marker blocks requests even when zero-valued");
    enemy = movement_agent();
    enemy.asm = undefined;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\zombie_movement::eligible(enemy),
        "An uninitialized ASM record blocks movement requests");
    enemy = movement_agent();
    enemy._blackboard = undefined;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\zombie_movement::eligible(enemy),
        "An uninitialized native blackboard blocks movement requests");
}

movement_policy_rejects_blocking_or_malformed_flags()
{
    enemy = movement_agent();
    enemy.statelocked = undefined;
    enemy.is_reserved = undefined;
    enemy.is_suicide_bomber = undefined;
    enemy.is_crawler = undefined;
    enemy.dismember_crawl = undefined;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\zombie_movement::eligible(enemy),
        "Absent nonblocking native flags are accepted");

    enemy = movement_agent();
    enemy.statelocked = "0";
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\zombie_movement::eligible(enemy),
        "Malformed scripted-lock state is rejected rather than treated as unlocked");
    enemy = movement_agent();
    enemy.is_reserved = "0";
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\zombie_movement::eligible(enemy),
        "Malformed reservation state is rejected rather than treated as unreserved");
    enemy = movement_agent();
    enemy.is_suicide_bomber = "0";
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\zombie_movement::eligible(enemy),
        "Malformed suicide-bomber state is rejected rather than treated as safe");
    enemy = movement_agent();
    enemy.is_crawler = "0";
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\zombie_movement::eligible(enemy),
        "Malformed crawler state is rejected rather than treated as safe");
    enemy = movement_agent();
    enemy.dismember_crawl = "0";
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\zombie_movement::eligible(enemy),
        "Malformed dismember-crawl state is rejected rather than treated as safe");
    enemy = movement_agent();
    enemy.is_suicide_bomber = 1;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\zombie_movement::eligible(enemy),
        "Suicide-bomber movement remains native-owned");
    enemy = movement_agent();
    enemy.is_crawler = 1;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\zombie_movement::eligible(enemy),
        "Crawler movement remains native-owned");
    enemy = movement_agent();
    enemy.dismember_crawl = 1;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\zombie_movement::eligible(enemy),
        "Dismember-crawl movement remains native-owned");
}

movement_snapshot_requires_native_tables_and_detaches_unique_targets()
{
    state = movement_state();
    first = movement_agent();
    second = movement_agent();
    second.movemode = "sprint";
    agents = [first, first, second];
    state.agentarray = agents;

    result = scripts\apparition\maps\spaceland\zombie_movement::inspect(state, agents);
    tests\support\checks::expect(result.reason == "" && result.targets.size == 2
        && result.targets[0] == first && result.targets[1] == second,
        "Ready native mode tuning admits unique ordinary agents in roster order");
    tests\support\checks::expect(isDefined(result.hint) && isstring(result.hint),
        "A ready snapshot includes current-pass request wording");
    tests\support\checks::expect(first.movemode == "walk" && second.movemode == "sprint",
        "Inspecting movement choices does not change actor modes");

    result.targets[0] = 7;
    tests\support\checks::expect(agents[0] == first && agents[1] == first,
        "Snapshot targets are built separately from the input roster");

    state = movement_state();
    state.agentarray = [];
    result = scripts\apparition\maps\spaceland\zombie_movement::inspect(state, []);
    tests\support\checks::expect(result.reason == "" && result.targets.size == 0,
        "An initialized empty native roster is a ready empty snapshot");
}

movement_snapshot_rejects_malformed_tables_without_actor_mutation()
{
    tests\support\checks::expect(scripts\apparition\maps\spaceland\zombie_movement::inspect(undefined, []).reason != "",
        "A missing state cannot authorize movement requests");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\zombie_movement::inspect([], []).reason != "",
        "An array cannot stand in for native Spaceland state");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\zombie_movement::inspect(movement_state(), "bad roster").reason != "",
        "A malformed supplied actor roster is not treated as empty");

    state = movement_state();
    state._id_13FA8 = undefined;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\zombie_movement::inspect(state, []).reason != "",
        "A missing native movement table cannot authorize requests");

    tests\support\checks::expect(scripts\apparition\maps\spaceland\zombie_movement::inspect(movement_state(), undefined).reason != "",
        "An undefined supplied actor roster cannot authorize requests");

    foreach (invalid in ["bad table", spawnstruct()])
    {
        state = movement_state();
        state._id_13FA8 = invalid;
        result = scripts\apparition\maps\spaceland\zombie_movement::inspect(state, []);
        tests\support\checks::expect(result.reason != "" && result.targets.size == 0,
            "Missing or malformed movement tuning blocks the complete request catalog");
    }

    foreach (mode in ["walk", "run", "sprint"])
    {
        state = movement_state();
        state._id_13FA8[mode] = 0;
        result = scripts\apparition\maps\spaceland\zombie_movement::inspect(state, []);
        tests\support\checks::expect(result.reason != "",
            "A missing positive native tuning value blocks movement requests");

        state = movement_state();
        state._id_13FA8[mode] = "20";
        result = scripts\apparition\maps\spaceland\zombie_movement::inspect(state, []);
        tests\support\checks::expect(result.reason != "",
            "Text tuning values cannot be used as native movement metadata");
    }

    state = movement_state();
    state._id_13FA8["sprint"] = undefined;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\zombie_movement::inspect(state, []).reason != "",
        "Each supported request mode must have a native movement-table entry");

    state = movement_state();
    enemy = movement_agent();
    result = scripts\apparition\maps\spaceland\zombie_movement::inspect(state, [enemy]);
    tests\support\checks::expect(result.reason == "" && result.targets.size == 0,
        "A candidate outside the current native agent registry is not selected");

    state = movement_state();
    enemy = movement_agent();
    state.agentarray = [enemy];
    enemy.is_reserved = 1;
    original_mode = enemy.movemode;
    result = scripts\apparition\maps\spaceland\zombie_movement::inspect(state, [enemy]);
    tests\support\checks::expect(result.reason == "" && result.targets.size == 0
        && enemy.movemode == original_mode,
        "Reserved actors are excluded without mutating their native mode");
}

live_requests_reject_unsupported_modes_and_missing_host_before_native_calls()
{
    result = scripts\apparition\maps\spaceland\zombie_movement::probe(undefined);
    tests\support\checks::expect(result.reason != "" && result.targets.size == 0,
        "A missing host is rejected before native agent methods or movement setters");
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\zombie_movement::request(undefined, "Super Sprint")
        && !scripts\apparition\maps\spaceland\zombie_movement::request(undefined, "unknown")
        && !scripts\apparition\maps\spaceland\zombie_movement::request(undefined, 2),
        "Unsupported or malformed movement choices reject before host or agent queries");
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\zombie_movement::request(undefined, "Walk"),
        "A supported mode still rejects when no current host actor is available");
}

movement_state()
{
    // Native initialization supplies these entries before a request is admitted
    state = spawnstruct();
    state.agentarray = [];
    state._id_13FA8 = [];
    state._id_13FA8["walk"] = 20;
    state._id_13FA8["run"] = 24;
    state._id_13FA8["sprint"] = 32;
    return state;
}

movement_agent()
{
    // These fields model initialized state without creating a live game agent
    enemy = spawnstruct();
    enemy.agent_type = "generic_zombie";
    enemy.team = "axis";
    enemy.health = 500;
    enemy.movemode = "walk";
    enemy.aistate = "idle";
    enemy.statelocked = 0;
    enemy.asm = spawnstruct();
    enemy.asm.cur_move_mode = "walk";
    enemy._blackboard = spawnstruct();
    enemy._blackboard.movetype = "walk";
    enemy.is_reserved = 0;
    enemy.is_suicide_bomber = 0;
    enemy.is_crawler = 0;
    enemy.dismember_crawl = 0;
    return enemy;
}
