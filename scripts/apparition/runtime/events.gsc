// A ticket arms its listener before the operation that can emit an immediate ack

arm(source, events)
{
    ticket = spawnstruct();
    ticket.state = "Arming";
    ticket.waiting = 0;
    foreach (event in events)
        source thread capture(ticket, event);
    // A bounded handshake avoids relying on how newly started threads are scheduled
    deadline = getTime() + 1000;
    while (ticket.state == "Arming" && ticket.waiting < events.size && getTime() < deadline)
        wait 0.05;
    if (ticket.state == "Arming")
    {
        if (ticket.waiting == events.size)
            ticket.state = "Armed";
        else
            cancel(ticket);
    }
    ticket.waiting = undefined;
    return ticket;
}

capture(ticket, event)
{
    if (ticket.state != "Arming" && ticket.state != "Armed")
        return;
    ticket endon("apparition_cancel_event");
    level endon("game_ended");
    ticket.waiting++;
    // No yielding operation separates readiness from entering the event wait
    self waittill(event);
    if (!isDefined(ticket.event))
    {
        ticket.event = event;
        ticket.state = "Received";
    }
    // The first response removes all sibling listeners through their shared ticket
    ticket notify("apparition_cancel_event");
}

cancel(ticket)
{
    ticket.state = "Cancelled";
    ticket notify("apparition_cancel_event");
}
