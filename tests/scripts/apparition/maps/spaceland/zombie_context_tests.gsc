// Zombie requests share authority checks and an owned snapshot result

run()
{
    a_missing_owner_is_rejected_before_live_session_queries();
    snapshot_errors_keep_the_reason_and_an_empty_target_list();
    snapshot_targets_are_owned_by_the_returned_record();
}

a_missing_owner_is_rejected_before_live_session_queries()
{
    tests\support\checks::expect(scripts\apparition\maps\spaceland\zombie_context::owner_reason(undefined)
        == "The current host reference is unavailable",
        "A missing owner cannot reach native session or player predicates");
}

snapshot_errors_keep_the_reason_and_an_empty_target_list()
{
    result = scripts\apparition\maps\spaceland\zombie_context::snapshot("Wait for native agents");
    tests\support\checks::expect(result.reason == "Wait for native agents"
        && result.hint == result.reason && isarray(result.targets) && result.targets.size == 0,
        "Unavailable requests return their reason with no stale target payload");
}

snapshot_targets_are_owned_by_the_returned_record()
{
    first = scripts\apparition\maps\spaceland\zombie_context::snapshot("First request");
    second = scripts\apparition\maps\spaceland\zombie_context::snapshot("Second request");
    first.targets[0] = spawnstruct();
    first.reason = "Changed";
    tests\support\checks::expect(second.targets.size == 0 && second.reason == "Second request",
        "One request cannot change another snapshot's targets or availability");
}
