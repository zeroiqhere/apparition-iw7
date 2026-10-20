// Server settings keep the source positions and use current native state only

build(view)
{
    labels = ["Super Jump", "Low Gravity", "Super Speed", "Timescale", "Set Round",
        "Anti-Join", "Anti-Quit", "Auto-Revive", "Auto-Respawn", "Pause World",
        "Newsbar", "Doheart Options", "Lobby Timer Options", "Mystery Box Options",
        "Open All Doors & Debris", "Zombie Barriers", "Spawn Bot", "Craftables",
        "Zombie Traps", "Change Map", "Restart Game", "End Game"];
    rows = [];

    for (index = 0; index < labels.size; index++)
    {
        label = labels[index];
        if (index == 1)
            row = server_movement_row(view, "low_gravity", label);
        else if (index == 2)
            row = server_movement_row(view, "super_speed", label);
        else if (index == 3)
            row = timescale_row(view);
        else if (index == 7)
            row = auto_revive_row(view);
        else if (index == 10)
            row = newsbar_row(view);
        else if (index == 11)
        {
            row = scripts\apparition\menu\model::link(label, "Doheart Options", view.owner);
            row.callback = scripts\apparition\menu\actions::open_doheart;
        }
        else if (index == 12)
            row = scripts\apparition\menu\model::link(label, "Lobby Timer Options", view.owner);
        else if (index == 21)
            row = end_game_row(view);
        else
            row = unavailable_row(label);
        rows[rows.size] = row;
    }

    return rows;
}

timer_rows(view)
{
    toggle = scripts\apparition\menu\model::action("Lobby Timer",
        scripts\apparition\menu\actions::toggle_lobby_timer, undefined, true);
    toggle.kind = "toggle";
    toggle.checked = false;
    slider = scripts\apparition\menu\model::action("Set Lobby Timer",
        scripts\apparition\menu\actions::configure_lobby_timer, undefined, true);
    slider.kind = "slider";
    slider.values = scripts\apparition\features\server\lobby_timer::values();
    // The source always starts this preview at ten, independently of stored duration
    slider.initial_index = 9;
    slider.active_value = "Unknown";
    rows = [toggle, slider];
    foreach (row in rows)
    {
        row.enabled = false;
        row.description = "Co-Host access is required to change server settings";
    }
    if (!isDefined(view) || !isstruct(view) || !scripts\apparition\runtime\player_control::can_manage(view.access))
        return rows;
    foreach (row in rows)
        row.description = "Wait for lobby timer readiness";
    snapshot = view.lobby_timer;
    if (!isDefined(snapshot) || !isstruct(snapshot)
        || !isDefined(snapshot.reason) || !isstring(snapshot.reason))
        return rows;
    if (snapshot.reason != "")
    {
        foreach (row in rows)
            row.description = snapshot.reason;
        return rows;
    }
    if (!isDefined(snapshot.configured) || !isnumber(snapshot.configured)
        || !(snapshot.configured == 0 || snapshot.configured == 1)
        || !isDefined(snapshot.phase) || !isstring(snapshot.phase)
        || !isDefined(snapshot.error) || !isstring(snapshot.error)
        || !isDefined(snapshot.native_reason) || !isstring(snapshot.native_reason)
        || !isDefined(snapshot.time_reason) || !isstring(snapshot.time_reason))
        return rows;
    if (isDefined(snapshot.minutes))
    {
        if (!scripts\apparition\features\server\lobby_timer::valid_minutes(snapshot.minutes))
            return rows;
        slider.active_value = snapshot.minutes;
    }
    else if (snapshot.time_reason == "")
        return rows;

    // Typed invalid-duration state can still be cleared or repaired with a new valid choice
    toggle.checked = snapshot.configured == 1;
    toggle.enabled = toggle.checked || (snapshot.time_reason == "" && snapshot.native_reason == ""
        && isDefined(scripts\apparition\features\server\lobby_timer::deadline(snapshot.clock, snapshot.minutes)));
    slider.choice_reasons = [];
    slider.enabled = false;
    foreach (minutes in slider.values)
    {
        // A shorter reset may still fit when the current duration cannot
        reason = "";
        if (toggle.checked)
        {
            reason = snapshot.native_reason;
            if (reason == "" && !isDefined(scripts\apparition\features\server\lobby_timer::deadline(snapshot.clock, minutes)))
                reason = "The game clock cannot represent this countdown";
        }
        slider.choice_reasons[minutes] = reason;
        if (reason == "")
            slider.enabled = true;
    }
    status = "Phase: " + snapshot.phase + "; Duration: " + slider.active_value;
    if (snapshot.error != "")
        status += "; " + snapshot.error;
    if (snapshot.native_reason != "")
        status += "; " + snapshot.native_reason;
    if (snapshot.time_reason != "")
        status += "; " + snapshot.time_reason;
    toggle.description = status + (toggle.checked ? "; Use turns it off"
        : "; Use starts the countdown; expiry ends the private lobby");
    slider.description = status + (toggle.checked
        ? "; Use restarts the full countdown, even for the same duration"
        : "; Use stores preview minutes without starting a countdown");
    return rows;
}

