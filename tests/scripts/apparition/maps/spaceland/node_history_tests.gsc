// Potential-cycle history is an exclusion guard and never proof of native activation

run()
{
    duplicate_and_unmapped_hits_cannot_complete_a_history_cycle();
    every_distinct_node_latches_exclusion_regardless_of_order();
    a_late_listener_exits_without_changing_history();
}

history()
{
    nodes = [];
    for (index = 0; index < 5; index++)
        nodes[index] = spawnstruct();
    return scripts\apparition\maps\spaceland\node_history::create(nodes, spawnstruct());
}

duplicate_and_unmapped_hits_cannot_complete_a_history_cycle()
{
    watch = history();
    scripts\apparition\maps\spaceland\node_history::observe(watch, -1);
    tests\support\checks::expect(watch.seen.size == 0 && !watch.cycle_spent, "An unmapped damage event does not count toward exclusion");
    scripts\apparition\maps\spaceland\node_history::observe(watch, 2);
    scripts\apparition\maps\spaceland\node_history::observe(watch, 2);
    tests\support\checks::expect(isDefined(watch.seen[2]) && !isDefined(watch.seen[0]) && !watch.cycle_spent, "Repeated damage at one node is counted once");
    tests\support\checks::expect(!isDefined(watch.nodes[2].is_activated), "Observed input does not assign native node activation");
}

every_distinct_node_latches_exclusion_regardless_of_order()
{
    watch = history();
    scripts\apparition\maps\spaceland\node_history::observe(watch, 4);
    tests\support\checks::expect(!watch.cycle_spent, "A first hit at node five cannot substitute for the other four distinct nodes");
    foreach (index in [0, 3, 1, 2])
        scripts\apparition\maps\spaceland\node_history::observe(watch, index);
    tests\support\checks::expect(watch.cycle_spent, "Hits mapped to all five nodes permanently exclude another remote cycle");
    // Native resets, job cancellation and owner loss do not own this map history
    foreach (node in watch.nodes)
        node.is_activated = 0;
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\node_history::claim(watch, 0), "Cleared flags cannot allow a hit while a projectile may remain in flight");
    scripts\apparition\maps\spaceland\node_history::observe(watch, 0);
    tests\support\checks::expect(watch.cycle_spent && watch.seen.size == 5, "Later physical input never clears the exclusion latch");
}

a_late_listener_exits_without_changing_history()
{
    watch = history();
    watch.state = "Unavailable";
    // No entity wait is reached, so isolated structs are sufficient for this regression
    scripts\apparition\maps\spaceland\node_history::listen(watch);
    tests\support\checks::expect(!watch.waiting && watch.seen.size == 0, "A child scheduled after failed arming cannot become a live late observer");
}
