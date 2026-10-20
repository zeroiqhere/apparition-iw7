// The checkbox records intent while the description reports current readiness

build(view)
{
    row = scripts\apparition\menu\model::action("Demi-God", scripts\apparition\menu\actions::toggle_demi_god, view.target, false);
    row.kind = "toggle";
    row.checked = false;
    reason = scripts\apparition\menu\model::target_snapshot_reason(view);
    row.enabled = reason == "";
    if (!row.enabled)
    {
        row.description = reason;
        return row;
    }

    // Actor admission precedes every read of the selected player's saved flag
    row.checked = scripts\apparition\features\demi_god::enabled(view.target);
    hook_active = scripts\apparition\menu\model::truth(view.god_ready);
    reason = scripts\apparition\features\demi_god::reason(view.target, hook_active, view.demi_feedback_reason);
    row.enabled = reason == "";
    if (!row.enabled)
    {
        row.description = reason;
        return row;
    }

    if (row.checked && !hook_active)
        row.description = "Disable the saved Demi-God setting; damage protection is not confirmed";
    else if (row.checked && (!isDefined(view.demi_feedback_reason)
        || !isstring(view.demi_feedback_reason) || view.demi_feedback_reason != ""))
        row.description = "Disable the saved Demi-God setting; directional hit effects are unavailable";
    else
        row.description = "Block damage with native directional hit effects; enabling clears God Mode";
    return row;
}
