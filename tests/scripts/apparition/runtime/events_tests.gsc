// Real GSC notifications check that an observer is armed before its caller acts

run()
{
    an_immediate_event_is_captured_after_arming();
    the_first_matching_event_is_retained();
    cancellation_removes_the_pending_observer();
}

an_immediate_event_is_captured_after_arming()
{
    emitter = spawnstruct();
    ticket = scripts\apparition\runtime\events::arm(emitter, ["ack"]);
    tests\support\checks::expect(ticket.state == "Armed", "Arming returns only after its listener reaches the wait");
    emitter notify("ack");
    wait 0.05;
    tests\support\checks::expect(isDefined(ticket.event) && ticket.event == "ack", "An event immediately after arming cannot be lost");
    tests\support\checks::expect(ticket.state == "Received", "A captured event closes the observer ticket");
    scripts\apparition\runtime\events::cancel(ticket);
}

the_first_matching_event_is_retained()
{
    emitter = spawnstruct();
    ticket = scripts\apparition\runtime\events::arm(emitter, ["ack", "failure"]);
    emitter notify("failure");
    wait 0.05;
    emitter notify("ack");
    wait 0.05;
    tests\support\checks::expect(isDefined(ticket.event) && ticket.event == "failure", "A later event cannot overwrite the first result");
    scripts\apparition\runtime\events::cancel(ticket);
}

cancellation_removes_the_pending_observer()
{
    emitter = spawnstruct();
    ticket = scripts\apparition\runtime\events::arm(emitter, ["ack"]);
    scripts\apparition\runtime\events::cancel(ticket);
    tests\support\checks::expect(ticket.state == "Cancelled", "Cancellation records a terminal ticket state");
    emitter notify("ack");
    wait 0.05;
    tests\support\checks::expect(!isDefined(ticket.event), "A cancelled observer cannot capture later events");
}
