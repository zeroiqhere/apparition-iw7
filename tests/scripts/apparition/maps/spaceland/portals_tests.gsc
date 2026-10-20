// Native portal readiness is checked without moving an actor or writing quest flags

run()
{
    the_readiness_gate_accepts_an_initialized_normal_unlock();
    every_side_portal_must_have_been_used();
    used_side_portals_do_not_need_unused_return_destinations();
    debug_unlock_state_cannot_replace_side_portal_progress();
    missing_registration_or_map_objects_prevent_entry();
    power_cooldown_and_portal_locks_prevent_entry();
    portal_use_waits_for_native_wave_progression();
    entry_observation_distinguishes_pending_from_confirmed_and_unavailable();
    an_unused_powered_side_portal_is_ready_before_the_pap_unlock();
    an_open_side_portal_can_be_used_without_starting_another_charge();
    side_portal_power_cooldown_and_alternate_routing_are_respected();
    incomplete_side_portal_objects_and_unknown_areas_are_rejected();
    opening_observation_waits_for_native_charge_and_stops_on_changed_state();
    side_travel_confirmation_requires_actor_completion_and_native_use();
}

the_readiness_gate_accepts_an_initialized_normal_unlock()
{
    state = tests\fixtures\spaceland::portals();
    tests\support\checks::expect(scripts\apparition\maps\spaceland\portals::entry_reason(state) == "", "The readiness gate accepts a fully initialized normal portal unlock");
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\portals::used(state), "Entry readiness does not fake portal use");
    tests\support\checks::expect(state._id_13F1B["ufo"] == 1, "Readiness leaves the quest index unchanged");
}

every_side_portal_must_have_been_used()
{
    foreach (area in ["arcade", "moon", "europa", "mars"])
    {
        state = tests\fixtures\spaceland::portals();
        state.fast_travel_spots[area].used_once = undefined;
        tests\support\checks::expect(scripts\apparition\maps\spaceland\portals::entry_reason(state) != "", "A missing side-portal use blocks hidden-room entry");
    }
    state = tests\fixtures\spaceland::portals();
    state.fast_travel_spots["mars"] = undefined;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\portals::entry_reason(state) != "", "An absent side-portal struct is not a completed unlock");
}

used_side_portals_do_not_need_unused_return_destinations()
{
    state = tests\fixtures\spaceland::portals();
    state.fast_travel_spots["arcade"].end_positions = [];
    tests\support\checks::expect(scripts\apparition\maps\spaceland\portals::entry_reason(state) == "", "Only the main-street return destination is consumed by the native exit");
}

debug_unlock_state_cannot_replace_side_portal_progress()
{
    state = tests\fixtures\spaceland::portals();
    state.fast_travel_spots["arcade"].used_once = 0;
    state._id_8E61 = 1;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\portals::entry_reason(state) != "", "The room-open field alone cannot prove the four normal uses");
}

missing_registration_or_map_objects_prevent_entry()
{
    state = tests\fixtures\spaceland::portals();
    state.interactions["fast_travel"].activation_func = scripts\cp\maps\cp_zmb\cp_zmb_dj::init_fetch_quest;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\portals::entry_reason(state) != "", "A changed native activation function is rejected");
    state = tests\fixtures\spaceland::portals();
    state.fast_travel_spots["main_street"]._id_D680 = undefined;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\portals::entry_reason(state) != "", "A missing native trigger means initialization is incomplete");
    state = tests\fixtures\spaceland::portals();
    state.fast_travel_spots["main_street"].end_positions = [];
    tests\support\checks::expect(scripts\apparition\maps\spaceland\portals::entry_reason(state) != "", "Entry requires native return positions for the later automatic exit");
    state = tests\fixtures\spaceland::portals();
    state.flag["disable_portals"] = undefined;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\portals::entry_reason(state) != "", "The early init-done flag cannot replace later flag initialization");
    state = tests\fixtures\spaceland::portals();
    state.flag["pap_portal_used"] = undefined;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\portals::entry_reason(state) != "", "The native use flag must exist before entry is offered");
    state = tests\fixtures\spaceland::portals();
    state.flag["fast_travel_init_done"] = undefined;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\portals::entry_reason(state) != "", "Missing native initialization cannot be inferred from other fields");
}

