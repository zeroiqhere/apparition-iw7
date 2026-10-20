// Message controls retain source order while exposing only supported delivery

run()
{
    the_verified_main_link_opens_messages_for_the_owner();
    the_root_keeps_source_order_and_separate_preview_and_configuration();
    notify_is_visible_but_cannot_be_selected();
    preset_rows_use_stable_ids_and_the_owner_scope();
    notify_blocks_broadcasts_without_hiding_the_presets();
    source_only_icons_and_missing_host_names_stay_unavailable();
    missing_and_malformed_snapshots_cannot_enable_messages();
    renamed_owner_rows_keep_their_selected_preset();
    an_actor_rejection_precedes_the_display_type_reason();
}

the_verified_main_link_opens_messages_for_the_owner()
{
    view = ready_view("Message Menu", "Notify");
    view.access = "Verified";
    view.host = false;
    rows = scripts\apparition\menu\main_rows::build(view);
    tests\support\checks::expect(rows.size == 4 && rows[2].label == "Message Menu"
        && rows[2].destination == "Message Menu" && rows[2].enabled
        && rows[2].target == view.owner && !rows[2].lobby,
        "A verified guest opens their own message controls at the source main position");
}

the_root_keeps_source_order_and_separate_preview_and_configuration()
{
    view = ready_view("Message Menu", "Notify");
    rows = scripts\apparition\menu\model::build("Message Menu", view);
    tests\support\checks::expect(rows.size == 4 && rows[0].label == "Display Type"
        && rows[1].label == "Custom Message" && rows[2].label == "Miscellaneous"
        && rows[3].label == "Advertisements", "The root retains all four source controls in order");
    row = rows[0];
    tests\support\checks::expect(row.kind == "slider" && row.enabled && row.initial_index == 0
        && row.active_value == "Notify" && row.values.size == 2
        && row.values[0] == "Notify" && row.values[1] == "Print Bold"
        && row.target == view.owner && !row.lobby
        && row.callback == scripts\apparition\menu\actions::set_message_display,
        "The default configured Notify remains distinct from the preview choice");
    tests\support\checks::expect(!rows[1].enabled
        && rows[1].callback == scripts\apparition\menu\actions::open_message_keyboard
        && rows[2].destination == "Miscellaneous Messages"
        && rows[3].destination == "Advertisements Messages"
        && rows[2].target == view.owner && rows[3].target == view.owner,
        "Notify blocks custom delivery while keyboard and preset navigation remain owner scoped");
    state = scripts\apparition\menu\state::create(view.owner);
    state.page = "Message Menu";
    // Slider navigation changes the session preview rather than the feature setting
    scripts\apparition\menu\state::adjust_slider(state, row, 1);
    tests\support\checks::expect(scripts\apparition\menu\state::slider_value(state, row) == "Print Bold"
        && row.active_value == "Notify" && view.messages.mode == "Notify",
        "Previewing bold text does not change the saved delivery mode or snapshot");
}

notify_is_visible_but_cannot_be_selected()
{
    rows = scripts\apparition\menu\message_rows::build("Message Menu", ready_view("Message Menu", "Print Bold"));
    row = rows[0];
    tests\support\checks::expect(scripts\apparition\menu\availability::choice_reason(row, "Notify") != ""
        && !scripts\apparition\menu\dispatch::can_start(row, false, "Notify")
        && scripts\apparition\menu\dispatch::can_start(row, false, "Print Bold"),
        "The same choice contract blocks Notify and permits the supported bold setting");
    tests\support\checks::expect(scripts\apparition\menu\availability::description(row, "Notify")
        == scripts\apparition\features\messages::delivery_reason("Notify"),
        "The unavailable preview footer explains the same binding gap as dispatch");
}

preset_rows_use_stable_ids_and_the_owner_scope()
{
    view = ready_view("Miscellaneous Messages", "Print Bold");
    rows = scripts\apparition\menu\model::build("Miscellaneous Messages", view);
    tests\support\checks::expect(rows.size == 6 && rows[0].label == "Want Menu?"
        && rows[1].label == "Who's Modding?" && rows[2].label == "Guest"
        && rows[3].label == "Deranked" && rows[5].label == "Host",
        "Miscellaneous presets retain the source order and cleaned owner label");
    tests\support\checks::expect(rows[0].message_id == "want_menu"
        && rows[0].message_page == "Miscellaneous Messages"
        && rows[0].selection_key == "want_menu" && rows[0].target == view.owner
        && !rows[0].lobby && rows[0].enabled
        && rows[0].callback == scripts\apparition\menu\actions::send_message_preset,
        "A supported preset carries a stable selector for fresh resolution at dispatch");
    tests\support\checks::expect(!isDefined(rows[0].text) && !isDefined(rows[0].message)
        && !isDefined(rows[0].active_value),
        "Rows retain neither cached message text nor a false active-mode claim");
    tests\support\checks::expect(isSubStr(rows[3].description, "Text announcement only"),
        "The source Deranked preset explains that it sends text without changing a profile");
    view = ready_view("Advertisements Messages", "Print Bold");
    rows = scripts\apparition\menu\model::build("Advertisements Messages", view);
    tests\support\checks::expect(rows.size == 5 && rows[0].label == "Welcome"
        && rows[1].label == "Discord Server" && rows[2].label == "Apparition"
        && rows[3].label == "Developer" && rows[4].label == "YouTube"
        && rows[2].enabled, "Advertisements retain the five original source presets");
    tests\support\checks::expect(isSubStr(rows[2].description, "BO3"),
        "The original BO3 advertisement wording is disclosed before sending");
}

