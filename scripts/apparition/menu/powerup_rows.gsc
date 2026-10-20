// Power-up rows use one captured admission result and never retain a spawn point

build(view)
{
    snapshot = view.powerups;
    actor_reason = "Wait for a valid player roster";
    drop_reason = "Wait for native power-up data";
    if (isDefined(snapshot) && isstruct(snapshot))
    {
        if (isDefined(snapshot.actor_reason) && isstring(snapshot.actor_reason))
            actor_reason = snapshot.actor_reason;
        if (isDefined(snapshot.reason) && isstring(snapshot.reason))
            drop_reason = snapshot.reason;

        // A ready reason still needs a complete native point and per-item result
        if (drop_reason == "" && (!isDefined(snapshot.origin) || !isvector(snapshot.origin)
            || !isDefined(snapshot.reasons) || !isarray(snapshot.reasons)))
            drop_reason = "Wait for native power-up data";
    }
    if (actor_reason != "")
        drop_reason = actor_reason;
    // Host permission stays ahead of missing or stale native data for guests
    if (!scripts\apparition\menu\model::truth(view.host))
        drop_reason = "Only the current host can spawn power-ups";

    location = scripts\apparition\features\powerups::configured_location(view.owner);
    rows = [];
    row = scripts\apparition\menu\model::action("Spawn Location", scripts\apparition\menu\actions::set_powerup_location, view.owner, false);
    row.kind = "slider";
    row.values = scripts\apparition\features\powerups::locations();
    row.active_value = location;
    row.enabled = actor_reason == "";
    row.description = row.enabled ? "Configured: " + location + "; Use applies the preview location" : actor_reason;
    rows[rows.size] = row;
    rows[rows.size] = scripts\apparition\menu\model::unavailable("Reign Drops", "The BO3 Reign Drops activation has no verified IW7 equivalent");
    rows[rows.size] = scripts\apparition\menu\model::unavailable("", "");

    foreach (entry in scripts\apparition\maps\spaceland\powerups::catalog())
    {
        row = scripts\apparition\menu\model::action(entry.label, scripts\apparition\menu\actions::drop_powerup, undefined, true);
        row.powerup_id = entry.id;
        reason = drop_reason;
        if (reason == "")
        {
            // One unavailable item must not hide unrelated native pickups
            reason = isDefined(snapshot.reasons[entry.id]) && isstring(snapshot.reasons[entry.id])
                ? snapshot.reasons[entry.id] : "Wait for native power-up data";
        }
        row.enabled = reason == "";
        place = location == "Self" ? "the host" : "the aimed surface";
        row.description = row.enabled ? "Spawn a " + entry.label + " pickup near " + place + "; collect it for the effect" : reason;
        rows[rows.size] = row;
    }
    return rows;
}