power_cooldown_and_portal_locks_prevent_entry()
{
    state = tests\fixtures\spaceland::portals();
    state.flag["disable_portals"] = 1;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\portals::entry_reason(state) != "", "The native portal lock prevents entry");
    state = tests\fixtures\spaceland::portals();
    state._id_8E61 = 0;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\portals::entry_reason(state) != "", "A native room cooldown cannot be bypassed");
    state = tests\fixtures\spaceland::portals();
    state.fast_travel_spots["main_street"].powered_on = 0;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\portals::entry_reason(state) != "", "Power loss prevents a stale portal-ready field from advertising entry");
    state = tests\fixtures\spaceland::portals();
    state.fast_travel_spots["main_street"].portal_can_be_started = 0;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\portals::entry_reason(state) != "", "The registered callback's portal gate must be ready");
}

portal_use_waits_for_native_wave_progression()
{
    state = tests\fixtures\spaceland::portals();
    state.flag["pap_portal_used"] = 1;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\portals::used(state), "The actual native use flag is visible while step 1 remains active");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\portals::entry_reason(state) == "Portal used; wait for the next wave", "The UI explains the native wave-start wait instead of offering another entry");
    tests\support\checks::expect(state._id_13F1B["ufo"] == 1, "Reading a used portal never advances the stage itself");
    state._id_13F1B["ufo"] = 2;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\portals::entry_reason(state) != "", "An already advanced stage cannot re-run its portal action");
}

entry_observation_distinguishes_pending_from_confirmed_and_unavailable()
{
    state = tests\fixtures\spaceland::portals();
    player = spawnstruct();
    tests\support\checks::expect(scripts\apparition\maps\spaceland\portals::entry_outcome(state, player, true, false) == "", "An authorized unconfirmed trip remains under observation");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\portals::entry_outcome(state, player, true, true) == "Pending", "Observation expiry does not claim the native worker failed");
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\portals::used(state), "A pending observation does not mark native portal use");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\portals::entry_outcome(state, player, false, false) == "Unavailable", "Lost authorization stops the menu observer");
    state.flag["pap_portal_used"] = 1;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\portals::entry_outcome(state, player, true, false) == "", "Another actor's global portal use cannot confirm this actor's entry");
    player.is_in_pap = 1;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\portals::entry_outcome(state, player, true, true) == "Entered", "The actor's native room state and global use flag confirm entry even at the deadline");
}

an_unused_powered_side_portal_is_ready_before_the_pap_unlock()
{
    state = tests\fixtures\spaceland::portals();
    state.fast_travel_spots["arcade"].used_once = 0;
    state._id_8E61 = 0;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\portals::side_reason(state, "arcade") == "", "A powered unused side portal is accepted before the hidden room unlocks");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\portals::entry_reason(state) != "", "A ready side visit does not unlock Pack-a-Punch early");
    tests\support\checks::expect(!scripts\apparition\maps\spaceland\portals::side_used(state, "arcade"), "Readiness does not mark a side portal as used");
    state.fast_travel_spots["arcade"].used_once = 1;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\portals::side_reason(state, "arcade") != "", "A completed side visit cannot be repeated by the progress action");
}

an_open_side_portal_can_be_used_without_starting_another_charge()
{
    state = tests\fixtures\spaceland::portals();
    ticket = tests\fixtures\spaceland::armed_ticket();
    spot = state.fast_travel_spots["moon"];
    spot.used_once = 0;
    spot.portal_is_open = 1;
    spot.portal_can_be_started = 0;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\portals::side_reason(state, "moon") == "", "An already open unused portal is accepted without another charge");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\portals::opening_outcome(state, "moon", ticket, true, false) == "Open", "The observer recognizes the source open flag");
    spot.powered_on = 0;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\portals::side_reason(state, "moon") == "", "A native open window remains usable after local power turns off");
}

side_portal_power_cooldown_and_alternate_routing_are_respected()
{
    state = tests\fixtures\spaceland::portals();
    spot = state.fast_travel_spots["mars"];
    spot.used_once = 0;
    spot.powered_on = 0;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\portals::side_reason(state, "mars") != "", "A side visit cannot bypass local power");
    spot.powered_on = 1;
    spot.portal_can_be_started = 0;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\portals::side_reason(state, "mars") != "", "A closed side portal respects its native cooldown");
    spot.portal_can_be_started = 1;
    state.wor_portal_change_time = 1;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\portals::side_reason(state, "mars") != "", "Alternate portal routing cannot masquerade as a normal side visit");
}

