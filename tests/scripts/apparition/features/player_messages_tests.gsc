// Player-message formatting preserves the source prefix and dispatch rejects invalid keyboard text

run()
{
    format_text_uses_the_cleaned_source_name_and_exact_prefix();
    format_text_does_not_invent_a_name_when_cleanup_is_empty();
    format_text_preserves_keyboard_literal_text();
    send_rejects_invalid_keyboard_text();
    send_rejects_missing_and_nonplayer_owners();
    malformed_routes_reject_before_player_reads();
}

format_text_uses_the_cleaned_source_name_and_exact_prefix()
{
    text = scripts\apparition\features\player_messages::format_text("^1^AHostj=Name^7", "Hello 0?");
    tests\support\checks::expect(text == "^2HostName: ^7Hello 0?",
        "A selected-player message uses the source color prefix and canonical cleaned sender name");
}

format_text_does_not_invent_a_name_when_cleanup_is_empty()
{
    tests\support\checks::expect(scripts\apparition\features\player_messages::format_text("^A^B", "Hi")
        == "^2: ^7Hi",
        "A sender name cleaned to empty stays empty instead of gaining an invented fallback");
    tests\support\checks::expect(scripts\apparition\features\player_messages::format_text(7, "Hi")
        == "^2: ^7Hi",
        "A malformed name follows the canonical cleaner's empty result");
    tests\support\checks::expect(scripts\apparition\features\player_messages::format_text(undefined, "Hi")
        == "^2: ^7Hi",
        "A missing name follows the canonical cleaner's empty result");
}

format_text_preserves_keyboard_literal_text()
{
    text = "ABc=0? .<>$#-{}@/_^[!";
    tests\support\checks::expect(scripts\apparition\features\player_messages::format_text("Sender", text)
        == "^2Sender: ^7" + text,
        "Formatting leaves source-keyboard characters and spaces unchanged");
}

send_rejects_invalid_keyboard_text()
{
    owner = spawnstruct();
    target = spawnstruct();
    forty_five_characters = "";
    for (index = 0; index < 45; index++)
        forty_five_characters += "0";

    foreach (invalid_text in ["", "~", "0\nA", "0\tA", forty_five_characters + "0"])
        tests\support\checks::expect(!scripts\apparition\features\player_messages::send(
            owner, target, invalid_text, false),
            "Empty, unsupported, control-character, and over-limit text cannot be dispatched");

    tests\support\checks::expect(!scripts\apparition\features\player_messages::send(
        owner, target, undefined, false)
        && !scripts\apparition\features\player_messages::send(owner, target, 7, false),
        "Missing and non-string text cannot be dispatched");
}

send_rejects_missing_and_nonplayer_owners()
{
    target = spawnstruct();
    tests\support\checks::expect(!scripts\apparition\features\player_messages::send(
        undefined, target, "Hello 0?", false),
        "A missing owner is rejected before a recipient can receive native output");

    owner = spawnstruct();
    tests\support\checks::expect(!scripts\apparition\features\player_messages::send(
        owner, target, "Hello 0?", false),
        "A non-player owner is rejected before a recipient can receive native output");
}

malformed_routes_reject_before_player_reads()
{
    foreach (invalid_route in ["All", 2, -1, 0.5, spawnstruct()])
        tests\support\checks::expect(!scripts\apparition\features\player_messages::send(
            undefined, undefined, "Hi", invalid_route),
            "Only exact personal and lobby route flags can reach player admission");
    tests\support\checks::expect(!scripts\apparition\features\player_messages::send(
        undefined, undefined, "Hi", undefined),
        "A missing route flag cannot reach player admission");
}
