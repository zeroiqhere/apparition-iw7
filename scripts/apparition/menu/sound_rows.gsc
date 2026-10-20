// Sound pages expose only canonical perk aliases with current readiness

build(page, view)
{
    actor_reason = isDefined(view) && isstruct(view)
        ? scripts\apparition\menu\model::target_snapshot_reason(view) : "Wait for a valid player roster";
    target = isDefined(view) && isstruct(view) ? view.target : undefined;
    snapshot = undefined;
    if (actor_reason == "")
    {
        // Snapshot members stay unread until the selected actor is admitted
        snapshot = view.perk_sounds;
    }

    if (page == "Sounds & Jingles")
        return sounds_page(target, actor_reason, snapshot);
    if (page == "Perk Jingles & Quotes")
        return perk_page(target, actor_reason, snapshot);
    return [scripts\apparition\menu\model::unavailable("Sounds & Jingles", "Wait for a valid sound page")];
}

sounds_page(target, actor_reason, snapshot)
{
    rows = [];
    link = scripts\apparition\menu\model::link("Perk Jingles & Quotes", "Perk Jingles & Quotes", target);
    reason = actor_reason != "" ? actor_reason : snapshot_reason(snapshot);
    link.enabled = reason == "";
    if (reason != "")
        link.description = reason;
    else if (!snapshot.entries.size)
    {
        link.enabled = false;
        link.description = "No placed perk machines were found";
    }
    rows[rows.size] = link;
    rows[rows.size] = scripts\apparition\menu\model::unavailable("Player Dialogue Categories",
        "BO3 sndplayervox has no verified IW7 category map");
    return rows;
}

perk_page(target, actor_reason, snapshot)
{
    reason = actor_reason != "" ? actor_reason : snapshot_reason(snapshot);
    if (reason != "")
        return [scripts\apparition\menu\model::unavailable("Perk Jingles & Quotes", reason)];

    if (!snapshot.entries.size)
        return [scripts\apparition\menu\model::unavailable("Perk Jingles & Quotes",
            "No placed perk machines were found")];

    rows = [];
    foreach (entry in snapshot.entries)
    {
        rows[rows.size] = sound_action(target, entry, "Jingle", entry.jingle_reason);
        rows[rows.size] = sound_action(target, entry, "Quote", entry.quote_reason);
    }
    return rows;
}

snapshot_reason(snapshot)
{
    if (!isDefined(snapshot) || !isstruct(snapshot)
        || !isDefined(snapshot.reason) || !isstring(snapshot.reason))
        return "Wait for current perk sound data";
    // A current native blocker remains readable without entry details
    if (snapshot.reason != "")
        return snapshot.reason;
    if (!isDefined(snapshot.entries) || !isarray(snapshot.entries))
        return "Wait for current perk sound data";

    catalog = scripts\apparition\maps\spaceland\perks::catalog();
    if (snapshot.entries.size > catalog.size)
        return "Wait for current perk sound data";

    previous = -1;
    for (index = 0; index < snapshot.entries.size; index++)
    {
        entry = snapshot.entries[index];
        if (!isDefined(entry) || !isstruct(entry)
            || !isDefined(entry.id) || !isstring(entry.id)
            || !isDefined(entry.label) || !isstring(entry.label)
            || !isDefined(entry.jingle_reason) || !isstring(entry.jingle_reason)
            || !isDefined(entry.quote_reason) || !isstring(entry.quote_reason))
            return "Wait for current perk sound data";

        position = -1;
        for (catalog_index = 0; catalog_index < catalog.size; catalog_index++)
        {
            if (catalog[catalog_index].id == entry.id)
            {
                position = catalog_index;
                break;
            }
        }
        if (position < 0)
            return "Wait for current perk sound data";
        // Strict catalog order also rejects duplicate IDs and foreign labels
        if (position <= previous || catalog[position].label != entry.label)
            return "Wait for current perk sound data";
        previous = position;
    }
    return "";
}

sound_action(target, entry, kind, reason)
{
    row = scripts\apparition\menu\model::action(entry.label + " " + kind,
        scripts\apparition\menu\actions::play_perk_sound, target, false);
    row.perk_id = entry.id;
    row.sound_kind = kind;
    row.selection_key = entry.id + ":" + kind;
    row.enabled = reason == "";
    row.description = reason != "" ? reason
        : "Request the native sound for this player; nearby players may hear it. Playback completion is not confirmed";
    return row;
}
