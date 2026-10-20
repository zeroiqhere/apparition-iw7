// Verification rows show the current session role and bind host-only assignments

build(view, lobby)
{
    if (isDefined(lobby) && lobby)
        return lobby_rows(view);
    return personal_rows(view);
}

personal_rows(view)
{
    rows = [];
    rows[rows.size] = scripts\apparition\menu\model::unavailable("Save Verification",
        "Verification grants last only for this session; persistence is not verified");

    target = undefined;
    if (isDefined(view) && isstruct(view))
        target = view.target;

    reason = "Only the current host can manage verification";
    if (isDefined(view) && isstruct(view) && scripts\apparition\menu\model::truth(view.host))
        reason = scripts\apparition\menu\player_rows::selection_reason(view);
    current = undefined;
    if (reason == "")
    {
        // Player labels and assignment rows share one captured role per current actor
        target_access = scripts\apparition\menu\player_rows::captured_access(view, target);
        if (target == view.owner)
            reason = "The host cannot change their own verification level";
        else if (!scripts\engine\utility::array_contains(
            scripts\apparition\runtime\access::assignable(), target_access))
            reason = "This player has a protected verification level";
        else
            current = target_access;
    }

    foreach (level_name in scripts\apparition\runtime\access::assignable())
    {
        row = scripts\apparition\menu\model::action(level_name,
            scripts\apparition\menu\actions::set_verification, target, false);
        row.kind = "toggle";
        row.access_level = level_name;
        row.checked = isDefined(current) && current == level_name;
        row.enabled = reason == "" && current != level_name;
        if (reason != "")
            row.description = reason;
        else if (current == level_name)
            row.description = "This player already has this verification level";
        else
            row.description = "Grant this verification level for the current session";
        rows[rows.size] = row;
    }
    return rows;
}

lobby_rows(view)
{
    levels = scripts\apparition\runtime\access::assignable();
    reason = lobby_reason(view);
    if (reason == "" && !valid_player_access(view))
        reason = "Wait for a complete player verification snapshot";

    rows = [];
    foreach (level_name in levels)
    {
        row = scripts\apparition\menu\model::action(level_name,
            scripts\apparition\menu\actions::set_verification_all, undefined, true);
        row.access_level = level_name;
        row.enabled = false;

        if (reason != "")
            row.description = reason;
        else if (has_different_eligible_player(view, level_name))
        {
            row.enabled = true;
            row.description = "Grant this level to eligible current players for this session";
        }
        else
            row.description = "No eligible player needs a different verification level";
        rows[rows.size] = row;
    }
    return rows;
}

lobby_reason(view)
{
    // Host denial remains visible before malformed roster details
    if (!isDefined(view) || !isstruct(view)
        || !scripts\apparition\menu\model::truth(view.host))
        return "Only the current host can open player controls";

    reason = scripts\apparition\menu\player_rows::roster_reason(view);
    if (reason != "")
        return reason;
    if (!scripts\apparition\runtime\context::in_roster(view.players, view.owner))
        return "Wait for a valid player roster";

    return "";
}

valid_player_access(view)
{
    if (!isDefined(view) || !isstruct(view)
        || !isDefined(view.players) || !isarray(view.players)
        || !isDefined(view.player_access) || !isarray(view.player_access)
        || view.player_access.size != view.players.size)
        return false;

    catalog = scripts\apparition\runtime\access::catalog();
    seen = [];
    foreach (entry in view.player_access)
    {
        if (!isDefined(entry) || !isstruct(entry)
            || !isDefined(entry.player) || !isDefined(entry.access) || !isstring(entry.access)
            || !scripts\apparition\runtime\context::in_roster(view.players, entry.player)
            || !scripts\engine\utility::array_contains(catalog, entry.access)
            || scripts\engine\utility::array_contains(seen, entry.player))
            return false;

        // Equal count plus unique current members proves the snapshot covers the roster
        seen[seen.size] = entry.player;
    }
    return true;
}

has_different_eligible_player(view, requested)
{
    assignable = scripts\apparition\runtime\access::assignable();
    foreach (entry in view.player_access)
    {
        // The current host and protected roles are never bulk-assignment targets
        if (entry.player != view.owner
            && scripts\engine\utility::array_contains(assignable, entry.access)
            && entry.access != requested)
            return true;
    }
    return false;
}