newsbar_row(view)
{
    row = scripts\apparition\menu\model::action("Newsbar",
        scripts\apparition\menu\actions::toggle_newsbar, undefined, true);
    row.kind = "toggle";
    row.checked = false;
    row.enabled = false;
    row.description = "Co-Host access is required to change server settings";

    // Role denial takes precedence over captured setting or resource data
    if (!isDefined(view) || !isstruct(view) || !scripts\apparition\runtime\player_control::can_manage(view.access))
        return row;
    row.description = "Wait for lobby Newsbar state";
    snapshot = view.newsbar;
    if (!isDefined(snapshot) || !isstruct(snapshot)
        || !isDefined(snapshot.reason) || !isstring(snapshot.reason)
        || !isDefined(snapshot.configured) || !isnumber(snapshot.configured)
        || !(snapshot.configured == 0 || snapshot.configured == 1))
        return row;

    // A typed denial may still explain an already configured setting
    row.checked = snapshot.configured == 1;
    if (snapshot.reason != "")
    {
        row.description = snapshot.reason;
        return row;
    }
    row.enabled = true;
    row.description = "Global Newsbar for all players; "
        + (row.checked ? "Configured on; Use turns it off" : "Configured off; Use turns it on");
    return row;
}

server_movement_row(view, id, label)
{
    row = scripts\apparition\menu\model::action(label,
        scripts\apparition\menu\actions::toggle_server_movement, undefined, true);
    row.kind = "toggle";
    row.setting = id;
    row.checked = false;
    row.enabled = false;
    row.description = "Co-Host access is required to change server settings";

    // Roles below Co-Host stop before the captured native values are read
    if (!isDefined(view) || !isstruct(view) || !scripts\apparition\runtime\player_control::can_manage(view.access))
        return row;

    row.description = "Wait for native server movement state";
    if (!isDefined(view.server_movements) || !isarray(view.server_movements))
        return row;
    snapshot = view.server_movements[id];
    if (!isDefined(snapshot) || !isstruct(snapshot)
        || !isDefined(snapshot.id) || !isstring(snapshot.id) || snapshot.id != id
        || !isDefined(snapshot.reason) || !isstring(snapshot.reason))
        return row;

    // Keep the exact live target visible even when the startup baseline is unavailable
    if (isDefined(snapshot.current) && isnumber(snapshot.current)
        && isDefined(snapshot.target) && isnumber(snapshot.target)
        && isDefined(snapshot.checked) && isnumber(snapshot.checked)
        && (snapshot.checked == 0 || snapshot.checked == 1))
        row.checked = snapshot.checked == 1;

    if (snapshot.reason != "")
    {
        row.description = snapshot.reason;
        return row;
    }
    if (!isDefined(snapshot.current) || !isnumber(snapshot.current)
        || !isDefined(snapshot.target) || !isnumber(snapshot.target)
        || !isDefined(snapshot.checked) || !isnumber(snapshot.checked)
        || !(snapshot.checked == 0 || snapshot.checked == 1)
        || !isDefined(snapshot.next_value) || !isnumber(snapshot.next_value)
        || !isDefined(snapshot.enabled) || !isnumber(snapshot.enabled)
        || !(snapshot.enabled == 0 || snapshot.enabled == 1))
        return row;
    if (snapshot.enabled != 1)
        return row;

    row.enabled = true;
    row.description = "Global setting for all players; Current: " + snapshot.current
        + "; Use sets " + snapshot.next_value
        + "; toggles between the preset and captured startup value";
    return row;
}

