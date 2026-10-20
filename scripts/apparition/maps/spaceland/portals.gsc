// Native portal state controls readiness and progress without a menu-owned unlock

areas()
{
    return ["arcade", "moon", "europa", "mars"];
}

used(state)
{
    return isDefined(state.flag) && isDefined(state.flag["pap_portal_used"]) && state.flag["pap_portal_used"];
}

spot_valid(spot, area)
{
    if (!isDefined(spot) || !isDefined(spot.script_area) || spot.script_area != area
        || !isDefined(spot.script_noteworthy) || spot.script_noteworthy != "fast_travel")
        return false;
    if (area != "main_street")
        return true;
    if (!isDefined(spot.origin) || !isDefined(spot._id_D680) || !isDefined(spot._id_D682)
        || !isDefined(spot.end_positions) || spot.end_positions.size == 0)
        return false;
    // The native automatic exit needs a complete destination even after entry succeeds
    foreach (destination in spot.end_positions)
    {
        if (!isDefined(destination) || !isDefined(destination.origin) || !isDefined(destination.angles))
            return false;
    }
    return true;
}

context_reason(state)
{
    if (scripts\apparition\maps\spaceland\quest::current_step(state) != 1)
        return "The UFO quest is not on its portal stage";
    if (!isDefined(state.flag) || !isDefined(state.flag["fast_travel_init_done"]) || !state.flag["fast_travel_init_done"]
        || !isDefined(state.flag["disable_portals"]) || !isDefined(state.flag["pap_portal_used"]))
        return "Native portal initialization is incomplete";
    if (used(state))
        return "Portal used; wait for the next wave";
    if (state.flag["disable_portals"])
        return "The game has locked the portals";
    if (!isDefined(state.interactions) || !isDefined(state.interactions["fast_travel"])
        || !isDefined(state.interactions["fast_travel"].enabled) || !state.interactions["fast_travel"].enabled
        || !isDefined(state.interactions["fast_travel"].activation_func)
        || state.interactions["fast_travel"].activation_func != scripts\cp\zombies\zombie_fast_travel::run_fast_travel_logic)
        return "The native fast-travel callback is unavailable";
    if (!isDefined(state.end_portal_name) || state.end_portal_name != "main_street"
        || !isDefined(state.fast_travel_spots) || state.fast_travel_spots.size != 5)
        return "The five native Spaceland portal spots are incomplete";
    if (!spot_valid(state.fast_travel_spots[state.end_portal_name], state.end_portal_name))
        return "The native main-street portal is incomplete";
    return "";
}

entry_reason(state)
{
    reason = context_reason(state);
    if (reason != "")
        return reason;
    // A debug unlock field cannot replace the four normal side-portal uses
    foreach (area in areas())
    {
        spot = state.fast_travel_spots[area];
        if (!spot_valid(spot, area) || !isDefined(spot.used_once) || !spot.used_once)
            return "Use all four powered side portals first";
    }
    spot = state.fast_travel_spots[state.end_portal_name];
    if (!isDefined(spot.powered_on) || !spot.powered_on
        || !isDefined(spot.portal_can_be_started) || !spot.portal_can_be_started)
        return "The main-street portal is not powered and ready";
    if (!isDefined(state._id_8E61) || !state._id_8E61)
        return "Wait for the native Pack-a-Punch unlock or cooldown";
    return "";
}

entry_outcome(state, player, authorized, expired)
{
    if (isDefined(player) && isDefined(player.is_in_pap) && player.is_in_pap && used(state))
        return "Entered";
    if (!authorized)
        return "Unavailable";
    // An expired observer cannot establish that the separately owned native trip failed
    return expired ? "Pending" : "";
}

side_used(state, area)
{
    return isDefined(state.fast_travel_spots) && isDefined(state.fast_travel_spots[area])
        && isDefined(state.fast_travel_spots[area].used_once) && state.fast_travel_spots[area].used_once;
}

side_base_reason(state, area)
{
    if (!isDefined(area) || !scripts\engine\utility::array_contains(areas(), area))
        return "Unknown side portal";
    reason = context_reason(state);
    if (reason != "")
        return reason;
    if (isDefined(state.wor_portal_change_time) && state.wor_portal_change_time)
        return "The game is using an alternate portal route";
    spot = state.fast_travel_spots[area];
    if (!spot_valid(spot, area) || !isDefined(spot.origin) || !isDefined(spot._id_D680)
        || !isDefined(spot._id_D682) || !isDefined(spot._id_D682.angles) || !isDefined(spot.light)
        || !isDefined(spot.portal_is_open) || !isDefined(spot.portal_charging)
        || !isDefined(spot.portal_can_be_started) || !isDefined(spot.powered_on))
        return "The native side portal is incomplete";
    if (isDefined(spot.disabled) && spot.disabled)
        return "The game has disabled this side portal";
    return "";
}

side_reason(state, area)
{
    reason = side_base_reason(state, area);
    if (reason != "")
        return reason;
    if (side_used(state, area))
        return "This side portal has already been visited";
    spot = state.fast_travel_spots[area];
    // Opening clears the start flag, so an open portal must be checked first
    if (spot.portal_is_open)
        return "";
    // Power is required to start a charge, while stock open windows survive power loss
    if (!spot.powered_on)
        return "Turn on this portal's power first";
    if (spot.portal_charging)
        return "The side portal is charging";
    if (!spot.portal_can_be_started)
        return "Wait for this side portal's cooldown";
    return "";
}

opening_outcome(state, area, ticket, authorized, expired)
{
    // A teammate may finish the shared progress while the host waits for an opening
    if (side_used(state, area))
        return "Visited";
    if (!authorized || side_base_reason(state, area) != "")
        return "Unavailable";
    if (ticket.state == "Received")
        return "Interrupted";
    if (ticket.state != "Armed")
        return "Unavailable";
    if (state.fast_travel_spots[area].portal_is_open)
        return "Open";
    return expired ? "Pending" : "";
}

travel_outcome(state, area, ticket, authorized, expired)
{
    // A shared use flag and this actor's completion event are separate evidence
    if (side_used(state, area) && isDefined(ticket.event) && ticket.event == "fast_travel_complete")
        return "Visited";
    if (!authorized)
        return "Unavailable";
    // The native travel thread keeps ownership of cleanup after the observer times out
    return expired ? "Pending" : "";
}
