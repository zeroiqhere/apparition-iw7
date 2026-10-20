// Saved Doheart choices outlive the single global display that uses them

styles()
{
    return ["Pulsing", "Pulse Effect", "Type Writer", "Moving", "Fade Effect"];
}

style_reason(value)
{
    if (!isDefined(value) || !isstring(value)
        || !scripts\engine\utility::array_contains(styles(), value))
        return "Choose a valid Doheart style";
    if (value == "Pulse Effect")
        return "The BO3 decode effect has no verified IW7 equivalent";
    if (value == "Type Writer")
        return "The BO3 typewriter effect has no verified IW7 equivalent";
    return "";
}

configuration_reason(text, style)
{
    if (!isDefined(text) || !isstring(text))
        return "Choose valid Doheart text";
    // Empty cleaned host names remain valid source text
    return style_reason(style);
}

text_choices(host_name)
{
    return [scripts\apparition\player_name::clean(host_name), "Apparition", "CF4_99",
        "discord.gg/apparitionbo3", "Custom"];
}

change_reason(configured, text, style, kind, value)
{
    if (!isDefined(kind) || !isstring(kind) || (kind != "text" && kind != "style")
        || !isDefined(value) || !isstring(value))
        return "Choose a valid Doheart text or style selection";
    if (kind == "style")
    {
        denied = style_reason(value);
        if (denied != "")
            return denied;
    }
    previous = kind == "text" ? text : style;
    // An unchanged selection does not recreate the display or repair another field
    if (isDefined(previous) && isstring(previous) && previous == value)
        return "";
    // The Custom selector opens an edit whose submitted text is validated separately
    if (kind == "text" && value == "Custom")
        return configured ? style_reason(style) : "";
    if (configured)
        return configuration_reason(kind == "text" ? value : text,
            kind == "style" ? value : style);
    return "";
}

owns(state, record)
{
    return isDefined(state) && isDefined(record) && isDefined(state.apparition_doheart)
        && state.apparition_doheart == record;
}

initialize(owner)
{
    if (scripts\apparition\features\server\context::reason(owner) != "")
        return false;
    settings = level.apparition_doheart_settings;
    if (isDefined(settings) && !isstruct(settings))
        return false;

    // Capture a missing host default on page entry, never during passive refresh
    text = undefined;
    if (!isDefined(settings) || !isDefined(settings.text))
    {
        host = scripts\apparition\runtime\context::current_host(level);
        if (!isDefined(host))
            return false;
        text = scripts\apparition\player_name::clean(host.name);
    }
    if (!isDefined(settings))
    {
        settings = spawnstruct();
        level.apparition_doheart_settings = settings;
    }
    // Defined values are preserved, including invalid values that need a selection
    if (!isDefined(settings.style))
        settings.style = "Pulsing";
    if (!isDefined(settings.text))
        settings.text = text;
    return true;
}

probe(owner)
{
    result = spawnstruct();
    result.configured = false;
    result.settings_ready = false;
    result.text_values = [];
    result.reason = scripts\apparition\features\server\context::reason(owner);
    if (result.reason != "")
        return result;

    result.configured = isDefined(level.apparition_doheart);
    settings = level.apparition_doheart_settings;
    result.settings_ready = isDefined(settings) && isstruct(settings);
    if (result.settings_ready)
    {
        result.text = settings.text;
        result.style = settings.style;
    }
    // The live host choice can change without recapturing the stored default
    host = scripts\apparition\runtime\context::current_host(level);
    if (isDefined(host))
        result.text_values = text_choices(host.name);
    return result;
}

toggle(owner)
{
    current = probe(owner);
    if (current.reason != "")
        return false;
    // An existing display stays removable even when its saved choices are invalid
    if (current.configured)
    {
        stop(level.apparition_doheart);
        return true;
    }
    if (!current.settings_ready || configuration_reason(current.text, current.style) != "")
        return false;
    record = scripts\apparition\menu\doheart_hud::create(current.text, current.style);
    if (!isDefined(record))
        return false;
    level.apparition_doheart = record;
    level thread run(record, current.style);
    return true;
}

configure(owner, kind, value)
{
    custom = isDefined(kind) && isstring(kind) && kind == "custom_text";
    if (custom)
    {
        if (!scripts\apparition\menu\keyboard_model::valid_text(value))
            return false;
        kind = "text";
    }
    else if (isDefined(kind) && kind == "text" && isDefined(value) && value == "Custom")
        return false;

    current = probe(owner);
    if (current.reason != "" || !current.settings_ready)
        return false;
    if (change_reason(current.configured, current.text, current.style, kind, value) != "")
        return false;
    if (kind == "text" && !custom
        && !scripts\engine\utility::array_contains(current.text_values, value))
        return false;
    text = kind == "text" ? value : current.text;
    style = kind == "style" ? value : current.style;
    // The source does not refresh or rewrite an unchanged selected value
    previous = kind == "text" ? current.text : current.style;
    if (isDefined(previous) && isstring(previous) && previous == value)
        return true;

    record = undefined;
    if (current.configured)
    {
        record = scripts\apparition\menu\doheart_hud::create(text, style);
        if (!isDefined(record))
            return false;
        // Allocation failure leaves both the old display and saved choices intact
        stop(level.apparition_doheart);
    }
    // Off-state edits update only the selected choice and allocate no HUD
    if (kind == "text")
        level.apparition_doheart_settings.text = value;
    else
        level.apparition_doheart_settings.style = value;
    if (current.configured)
    {
        level.apparition_doheart = record;
        level thread run(record, style);
    }
    return true;
}

stop(record)
{
    if (!isDefined(record))
        return;
    if (owns(level, record))
        level.apparition_doheart = undefined;
    scripts\apparition\menu\doheart_hud::destroy_record(record);
    // Destroy the owned handle before notifying a worker that may be this caller
    if (isstruct(record))
        record notify("apparition_stop_doheart");
}

run(record, style)
{
    level endon("game_ended");
    record endon("apparition_stop_doheart");
    while (owns(level, record))
    {
        // This level display survives menu close, player death and host migration
        if (!scripts\apparition\runtime\context::supported()
            || (isDefined(level.gameended) && level.gameended)
            || !scripts\apparition\menu\doheart_hud::cycle(record, style))
        {
            stop(record);
            return;
        }
    }
    stop(record);
}
