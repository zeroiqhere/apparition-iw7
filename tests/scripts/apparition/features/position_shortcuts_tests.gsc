// Position shortcut contracts cover saved intent, worker ownership and menu suppression

run()
{
    missing_records_are_off_and_saved_state_is_read_only();
    outside_menu_rejects_open_and_pending_sessions();
    release_clears_only_the_owned_record_and_notifies_once();
    stale_release_preserves_a_newer_record_and_listener();
    an_old_stop_source_cannot_reach_a_new_worker();
    repeated_release_does_not_emit_an_extra_stop();
    malformed_saved_state_can_be_cleared_without_an_invalid_notify();
    rejected_authority_preserves_existing_shortcuts();
    invalid_actor_authority_releases_the_owned_worker_only();
    a_stale_worker_cannot_clear_or_stop_the_current_generation();
}

missing_records_are_off_and_saved_state_is_read_only()
{
    tests\support\checks::expect(!scripts\apparition\features\position_shortcuts::configured(undefined),
        "A missing player has no saved shortcut setting");
    player = spawnstruct();
    tests\support\checks::expect(!scripts\apparition\features\position_shortcuts::configured(player),
        "A player without a shortcut record is configured off");
    record = spawnstruct();
    record.owner = spawnstruct();
    grant = spawnstruct();
    grant.access = "Verified";
    record.menu_grant = grant;
    saved_position = spawnstruct();
    gun_record = spawnstruct();
    player.apparition_position_shortcuts = record;
    player.apparition_saved_position = saved_position;
    player.apparition_teleport_gun = gun_record;

    tests\support\checks::expect(scripts\apparition\features\position_shortcuts::configured(player),
        "A shortcut record reports saved intent without claiming the player can move now");
    tests\support\checks::expect(player.apparition_position_shortcuts == record
        && record.owner != player && record.menu_grant == grant
        && player.apparition_saved_position == saved_position
        && player.apparition_teleport_gun == gun_record,
        "Reading shortcut state leaves ownership, saved position and Teleport Gun unchanged");
}

outside_menu_rejects_open_and_pending_sessions()
{
    tests\support\checks::expect(!scripts\apparition\features\position_shortcuts::outside_menu(undefined),
        "A missing player cannot poll action-slot input");
    player = spawnstruct();
    tests\support\checks::expect(scripts\apparition\features\position_shortcuts::outside_menu(player),
        "A player with no open or pending menu can poll shortcuts");

    player.apparition_open = true;
    tests\support\checks::expect(!scripts\apparition\features\position_shortcuts::outside_menu(player),
        "An open menu suppresses shortcut input");
    player.apparition_open = false;
    player.apparition_open_request = spawnstruct();
    tests\support\checks::expect(!scripts\apparition\features\position_shortcuts::outside_menu(player),
        "A pending menu open suppresses shortcut input before it becomes visible");
    player.apparition_open_request = undefined;
    tests\support\checks::expect(scripts\apparition\features\position_shortcuts::outside_menu(player),
        "Clearing the pending request restores outside-menu input");
}

release_clears_only_the_owned_record_and_notifies_once()
{
    player = spawnstruct();
    record = spawnstruct();
    saved_position = spawnstruct();
    gun_record = spawnstruct();
    player.apparition_position_shortcuts = record;
    player.apparition_saved_position = saved_position;
    player.apparition_teleport_gun = gun_record;
    ticket = scripts\apparition\runtime\events::arm(record, ["apparition_stop_position_shortcuts"]);
    tests\support\checks::expect(ticket.state == "Armed", "The shortcut stop observer is armed first");

    tests\support\checks::expect(scripts\apparition\features\position_shortcuts::release(player, record),
        "The current shortcut worker can be released");
    tests\support\checks::expect(!scripts\apparition\features\position_shortcuts::configured(player),
        "Release clears saved shortcut intent before returning");
    tests\support\checks::expect(player.apparition_saved_position == saved_position
        && player.apparition_teleport_gun == gun_record,
        "Disabling shortcuts preserves the saved position and independent Teleport Gun");
    wait 0.05;
    tests\support\checks::expect(isDefined(ticket.event)
        && ticket.event == "apparition_stop_position_shortcuts",
        "Release notifies only the shortcut worker's stop event");
    scripts\apparition\runtime\events::cancel(ticket);
}

stale_release_preserves_a_newer_record_and_listener()
{
    player = spawnstruct();
    old_record = spawnstruct();
    new_record = spawnstruct();
    player.apparition_position_shortcuts = new_record;
    ticket = scripts\apparition\runtime\events::arm(new_record, ["apparition_stop_position_shortcuts"]);

    tests\support\checks::expect(!scripts\apparition\features\position_shortcuts::release(player, old_record),
        "A stale worker cannot release a newer shortcut generation");
    wait 0.05;
    tests\support\checks::expect(player.apparition_position_shortcuts == new_record
        && !isDefined(ticket.event), "Stale cleanup leaves the current record and its listener untouched");
    scripts\apparition\runtime\events::cancel(ticket);
    scripts\apparition\features\position_shortcuts::release(player);
}

