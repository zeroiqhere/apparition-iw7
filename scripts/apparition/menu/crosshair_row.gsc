// Crosshair preview is separate from the target's saved text and HUD handle

build(view)
{
    row = scripts\apparition\menu\model::action("Custom Crosshairs", scripts\apparition\menu\actions::set_crosshair, view.target, false);
    row.kind = "slider";
    row.active_value = "Unknown";
    reason = scripts\apparition\menu\model::target_snapshot_reason(view);
    row.enabled = reason == "";
    if (!row.enabled)
    {
        row.values = scripts\apparition\features\crosshairs::choices("");
        row.description = reason;
        return row;
    }

    // Target fields are read only after the shared actual-player snapshot passes
    row.values = scripts\apparition\features\crosshairs::choices(view.target.name);
    configured = scripts\apparition\features\crosshairs::configured(view.target);
    row.active_value = configured;
    row.description = "Configured: " + configured + "; Use applies the preview text";
    if (configured != "Disable" && configured != "Unknown")
    {
        if (!isDefined(view.target.apparition_crosshair.element))
            row.description = "Configured: " + configured + "; HUD handle missing; Use applies the preview text";
        else
            row.description += "; native visibility is unconfirmed";
    }
    return row;
}
