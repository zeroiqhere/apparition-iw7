// Insta-Kill keeps configured mode separate from the source slider preview

build(view)
{
    target = undefined;
    actor_reason = "Wait for a valid player roster";
    if (isDefined(view) && isstruct(view))
    {
        actor_reason = scripts\apparition\menu\model::target_snapshot_reason(view);
        target = view.target;
    }

    row = scripts\apparition\menu\model::action("Insta-Kill",
        scripts\apparition\menu\actions::set_insta_kill, target, false);
    row.kind = "slider";
    // Disable stays first so the preview begins with the safe clear action
    row.values = scripts\apparition\features\insta_kill::modes();
    row.initial_index = 0;
    row.active_value = "Unknown";
    row.choice_reasons = [];
    row.enabled = false;
    row.description = actor_reason != "" ? actor_reason : "Wait for a current Insta-Kill snapshot";

    // Target admission precedes all feature snapshot reads
    if (actor_reason != "")
        return row;

    snapshot = view.insta_kill;
    // Configured data is trusted only after all snapshot fields are typed
    if (!isDefined(snapshot) || !isstruct(snapshot)
        || !isDefined(snapshot.reason) || !isstring(snapshot.reason)
        || !isDefined(snapshot.mode) || !isstring(snapshot.mode)
        || !isDefined(snapshot.hook_reason) || !isstring(snapshot.hook_reason))
        return row;

    if (snapshot.mode != "Unknown"
        && !scripts\engine\utility::array_contains(row.values, snapshot.mode))
        return row;

    // Preserve the actual setting even when the base readiness reason blocks changes
    row.active_value = snapshot.mode;
    // Hook loss blocks new damage modes without blocking cleanup
    row.choice_reasons["Disable"] = "";
    row.choice_reasons["All"] = snapshot.hook_reason;
    row.choice_reasons["Melee"] = snapshot.hook_reason;
    if (snapshot.reason != "")
    {
        row.description = snapshot.reason;
        return row;
    }

    row.enabled = true;
    if (snapshot.hook_reason != "")
        row.description = "Configured: " + snapshot.mode + "; " + snapshot.hook_reason + "; use Disable to clear. Preserves Brute and Grey protections; accepted hits only, kills unconfirmed.";
    else
        row.description = "Configured: " + snapshot.mode + "; Use applies preview. Preserves Brute and Grey protections; accepted hits only, kills unconfirmed.";
    return row;
}
