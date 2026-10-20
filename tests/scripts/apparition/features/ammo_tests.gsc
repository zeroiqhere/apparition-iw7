// Mode validation is separate from the native weapon-refill integration cases

run()
{
    supported_modes_are_accepted();
    unknown_and_undefined_modes_are_rejected();
    bulk_setter_rejects_invalid_rosters_before_side_effects();
    lobby_display_reports_uniform_and_mixed_modes();
    each_refresh_event_is_captured_immediately_after_parent_start();
    weapon_changes_and_respawns_return_without_ending_the_waiter();
    cancelled_parent_removes_its_refresh_children();
    refresh_capture_keeps_the_first_event();
}

supported_modes_are_accepted()
{
    tests\support\checks::expect(scripts\apparition\features\ammo::valid_mode("Continuous"), "Continuous refill mode is accepted");
    tests\support\checks::expect(scripts\apparition\features\ammo::valid_mode("Reload"), "Reserve-only refill mode is accepted");
    tests\support\checks::expect(scripts\apparition\features\ammo::valid_mode("Disable"), "Stopping refills is accepted");
}

unknown_and_undefined_modes_are_rejected()
{
    tests\support\checks::expect(!scripts\apparition\features\ammo::valid_mode("unknown"), "Unknown mode is rejected");
    tests\support\checks::expect(!scripts\apparition\features\ammo::valid_mode(undefined), "Undefined mode is rejected");
    tests\support\checks::expect(!scripts\apparition\features\ammo::valid_mode(""), "Empty mode is rejected");
    tests\support\checks::expect(!scripts\apparition\features\ammo::valid_mode(1), "A numeric value cannot select a named ammo mode");
    tests\support\checks::expect(!scripts\apparition\features\ammo::valid_mode([]), "An array cannot select a named ammo mode");
}

bulk_setter_rejects_invalid_rosters_before_side_effects()
{
    foreach (mode in scripts\apparition\features\ammo::modes())
    {
        tests\support\checks::expect(!scripts\apparition\features\ammo::set_mode(undefined, mode),
            "An undefined roster cannot configure a valid ammo mode");
        tests\support\checks::expect(!scripts\apparition\features\ammo::set_mode([], mode),
            "An empty roster cannot configure a valid ammo mode");
        tests\support\checks::expect(!scripts\apparition\features\ammo::set_mode("invalid", mode),
            "A non-array selection cannot configure a valid ammo mode");
        actor = spawnstruct();
        tests\support\checks::expect(!scripts\apparition\features\ammo::set_mode([actor], mode),
            "A roster containing a non-player cannot configure a valid ammo mode");
        tests\support\checks::expect(!isDefined(actor.apparition_ammo_mode),
            "Rejected roster validation leaves player settings untouched");
    }

    actor = spawnstruct();
    actor.apparition_ammo_mode = "Reload";
    tests\support\checks::expect(!scripts\apparition\features\ammo::set_mode([actor], undefined)
        && actor.apparition_ammo_mode == "Reload", "An absent mode preserves the current configuration");
    foreach (mode in ["unknown", "", 1])
    {
        tests\support\checks::expect(!scripts\apparition\features\ammo::set_mode([actor], mode),
            "An invalid mode is rejected before roster effects");
        tests\support\checks::expect(actor.apparition_ammo_mode == "Reload",
            "An invalid mode preserves the current configuration");
    }
}

lobby_display_reports_uniform_and_mixed_modes()
{
    first = spawnstruct();
    second = spawnstruct();
    tests\support\checks::expect(scripts\apparition\features\ammo::lobby_mode(undefined) == "Unavailable", "An unavailable roster has no aggregate mode");
    tests\support\checks::expect(scripts\apparition\features\ammo::lobby_mode([]) == "Unavailable", "An empty roster has no aggregate mode");
    tests\support\checks::expect(scripts\apparition\features\ammo::lobby_mode(spawnstruct()) == "Unavailable", "A non-array roster has no aggregate mode");
    tests\support\checks::expect(scripts\apparition\features\ammo::lobby_mode([first, second]) == "Disable", "Unconfigured players display Disable");
    first.apparition_ammo_mode = "Reload";
    tests\support\checks::expect(scripts\apparition\features\ammo::lobby_mode([first, second]) == "Mixed", "Different player modes display Mixed");
    second.apparition_ammo_mode = "Reload";
    tests\support\checks::expect(scripts\apparition\features\ammo::lobby_mode([first, second]) == "Reload", "A uniform roster displays its actual mode");
}

