// Current hold predicates remain separate from native activation and arena results

build(view)
{
    snapshot = view.cabinet_activation;
    valid = isDefined(snapshot) && isstruct(snapshot)
        && isDefined(snapshot.reason) && isstring(snapshot.reason);
    if (valid && snapshot.reason != "")
        return [scripts\apparition\menu\model::unavailable("Cabinet Hold: Unavailable", snapshot.reason)];

    valid = valid && isDefined(snapshot.route) && isstring(snapshot.route)
        && (snapshot.route == "Initial Unlock" || snapshot.route == "Reactivation")
        && isDefined(snapshot.members) && isarray(snapshot.members) && snapshot.members.size > 0;
    passing = 0;
    if (valid)
    {
        // Validate the full captured roster before displaying any passing count
        foreach (member in snapshot.members)
        {
            if (!isDefined(member) || !isstruct(member)
                || !isDefined(member.name) || !isstring(member.name) || member.name == ""
                || !isDefined(member.reason) || !isstring(member.reason))
            {
                valid = false;
                break;
            }
            if (member.reason == "")
                passing++;
        }
    }
    if (!valid)
        return [scripts\apparition\menu\model::unavailable("Cabinet Hold: Unknown", "Wait for a complete native cabinet snapshot")];

    rows = [];
    rows[rows.size] = scripts\apparition\menu\model::unavailable("Hold Use Together",
        "All current players must leave last stand, stop carrying, move within 50 units of the cabinet corner and hold [{+activate}] together");
    rows[rows.size] = scripts\apparition\menu\model::unavailable("Cabinet Route: " + snapshot.route,
        "Registered route and native marker snapshot; a running activation wait is not confirmed");
    rows[rows.size] = scripts\apparition\menu\model::unavailable("Passing Now: " + passing + "/" + snapshot.members.size,
        "One snapshot is not activation; keep Use held for the native two scans 0.25 seconds apart");
    foreach (member in snapshot.members)
    {
        // Keep names compact and put the full blocker in the existing wrapped footer
        label = member.reason == "" ? "Passing Now" : "Blocked";
        description = member.reason == ""
            ? "Current sample passes; keep Use held for the native check" : member.reason;
        rows[rows.size] = scripts\apparition\menu\model::unavailable(member.name + ": " + label,
            description);
    }
    return rows;
}
