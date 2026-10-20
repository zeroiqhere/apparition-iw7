// Doheart previews stay separate from the level's saved text and style

build(view)
{
    toggle = scripts\apparition\menu\model::action("Doheart",
        scripts\apparition\menu\actions::toggle_doheart, undefined, true);
    toggle.kind = "toggle";
    toggle.checked = false;
    text = scripts\apparition\menu\model::action("Text",
        scripts\apparition\menu\actions::configure_doheart, undefined, true);
    text.kind = "slider";
    text.setting = "text";
    text.values = scripts\apparition\features\server\doheart::text_choices(undefined);
    style = scripts\apparition\menu\model::action("Style",
        scripts\apparition\menu\actions::configure_doheart, undefined, true);
    style.kind = "slider";
    style.setting = "style";
    style.values = scripts\apparition\features\server\doheart::styles();
    foreach (row in [text, style])
    {
        // Both source sliders start at their first choice, independent of saved values
        row.initial_index = 0;
    }
    rows = [toggle, text, style];
    foreach (row in rows)
    {
        row.enabled = false;
        row.description = "Co-Host access is required to manage Doheart";
    }
    if (!isDefined(view) || !isstruct(view)
        || !scripts\apparition\runtime\player_control::can_manage(view.access))
        return rows;

    foreach (row in rows)
        row.description = "Wait for current Doheart settings";
    snapshot = view.doheart;
    if (!isDefined(snapshot) || !isstruct(snapshot)
        || !isDefined(snapshot.reason) || !isstring(snapshot.reason))
        return rows;
    // A current permission denial precedes saved configuration and checkbox reads
    if (snapshot.reason != "")
    {
        foreach (row in rows)
            row.description = snapshot.reason;
        return rows;
    }
    if (!isDefined(snapshot.configured) || !isnumber(snapshot.configured)
        || !(snapshot.configured == 0 || snapshot.configured == 1)
        || !isDefined(snapshot.settings_ready) || !isnumber(snapshot.settings_ready)
        || !(snapshot.settings_ready == 0 || snapshot.settings_ready == 1))
        return rows;
    toggle.checked = snapshot.configured == 1;
    toggle.enabled = toggle.checked;
    if (!snapshot.settings_ready)
    {
        foreach (row in rows)
            row.description = "Reopen Doheart Options to initialize saved choices";
        return rows;
    }

    // The real footer consumes descriptions; slider values remain unapplied previews
    saved_text = isDefined(snapshot.text) && isstring(snapshot.text) ? snapshot.text : "Unknown";
    saved_style = isDefined(snapshot.style) && isstring(snapshot.style) ? snapshot.style : "Unknown";
    reason = scripts\apparition\features\server\doheart::configuration_reason(snapshot.text, snapshot.style);
    toggle.enabled = toggle.checked || reason == "";
    toggle.description = toggle.checked ? "Configured on; Use removes the global display"
        : "Use displays the saved text and style for the lobby";
    if (reason != "")
        toggle.description += "; " + reason;

    // Each active change must leave a complete supported configuration
    style.choice_reasons = [];
    foreach (value in style.values)
    {
        reason = scripts\apparition\features\server\doheart::change_reason(toggle.checked,
            snapshot.text, snapshot.style, "style", value);
        style.choice_reasons[value] = reason;
        if (reason == "")
            style.enabled = true;
    }
    style.description = "Saved style: " + saved_style + "; ";
    style.description += toggle.checked
        ? "Use applies a changed style and restarts its display; the same style does nothing"
        : "Use stores a style without starting the display";

    // A missing current host catalog affects text selection, not saved display or style
    values = snapshot.text_values;
    valid_values = isDefined(values) && isarray(values) && values.size == 5;
    if (valid_values)
    {
        for (index = 0; index < values.size; index++)
        {
            if (!isDefined(values[index]) || !isstring(values[index]))
                valid_values = false;
        }
    }
    text.description = "Saved text: " + saved_text + "; Wait for the current host's text choices";
    if (!valid_values)
        return rows;
    text.values = values;
    text.choice_reasons = [];
    foreach (value in values)
    {
        reason = scripts\apparition\features\server\doheart::change_reason(toggle.checked,
            snapshot.text, snapshot.style, "text", value);
        text.choice_reasons[value] = reason;
        if (reason == "")
            text.enabled = true;
    }
    text.description = "Saved text: " + saved_text + "; ";
    text.description += toggle.checked
        ? "Use applies changed text and restarts its display; the same text does nothing"
        : "Use stores text without starting the display";
    text.description += "; Custom opens the source keyboard";
    return rows;
}