weapon_changes_and_respawns_return_without_ending_the_waiter()
{
    actor = spawnstruct();
    actor.observed_refreshes = [];
    actor thread record_refreshes(3);
    wait 0.05;
    actor notify("weapon_fired");
    wait 0.05;
    actor notify("weapon_change");
    wait 0.05;
    actor notify("death");
    wait 0.05;
    actor notify("spawned_player");
    wait 0.05;
    tests\support\checks::expect(actor.observed_refreshes.size == 3, "Fire, weapon change and respawn all return to the same waiter");
    if (actor.observed_refreshes.size == 3)
    {
        tests\support\checks::expect(actor.observed_refreshes[0] == "weapon_fired", "The native fire event returns to refresh ammunition");
        tests\support\checks::expect(actor.observed_refreshes[1] == "weapon_change", "The weapon-change event is returned");
        tests\support\checks::expect(actor.observed_refreshes[2] == "spawned_player", "A death event does not kill the respawn wait");
    }
    // A failing implementation cannot leave the recording worker behind
    actor notify("test_stop_refreshes");
}

each_refresh_event_is_captured_immediately_after_parent_start()
{
    foreach (event in ["weapon_fired", "weapon_change", "spawned_player"])
    {
        actor = spawnstruct();
        actor.observed_refreshes = [];
        actor thread record_refreshes(1);
        // No setup wait hides the ordering of the parent and its child listeners
        actor notify(event);
        wait 0.05;
        tests\support\checks::expect(actor.observed_refreshes.size == 1,
            "An immediate " + event + " returns from the production refresh waiter");
        if (actor.observed_refreshes.size == 1)
            tests\support\checks::expect(actor.observed_refreshes[0] == event,
                "The immediate refresh retains the actual " + event + " event");
        // Also clean up a blocked waiter if the runtime violates this contract
        actor notify("test_stop_refreshes");
    }
}

cancelled_parent_removes_its_refresh_children()
{
    actor = spawnstruct();
    ticket = spawnstruct();
    ticket.state = "Starting";
    actor thread parent_with_refresh_child(ticket);
    // Reach the real capture path before cancellation, with a bounded failure path
    deadline = getTime() + 1000;
    while (ticket.state == "Starting" && getTime() < deadline)
        wait 0.05;
    tests\support\checks::expect(ticket.state == "Capturing" && !isDefined(ticket.event),
        "The refresh child enters its synchronous capture path before parent cancellation");
    ticket.state = "Cancelled";
    actor notify("test_stop_refresh_parent");
    wait 0.05;
    actor notify("weapon_fired");
    wait 0.05;
    tests\support\checks::expect(!isDefined(ticket.event),
        "A refresh child cannot capture an event after its parent is cancelled");
    // Late test children also see Cancelled before entering the production waiter
    actor notify("test_stop_refresh_parent");
    ticket notify("apparition_cancel_ammo_refresh");
}

parent_with_refresh_child(ticket)
{
    self endon("test_stop_refresh_parent");
    if (ticket.state != "Starting")
        return;
    self childthread capture_pending_refresh(ticket);
    self waittill("test_stop_refresh_parent");
}

capture_pending_refresh(ticket)
{
    if (ticket.state != "Starting")
        return;
    ticket.state = "Capturing";
    // No wait separates entry observation from the real synchronous capture
    self scripts\apparition\features\ammo::capture_refresh(ticket, "weapon_fired");
}

refresh_capture_keeps_the_first_event()
{
    actor = spawnstruct();
    ticket = spawnstruct();
    actor childthread scripts\apparition\features\ammo::capture_refresh(ticket, "weapon_change");
    actor childthread scripts\apparition\features\ammo::capture_refresh(ticket, "spawned_player");
    // Back-to-back notifications expose first-receipt ordering without a setup delay
    actor notify("weapon_change");
    actor notify("spawned_player");
    wait 0.05;
    tests\support\checks::expect(isDefined(ticket.event) && ticket.event == "weapon_change",
        "Later refresh notifications cannot replace the first event receipt");
    ticket notify("apparition_cancel_ammo_refresh");
}

record_refreshes(count)
{
    self endon("test_stop_refreshes");
    for (index = 0; index < count; index++)
        self.observed_refreshes[self.observed_refreshes.size] = self scripts\apparition\features\ammo::wait_for_refresh();
}
