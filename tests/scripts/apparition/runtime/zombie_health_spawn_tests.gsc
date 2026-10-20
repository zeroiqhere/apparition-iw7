// Spawn callback ownership and deferred receipts reject foreign or stale writes

run()
{
    callback_install_accepts_only_exact_stock_or_owned_wrapper();
    a_new_receipt_invalidates_a_recycled_agents_old_worker();
    configuration_replacement_stops_an_old_worker();
    current_axis_policy_covers_non_generic_types();
    future_policy_is_limited_to_active_live_generic_axis_agents();
    missing_or_malformed_native_identity_fails_closed();
}

callback_install_accepts_only_exact_stock_or_owned_wrapper()
{
    stock = scripts\mp\agents\zombie\zombie_agent::setupagent;
    wrapper = scripts\apparition\runtime\zombie_health_spawn::setupagent_wrapper;
    foreign = ::run;
    tests\support\checks::expect(scripts\apparition\runtime\zombie_health_spawn::can_install_callback(stock)
        && scripts\apparition\runtime\zombie_health_spawn::can_install_callback(wrapper),
        "The exact native callback and an already-owned wrapper are idempotent installation states");
    tests\support\checks::expect(!scripts\apparition\runtime\zombie_health_spawn::can_install_callback(foreign),
        "A foreign profile callback is never overwritten or chained");
}

a_new_receipt_invalidates_a_recycled_agents_old_worker()
{
    config = scripts\apparition\maps\spaceland\zombie_health::configuration(200);
    agent = test_agent("generic_zombie", "axis", 1);
    first = scripts\apparition\runtime\zombie_health_spawn::new_receipt(agent, config);
    tests\support\checks::expect(scripts\apparition\runtime\zombie_health_spawn::receipt_matches(
        agent, first, config, config),
        "A deferred write owns the agent receipt created for its spawn");
    second = scripts\apparition\runtime\zombie_health_spawn::new_receipt(agent, config);
    tests\support\checks::expect(!scripts\apparition\runtime\zombie_health_spawn::receipt_matches(
        agent, first, config, config)
        && scripts\apparition\runtime\zombie_health_spawn::receipt_matches(agent, second, config, config),
        "A new spawn receipt invalidates delayed work for the recycled entity");
}

configuration_replacement_stops_an_old_worker()
{
    first_config = scripts\apparition\maps\spaceland\zombie_health::configuration(200);
    second_config = scripts\apparition\maps\spaceland\zombie_health::configuration(300);
    agent = test_agent("generic_zombie", "axis", 1);
    receipt = scripts\apparition\runtime\zombie_health_spawn::new_receipt(agent, first_config);
    tests\support\checks::expect(!scripts\apparition\runtime\zombie_health_spawn::receipt_matches(
        agent, receipt, first_config, second_config),
        "An older health policy cannot write after a newer configuration replaces it");
}

current_axis_policy_covers_non_generic_types()
{
    config = scripts\apparition\maps\spaceland\zombie_health::configuration(200);
    clown = test_agent("zombie_clown", "axis", 1);
    brute = test_agent("zombie_brute", "axis", 1);
    clown_receipt = scripts\apparition\runtime\zombie_health_spawn::new_receipt(clown, config);
    brute_receipt = scripts\apparition\runtime\zombie_health_spawn::new_receipt(brute, config);
    tests\support\checks::expect(scripts\apparition\runtime\zombie_health_spawn::eligible_current(
        clown, clown_receipt, config, config, true, true)
        && scripts\apparition\runtime\zombie_health_spawn::eligible_current(
            brute, brute_receipt, config, config, true, true),
        "The original current team scan can include live axis clowns and other agent profiles");
    clown.isactive = 0;
    tests\support\checks::expect(!scripts\apparition\runtime\zombie_health_spawn::eligible_current(
        clown, clown_receipt, config, config, true, true),
        "An inactive pooled actor is excluded from the current live team scan");
}

future_policy_is_limited_to_active_live_generic_axis_agents()
{
    config = scripts\apparition\maps\spaceland\zombie_health::configuration(200);
    generic = test_agent("generic_zombie", "axis", 1);
    generic_receipt = scripts\apparition\runtime\zombie_health_spawn::new_receipt(generic, config);
    clown = test_agent("zombie_clown", "axis", 1);
    clown_receipt = scripts\apparition\runtime\zombie_health_spawn::new_receipt(clown, config);
    tests\support\checks::expect(scripts\apparition\runtime\zombie_health_spawn::eligible_future(
        generic, generic_receipt, config, config, true, true),
        "The future-spawn hook admits the live active generic zombie archetype");
    tests\support\checks::expect(!scripts\apparition\runtime\zombie_health_spawn::eligible_future(
        clown, clown_receipt, config, config, true, true),
        "The future hook stays narrower than the current all-axis team scan");
    generic.team = "allies";
    tests\support\checks::expect(!scripts\apparition\runtime\zombie_health_spawn::eligible_future(
        generic, generic_receipt, config, config, true, true),
        "A future actor outside the axis team cannot receive a health write");
    generic.team = "axis";
    generic.isactive = 0;
    tests\support\checks::expect(!scripts\apparition\runtime\zombie_health_spawn::eligible_future(
        generic, generic_receipt, config, config, true, true),
        "An inactive future agent cannot receive a health write");
    generic.isactive = 1;
    tests\support\checks::expect(!scripts\apparition\runtime\zombie_health_spawn::eligible_future(
        generic, generic_receipt, config, config, false, true)
        && !scripts\apparition\runtime\zombie_health_spawn::eligible_future(
            generic, generic_receipt, config, config, true, false),
        "A stale roster entry or dead actor cannot receive a future health write");
}

missing_or_malformed_native_identity_fails_closed()
{
    config = scripts\apparition\maps\spaceland\zombie_health::configuration(200);
    agent = test_agent("generic_zombie", "axis", 1);
    receipt = scripts\apparition\runtime\zombie_health_spawn::new_receipt(agent, config);
    tests\support\checks::expect(!scripts\apparition\runtime\zombie_health_spawn::receipt_matches(
        agent, receipt, config, undefined),
        "A retired configuration cannot authorize deferred work");
    agent.agent_type = undefined;
    tests\support\checks::expect(!isDefined(scripts\apparition\runtime\zombie_health_spawn::new_receipt(agent, config)),
        "An agent without a typed profile cannot receive a spawn receipt");
    tests\support\checks::expect(!scripts\apparition\runtime\zombie_health_spawn::eligible_current(
        agent, receipt, config, config, true, true),
        "A mutated profile invalidates an earlier delayed receipt");
}

test_agent(type, team, active)
{
    result = spawnstruct();
    result.agent_type = type;
    result.team = team;
    result.isactive = active;
    result.health = 100;
    return result;
}
