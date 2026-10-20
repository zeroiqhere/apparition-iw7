// Doheart rows preserve saved settings while exposing only source-backed choices

run()
{
    model_route_exposes_the_three_global_controls_and_fixed_previews();
    cohosts_can_manage_global_doheart_while_vips_cannot();
    a_configured_setting_can_be_cleared_and_bad_fields_can_be_repaired();
    settings_unready_keeps_an_active_toggle_clearable_only();
    shared_configuration_rules_block_unsupported_choices();
    missing_text_catalog_blocks_only_the_text_slider();
    malformed_snapshots_stay_disabled_and_unchecked();
    rendering_does_not_mutate_settings_or_copy_native_payloads();
}

model_route_exposes_the_three_global_controls_and_fixed_previews()
{
    view = view_fixture("Host", 0, "CF4_99", "Moving", 1);
    rows = scripts\apparition\menu\model::build("Doheart Options", view);

    tests\support\checks::expect(isDefined(rows) && isarray(rows) && rows.size == 3,
        "The Doheart page exposes exactly its toggle, text, and style controls");
    if (!isDefined(rows) || !isarray(rows) || rows.size != 3)
        return;

    toggle = rows[0];
    text = rows[1];
    style = rows[2];
    tests\support\checks::expect(toggle.label == "Doheart" && toggle.kind == "toggle"
        && toggle.callback == scripts\apparition\menu\actions::toggle_doheart
        && toggle.lobby && !isDefined(toggle.target) && toggle.enabled && !toggle.checked,
        "Doheart is a global toggle with no selected-player target");
    tests\support\checks::expect(text.label == "Text" && text.kind == "slider"
        && text.callback == scripts\apparition\menu\actions::configure_doheart
        && text.setting == "text" && text.lobby && !isDefined(text.target)
        && text.enabled && text.initial_index == 0
        && isSubStr(scripts\apparition\menu\availability::description(text, text.values[0]),
            "Saved text: CF4_99; "),
        "Text previews begin at the source first choice while showing saved text in the rendered description");
    tests\support\checks::expect(style.label == "Style" && style.kind == "slider"
        && style.callback == scripts\apparition\menu\actions::configure_doheart
        && style.setting == "style" && style.lobby && !isDefined(style.target)
        && style.enabled && style.initial_index == 0
        && isSubStr(scripts\apparition\menu\availability::description(style, style.values[0]),
            "Saved style: Moving; "),
        "Style previews begin at the source first choice while showing saved style in the rendered description");

    expected_text = ["HostName", "Apparition", "CF4_99", "discord.gg/apparitionbo3", "Custom"];
    expected_styles = ["Pulsing", "Pulse Effect", "Type Writer", "Moving", "Fade Effect"];
    tests\support\checks::expect(text.values.size == expected_text.size
        && style.values.size == expected_styles.size,
        "Both controls retain the five source choices");
    if (text.values.size != expected_text.size || style.values.size != expected_styles.size)
        return;
    for (index = 0; index < expected_text.size; index++)
    {
        tests\support\checks::expect(text.values[index] == expected_text[index],
            "The text control keeps its dynamic host choice and fixed source order");
        tests\support\checks::expect(style.values[index] == expected_styles[index],
            "The style control keeps the source order, including unsupported styles");
    }
}

cohosts_can_manage_global_doheart_while_vips_cannot()
{
    view = view_fixture("Co-Host", 0, "Apparition", "Pulsing", 1);
    view.host = false;
    rows = scripts\apparition\menu\model::build("Doheart Options", view);
    tests\support\checks::expect(rows.size == 3 && rows[0].enabled
        && rows[1].enabled && rows[2].enabled,
        "Co-Host role can manage Doheart without being the native host");

    // The saved role, rather than native host identity, controls this global page
    view = view_fixture("VIP", 1, "Apparition", "Pulsing", 1);
    view.host = true;
    view.doheart.reason = "Snapshot state must not cross the role gate";
    rows = scripts\apparition\menu\model::build("Doheart Options", view);
    tests\support\checks::expect(rows.size == 3 && !rows[0].enabled && !rows[0].checked
        && !rows[1].enabled && !rows[2].enabled,
        "A VIP cannot manage global Doheart even when host identity is set in the view");
    tests\support\checks::expect(rows[0].description != view.doheart.reason,
        "Role denial precedes the Doheart snapshot reason");
}

