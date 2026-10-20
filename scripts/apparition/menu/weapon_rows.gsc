// Weapon pages retain the source hierarchy while unbound controls stay unavailable

build(page, view)
{
    if (page == "Weaponry")
        return root_rows(view);
    if (page != "Weapon Options")
        return [];
    target = isDefined(view) && isstruct(view) ? view.target : undefined;
    rows = [current_row(view)];
    rows[rows.size] = scripts\apparition\menu\model::unavailable("Take All Weapons",
        "Full IW7 inventory coverage for the source exclusions is unresolved");
    drop = scripts\apparition\menu\model::action("Drop Current Weapon", undefined, target, false);
    drop.kind = "slider";
    drop.values = ["Take", "Don't Take"];
    drop.enabled = false;
    drop.description = "Native drop ownership and source drop/regrant preservation are unresolved";
    rows[rows.size] = drop;
    rows[rows.size] = scripts\apparition\menu\model::unavailable("Pack 'a' Punch Current Weapon",
        "The source upgrade toggle has no verified IW7 transaction yet");
    return rows;
}

page_reason(view)
{
    if (!isDefined(view) || !isstruct(view))
        return "Wait for a valid player roster";
    reason = scripts\apparition\menu\model::target_snapshot_reason(view);
    if (reason != "")
        return reason;
    return scripts\apparition\features\weapons::role_reason(view.access);
}

root_rows(view)
{
    target = isDefined(view) && isstruct(view) ? view.target : undefined;
    reason = page_reason(view);
    options = scripts\apparition\menu\model::link("Options", "Weapon Options", target);
    options.enabled = reason == "";
    if (reason != "")
        options.description = reason;
    rows = [options];
    foreach (label in ["Attachments", "Loadout", "Camo", "AAT", "", "Equipment",
        "Assault Rifles", "Sub Machine Guns", "Light Machine Guns", "Sniper Rifles",
        "Shotguns", "Pistols", "Launchers", "Specials"])
        rows[rows.size] = scripts\apparition\menu\model::unavailable(label,
            "This source weapon control has no verified IW7 binding yet");
    return rows;
}

current_row(view)
{
    target = isDefined(view) && isstruct(view) ? view.target : undefined;
    row = scripts\apparition\menu\model::action("Take Current Weapon",
        scripts\apparition\menu\actions::take_current_weapon, target, false);
    row.enabled = false;
    row.description = page_reason(view);
    // Current actor and source role admission precede captured weapon state
    if (row.description != "")
        return row;
    row.description = "Wait for native weapon readiness";
    snapshot = view.weapon_current;
    if (!isDefined(snapshot) || !isstruct(snapshot)
        || !isDefined(snapshot.reason) || !isstring(snapshot.reason))
        return row;
    if (snapshot.reason != "")
    {
        row.description = snapshot.reason;
        return row;
    }
    if (!scripts\apparition\features\weapons::valid_name(snapshot.weapon))
        return row;
    row.enabled = true;
    // Only the selected actor is dispatched; the action resolves the held weapon again
    row.description = "Current: " + snapshot.weapon
        + "; Use removes the weapon held when the action runs; base melee and knife weapons are preserved";
    return row;
}
