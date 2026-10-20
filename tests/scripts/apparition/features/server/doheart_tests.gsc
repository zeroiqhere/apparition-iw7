// Pure Doheart contracts and denied provider calls avoid starting a worker

run()
{
    style_catalog_preserves_all_source_choices_and_supported_subset();
    change_reason_allows_only_safe_selected_choice_transitions();
    text_choices_clean_the_host_without_deduplicating_source_entries();
    only_the_current_level_record_owns_the_doheart_worker();
    invalid_requesters_receive_denied_defaults_without_configuration_changes();
}

change_reason_allows_only_safe_selected_choice_transitions()
{
    tests\support\checks::expect(scripts\apparition\features\server\doheart::change_reason(0, "Apparition", "Pulsing", "text", "CF4_99") == ""
        && scripts\apparition\features\server\doheart::change_reason(0, "Apparition", "Pulsing", "style", "Moving") == "",
        "A valid changed choice can be stored while Doheart is off");
    tests\support\checks::expect(scripts\apparition\features\server\doheart::change_reason(1, "Apparition", "Pulsing", "text", "CF4_99") == ""
        && scripts\apparition\features\server\doheart::change_reason(1, "Apparition", "Pulsing", "style", "Moving") == "",
        "A valid live text or style change remains available");

    tests\support\checks::expect(scripts\apparition\features\server\doheart::change_reason(1, "Apparition", "Pulse Effect", "text", "Apparition") == "",
        "Reapplying the selected text remains a safe no-op with an unsupported other setting");
    tests\support\checks::expect(scripts\apparition\features\server\doheart::change_reason(1, undefined, "Moving", "style", "Moving") == "",
        "Reapplying the selected style remains a safe no-op with missing other text");
    tests\support\checks::expect(scripts\apparition\features\server\doheart::change_reason(0, undefined, "Pulse Effect", "text", "Apparition") == ""
        && scripts\apparition\features\server\doheart::change_reason(0, undefined, "Pulsing", "style", "Moving") == "",
        "Off-state changes remain available to repair an invalid other setting");

    tests\support\checks::expect(scripts\apparition\features\server\doheart::change_reason(1, "Apparition", "Pulse Effect", "text", "CF4_99") != ""
        && scripts\apparition\features\server\doheart::change_reason(1, undefined, "Moving", "style", "Pulsing") != "",
        "A live changed choice cannot preserve an invalid other setting");
    tests\support\checks::expect(scripts\apparition\features\server\doheart::change_reason(0, "Apparition", "Pulsing", "text", "Custom") == ""
        && scripts\apparition\features\server\doheart::change_reason(0, "Apparition", "Pulsing", "style", "Pulse Effect") != "",
        "Custom opens the keyboard while unsupported styles stay blocked even while off");
    tests\support\checks::expect(scripts\apparition\features\server\doheart::change_reason(0, "Apparition", "Pulsing", "Text", "CF4_99") != ""
        && scripts\apparition\features\server\doheart::change_reason(0, "Apparition", "Pulsing", "style", undefined) != ""
        && scripts\apparition\features\server\doheart::change_reason(0, "Apparition", "Pulsing", "style", 17) != "",
        "Unknown kinds and missing or nonstring values are rejected");
}

style_catalog_preserves_all_source_choices_and_supported_subset()
{
    styles = scripts\apparition\features\server\doheart::styles();
    expected = ["Pulsing", "Pulse Effect", "Type Writer", "Moving", "Fade Effect"];

    tests\support\checks::expect(isDefined(styles) && isarray(styles)
        && styles.size == expected.size,
        "Doheart retains five source-ordered style choices");
    if (!isDefined(styles) || !isarray(styles) || styles.size != expected.size)
        return;
    for (index = 0; index < expected.size; index++)
        tests\support\checks::expect(styles[index] == expected[index],
            "Doheart style order remains stable");

    tests\support\checks::expect(scripts\apparition\features\server\doheart::style_reason("Pulsing") == ""
        && scripts\apparition\features\server\doheart::style_reason("Moving") == ""
        && scripts\apparition\features\server\doheart::style_reason("Fade Effect") == "",
        "Pulsing, Moving, and Fade Effect are the supported styles");
    tests\support\checks::expect(scripts\apparition\features\server\doheart::style_reason("Pulse Effect") != ""
        && scripts\apparition\features\server\doheart::style_reason("Type Writer") != "",
        "Styles without a verified IW7 effect remain unavailable");
    tests\support\checks::expect(scripts\apparition\features\server\doheart::style_reason(undefined) != ""
        && scripts\apparition\features\server\doheart::style_reason(17) != ""
        && scripts\apparition\features\server\doheart::style_reason("Unknown") != "",
        "Missing, nonstring, and unknown styles are rejected");
    tests\support\checks::expect(scripts\apparition\features\server\doheart::configuration_reason("", "Pulsing") == ""
        && scripts\apparition\features\server\doheart::configuration_reason("Apparition", "Moving") == "",
        "Empty display text and supported styles form a valid configuration");
    tests\support\checks::expect(scripts\apparition\features\server\doheart::configuration_reason(undefined, "Pulsing") != ""
        && scripts\apparition\features\server\doheart::configuration_reason(17, "Moving") != ""
        && scripts\apparition\features\server\doheart::configuration_reason("Apparition", "Type Writer") != "",
        "Malformed text and unsupported styles are rejected as configuration");
}

