// The Spaceland page retains source controls while native adapters remain explicit

build(view)
{
    rows = [];
    labels = ["Spawner", "Prioritize", "Death Effect", "Damage Effect", "Animations", "Model", "Gib",
        "Kill", "Health", "Movement", "Knockdown", "Teleport", "Animation Speed", "Teleport To Crosshairs",
        "Disable Player Collision", "Disable Spawning", "Disable Push", "Invisibility", "Freeze", "Death Sounds",
        "Projectile Vomit", "Disappearing Zombies", "Exploding Zombies", "Ragdoll After Death", "Stack Zombies",
        "Remove Eyes", "Bodies Float", "Make Crawlers", "Detach Heads", "Clear All Corpses"];
    foreach (label in labels)
    {
        if (label == "Kill")
            row = kill_row(view);
        else if (label == "Health")
            row = scripts\apparition\menu\zombie_health_row::build(view);
        else if (label == "Movement")
            row = movement_row(view);
        else if (label == "Invisibility")
            row = invisibility_row(view);
        else if (label == "Freeze")
            row = scripts\apparition\menu\model::unavailable(label,
                "A reversible IW7 AI freeze binding is unresolved");
        else
            row = scripts\apparition\menu\model::unavailable(label);
        rows[rows.size] = row;
    }
    return rows;
}

kill_row(view)
{
    row = scripts\apparition\menu\model::action("Kill", scripts\apparition\menu\actions::kill_zombies, undefined, true);
    row.kind = "slider";
    row.values = scripts\apparition\maps\spaceland\zombie_kill::modes();
    row.initial_index = 0;
    row.choice_reasons = [];
    foreach (mode in row.values)
        row.choice_reasons[mode] = mode == "Death" ? "" : mode + " is not available in this build";

    host = isDefined(view) && isstruct(view) && scripts\apparition\menu\model::truth(view.host);
    snapshot = host ? view.zombie_kill : undefined;
    return apply_snapshot(row, host, snapshot, "Only the current host can request zombie deaths",
        "No eligible current zombies can receive Death");
}

movement_row(view)
{
    row = scripts\apparition\menu\model::action("Movement", scripts\apparition\menu\actions::set_zombie_movement, undefined, true);
    row.kind = "slider";
    row.values = scripts\apparition\maps\spaceland\zombie_movement::modes();
    row.initial_index = 0;
    row.choice_reasons = [];
    foreach (mode in row.values)
        row.choice_reasons[mode] = isDefined(scripts\apparition\maps\spaceland\zombie_movement::native_mode(mode))
            ? "" : mode + " has no verified IW7 movement mapping";
    host = isDefined(view) && isstruct(view) && scripts\apparition\menu\model::truth(view.host);
    snapshot = host ? view.zombie_movement : undefined;
    return apply_snapshot(row, host, snapshot, "Only the current host can request zombie movement",
        "No eligible current zombies can receive Movement");
}

apply_snapshot(row, host, snapshot, host_reason, empty_reason)
{
    reason = host_reason;
    hint = "";
    if (host)
    {
        reason = "Wait for a current zombie snapshot";
        // Counts and hints are display data; Use resolves fresh actors independently
        if (isDefined(snapshot) && isstruct(snapshot)
            && isDefined(snapshot.reason) && isstring(snapshot.reason)
            && isDefined(snapshot.hint) && isstring(snapshot.hint)
            && isDefined(snapshot.targets) && isarray(snapshot.targets))
        {
            reason = snapshot.reason;
            hint = snapshot.hint;
            if (reason == "" && snapshot.targets.size == 0)
                reason = empty_reason;
        }
    }
    row.enabled = reason == "";
    row.description = row.enabled ? hint : reason;
    return row;
}


invisibility_row(view)
{
    row = scripts\apparition\menu\model::action("Invisibility",
        scripts\apparition\menu\actions::toggle_zombie_visibility, undefined, true);
    row.kind = "toggle";
    row.checked = false;
    row.enabled = false;
    row.description = "Only the current host can change zombie visibility";
    if (!isDefined(view) || !isstruct(view) || !scripts\apparition\menu\model::truth(view.host))
        return row;
    row.description = "Wait for native zombie visibility state";
    snapshot = view.zombie_visibility;
    if (!isDefined(snapshot) || !isstruct(snapshot)
        || !isDefined(snapshot.reason) || !isstring(snapshot.reason)
        || !isDefined(snapshot.configured) || !isnumber(snapshot.configured)
        || !(snapshot.configured == 0 || snapshot.configured == 1))
        return row;
    // The checkbox records the policy, not measured native rendering
    row.checked = snapshot.configured == 1;
    if (snapshot.reason != "")
    {
        row.description = snapshot.reason;
        return row;
    }
    row.enabled = true;
    row.description = row.checked
        ? "Configured on; Use stops hiding and requests Show for current living Axis agents; prior visibility is not restored"
        : "Hide living Axis agents every 0.5s, including special and quest enemies; snapshots do not measure visibility";
    return row;
}
