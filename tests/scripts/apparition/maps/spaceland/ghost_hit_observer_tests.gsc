// Isolated callbacks exercise the shared observer without native damage or actors

run()
{
    a_terminal_result_returns_without_an_extra_poll();
    a_nonterminal_result_is_polled_again_before_returning();
    an_expired_deadline_is_passed_to_the_policy_immediately();
    running_and_status_use_one_observer_state();
}

a_terminal_result_returns_without_an_extra_poll()
{
    job = spawnstruct();
    job.calls = 0;
    job.after = 1;
    job.result = "Completed";
    result = scripts\apparition\maps\spaceland\ghost_hit_observer::wait_for_result(job, ::record_poll, getTime() + 5000);
    tests\support\checks::expect(result == "Completed" && job.calls == 1, "A terminal policy result ends observation before another callback");
}

a_nonterminal_result_is_polled_again_before_returning()
{
    job = spawnstruct();
    job.calls = 0;
    job.after = 2;
    job.result = "Unavailable";
    result = scripts\apparition\maps\spaceland\ghost_hit_observer::wait_for_result(job, ::record_poll, getTime() + 5000);
    tests\support\checks::expect(result == "Unavailable" && job.calls == 2, "An unresolved policy is revisited until it returns a terminal result");
}

an_expired_deadline_is_passed_to_the_policy_immediately()
{
    job = spawnstruct();
    job.calls = 0;
    job.after = 1;
    job.result = "Pending";
    result = scripts\apparition\maps\spaceland\ghost_hit_observer::wait_for_result(job, ::record_poll, getTime() - 1);
    tests\support\checks::expect(result == "Pending" && job.expired, "An already-expired bound reaches policy without a preliminary wait");
}

running_and_status_use_one_observer_state()
{
    job = spawnstruct();
    job.state = "Observing";
    tests\support\checks::expect(scripts\apparition\maps\spaceland\ghost_hit_observer::running(job), "An observing job owns its feature's input slot");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\ghost_hit_observer::status(job) == "Observing", "Observer state remains separate from native quest progress");
    job.state = "Pending";
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\ghost_hit_observer::running(job), "A terminal observation does not stay active");
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\ghost_hit_observer::running(undefined), "A missing job cannot own an input slot");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\ghost_hit_observer::status(undefined) == "Idle", "No job has an idle status");
}

record_poll(job, expired)
{
    job.calls++;
    job.expired = expired;
    return job.calls >= job.after ? job.result : "";
}
