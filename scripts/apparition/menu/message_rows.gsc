// Message pages render captured readiness and send only stable preset selectors

build(page, view)
{
    owner = undefined;
    snapshot = undefined;
    if (isDefined(view) && isstruct(view))
    {
        owner = view.owner;
        snapshot = view.messages;
    }
    ready = valid_snapshot(page, snapshot);
    reason = ready ? snapshot.reason : "Wait for message readiness";
    // A rejected probe can explain denial without reading names or building entries
    if (!ready && isDefined(snapshot) && isstruct(snapshot)
        && isDefined(snapshot.reason) && isstring(snapshot.reason) && snapshot.reason != "")
        reason = snapshot.reason;
    mode = ready ? snapshot.mode : "Unknown";
    rows = [];

    if (page == "Message Menu")
    {
        row = scripts\apparition\menu\model::action("Display Type",
            scripts\apparition\menu\actions::set_message_display, owner, false);
        row.kind = "slider";
        row.values = scripts\apparition\features\messages::types();
        row.initial_index = 0;
        row.active_value = mode;
        row.enabled = reason == "";
        // Previewing a type cannot silently change the configured delivery path
        row.choice_reasons = [];
        foreach (type in row.values)
            row.choice_reasons[type] = scripts\apparition\features\messages::delivery_reason(type);
        row.description = row.enabled ? "Configured: " + mode + "; Use applies the preview display type" : reason;
        rows[rows.size] = row;
        row = scripts\apparition\menu\model::action("Custom Message",
            scripts\apparition\menu\actions::open_message_keyboard, owner, false);
        blocked = reason != "" ? reason : scripts\apparition\features\messages::delivery_reason(mode);
        row.enabled = blocked == "";
        row.description = row.enabled
            ? "Open the source keyboard; Jump confirms a private-lobby Print Bold message" : blocked;
        rows[rows.size] = row;
        foreach (label in ["Miscellaneous", "Advertisements"])
        {
            row = scripts\apparition\menu\model::link(label, label + " Messages", owner);
            row.enabled = reason == "";
            if (!row.enabled)
                row.description = reason;
            rows[rows.size] = row;
        }
        return rows;
    }

    if (!ready)
        return [scripts\apparition\menu\model::unavailable("Messages", reason)];
    foreach (entry in snapshot.entries)
    {
        row = scripts\apparition\menu\model::action(entry.label,
            scripts\apparition\menu\actions::send_message_preset, owner, false);
        row.message_page = page;
        row.message_id = entry.id;
        row.selection_key = entry.id;
        // Actor denial remains first; each source-only preset keeps its own reason
        blocked = reason != "" ? reason : entry.reason;
        if (blocked == "")
            blocked = scripts\apparition\features\messages::delivery_reason(mode);
        row.enabled = blocked == "";
        if (blocked != "")
            row.description = blocked;
        else if (entry.id == "deranked")
            row.description = "Text announcement only; sends the original preset to the private lobby";
        else if (entry.id == "apparition")
            row.description = "Send the original BO3 advertisement wording to the private lobby";
        else
            row.description = "Send the original preset to the private lobby using Print Bold";
        rows[rows.size] = row;
    }
    return rows;
}

valid_snapshot(page, snapshot)
{
    if (!isDefined(page) || !isstring(page)
        || !isDefined(snapshot) || !isstruct(snapshot)
        || !isDefined(snapshot.reason) || !isstring(snapshot.reason)
        || !isDefined(snapshot.mode) || !isstring(snapshot.mode)
        || !isDefined(snapshot.entries) || !isarray(snapshot.entries))
        return false;
    if (snapshot.mode != "Unknown"
        && !scripts\engine\utility::array_contains(scripts\apparition\features\messages::types(), snapshot.mode))
        return false;
    if (page == "Message Menu")
        return true;
    if (page != "Miscellaneous Messages" && page != "Advertisements Messages")
        return false;

    // Canonical IDs and order bind the readiness snapshot to its visible page
    expected = scripts\apparition\features\messages::presets(page, undefined, undefined);
    if (snapshot.entries.size != expected.size)
        return false;
    for (index = 0; index < expected.size; index++)
    {
        entry = snapshot.entries[index];
        if (!isDefined(entry) || !isstruct(entry)
            || !isDefined(entry.id) || !isstring(entry.id) || entry.id != expected[index].id
            || !isDefined(entry.label) || !isstring(entry.label)
            || !isDefined(entry.reason) || !isstring(entry.reason)
            || (entry.reason == "" && (!isDefined(entry.text) || !isstring(entry.text))))
            return false;
        // Only the owner's name is dynamic; fixed labels describe their exact IDs
        if (entry.id != "owner_name" && entry.label != expected[index].label)
            return false;
    }
    return true;
}