text_choices_clean_the_host_without_deduplicating_source_entries()
{
    choices = scripts\apparition\features\server\doheart::text_choices("^AHost^9Name");
    expected = ["HostName", "Apparition", "CF4_99", "discord.gg/apparitionbo3", "Custom"];

    tests\support\checks::expect(isDefined(choices) && isarray(choices)
        && choices.size == expected.size,
        "Doheart keeps the cleaned host and four fixed text choices");
    if (!isDefined(choices) || !isarray(choices) || choices.size != expected.size)
        return;
    for (index = 0; index < expected.size; index++)
        tests\support\checks::expect(choices[index] == expected[index],
            "Doheart text choice order and host cleanup remain stable");

    choices = scripts\apparition\features\server\doheart::text_choices("^A^9");
    tests\support\checks::expect(isDefined(choices) && choices.size == 5 && choices[0] == "",
        "An empty cleaned host name remains a source choice");
    choices = scripts\apparition\features\server\doheart::text_choices("Apparition");
    tests\support\checks::expect(choices.size == 5 && choices[0] == choices[1],
        "A host name matching a fixed choice is not silently deduplicated");
}

only_the_current_level_record_owns_the_doheart_worker()
{
    state = spawnstruct();
    current = spawnstruct();
    replacement = spawnstruct();

    tests\support\checks::expect(!scripts\apparition\features\server\doheart::owns(undefined, current)
        && !scripts\apparition\features\server\doheart::owns(state, undefined),
        "Missing state or record cannot own Doheart");
    state.apparition_doheart = current;
    tests\support\checks::expect(scripts\apparition\features\server\doheart::owns(state, current)
        && !scripts\apparition\features\server\doheart::owns(state, replacement),
        "Only the currently published Doheart record owns the worker");
    state.apparition_doheart = replacement;
    tests\support\checks::expect(!scripts\apparition\features\server\doheart::owns(state, current)
        && scripts\apparition\features\server\doheart::owns(state, replacement),
        "Publishing a replacement retires the previous Doheart owner");
    state.apparition_doheart = undefined;
    tests\support\checks::expect(!scripts\apparition\features\server\doheart::owns(state, replacement),
        "Clearing the Doheart record retires its owner");
}

invalid_requesters_receive_denied_defaults_without_configuration_changes()
{
    before = level.apparition_doheart_settings;
    before_struct = isDefined(before) && isstruct(before);
    before_text = undefined;
    before_style = undefined;
    if (before_struct)
    {
        before_text = before.text;
        before_style = before.style;
    }

    missing = scripts\apparition\features\server\doheart::probe(undefined);
    tests\support\checks::expect(isDefined(missing.reason) && isstring(missing.reason)
        && missing.reason != "" && missing.configured == 0
        && missing.settings_ready == 0
        && !isDefined(missing.text) && !isDefined(missing.style)
        && isDefined(missing.text_values) && isarray(missing.text_values)
        && missing.text_values.size == 0,
        "A missing requester receives denied defaults without configuration data");

    requester = spawnstruct();
    invalid = scripts\apparition\features\server\doheart::probe(requester);
    tests\support\checks::expect(isDefined(invalid.reason) && invalid.reason != ""
        && invalid.configured == 0 && invalid.settings_ready == 0
        && !isDefined(invalid.text) && !isDefined(invalid.style)
        && invalid.text_values.size == 0,
        "A nonplayer requester cannot read Doheart settings");

    tests\support\checks::expect(!scripts\apparition\features\server\doheart::initialize(undefined)
        && !scripts\apparition\features\server\doheart::initialize(requester)
        && !scripts\apparition\features\server\doheart::toggle(undefined)
        && !scripts\apparition\features\server\doheart::toggle(requester),
        "Invalid requesters cannot initialize or toggle Doheart");
    tests\support\checks::expect(!scripts\apparition\features\server\doheart::configure(undefined, "style", "Pulsing")
        && !scripts\apparition\features\server\doheart::configure(requester, "text", "Apparition"),
        "Invalid requesters cannot configure Doheart text or style");
    after = level.apparition_doheart_settings;
    unchanged = false;
    if (isDefined(after) == isDefined(before))
    {
        unchanged = true;
        if (before_struct)
        {
            unchanged = isDefined(after) && isstruct(after);
            if (unchanged)
                unchanged = same_optional_setting(before_text, after.text)
                    && same_optional_setting(before_style, after.style);
        }
    }
    tests\support\checks::expect(unchanged,
        "Denied requests leave level Doheart settings unchanged");
}

same_optional_setting(before, after)
{
    if (isDefined(before) != isDefined(after))
        return false;
    if (!isDefined(before))
        return true;
    if (isstring(before) != isstring(after))
        return false;
    if (isstring(before))
        return before == after;
    return true;
}
