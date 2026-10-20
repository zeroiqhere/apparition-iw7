// Keyboard confirmation uses fresh feature admission and the source text alphabet

run()
{
    custom_broadcast_requires_print_bold_and_keeps_the_source_row_position();
    invalid_custom_text_is_rejected_before_native_feature_reads();
    missing_owners_cannot_send_or_save_valid_custom_text();
    doheart_custom_entry_preserves_live_style_admission();
}

custom_broadcast_requires_print_bold_and_keeps_the_source_row_position()
{
    view = spawnstruct();
    view.owner = spawnstruct();
    view.messages = spawnstruct();
    view.messages.reason = "";
    view.messages.mode = "Print Bold";
    view.messages.entries = [];
    rows = scripts\apparition\menu\message_rows::build("Message Menu", view);
    tests\support\checks::expect(rows.size == 4 && rows[1].label == "Custom Message"
        && rows[1].enabled && rows[1].target == view.owner && !rows[1].lobby
        && rows[1].callback == scripts\apparition\menu\actions::open_message_keyboard,
        "The source second message row opens the owner's keyboard for Print Bold");
    tests\support\checks::expect(!isDefined(rows[1].message_text)
        && !isDefined(rows[1].keyboard_callback),
        "The row contains no pretyped text or arbitrary confirmation callback");

    view.messages.mode = "Notify";
    rows = scripts\apparition\menu\message_rows::build("Message Menu", view);
    tests\support\checks::expect(!rows[1].enabled && rows[1].description
        == scripts\apparition\features\messages::delivery_reason("Notify"),
        "Unsupported Notify delivery blocks Custom Message with its actual reason");
    view.messages.reason = "Menu verification is required";
    rows = scripts\apparition\menu\message_rows::build("Message Menu", view);
    tests\support\checks::expect(!rows[1].enabled
        && rows[1].description == view.messages.reason,
        "Actor admission remains first before delivery readiness");
}

invalid_custom_text_is_rejected_before_native_feature_reads()
{
    too_long = "";
    for (index = 0; index < 46; index++)
        too_long += "0";
    foreach (invalid in [undefined, 17, true, [], spawnstruct(), "", "line\nbreak", "~", too_long])
    {
        tests\support\checks::expect(!scripts\apparition\features\messages::send_custom(undefined, invalid),
            "Invalid custom broadcast text cannot reach a native message action");
        tests\support\checks::expect(!scripts\apparition\features\server\doheart::configure(undefined,
            "custom_text", invalid),
            "Invalid custom Doheart text cannot change native display or saved choices");
    }
}

missing_owners_cannot_send_or_save_valid_custom_text()
{
    foreach (text in ["Apparition", "Custom", "Hello World", "^1IW7"])
    {
        tests\support\checks::expect(!scripts\apparition\features\messages::send_custom(undefined, text)
            && !scripts\apparition\features\server\doheart::configure(undefined, "custom_text", text),
            "Valid text still needs a currently admitted owner at confirmation");
    }
}

doheart_custom_entry_preserves_live_style_admission()
{
    tests\support\checks::expect(scripts\apparition\features\server\doheart::change_reason(0,
        undefined, "Pulse Effect", "text", "Custom") == "",
        "An off-state custom edit can repair text without creating an unsupported display");
    tests\support\checks::expect(scripts\apparition\features\server\doheart::change_reason(1,
        "old", "Moving", "text", "Custom") == ""
        && scripts\apparition\features\server\doheart::change_reason(1,
            "old", "Pulse Effect", "text", "Custom") != "",
        "A live custom edit requires a supported current Doheart style");
}