timescale_row(view)
{
    row = scripts\apparition\menu\model::action("Timescale",
        scripts\apparition\menu\actions::set_server_timescale, undefined, true);
    row.kind = "slider";
    row.values = scripts\apparition\features\server\timescale::values();
    row.initial_index = 1;
    row.active_value = "Unknown";
    row.enabled = false;
    row.description = "Co-Host access is required to change server settings";

    // Role denial is settled before the captured native dvar is read
    if (!isDefined(view) || !isstruct(view) || !scripts\apparition\runtime\player_control::can_manage(view.access))
        return row;

    row.description = "Wait for native server timescale";
    snapshot = view.server_timescale;
    if (!isDefined(snapshot) || !isstruct(snapshot)
        || !isDefined(snapshot.reason) || !isstring(snapshot.reason))
        return row;
    if (snapshot.reason != "")
    {
        row.description = snapshot.reason;
        return row;
    }
    if (!isDefined(snapshot.current) || !isnumber(snapshot.current)
        || !(snapshot.current >= 0.001 && snapshot.current <= 1000.0))
        return row;

    // A live value outside the preview catalog stays visible and is never rounded
    row.active_value = snapshot.current;
    foreach (index, choice in row.values)
    {
        if (choice == snapshot.current)
        {
            row.initial_index = index;
            break;
        }
    }
    row.enabled = true;
    row.description = "Current: " + snapshot.current
        + "x; game speed for all players; 1x is normal; Use applies preview";
    return row;
}

auto_revive_row(view)
{
    row = scripts\apparition\menu\model::action("Auto-Revive",
        scripts\apparition\menu\actions::toggle_auto_revive, undefined, true);
    row.kind = "toggle";
    row.checked = false;
    row.enabled = false;
    row.description = "Co-Host access is required to change server settings";

    // Role denial is settled before the captured global setting is read
    if (!isDefined(view) || !isstruct(view) || !scripts\apparition\runtime\player_control::can_manage(view.access))
        return row;

    row.description = "Wait for native auto-revive state";
    snapshot = view.auto_revive;
    if (!isDefined(snapshot) || !isstruct(snapshot)
        || !isDefined(snapshot.reason) || !isstring(snapshot.reason))
        return row;

    // A provider denial can still carry a checked setting that remains visible
    if (isDefined(snapshot.enabled) && isnumber(snapshot.enabled)
        && (snapshot.enabled == 0 || snapshot.enabled == 1))
        row.checked = snapshot.enabled == 1;
    if (snapshot.reason != "")
    {
        row.description = snapshot.reason;
        return row;
    }
    if (!isDefined(snapshot.enabled) || !isnumber(snapshot.enabled)
        || !(snapshot.enabled == 0 || snapshot.enabled == 1)
        || !isDefined(snapshot.native_reason) || !isstring(snapshot.native_reason))
        return row;

    // This records a global setting, not confirmation that anyone was revived
    row.enabled = true;
    row.description = "Global setting: supported revives for current and future players, including the host; "
        + (row.checked ? "Configured on; Use turns it off" : "Configured off; Use turns it on");
    if (snapshot.native_reason != "")
        row.description += "; Native revive: " + snapshot.native_reason;
    return row;
}

end_game_row(view)
{
    row = scripts\apparition\menu\model::action("End Game",
        scripts\apparition\menu\actions::request_end_game, undefined, true);
    row.enabled = false;
    row.description = "Co-Host access is required to change server settings";

    // Roles below Co-Host stop before the native terminal readiness reason is read
    if (!isDefined(view) || !isstruct(view) || !scripts\apparition\runtime\player_control::can_manage(view.access))
        return row;
    row.description = "Wait for native game-over readiness";
    if (!isDefined(view.server_end_reason) || !isstring(view.server_end_reason))
        return row;
    if (view.server_end_reason != "")
    {
        row.description = view.server_end_reason;
        return row;
    }

    // Selection requests the native flow and never claims that it has finished
    row.enabled = true;
    row.description = "Request the normal game-over sequence for all players in this private game";
    return row;
}

unavailable_row(label)
{
    description = "This source server control has no verified IW7 binding yet";
    if (label == "Open All Doors & Debris")
        description = "Full native door, debris and quest-door coverage is unresolved";
    else if (label == "Pause World")
        description = "Native global pause and resume behavior is unresolved";
    return scripts\apparition\menu\model::unavailable(label, description);
}
