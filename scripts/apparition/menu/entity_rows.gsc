// Entity rows publish native entry references only after the full snapshot validates

build(view)
{
    actor_reason = "Wait for entity teleport actor authorization";
    movement_reason = "Wait for target movement readiness";
    catalog_reason = "Wait for native entity destinations";
    target = undefined;
    entries = undefined;
    readiness_valid = false;
    catalog_valid = false;

    // Empty readiness reasons count as ready only when both snapshots are shaped correctly
    if (isDefined(view) && isstruct(view))
    {
        target = view.target;
        teleport = view.teleport;
        if (isDefined(teleport) && isstruct(teleport))
        {
            actor_valid = false;
            movement_valid = false;
            if (isDefined(teleport.actor_reason) && isstring(teleport.actor_reason))
            {
                actor_reason = teleport.actor_reason;
                actor_valid = true;
            }
            if (isDefined(teleport.reason) && isstring(teleport.reason))
            {
                movement_reason = teleport.reason;
                movement_valid = true;
            }
            readiness_valid = actor_valid && movement_valid;
        }

        snapshot = view.entity_teleports;
        if (isDefined(snapshot) && isstruct(snapshot))
        {
            if (isDefined(snapshot.reason) && isstring(snapshot.reason))
                catalog_reason = snapshot.reason;
            if (isDefined(snapshot.reason) && isstring(snapshot.reason)
                && isDefined(snapshot.entries) && isarray(snapshot.entries))
            {
                entries = snapshot.entries;
                catalog_valid = true;
                // Preserve registry order and reject the whole list before creating rows
                for (index = 0; index < entries.size; index++)
                {
                    entry = entries[index];
                    entry_valid = isDefined(entry) && isstruct(entry);
                    if (entry_valid)
                    {
                        entry_valid = isDefined(entry.kind) && isstring(entry.kind)
                            && (entry.kind == "wheel" || entry.kind == "perk")
                            && isDefined(entry.id) && isstring(entry.id) && entry.id != ""
                            && isDefined(entry.label) && isstring(entry.label) && entry.label != ""
                            && isDefined(entry.point);
                    }
                    if (!entry_valid)
                    {
                        catalog_valid = false;
                        catalog_reason = "Native entity destination data is malformed";
                        break;
                    }
                }
            }
            else if (catalog_reason == "")
                catalog_reason = "Native entity destination data is malformed";
        }
    }

    // Invalid input never leaks a valid prefix into a partially usable page
    if (!readiness_valid || !catalog_valid)
    {
        description = blocked_reason(actor_reason, movement_reason, catalog_reason);
        return [scripts\apparition\menu\model::unavailable("Entity Teleports", description)];
    }

    if (entries.size == 0)
    {
        if (catalog_reason != "")
        {
            description = blocked_reason(actor_reason, movement_reason, catalog_reason);
            return [scripts\apparition\menu\model::unavailable("Entity Teleports", description)];
        }
        // Readiness reasons take priority while the empty catalog label stays stable
        description = blocked_reason(actor_reason, movement_reason, "");
        if (description == "")
            description = "No supported native wheel or perk destinations are available";
        return [scripts\apparition\menu\model::unavailable("No Native Entity Destinations", description)];
    }

    rows = [];
    for (index = 0; index < entries.size; index++)
    {
        entry = entries[index];
        row = scripts\apparition\menu\model::action(entry.label,
            scripts\apparition\menu\actions::entity_teleport, target, false);
        // The native point keeps same-label machine choices distinct during menu rebuilds
        row.selection_key = entry.point;
        row.enabled = actor_reason == "" && movement_reason == "" && catalog_reason == "";
        // Blocked actions retain selection but never expose stale movement payloads
        if (row.enabled)
        {
            row.teleport_entry = entry;
            if (entry.kind == "wheel")
                row.description = "Move selected player 70 units from the current native Mystery Wheel and face it; rechecked on Use";
            else
                row.description = "Move selected player 70 units from this native perk point and face it; rechecked on Use";
        }
        else
            row.description = blocked_reason(actor_reason, movement_reason, catalog_reason);
        rows[rows.size] = row;
    }
    return rows;
}

blocked_reason(actor_reason, movement_reason, catalog_reason)
{
    if (actor_reason != "")
        return actor_reason;
    if (movement_reason != "")
        return movement_reason;
    return catalog_reason;
}