notify_blocks_broadcasts_without_hiding_the_presets()
{
    view = ready_view("Miscellaneous Messages", "Notify");
    rows = scripts\apparition\menu\message_rows::build("Miscellaneous Messages", view);
    foreach (row in rows)
        tests\support\checks::expect(!row.enabled
            && !scripts\apparition\menu\dispatch::can_start(row, false),
            "The default unbound Notify mode cannot silently fall back to bold text");
    tests\support\checks::expect(rows[0].description == scripts\apparition\features\messages::delivery_reason("Notify"),
        "A blocked preset explains the configured delivery limitation");
}

source_only_icons_and_missing_host_names_stay_unavailable()
{
    view = ready_view("Miscellaneous Messages", "Print Bold");
    view.messages.entries = scripts\apparition\features\messages::presets("Miscellaneous Messages", "Guest", undefined);
    rows = scripts\apparition\menu\message_rows::build("Miscellaneous Messages", view);
    tests\support\checks::expect(rows[0].enabled && !rows[4].enabled && !rows[5].enabled
        && rows[4].description != "" && rows[5].description != "",
        "An unsupported icon or missing native host blocks only its own preset");
    tests\support\checks::expect(rows[4].label == "BO3 Vial Icon" && !isSubStr(rows[4].label, "^B"),
        "The disabled icon row sends a readable label rather than BO3 glyph syntax to the native HUD");
}

missing_and_malformed_snapshots_cannot_enable_messages()
{
    view = ready_view("Message Menu", "Print Bold");
    foreach (bad in [7, "ready", [], spawnstruct()])
    {
        view.messages = bad;
        rows = scripts\apparition\menu\message_rows::build("Message Menu", view);
        tests\support\checks::expect(!rows[0].enabled && !rows[2].enabled && !rows[3].enabled,
            "An incomplete snapshot cannot enable settings or preset navigation");
    }
    view.messages = undefined;
    rows = scripts\apparition\menu\message_rows::build("Miscellaneous Messages", view);
    tests\support\checks::expect(rows.size == 1 && !rows[0].enabled && !isDefined(rows[0].callback),
        "A missing preset snapshot displays one inert explanation");
    view = ready_view("Miscellaneous Messages", "Print Bold");
    view.messages.entries[0].reason = 7;
    rows = scripts\apparition\menu\message_rows::build("Miscellaneous Messages", view);
    tests\support\checks::expect(rows.size == 1 && !rows[0].enabled,
        "A nonstring entry reason cannot enable a broadcast");
    view = ready_view("Miscellaneous Messages", "Print Bold");
    view.messages.entries[1].id = "want_menu";
    // A copied command ID cannot borrow another visible row's meaning
    rows = scripts\apparition\menu\message_rows::build("Miscellaneous Messages", view);
    tests\support\checks::expect(rows.size == 1 && !rows[0].enabled,
        "A duplicate or misplaced preset ID cannot inherit another entry's visible readiness");
    view = ready_view("Miscellaneous Messages", "Print Bold");
    view.messages.mode = 7;
    rows = scripts\apparition\menu\message_rows::build("Miscellaneous Messages", view);
    tests\support\checks::expect(rows.size == 1 && !rows[0].enabled,
        "An untyped delivery setting cannot enable preset selection");
    view = ready_view("Miscellaneous Messages", "Print Bold");
    view.messages.entries[0].label = "Host";
    rows = scripts\apparition\menu\message_rows::build("Miscellaneous Messages", view);
    tests\support\checks::expect(rows.size == 1 && !rows[0].enabled,
        "A fixed label cannot describe a different command than its stable preset ID");
}

renamed_owner_rows_keep_their_selected_preset()
{
    view = ready_view("Miscellaneous Messages", "Print Bold");
    previous = scripts\apparition\menu\message_rows::build("Miscellaneous Messages", view)[2];
    state = scripts\apparition\menu\state::create(view.owner);
    state.page = "Miscellaneous Messages";
    state.cursors[state.page] = 2;
    view.messages.entries = scripts\apparition\features\messages::presets(state.page, "Renamed Guest", "Host");
    rows = scripts\apparition\menu\message_rows::build(state.page, view);
    tests\support\checks::expect(rows[2].label == "Renamed Guest"
        && scripts\apparition\menu\state::cursor_after_rebuild(state, rows,
            previous.label, previous.target, previous.selection_key) == 2,
        "A fresh owner name changes the label without redirecting the selected preset");
}

an_actor_rejection_precedes_the_display_type_reason()
{
    view = ready_view("Miscellaneous Messages", "Notify");
    view.messages.reason = "The original menu grant was revoked";
    rows = scripts\apparition\menu\message_rows::build("Miscellaneous Messages", view);
    tests\support\checks::expect(!rows[0].enabled
        && rows[0].description == "The original menu grant was revoked",
        "An actor or access rejection remains ahead of unavailable delivery details");
    view.messages.entries = [];
    // Admission can reject before any player-name catalog is safe to produce
    rows = scripts\apparition\menu\message_rows::build("Miscellaneous Messages", view);
    tests\support\checks::expect(rows.size == 1 && !rows[0].enabled
        && rows[0].description == "The original menu grant was revoked",
        "A rejected probe needs no player-name catalog to preserve its real denial reason");
}

ready_view(page, mode)
{
    view = spawnstruct();
    view.owner = spawnstruct();
    view.target = spawnstruct();
    view.messages = spawnstruct();
    view.messages.reason = "";
    view.messages.mode = mode;
    view.messages.entries = scripts\apparition\features\messages::presets(page, "^2Guest", "^1Host");
    return view;
}
