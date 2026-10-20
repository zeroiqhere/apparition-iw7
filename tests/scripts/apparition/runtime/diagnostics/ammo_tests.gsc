// Optional contracts use real console output without touching player state

run()
{
    new_trace_starts_empty_with_fixed_limits();
    inventory_details_require_the_explicit_ticket_flag();
    first_record_is_emitted_and_counted();
    last_record_is_emitted_and_later_records_are_rejected();
    event_catalog_includes_down_revive_and_worker_refreshes();
}

new_trace_starts_empty_with_fixed_limits()
{
    ticket = scripts\apparition\runtime\diagnostics\ammo::new_ticket();
    tests\support\checks::expect(ticket.count == 0, "A new trace has no emitted records");
    tests\support\checks::expect(ticket.limit == 512, "A new trace allows at most 512 records");
    tests\support\checks::expect(ticket.deadline - ticket.started == 180000,
        "The trace deadline is three minutes after its start");
    tests\support\checks::expect(!ticket.include_inventory,
        "An ordinary trace omits the optional inventory queries");
}

inventory_details_require_the_explicit_ticket_flag()
{
    ticket = scripts\apparition\runtime\diagnostics\ammo::new_ticket(true);
    tests\support\checks::expect(ticket.include_inventory,
        "The explicit inventory flag enables detailed observations");
    foreach (invalid in [false, 2, "1", [], spawnstruct()])
    {
        ticket = scripts\apparition\runtime\diagnostics\ammo::new_ticket(invalid);
        tests\support\checks::expect(!ticket.include_inventory,
            "An invalid inventory flag leaves the optional queries disabled");
    }
}

first_record_is_emitted_and_counted()
{
    ticket = scripts\apparition\runtime\diagnostics\ammo::new_ticket();
    tests\support\checks::expect(scripts\apparition\runtime\diagnostics\ammo::emit(ticket, "contract", "first"),
        "The first diagnostic record is accepted");
    tests\support\checks::expect(ticket.count == 1,
        "One emitted diagnostic record consumes one slot");
}

last_record_is_emitted_and_later_records_are_rejected()
{
    ticket = scripts\apparition\runtime\diagnostics\ammo::new_ticket();
    ticket.count = 511;
    tests\support\checks::expect(scripts\apparition\runtime\diagnostics\ammo::emit(ticket, "contract", "last"),
        "The final diagnostic slot remains usable");
    tests\support\checks::expect(ticket.count == 512,
        "The final record reaches the fixed diagnostic limit");
    tests\support\checks::expect(!scripts\apparition\runtime\diagnostics\ammo::emit(ticket, "contract", "overflow"),
        "A full trace refuses another console record");
    tests\support\checks::expect(ticket.count == 512,
        "A rejected diagnostic record leaves its count unchanged");
}

event_catalog_includes_down_revive_and_worker_refreshes()
{
    events = scripts\apparition\runtime\diagnostics\ammo::events();
    tests\support\checks::expect(events.size == 5,
        "The diagnostic watches exactly five relevant events");
    foreach (required in ["weapon_fired", "weapon_change", "spawned_player", "last_stand", "revive"])
    {
        occurrences = 0;
        foreach (event in events)
        {
            if (event == required)
                occurrences++;
        }
        tests\support\checks::expect(occurrences == 1,
            "The " + required + " event has one diagnostic listener");
    }
}
