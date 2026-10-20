// The source Options page connects each roster entry to its personal controls

roster_reason(view)
{
    if (!isDefined(view) || !isstruct(view)
        || !isDefined(view.players) || !isarray(view.players)
        || !isDefined(view.actor_reason) || !isstring(view.actor_reason))
        return "Wait for a valid player roster";
    return view.actor_reason;
}

players(view)
{
    rows = [];
    if (roster_reason(view) != "")
        return rows;

    // Actual-player admission in the captured view precedes display-name reads
    foreach (player in view.players)
    {
        player_access = captured_access(view, player);
        row = scripts\apparition\menu\model::link(identity(player, player_access), "Options", player);
        row.selection_key = player;
        reason = target_permission_reason(view, player, player_access);
        row.enabled = reason == "";
        if (!row.enabled)
            row.description = reason;
        rows[rows.size] = row;
    }
    return rows;
}

options(view)
{
    // Selection admission is shared with the selected-player title
    target = isDefined(view) && isstruct(view) ? view.target : undefined;
    native_host = false;
    if (isDefined(view) && isstruct(view))
        native_host = scripts\apparition\menu\model::truth(view.host);
    reason = selection_reason(view);

    rows = [];
    // Keep source positions stable while unsupported entries have no callbacks
    foreach (label in ["Verification", "Basic Scripts", "Teleport Menu", "Profile Management", "Weaponry",
        "Bullet Menu", "Fun Scripts", "Model Manipulation", "Aimbot Menu", "Model Attachment",
        "Malicious Options", "Send Message", "Freeze", "Kick"])
    {
        if (label == "Verification" || label == "Basic Scripts" || label == "Teleport Menu" || label == "Fun Scripts" || label == "Weaponry")
        {
            row = scripts\apparition\menu\model::link(label, label, target);
            row.enabled = reason == "";
            if (label == "Verification" && !native_host)
                row.enabled = false;
            // Permission loss stays visible before another page is opened
            if (!row.enabled)
                row.description = reason != "" ? reason : "Only the current host can manage verification";
        }
        else if (label == "Send Message")
            row = scripts\apparition\menu\player_message_row::build(view, false);
        else
            row = scripts\apparition\menu\model::unavailable(label);
        rows[rows.size] = row;
    }
    return rows;
}

selection_reason(view)
{
    if (!isDefined(view) || !isstruct(view)
        || !scripts\apparition\runtime\player_control::can_manage(view.access))
        return "Co-Host access is required to open player controls";
    reason = roster_reason(view);
    if (reason != "")
        return reason;
    if (!scripts\apparition\runtime\context::in_roster(view.players, view.owner)
        || !scripts\apparition\runtime\context::in_roster(view.players, view.target))
        return "Both players must belong to the current roster";
    target_access = captured_access(view, view.target);
    if (!isDefined(target_access))
        return "Wait for current player verification";
    return scripts\apparition\runtime\player_control::target_reason(view.access,
        view.owner == view.target, target_access == "Host");
}

title(view)
{
    // Current membership is checked before a departed actor's name can be read
    if (selection_reason(view) != "")
        return "Selected player unavailable";
    return identity(view.target, captured_access(view, view.target));
}

target_permission_reason(view, player, target_access)
{
    if (!scripts\apparition\runtime\player_control::can_manage(view.access))
        return "Co-Host access is required to open player controls";
    if (!isDefined(target_access))
        return "Wait for current player verification";
    return scripts\apparition\runtime\player_control::target_reason(view.access,
        view.owner == player, target_access == "Host");
}

captured_access(view, player)
{
    // Role badges and Co-Host admission use only the view's captured roster roles
    if (!isDefined(view.player_access) || !isarray(view.player_access))
        return undefined;

    selected_access = undefined;
    // Indexed reads reject missing entries instead of treating a sparse map as ready
    for (index = 0; index < view.player_access.size; index++)
    {
        entry = view.player_access[index];
        if (!isDefined(entry) || !isstruct(entry) || !isDefined(entry.player)
            || !isDefined(entry.access) || !isstring(entry.access)
            || !scripts\engine\utility::array_contains(scripts\apparition\runtime\access::catalog(), entry.access))
            return undefined;
        if (entry.player == player)
        {
            // One actor cannot carry conflicting role records in a single snapshot
            if (isDefined(selected_access))
                return undefined;
            selected_access = entry.access;
        }
    }
    return selected_access;
}

identity(player, access)
{
    name = scripts\apparition\player_name::clean(player.name);
    if (name == "")
        name = "Unnamed Player";
    if (!isDefined(access))
        access = "Unknown";
    return "[^2" + access + "^7]" + name;
}
