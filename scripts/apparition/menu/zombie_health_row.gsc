// The source Health slider keeps its two choices while Reset awaits a verified mapping

build(view)
{
    row = scripts\apparition\menu\model::action("Health",
        scripts\apparition\menu\actions::set_zombie_health, undefined, true);
    row.kind = "slider";
    row.values = ["Custom", "Reset"];
    row.initial_index = 0;
    row.choice_reasons = [];
    row.choice_reasons["Custom"] = "Wait for a current zombie health snapshot";
    row.choice_reasons["Reset"] = "Reset is unavailable until its native reset mapping is verified";
    row.enabled = false;
    row.description = "Wait for a current zombie health snapshot";

    // Host admission comes before reading feature-specific snapshot data
    if (!isDefined(view) || !isstruct(view))
        return row;
    if (!isDefined(view.host) || !(view.host == true || view.host == false))
    {
        row.description = "Wait for a typed current-host snapshot";
        row.choice_reasons["Custom"] = row.description;
        return row;
    }
    if (!view.host)
    {
        row.description = "Only the current host can change zombie health";
        row.choice_reasons["Custom"] = row.description;
        return row;
    }

    snapshot = view.zombie_health;
    if (!isDefined(snapshot) || !isstruct(snapshot)
        || !isDefined(snapshot.reason) || !isstring(snapshot.reason))
    {
        row.description = "Wait for a typed native zombie health snapshot";
        row.choice_reasons["Custom"] = row.description;
        return row;
    }

    // A native reason is authoritative and precedes optional configuration fields
    if (snapshot.reason != "")
    {
        row.description = snapshot.reason;
        row.choice_reasons["Custom"] = snapshot.reason;
        return row;
    }

    if (!isDefined(snapshot.configured)
        || !(snapshot.configured == true || snapshot.configured == false))
    {
        row.description = "Wait for a typed native zombie health configuration";
        row.choice_reasons["Custom"] = row.description;
        return row;
    }

    if (snapshot.configured)
    {
        // Validate the configured request before converting or displaying it
        if (!isDefined(snapshot.value)
            || !scripts\apparition\maps\spaceland\zombie_health::valid_health(snapshot.value))
        {
            row.description = "The configured zombie health request is not a valid signed integer";
            row.choice_reasons["Custom"] = row.description;
            return row;
        }

        row.description = "Requested value: " + snapshot.value
            + "; Custom targets current live team agents and the future base zombie archetype; later native health writers may replace its effect";
    }
    else
    {
        row.description = "Custom targets current live team agents and the future base zombie archetype; later native health writers may replace its effect";
    }

    row.choice_reasons["Custom"] = "";
    row.enabled = true;
    return row;
}