incomplete_side_portal_objects_and_unknown_areas_are_rejected()
{
    state = tests\fixtures\spaceland::portals();
    spot = state.fast_travel_spots["europa"];
    spot.used_once = 0;
    spot.light = undefined;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\portals::side_reason(state, "europa") != "", "Native charge cleanup requires the portal light");
    spot.light = spawnstruct();
    spot._id_D680 = undefined;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\portals::side_reason(state, "europa") != "", "A side visit requires its initialized trigger");
    spot._id_D680 = spawnstruct();
    spot._id_D682.angles = undefined;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\portals::side_reason(state, "europa") != "", "A missing native model angle cannot enter the charge callback");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\portals::side_reason(state, "main_street") != "", "Side controls cannot bypass the separate hidden-room unlock");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\portals::side_reason(state, "unknown") != "", "Only the four known side portal keys are accepted");
}

opening_observation_waits_for_native_charge_and_stops_on_changed_state()
{
    state = tests\fixtures\spaceland::portals();
    ticket = tests\fixtures\spaceland::armed_ticket();
    spot = state.fast_travel_spots["arcade"];
    spot.used_once = 0;
    spot.portal_can_be_started = 0;
    spot.portal_charging = 1;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\portals::opening_outcome(state, "arcade", ticket, true, false) == "", "The observer does not reject the charge that its own action started");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\portals::opening_outcome(state, "arcade", ticket, true, true) == "Pending", "A charge observation timeout does not claim native failure");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\portals::opening_outcome(state, "arcade", ticket, false, false) == "Unavailable", "Lost actor readiness stops before any trigger is sent");
    spot.portal_charging = 0;
    spot.portal_is_open = 1;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\portals::opening_outcome(state, "arcade", ticket, true, false) == "Open", "A fresh native opening can proceed to final trigger admission");
    ticket.event = "trigger";
    ticket.state = "Received";
    tests\support\checks::expect(scripts\apparition\maps\spaceland\portals::opening_outcome(state, "arcade", ticket, true, false) == "Interrupted", "Input captured before the host's trigger prevents another menu trigger");
    ticket.state = "Cancelled";
    tests\support\checks::expect(scripts\apparition\maps\spaceland\portals::opening_outcome(state, "arcade", ticket, true, false) == "Unavailable", "A canceled observer cannot authorize native input even with a retained old event");
    ticket.event = undefined;
    ticket.state = "Armed";
    spot.powered_on = 0;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\portals::opening_outcome(state, "arcade", ticket, true, false) == "Open", "The native open window remains authoritative after power loss");
    spot.portal_is_open = 0;
    spot.portal_charging = 1;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\portals::opening_outcome(state, "arcade", ticket, true, false) == "", "Power loss does not cancel an admitted native charge");
    spot.used_once = 1;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\portals::opening_outcome(state, "arcade", ticket, true, false) == "Visited", "A teammate's completed visit stops another trip during opening");
}

side_travel_confirmation_requires_actor_completion_and_native_use()
{
    state = tests\fixtures\spaceland::portals();
    state.fast_travel_spots["mars"].used_once = 0;
    ticket = tests\fixtures\spaceland::armed_ticket();
    tests\support\checks::expect(scripts\apparition\maps\spaceland\portals::travel_outcome(state, "mars", ticket, true, false) == "", "An unconfirmed native side trip remains under observation");
    ticket.event = "fast_travel_complete";
    tests\support\checks::expect(scripts\apparition\maps\spaceland\portals::travel_outcome(state, "mars", ticket, true, false) == "", "An actor completion event alone cannot fake this portal's use");
    state.fast_travel_spots["mars"].used_once = 1;
    ticket.event = undefined;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\portals::travel_outcome(state, "mars", ticket, true, false) == "", "A teammate's use alone does not confirm the host's transfer");
    tests\support\checks::expect(scripts\apparition\maps\spaceland\portals::travel_outcome(state, "mars", ticket, true, true) == "Pending", "An expired transfer observation remains pending");
    ticket.event = "fast_travel_complete";
    tests\support\checks::expect(scripts\apparition\maps\spaceland\portals::travel_outcome(state, "mars", ticket, true, true) == "Visited", "Native use and actor completion confirm the side trip at the deadline");
    state.fast_travel_spots["mars"].used_once = 0;
    tests\support\checks::expect(scripts\apparition\maps\spaceland\portals::travel_outcome(state, "mars", ticket, false, false) == "Unavailable", "Lost authorization ends the menu observer without changing native progress");
}
