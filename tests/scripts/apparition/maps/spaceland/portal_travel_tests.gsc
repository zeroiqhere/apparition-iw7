// Side-visit job contracts use isolated structs and real notification tickets

run()
{
    only_opening_and_travelling_reserve_the_side_visit_slot();
    status_uses_the_same_side_order_as_the_controls();
    finishing_a_visit_releases_listeners_and_actor_references();
}

only_opening_and_travelling_reserve_the_side_visit_slot()
{
    job = spawnstruct();
    job.state = "Opening";
    tests\support\checks::expect(scripts\apparition\maps\spaceland\portal_travel::running(job), "Opening reserves the shared side-visit job");
    job.state = "Travelling";
    tests\support\checks::expect(scripts\apparition\maps\spaceland\portal_travel::running(job), "A submitted native trip prevents another menu visit");
    foreach (outcome in ["Visited", "Pending", "Interrupted", "Unavailable"])
    {
        job.state = outcome;
        tests\support\checks::expect(!scripts\apparition\maps\spaceland\portal_travel::running(job), "A terminal observation does not reserve another job");
    }
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\portal_travel::running(undefined), "A missing job does not reserve the controls");
}

status_uses_the_same_side_order_as_the_controls()
{
    state = spawnstruct();
    tests\support\checks::expect(scripts\apparition\maps\spaceland\portal_travel::status(state) == "Idle", "No visit displays Idle");
    state.apparition_portal_job = spawnstruct();
    state.apparition_portal_job.area = "arcade";
    state.apparition_portal_job.state = "Opening";
    tests\support\checks::expect(scripts\apparition\maps\spaceland\portal_travel::status(state) == "Side Portal 1: Opening", "The status identifies the first side control");
    state.apparition_portal_job.area = "mars";
    state.apparition_portal_job.state = "Visited";
    tests\support\checks::expect(scripts\apparition\maps\spaceland\portal_travel::status(state) == "Side Portal 4: Visited", "A terminal result keeps its selected side identity");
}

finishing_a_visit_releases_listeners_and_actor_references()
{
    emitter = spawnstruct();
    trigger = scripts\apparition\runtime\events::arm(emitter, ["trigger"]);
    complete = scripts\apparition\runtime\events::arm(emitter, ["fast_travel_complete"]);
    job = spawnstruct();
    job.owner = spawnstruct();
    job.trigger = trigger;
    job.complete = complete;
    job.state = "Opening";
    scripts\apparition\maps\spaceland\portal_worker::finish(job, "Interrupted");
    emitter notify("trigger");
    emitter notify("fast_travel_complete");
    wait 0.05;
    tests\support\checks::expect(job.state == "Interrupted" && !isDefined(job.owner), "Finishing preserves its outcome and releases the actor reference");
    tests\support\checks::expect(!isDefined(job.trigger) && !isDefined(job.complete), "Finished jobs keep no event-ticket references");
    tests\support\checks::expect(trigger.state == "Cancelled" && complete.state == "Cancelled", "Both native observers are canceled on exit");
    tests\support\checks::expect(!isDefined(trigger.event) && !isDefined(complete.event), "Canceled observers cannot capture later events");
}