a_configured_setting_can_be_cleared_and_bad_fields_can_be_repaired()
{
    view = view_fixture("Host", 1, "Apparition", "Pulse Effect", 1);
    rows = scripts\apparition\menu\model::build("Doheart Options", view);
    toggle = rows[0];
    text = rows[1];
    style = rows[2];

    tests\support\checks::expect(toggle.checked && toggle.enabled,
        "A configured Doheart remains available to turn off when its saved style is unsupported");
    tests\support\checks::expect(text.enabled
        && isSubStr(scripts\apparition\menu\availability::description(text, "Apparition"),
            "Saved text: Apparition; ")
        && scripts\apparition\menu\availability::choice_reason(text, "Apparition") == ""
        && scripts\apparition\menu\availability::choice_reason(text, "CF4_99") != "",
        "The selected text remains a no-op while changed text cannot preserve an unsupported active style");
    tests\support\checks::expect(style.enabled
        && isSubStr(scripts\apparition\menu\availability::description(style, "Pulsing"),
            "Saved style: Pulse Effect; ")
        && scripts\apparition\menu\availability::choice_reason(style, "Pulsing") == ""
        && scripts\apparition\menu\availability::choice_reason(style, "Moving") == ""
        && scripts\apparition\menu\availability::choice_reason(style, "Fade Effect") == "",
        "Supported style choices can repair an unsupported configured style");

    view = view_fixture("Host", 1, undefined, "Moving", 1);
    rows = scripts\apparition\menu\model::build("Doheart Options", view);
    tests\support\checks::expect(rows[0].checked && rows[0].enabled
        && rows[1].enabled
        && isSubStr(scripts\apparition\menu\availability::description(rows[1], "Apparition"),
            "Saved text: Unknown; "),
        "A configured Doheart with missing text stays clearable and exposes text repair choices");
    tests\support\checks::expect(rows[2].enabled
        && isSubStr(scripts\apparition\menu\availability::description(rows[2], "Moving"),
            "Saved style: Moving; ")
        && scripts\apparition\menu\availability::choice_reason(rows[2], "Moving") == ""
        && scripts\apparition\menu\availability::choice_reason(rows[2], "Pulsing") != "",
        "The selected style remains a no-op while changed styles cannot preserve missing text");

    view = view_fixture("Host", 0, undefined, "Moving", 1);
    rows = scripts\apparition\menu\model::build("Doheart Options", view);
    tests\support\checks::expect(!rows[0].checked && !rows[0].enabled
        && rows[1].enabled && !rows[2].enabled,
        "An invalid off configuration cannot start until its text is repaired");
}

settings_unready_keeps_an_active_toggle_clearable_only()
{
    view = view_fixture("Host", 1, "Apparition", "Pulsing", 0);
    rows = scripts\apparition\menu\model::build("Doheart Options", view);
    tests\support\checks::expect(rows[0].checked && rows[0].enabled
        && !rows[1].enabled && !rows[2].enabled,
        "An active Doheart remains clearable while saved settings are unavailable");

    view.doheart.configured = 0;
    rows = scripts\apparition\menu\model::build("Doheart Options", view);
    tests\support\checks::expect(!rows[0].enabled && !rows[0].checked
        && !rows[1].enabled && !rows[2].enabled,
        "Unavailable saved settings cannot start Doheart or accept new configuration");
}

shared_configuration_rules_block_unsupported_choices()
{
    view = view_fixture("Host", 0, "CF4_99", "Moving", 1);
    rows = scripts\apparition\menu\model::build("Doheart Options", view);
    text = rows[1];
    style = rows[2];

    tests\support\checks::expect(scripts\apparition\menu\availability::choice_reason(text, "HostName") == ""
        && scripts\apparition\menu\availability::choice_reason(text, "Apparition") == ""
        && scripts\apparition\menu\availability::choice_reason(text, "CF4_99") == ""
        && scripts\apparition\menu\availability::choice_reason(text, "discord.gg/apparitionbo3") == "",
        "Supported text choices pass the shared configuration guard");
    tests\support\checks::expect(scripts\apparition\menu\availability::choice_reason(text, "Custom") == "",
        "Custom text opens the source keyboard flow");
    tests\support\checks::expect(scripts\apparition\menu\availability::choice_reason(style, "Pulsing") == ""
        && scripts\apparition\menu\availability::choice_reason(style, "Moving") == ""
        && scripts\apparition\menu\availability::choice_reason(style, "Fade Effect") == "",
        "The supported styles remain selectable");
    tests\support\checks::expect(scripts\apparition\menu\availability::choice_reason(style, "Pulse Effect") != ""
        && scripts\apparition\menu\availability::choice_reason(style, "Type Writer") != "",
        "Both unverified effect styles remain visible but blocked");

    view.doheart.style = "Pulse Effect";
    view.doheart.configured = 1;
    rows = scripts\apparition\menu\model::build("Doheart Options", view);
    tests\support\checks::expect(rows[1].enabled
        && scripts\apparition\menu\availability::choice_reason(rows[1], "CF4_99") == ""
        && scripts\apparition\menu\availability::choice_reason(rows[1], "HostName") != "",
        "Only the selected text no-op bypasses an unsupported active style");
}

