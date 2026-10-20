// Host controls retain the original unknown-map order and current native host scope

build(view)
{
    labels = ["Disconnect", "Player Info", "Music Player", "Custom Map Spawns",
        "Player Score & Overhead Name Color", "Field Of View Scale", "Field Of View",
        "Show Origin", "Anti-End Game", "Force Host", "Entity Count Display",
        "Tris Lines", "DevGui Info", "Disable Fog", "SV Cheats", "Developer Mode"];
    rows = [];
    foreach (label in labels)
    {
        if (label == "Field Of View Scale")
            row = fov_row(view);
        else if (label == "Show Origin")
            row = origin_row(view);
        else if (label == "SV Cheats")
            row = cheats_row(view);
        else
            row = scripts\apparition\menu\model::unavailable(label,
                "This source host control has no verified IW7 binding yet");
        rows[rows.size] = row;
    }
    // The source conditionally inserts G_Spawn protection only for a known map limit
    return rows;
}

cheats_row(view)
{
    owner = isDefined(view) && isstruct(view) ? view.owner : undefined;
    row = scripts\apparition\menu\model::action("SV Cheats",
        scripts\apparition\menu\actions::toggle_server_cheats, owner, false);
    row.kind = "toggle";
    row.checked = false;
    row.enabled = false;
    row.description = "Only the current host can change SV Cheats";
    if (!isDefined(view) || !isstruct(view) || !scripts\apparition\menu\model::truth(view.host))
        return row;
    row.description = "Wait for native SV Cheats state";
    snapshot = view.server_cheats;
    if (!isDefined(owner) || !isDefined(snapshot) || !isstruct(snapshot)
        || !isDefined(snapshot.reason) || !isstring(snapshot.reason))
        return row;
    if (snapshot.reason != "")
    {
        row.description = snapshot.reason;
        return row;
    }
    if (!scripts\apparition\features\server_cheats::valid_value(snapshot.current))
        return row;
    // Only the current native reading drives the checkbox and next-action hint
    row.checked = snapshot.current == "1";
    row.enabled = true;
    row.description = row.checked ? "Server setting is ON; Use turns it OFF; native command rules still apply"
        : "Server setting is OFF; Use turns it ON; native command rules still apply";
    return row;
}

fov_row(view)
{
    owner = isDefined(view) && isstruct(view) ? view.owner : undefined;
    row = scripts\apparition\menu\model::action("Field Of View Scale",
        scripts\apparition\menu\actions::set_host_fov, owner, false);
    row.kind = "slider";
    row.range = scripts\apparition\features\fov::range();
    row.enabled = false;
    row.description = "Only the current host can change Field Of View Scale";
    if (!isDefined(view) || !isstruct(view) || !scripts\apparition\menu\model::truth(view.host))
        return row;
    row.description = "Wait for native field-of-view state";
    snapshot = view.fov;
    if (!isDefined(owner) || !isDefined(snapshot) || !isstruct(snapshot)
        || !isDefined(snapshot.reason) || !isstring(snapshot.reason))
        return row;
    if (snapshot.reason != "")
    {
        row.description = snapshot.reason;
        return row;
    }
    if (!isDefined(scripts\apparition\menu\numeric_slider::bound(snapshot.current, row.range.minimum, row.range.maximum)))
        return row;
    // A new session preview starts at the live value without replacing an existing choice
    row.range.start = snapshot.current;
    row.enabled = true;
    row.description = "Current setting: " + snapshot.current
        + "; Use applies preview; native camera modes may replace the effect";
    return row;
}

origin_row(view)
{
    owner = isDefined(view) && isstruct(view) ? view.owner : undefined;
    row = scripts\apparition\menu\model::action("Show Origin",
        scripts\apparition\menu\actions::toggle_show_origin, owner, false);
    row.kind = "toggle";
    row.checked = false;
    row.enabled = false;
    row.description = "Only the current host can use Show Origin";
    if (!isDefined(view) || !isstruct(view)
        || !scripts\apparition\menu\model::truth(view.host))
        return row;
    row.description = "Wait for native coordinate display state";
    snapshot = view.origin_display;
    if (!isDefined(snapshot) || !isstruct(snapshot)
        || !isDefined(snapshot.reason) || !isstring(snapshot.reason)
        || !isDefined(snapshot.configured) || !isnumber(snapshot.configured)
        || !(snapshot.configured == 0 || snapshot.configured == 1))
        return row;
    row.checked = snapshot.configured == 1;
    if (snapshot.reason != "")
    {
        row.description = snapshot.reason;
        return row;
    }
    row.enabled = true;
    row.description = "Live X, Y and Z coordinates; persists through death and menu closure; "
        + (row.checked ? "Use turns it off" : "Use turns it on");
    return row;
}