an_old_stop_source_cannot_reach_a_new_worker()
{
    old_record = spawnstruct();
    new_record = spawnstruct();
    ticket = scripts\apparition\runtime\events::arm(new_record, ["apparition_stop_position_shortcuts"]);

    old_record notify("apparition_stop_position_shortcuts");
    wait 0.05;
    tests\support\checks::expect(!isDefined(ticket.event),
        "An older record's stop source cannot reach a newer worker");
    scripts\apparition\runtime\events::cancel(ticket);
}

repeated_release_does_not_emit_an_extra_stop()
{
    player = spawnstruct();
    record = spawnstruct();
    player.apparition_position_shortcuts = record;
    scripts\apparition\features\position_shortcuts::release(player);
    ticket = scripts\apparition\runtime\events::arm(record, ["apparition_stop_position_shortcuts"]);

    tests\support\checks::expect(!scripts\apparition\features\position_shortcuts::release(player),
        "Releasing a disabled shortcut setting is a no-op");
    wait 0.05;
    tests\support\checks::expect(!isDefined(ticket.event),
        "A repeated release cannot stop later or unrelated work");
    tests\support\checks::expect(!scripts\apparition\features\position_shortcuts::release(undefined),
        "A missing player has no shortcut record or listener to release");
    scripts\apparition\runtime\events::cancel(ticket);
}

malformed_saved_state_can_be_cleared_without_an_invalid_notify()
{
    player = spawnstruct();
    player.apparition_position_shortcuts = 7;
    tests\support\checks::expect(scripts\apparition\features\position_shortcuts::release(player)
        && !isDefined(player.apparition_position_shortcuts),
        "Malformed shortcut state is cleared without treating a scalar as a stop emitter");
}

rejected_authority_preserves_existing_shortcuts()
{
    target = spawnstruct();
    record = spawnstruct();
    target.apparition_position_shortcuts = record;
    ticket = scripts\apparition\runtime\events::arm(record, ["apparition_stop_position_shortcuts"]);

    tests\support\checks::expect(!scripts\apparition\features\position_shortcuts::toggle(undefined, target),
        "A missing requester cannot disable or replace saved shortcuts");
    wait 0.05;
    tests\support\checks::expect(target.apparition_position_shortcuts == record && !isDefined(ticket.event),
        "Rejected authority preserves the worker record and stop listener");
    tests\support\checks::expect(!scripts\apparition\features\position_shortcuts::toggle(undefined, undefined),
        "Missing actors cannot enable a shortcut worker");
    scripts\apparition\runtime\events::cancel(ticket);
    scripts\apparition\features\position_shortcuts::release(target);
}

invalid_actor_authority_releases_the_owned_worker_only()
{
    actor = spawnstruct();
    owner = spawnstruct();
    record = spawnstruct();
    saved_position = spawnstruct();
    gun_record = spawnstruct();
    record.owner = owner;
    record.menu_grant = undefined;
    actor.apparition_position_shortcuts = record;
    actor.apparition_saved_position = saved_position;
    actor.apparition_teleport_gun = gun_record;
    ticket = scripts\apparition\runtime\events::arm(record, ["apparition_stop_position_shortcuts"]);

    actor thread scripts\apparition\features\position_shortcuts::run(record);
    wait 0.05;
    tests\support\checks::expect(!isDefined(actor.apparition_position_shortcuts),
        "A worker whose actors fail native actor admission clears its own active record");
    tests\support\checks::expect(isDefined(ticket.event)
        && ticket.event == "apparition_stop_position_shortcuts",
        "Invalid actor cleanup sends the current worker's stop event");
    tests\support\checks::expect(actor.apparition_saved_position == saved_position
        && actor.apparition_teleport_gun == gun_record,
        "Invalid actor cleanup preserves saved position and the separate gun worker");
    scripts\apparition\runtime\events::cancel(ticket);
    // A failing cleanup path must not leave its poller or record behind
    scripts\apparition\features\position_shortcuts::release(actor, record);
}

a_stale_worker_cannot_clear_or_stop_the_current_generation()
{
    actor = spawnstruct();
    stale_record = spawnstruct();
    current_record = spawnstruct();
    saved_position = spawnstruct();
    gun_record = spawnstruct();
    actor.apparition_position_shortcuts = current_record;
    actor.apparition_saved_position = saved_position;
    actor.apparition_teleport_gun = gun_record;
    ticket = scripts\apparition\runtime\events::arm(current_record,
        ["apparition_stop_position_shortcuts"]);

    receipt = spawnstruct();
    receipt.returned = false;
    actor thread observe_worker_return(stale_record, receipt);
    deadline = getTime() + 1000;
    while (!receipt.returned && getTime() < deadline)
        wait 0.05;
    tests\support\checks::expect(receipt.returned,
        "The real stale worker returns before the bounded observation deadline");
    tests\support\checks::expect(actor.apparition_position_shortcuts == current_record
        && !isDefined(ticket.event),
        "A stale worker exits before clearing or notifying the current generation");
    tests\support\checks::expect(actor.apparition_saved_position == saved_position
        && actor.apparition_teleport_gun == gun_record,
        "A stale worker leaves shared saved position and independent gun intent unchanged");
    scripts\apparition\runtime\events::cancel(ticket);
    scripts\apparition\features\position_shortcuts::release(actor, current_record);
    stale_record notify("apparition_stop_position_shortcuts");
}

observe_worker_return(record, receipt)
{
    self scripts\apparition\features\position_shortcuts::run(record);
    receipt.returned = true;
}