missing_text_catalog_blocks_only_the_text_slider()
{
    view = view_fixture("Host", 0, "Apparition", "Moving", 1);
    view.doheart.text_values = undefined;
    rows = scripts\apparition\menu\model::build("Doheart Options", view);
    tests\support\checks::expect(rows[0].enabled && rows[2].enabled
        && !rows[1].enabled
        && isSubStr(rows[1].description, "Saved text: Apparition; ")
        && isSubStr(rows[1].description, "Wait for the current host's text choices"),
        "Missing host choices keep saved text visible and disable only the text slider");

    view.doheart.text_values = "malformed";
    rows = scripts\apparition\menu\model::build("Doheart Options", view);
    tests\support\checks::expect(rows[0].enabled && rows[2].enabled && !rows[1].enabled,
        "A malformed host choice catalog does not block independent controls");

    values = ["HostName", "Apparition", "CF4_99", "discord.gg/apparitionbo3", "Custom"];
    values[2] = undefined;
    view.doheart.text_values = values;
    rows = scripts\apparition\menu\model::build("Doheart Options", view);
    tests\support\checks::expect(rows[0].enabled && rows[2].enabled && !rows[1].enabled,
        "A hole in the host choice catalog disables the text slider without blocking other controls");
}

malformed_snapshots_stay_disabled_and_unchecked()
{
    view = view_fixture("Host", 1, "Apparition", "Pulsing", 1);
    view.doheart = undefined;
    expect_pending_rows(view, "A missing Doheart snapshot keeps every control disabled");

    view.doheart = 17;
    expect_pending_rows(view, "A nonstruct Doheart snapshot cannot enable controls");

    view = view_fixture("Host", 1, "Apparition", "Pulsing", 1);
    view.doheart.reason = undefined;
    expect_pending_rows(view, "A missing Doheart authorization reason fails closed");
    view = view_fixture("Host", 1, "Apparition", "Pulsing", 1);
    view.doheart.reason = 17;
    expect_pending_rows(view, "A nonstring Doheart authorization reason fails closed");
    view = view_fixture("Host", 1, "Apparition", "Pulsing", 1);
    view.doheart.configured = 2;
    expect_pending_rows(view, "A nonbinary configured flag fails closed");
    view = view_fixture("Host", 1, "Apparition", "Pulsing", 1);
    view.doheart.settings_ready = undefined;
    expect_pending_rows(view, "A missing settings readiness flag fails closed");
    view = view_fixture("Host", 1, "Apparition", "Pulsing", 1);
    view.doheart.settings_ready = 2;
    expect_pending_rows(view, "A nonbinary settings readiness flag fails closed");

    view = view_fixture("Host", 1, "Apparition", "Pulsing", 1);
    view.doheart.reason = "Native Doheart state is unavailable";
    rows = scripts\apparition\menu\model::build("Doheart Options", view);
    tests\support\checks::expect(!rows[0].enabled && !rows[0].checked
        && !rows[1].enabled && !rows[2].enabled,
        "Provider denial hides configured state and disables every Doheart control");
}

rendering_does_not_mutate_settings_or_copy_native_payloads()
{
    view = view_fixture("Co-Host", 0, "CF4_99", "Moving", 1);
    snapshot = view.doheart;
    rows = scripts\apparition\menu\model::build("Doheart Options", view);

    tests\support\checks::expect(view.doheart == snapshot && snapshot.reason == ""
        && snapshot.configured == 0 && snapshot.settings_ready == 1
        && snapshot.text == "CF4_99" && snapshot.style == "Moving"
        && snapshot.text_values[2] == "CF4_99",
        "Building rows leaves the captured Doheart settings unchanged");
    foreach (row in rows)
        tests\support\checks::expect(!isDefined(row.target) && row.lobby
            && !isDefined(row.record) && !isDefined(row.worker) && !isDefined(row.handles)
            && !isDefined(row.hud) && !isDefined(row.players) && !isDefined(row.owner),
            "Doheart rows carry no actor, worker, or native HUD payload");
}

expect_pending_rows(view, message)
{
    rows = scripts\apparition\menu\model::build("Doheart Options", view);
    tests\support\checks::expect(rows.size == 3 && !rows[0].enabled && !rows[0].checked
        && !rows[1].enabled && !rows[2].enabled,
        message);
}

view_fixture(access, configured, text, style, settings_ready)
{
    view = spawnstruct();
    view.access = access;
    view.host = access == "Host";
    view.doheart = spawnstruct();
    view.doheart.reason = "";
    view.doheart.configured = configured;
    view.doheart.settings_ready = settings_ready;
    view.doheart.text = text;
    view.doheart.style = style;
    view.doheart.text_values = ["HostName", "Apparition", "CF4_99",
        "discord.gg/apparitionbo3", "Custom"];
    return view;
}
