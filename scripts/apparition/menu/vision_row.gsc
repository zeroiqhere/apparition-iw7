// The slider previews a request without claiming a saved or currently rendered profile

build(view)
{
    target = undefined;
    reason = "Wait for a valid player roster";
    if (isDefined(view) && isstruct(view))
    {
        target = view.target;
        reason = scripts\apparition\menu\model::target_snapshot_reason(view);
    }
    row = scripts\apparition\menu\model::action("Set Vision",
        scripts\apparition\menu\actions::set_vision, target, false);
    row.kind = "slider";
    row.values = scripts\apparition\features\vision::values();
    row.initial_index = 0;
    row.choice_reasons = [];
    row.enabled = false;
    row.description = reason != "" ? reason : "Wait for a current native vision snapshot";
    // Actor admission wins before malformed or stale feature snapshots are read
    if (reason != "")
        return row;

    snapshot = view.vision;
    if (!isDefined(snapshot) || !isstruct(snapshot)
        || !isDefined(snapshot.reason) || !isstring(snapshot.reason)
        || (isDefined(snapshot.override) && !isstring(snapshot.override)))
        return row;
    if (snapshot.reason != "")
    {
        row.description = snapshot.reason;
        return row;
    }

    // Shared choice policy keeps unsupported source names visible with a specific reason
    foreach (value in row.values)
    {
        selected = scripts\apparition\features\vision::choice(value, snapshot.override);
        row.choice_reasons[value] = selected.reason;
    }
    row.enabled = true;
    row.description = "Use requests IW7 Last Stand or black-and-white analogues. Default restores the current native base. Native events may replace the effect; display is unconfirmed.";
    return row;
}
