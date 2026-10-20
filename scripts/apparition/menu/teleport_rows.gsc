// Teleport rows bind only actions supported by the current readiness snapshot

build(view)
{
    owner = undefined;
    target = undefined;
    snapshot = undefined;
    if (isDefined(view) && isstruct(view))
    {
        owner = view.owner;
        target = view.target;
        snapshot = view.teleport;
    }

    // Every gate must be a string before an empty value can mean ready
    actor_reason = "Wait for teleport actor authorization";
    reason = "Wait for target travel readiness";
    aim_reason = "Wait for owner travel readiness";
    random_reason = "Wait for an eligible player";
    load_reason = "Wait for a valid saved location";
    if (isDefined(snapshot) && isstruct(snapshot)
        && isDefined(snapshot.actor_reason) && isstring(snapshot.actor_reason)
        && isDefined(snapshot.reason) && isstring(snapshot.reason)
        && isDefined(snapshot.aim_reason) && isstring(snapshot.aim_reason)
        && isDefined(snapshot.random_reason) && isstring(snapshot.random_reason)
        && isDefined(snapshot.load_reason) && isstring(snapshot.load_reason))
    {
        actor_reason = snapshot.actor_reason;
        reason = snapshot.reason;
        aim_reason = snapshot.aim_reason;
        random_reason = snapshot.random_reason;
        load_reason = snapshot.load_reason;
    }

    rows = [];
    rows[rows.size] = scripts\apparition\menu\model::unavailable("Disable Teleport Effect",
        "IW7 movement currently has no verified arrival-effect binding");
    official_spawn_row = scripts\apparition\menu\spawn_row::build(view, actor_reason, reason);
    if (isDefined(official_spawn_row))
        rows[rows.size] = official_spawn_row;
    row = scripts\apparition\menu\model::link("Entity Teleports", "Entity Teleports", target);
    row.enabled = actor_reason == "";
    row.description = row.enabled ? "Inspect current native machine destinations" : actor_reason;
    rows[rows.size] = row;

    row = scripts\apparition\menu\model::action("Teleport",
        scripts\apparition\menu\actions::teleport, target, false);
    row.kind = "slider";
    // An immediate move has a preview rather than a persistent active mode
    row.values = scripts\apparition\features\teleport::modes();
    row.initial_index = 0;
    row.enabled = actor_reason == "" && reason == "";
    // The selected preview shares one readiness gate with its footer and Use input
    row.choice_reasons = [];
    row.choice_reasons["Crosshairs"] = aim_reason;
    row.choice_reasons["Sky"] = "";
    row.choice_reasons["Random Player"] = random_reason;
    description = "Crosshairs uses the menu owner's aim; Sky adds 35000 Z; Random Player requires an eligible peer";
    if (actor_reason != "")
        description = actor_reason + "; " + description;
    else if (reason != "")
        description = reason + "; " + description;
    row.description = description;
    rows[rows.size] = row;

    // Saved intent belongs to the selected player and can change while movement is paused
    checked = false;
    if (actor_reason == "")
        checked = scripts\apparition\features\teleport_gun::configured(target);
    row = scripts\apparition\menu\model::action("Teleport Gun",
        scripts\apparition\menu\actions::toggle_teleport_gun, target, false);
    row.kind = "toggle";
    row.checked = checked;
    row.enabled = actor_reason == "";
    if (actor_reason != "")
        row.description = actor_reason;
    else
    {
        description = checked ? "Saved on; Use disables; shots use the selected player's own aim"
            : "Saved off; Use enables; shots use the selected player's own aim";
        if (reason != "")
            description = description + "; paused: " + reason;
        row.description = description;
    }
    rows[rows.size] = row;
    checked = false;
    if (actor_reason == "")
        checked = scripts\apparition\features\position_shortcuts::configured(target);
    row = scripts\apparition\menu\model::action("Save & Load Position",
        scripts\apparition\menu\actions::toggle_position_shortcuts, target, false);
    row.kind = "toggle";
    row.checked = checked;
    row.enabled = actor_reason == "";
    if (actor_reason != "")
        row.description = actor_reason;
    else
    {
        description = (checked ? "Saved on; Use disables" : "Saved off; Use enables")
            + "; Action Slot 3 saves and Action Slot 2 loads outside this player's menu";
        if (reason != "")
            description += "; paused: " + reason;
        row.description = description;
    }
    rows[rows.size] = row;

    row = scripts\apparition\menu\model::action("Save Current Location",
        scripts\apparition\menu\actions::save_location, target, false);
    row.enabled = actor_reason == "" && reason == "";
    row.description = row.enabled ? "Save the selected player's location and view angle"
        : actor_reason != "" ? actor_reason : reason;
    rows[rows.size] = row;

    // Loading reads the current save at dispatch rather than caching coordinates
    row = scripts\apparition\menu\model::action("Load Saved Location",
        scripts\apparition\menu\actions::load_location, target, false);
    row.enabled = actor_reason == "" && reason == "" && load_reason == "";
    row.description = row.enabled ? "Load the selected player's saved location and view angle"
        : actor_reason != "" ? actor_reason : reason != "" ? reason : load_reason;
    rows[rows.size] = row;

    if (owner != target)
    {
        // Either player can move here, so both movement reasons must be clear
        row = scripts\apparition\menu\model::action("Teleport To Self",
            scripts\apparition\menu\actions::teleport_to_self, target, false);
        row.enabled = actor_reason == "" && reason == "" && aim_reason == "";
        row.description = row.enabled ? "Move the selected player to the menu owner's position"
            : actor_reason != "" ? actor_reason : reason != "" ? reason : aim_reason;
        rows[rows.size] = row;

        row = scripts\apparition\menu\model::action("Teleport To Player",
            scripts\apparition\menu\actions::teleport_to_player, target, false);
        row.enabled = actor_reason == "" && reason == "" && aim_reason == "";
        row.description = row.enabled ? "Move the menu owner to the selected player's position"
            : actor_reason != "" ? actor_reason : reason != "" ? reason : aim_reason;
        rows[rows.size] = row;
    }
    return rows;
}
