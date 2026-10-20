// Gun contracts check saved intent, generation ownership and real stop notifications

run()
{
    missing_records_are_off_and_saved_records_are_read_only();
    only_the_current_record_matches_its_generation();
    release_clears_the_record_and_emits_the_stop_event();
    stale_release_preserves_a_newer_record_and_listener();
    an_old_record_stop_cannot_reach_the_new_generation();
    repeated_release_does_not_emit_an_extra_stop();
    malformed_saved_state_can_be_cleared_without_an_invalid_notify();
    rejected_authority_preserves_an_existing_setting();
}

missing_records_are_off_and_saved_records_are_read_only()
{
    tests\support\checks::expect(!scripts\apparition\features\teleport_gun::configured(undefined),
        "A missing player has no saved Teleport Gun setting");
    player = spawnstruct();
    tests\support\checks::expect(!scripts\apparition\features\teleport_gun::configured(player),
        "A player without a gun record is configured off");
    record = spawnstruct();
    record.owner = spawnstruct();
    player.apparition_teleport_gun = record;
    tests\support\checks::expect(scripts\apparition\features\teleport_gun::configured(player),
        "A saved record reports intent without claiming that the next shot can move");
    tests\support\checks::expect(player.apparition_teleport_gun == record
        && isDefined(record.owner), "Reading the checkbox leaves grant ownership unchanged");
}

only_the_current_record_matches_its_generation()
{
    player = spawnstruct();
    old_record = spawnstruct();
    current_record = spawnstruct();
    player.apparition_teleport_gun = current_record;
    tests\support\checks::expect(scripts\apparition\features\teleport_gun::is_current(player, current_record),
        "A worker recognizes the record still owned by its player");
    tests\support\checks::expect(!scripts\apparition\features\teleport_gun::is_current(player, old_record),
        "A replaced worker cannot treat the new record as its own");
    tests\support\checks::expect(!scripts\apparition\features\teleport_gun::is_current(player, undefined)
        && !scripts\apparition\features\teleport_gun::is_current(undefined, current_record),
        "Missing records and actors never match a live generation");
}

release_clears_the_record_and_emits_the_stop_event()
{
    player = spawnstruct();
    record = spawnstruct();
    player.apparition_teleport_gun = record;
    ticket = scripts\apparition\runtime\events::arm(record, ["apparition_stop_teleport_gun"]);
    tests\support\checks::expect(ticket.state == "Armed", "The stop observer is armed before release");
    tests\support\checks::expect(scripts\apparition\features\teleport_gun::release(player, record),
        "The current worker record can be released");
    tests\support\checks::expect(!scripts\apparition\features\teleport_gun::configured(player),
        "Release clears saved intent before returning");
    wait 0.05;
    tests\support\checks::expect(isDefined(ticket.event)
        && ticket.event == "apparition_stop_teleport_gun", "Release notifies the actual GSC stop listener");
    scripts\apparition\runtime\events::cancel(ticket);
}

stale_release_preserves_a_newer_record_and_listener()
{
    player = spawnstruct();
    old_record = spawnstruct();
    new_record = spawnstruct();
    player.apparition_teleport_gun = new_record;
    ticket = scripts\apparition\runtime\events::arm(new_record, ["apparition_stop_teleport_gun"]);
    tests\support\checks::expect(!scripts\apparition\features\teleport_gun::release(player, old_record),
        "A stale worker cannot release a newer generation");
    wait 0.05;
    tests\support\checks::expect(player.apparition_teleport_gun == new_record && !isDefined(ticket.event),
        "Stale cleanup changes neither current intent nor its stop event");
    scripts\apparition\runtime\events::cancel(ticket);
    scripts\apparition\features\teleport_gun::release(player);
}

an_old_record_stop_cannot_reach_the_new_generation()
{
    old_record = spawnstruct();
    new_record = spawnstruct();
    ticket = scripts\apparition\runtime\events::arm(new_record, ["apparition_stop_teleport_gun"]);
    old_record notify("apparition_stop_teleport_gun");
    wait 0.05;
    tests\support\checks::expect(!isDefined(ticket.event),
        "The old grant's stop source cannot reach a new grant's listener");
    scripts\apparition\runtime\events::cancel(ticket);
}

repeated_release_does_not_emit_an_extra_stop()
{
    player = spawnstruct();
    record = spawnstruct();
    player.apparition_teleport_gun = record;
    scripts\apparition\features\teleport_gun::release(player);
    ticket = scripts\apparition\runtime\events::arm(record, ["apparition_stop_teleport_gun"]);
    tests\support\checks::expect(!scripts\apparition\features\teleport_gun::release(player),
        "Releasing an already disabled setting is a no-op");
    wait 0.05;
    tests\support\checks::expect(!isDefined(ticket.event), "A repeated release cannot stop unrelated later work");
    tests\support\checks::expect(!scripts\apparition\features\teleport_gun::release(undefined),
        "A missing player has no record or listener to release");
    scripts\apparition\runtime\events::cancel(ticket);
}

malformed_saved_state_can_be_cleared_without_an_invalid_notify()
{
    player = spawnstruct();
    player.apparition_teleport_gun = 7;
    tests\support\checks::expect(scripts\apparition\features\teleport_gun::release(player)
        && !isDefined(player.apparition_teleport_gun),
        "Malformed saved state is cleared without treating a scalar as a stop emitter");
}

rejected_authority_preserves_an_existing_setting()
{
    player = spawnstruct();
    record = spawnstruct();
    player.apparition_teleport_gun = record;
    ticket = scripts\apparition\runtime\events::arm(record, ["apparition_stop_teleport_gun"]);
    tests\support\checks::expect(!scripts\apparition\features\teleport_gun::toggle(undefined, player),
        "A missing requester cannot disable or replace a saved setting");
    wait 0.05;
    tests\support\checks::expect(player.apparition_teleport_gun == record && !isDefined(ticket.event),
        "Rejected authorization leaves both the record and stop listeners untouched");
    tests\support\checks::expect(!scripts\apparition\features\teleport_gun::toggle(undefined, undefined),
        "Missing actors cannot enable a new gun worker");
    scripts\apparition\runtime\events::cancel(ticket);
    scripts\apparition\features\teleport_gun::release(player);
}
