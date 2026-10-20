// Fun rows keep the source order while exposing only verified personal controls

build(view)
{
    actor_reason = isDefined(view) && isstruct(view)
        ? scripts\apparition\menu\model::target_snapshot_reason(view) : "Wait for a valid player roster";
    target = isDefined(view) && isstruct(view) ? view.target : undefined;
    health_snapshot = undefined;
    frog_snapshot = undefined;
    if (actor_reason == "")
    {
        // Feature snapshots are read only after the shared actor admission passes
        health_snapshot = view.health_bar;
        frog_snapshot = view.frog_jump;
    }
    earthquake = scripts\apparition\menu\model::action("Earthquake",
        scripts\apparition\menu\actions::send_earthquake, target, false);
    earthquake.enabled = false;
    earthquake.description = actor_reason != "" ? actor_reason : "Wait for a current earthquake readiness snapshot";

    // Actor admission wins before the captured native readiness is inspected
    if (actor_reason == "" && isDefined(view.earthquake) && isstruct(view.earthquake)
        && isDefined(view.earthquake.reason) && isstring(view.earthquake.reason))
    {
        if (view.earthquake.reason == "")
        {
            earthquake.enabled = true;
            earthquake.description = "One global 15s quake at this player's current position, radius 750. Nearby players may feel it; request only.";
        }
        else
            earthquake.description = view.earthquake.reason;
    }

    rows = [earthquake];
    foreach (label in ["Adventure Time", "Force Field Options", "Effects Man Options", "Sounds & Jingles",
        "Hit Markers", "Insta-Kill", "Death Skull", "Mount Camera", "Shoot Power-Ups", "Drop Camera",
        "Dead Ops View", "Zombie Counter", "Light Protector", "Special Movements", "Moon Gravity",
        "Ice Skating", "Forge Mode", "Spec-Nade", "Nuke Nades", "Cod Jumper", "Frog Jump",
        "Jetpack", "Health Bar", "Cluster Grenades", "Electric Fire Cherry", "Human Centipede",
        "Rocket Riding", "Grappling Gun", "Gravity Gun", "Delete Gun", "Rapid Fire", "Extra Gore",
        "Head Drama", "Power-Up Magnet", "Disable Earning Points", "Points Multiplier"])
    {
        if (label == "Sounds & Jingles")
        {
            row = scripts\apparition\menu\model::link(label, label, target);
            row.enabled = actor_reason == "";
            if (!row.enabled)
                row.description = actor_reason;
        }
        else if (label == "Insta-Kill")
            row = scripts\apparition\menu\insta_kill_row::build(view);
        else if (label == "Frog Jump")
        {
            row = configured_toggle(label, scripts\apparition\menu\actions::toggle_frog_jump,
                target, actor_reason, frog_snapshot, "Wait for a current frog jump snapshot");
            if (row.enabled)
                row.description = row.checked
                    ? "Configured on; one boost until landing. Use turns it off; native rides and links can pause boosting."
                    : "Hold Jump while airborne and standing for one forward boost until landing; native rides and links pause it.";
        }
        else if (label == "Health Bar")
        {
            row = configured_toggle(label, scripts\apparition\menu\actions::toggle_health_bar,
                target, actor_reason, health_snapshot, "Wait for a current health bar snapshot");
            if (row.enabled)
                row.description = row.checked
                    ? "Configured on; Use removes this player's health bar. It stays outside the menu and turns off on death."
                    : "Show this player's live health bar until death or Use turns it off; native placement is adapted.";
        }
        else
        {
            description = undefined;
            if (label == "Zombie Counter")
                description = "Native all-phase zombie count semantics are unresolved";
            else if (label == "Rapid Fire")
                description = "Native player muzzle, weapon and shot-event behavior remain unverified";
            else if (label == "Disable Earning Points" || label == "Points Multiplier")
                description = "Native currency scaling also affects refunds and cannot isolate damage awards";
            else if (label == "Moon Gravity")
                description = "Per-player gravity has no verified IW7 binding";
            else if (label == "Ice Skating")
                description = "Per-player slick movement has no verified IW7 binding";
            else if (label == "Extra Gore")
                description = "Damage and death effects need matching native hooks and a blood effect";
            else if (label == "Head Drama")
                description = "The original headshot perk has no verified IW7 behavior";
            else if (label == "Power-Up Magnet")
                description = "Live pickup tracking and safe movement ownership remain unverified";
            row = scripts\apparition\menu\model::unavailable(label, description);
        }
        rows[rows.size] = row;
    }
    return rows;
}

configured_toggle(label, callback, target, actor_reason, snapshot, pending_hint)
{
    row = scripts\apparition\menu\model::action(label, callback, target, false);
    row.kind = "toggle";
    row.checked = false;
    row.enabled = false;
    row.description = actor_reason != "" ? actor_reason : pending_hint;

    // Actor rejection returns before the saved flag or native readiness is inspected
    if (actor_reason != "")
        return row;

    if (!isDefined(snapshot) || !isstruct(snapshot)
        || !isDefined(snapshot.reason) || !isstring(snapshot.reason)
        || !isDefined(snapshot.configured) || !isnumber(snapshot.configured)
        || (snapshot.configured != 0 && snapshot.configured != 1))
        return row;

    // Configuration remains visible while native effect readiness is blocked
    row.checked = snapshot.configured == 1;
    if (snapshot.reason != "")
    {
        row.description = snapshot.reason;
        return row;
    }

    row.enabled = true;
    return row;
}
