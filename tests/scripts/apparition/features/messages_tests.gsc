// Message contracts retain source text and mark unsupported delivery paths

run()
{
    display_types_and_default_match_the_source();
    invalid_display_values_remain_unknown();
    configured_rejects_scalar_owners_before_field_reads();
    delivery_reason_only_allows_print_bold();
    miscellaneous_presets_keep_exact_text_and_safe_names();
    missing_names_disable_only_their_dependent_rows();
    advertisement_presets_keep_exact_source_text();
    invalid_pages_return_no_presets();
    probe_accepts_the_root_message_page();
    probe_rejects_missing_or_nonplayer_owners_before_reads();
    display_setting_rejects_unsupported_values_and_nonplayers();
    send_rejects_invalid_requests_without_a_player();
}

display_types_and_default_match_the_source()
{
    types = scripts\apparition\features\messages::types();
    owner = spawnstruct();
    tests\support\checks::expect(types.size == 2
        && types[0] == "Notify" && types[1] == "Print Bold",
        "Display choices retain source order");
    tests\support\checks::expect(scripts\apparition\features\messages::configured(owner) == "Notify",
        "An unset source display setting defaults to Notify");

    owner.MessageDisplay = "Print Bold";
    // Reading a stored choice must not fall back to the source default
    tests\support\checks::expect(scripts\apparition\features\messages::configured(owner) == "Print Bold",
        "The supported source display setting remains selectable");
}

invalid_display_values_remain_unknown()
{
    foreach (value in ["print bold", "Typewriter", "", 7, false, spawnstruct()])
    {
        owner = spawnstruct();
        owner.MessageDisplay = value;
        tests\support\checks::expect(scripts\apparition\features\messages::configured(owner) == "Unknown",
            "Unknown saved display values do not inherit a supported mode");
    }
}

configured_rejects_scalar_owners_before_field_reads()
{
    tests\support\checks::expect(scripts\apparition\features\messages::configured(7) == "Unknown",
        "A scalar owner cannot be read as a settings record");
}

delivery_reason_only_allows_print_bold()
{
    tests\support\checks::expect(scripts\apparition\features\messages::delivery_reason("Print Bold") == "",
        "Print Bold has no delivery block");
    tests\support\checks::expect(scripts\apparition\features\messages::delivery_reason("Notify") != "",
        "Notify explains that its typewriter renderer is unavailable");
    tests\support\checks::expect(scripts\apparition\features\messages::delivery_reason("Unknown") != "",
        "Invalid display settings remain blocked");
}

miscellaneous_presets_keep_exact_text_and_safe_names()
{
    entries = scripts\apparition\features\messages::presets("Miscellaneous Messages", "^APlayer^9", "^BHost^9");
    // Name cleanup affects dynamic text while fixed source wording stays intact
    tests\support\checks::expect(entries.size == 6,
        "The miscellaneous page keeps all six source presets");
    tests\support\checks::expect(find_entry(entries, "want_menu").label == "Want Menu?"
        && find_entry(entries, "want_menu").text == "Want Menu?",
        "The Want Menu preset keeps its exact label and message");
    tests\support\checks::expect(find_entry(entries, "whos_modding").label == "Who's Modding?"
        && find_entry(entries, "whos_modding").text == "Who's Modding?",
        "The Who's Modding preset keeps its exact label and message");
    tests\support\checks::expect(find_entry(entries, "owner_name").label == "Player"
        && find_entry(entries, "owner_name").text == "Player <3",
        "The owner preset uses the cleaned owner name in both fields");
    tests\support\checks::expect(find_entry(entries, "deranked").text == "You've Been ^1Deranked",
        "The Deranked preset retains its source color and text");
    tests\support\checks::expect(find_entry(entries, "vial_icon").label == "BO3 Vial Icon"
        && find_entry(entries, "vial_icon").text == "^BBUTTON_ZM_VIAL_ICON^ ^BBUTTON_ZM_VIAL_ICON^ ^BBUTTON_ZM_VIAL_ICON^"
        && find_entry(entries, "vial_icon").reason != "",
        "The unavailable source vial message keeps its payload while its label avoids unverified glyph syntax");
    tests\support\checks::expect(find_entry(entries, "host").text == "Your Host Today Is Host",
        "The Host preset uses the cleaned native host name");
}

missing_names_disable_only_their_dependent_rows()
{
    entries = scripts\apparition\features\messages::presets("Miscellaneous Messages", "", undefined);
    tests\support\checks::expect(find_entry(entries, "owner_name").label == "Unnamed Player"
        && find_entry(entries, "owner_name").reason != "",
        "An empty owner name uses a safe label and disables its message");
    tests\support\checks::expect(find_entry(entries, "host").reason != "",
        "A missing current host disables only the Host preset");
    tests\support\checks::expect(find_entry(entries, "want_menu").reason == ""
        && find_entry(entries, "deranked").reason == "",
        "Unavailable dynamic names do not block fixed miscellaneous presets");
}

advertisement_presets_keep_exact_source_text()
{
    entries = scripts\apparition\features\messages::presets("Advertisements Messages", "", "");
    tests\support\checks::expect(entries.size == 5,
        "The advertisement page keeps all five source presets");
    tests\support\checks::expect(find_entry(entries, "welcome").text == "Welcome To Apparition",
        "Welcome uses the source menu name");
    tests\support\checks::expect(find_entry(entries, "discord").text == "Discord Server: discord.gg/apparitionbo3",
        "The Discord preset retains its source address");
    tests\support\checks::expect(find_entry(entries, "apparition").label == "Apparition"
        && find_entry(entries, "apparition").text == "Apparition Is The Biggest & Best Menu For BO3 Zombies",
        "The Apparition advertisement keeps its exact source wording");
    tests\support\checks::expect(find_entry(entries, "developer").text == "Apparition Was Developed By CF4_99",
        "The Developer preset retains its source credit");
    tests\support\checks::expect(find_entry(entries, "youtube").text == "YouTube: CF4_99",
        "The YouTube preset retains its source text");
    tests\support\checks::expect(find_entry(entries, "welcome").reason == ""
        && find_entry(entries, "discord").reason == "",
        "Fixed advertisements need no dynamic player names");
}

invalid_pages_return_no_presets()
{
    tests\support\checks::expect(scripts\apparition\features\messages::presets("Other", "Name", "Host").size == 0,
        "Unknown message pages do not return a partial catalog");
    tests\support\checks::expect(scripts\apparition\features\messages::presets(7, "Name", "Host").size == 0,
        "Nonstring message pages are rejected before catalog selection");
}

probe_accepts_the_root_message_page()
{
    root = scripts\apparition\features\messages::probe(undefined, "Message Menu");
    tests\support\checks::expect(root.reason == "Only an admitted player can inspect messages"
        && root.mode == "Unknown" && root.entries.size == 0,
        "The root display-setting page passes route validation before actor admission");

    invalid = scripts\apparition\features\messages::probe(undefined, "Other");
    tests\support\checks::expect(invalid.reason == "Wait for a valid message page",
        "Unrecognized root and preset routes are rejected before actor admission");

    owner = spawnstruct();
    owner.MessageDisplay = "Print Bold";
    rejected = scripts\apparition\features\messages::probe(owner, "Message Menu");
    tests\support\checks::expect(rejected.reason == "Only an admitted player can inspect messages"
        && rejected.mode == "Unknown" && rejected.entries.size == 0,
        "A nonplayer reaches root-route admission but cannot read its setting");
}

probe_rejects_missing_or_nonplayer_owners_before_reads()
{
    missing = scripts\apparition\features\messages::probe(undefined, "Miscellaneous Messages");
    tests\support\checks::expect(missing.reason != "" && missing.mode == "Unknown" && missing.entries.size == 0,
        "A missing owner cannot read settings or message names");

    owner = spawnstruct();
    owner.MessageDisplay = "Print Bold";
    owner.name = "Private Name";
    rejected = scripts\apparition\features\messages::probe(owner, "Miscellaneous Messages");
    tests\support\checks::expect(rejected.reason != "" && rejected.mode == "Unknown" && rejected.entries.size == 0,
        "A struct cannot pass player admission to message inspection");
}

display_setting_rejects_unsupported_values_and_nonplayers()
{
    tests\support\checks::expect(!scripts\apparition\features\messages::set_display(undefined, "Print Bold"),
        "A missing owner cannot change the display setting");

    owner = spawnstruct();
    owner.MessageDisplay = "Notify";
    // Invalid actors never reach the only production setting write
    tests\support\checks::expect(!scripts\apparition\features\messages::set_display(owner, "Notify")
        && owner.MessageDisplay == "Notify",
        "The unsupported typewriter setting is never written");
    tests\support\checks::expect(!scripts\apparition\features\messages::set_display(owner, "Other")
        && owner.MessageDisplay == "Notify",
        "Unknown display choices leave the saved setting untouched");
    tests\support\checks::expect(!scripts\apparition\features\messages::set_display(owner, "Print Bold")
        && owner.MessageDisplay == "Notify",
        "A nonplayer cannot change message delivery settings");
}

send_rejects_invalid_requests_without_a_player()
{
    tests\support\checks::expect(!scripts\apparition\features\messages::send(undefined, "Miscellaneous Messages", "want_menu"),
        "A missing actor cannot request a preset");
    owner = spawnstruct();
    // Rejected requests avoid the native message command entirely
    tests\support\checks::expect(!scripts\apparition\features\messages::send(owner, "Miscellaneous Messages", "unknown"),
        "An unknown preset ID cannot request a message");
    tests\support\checks::expect(!scripts\apparition\features\messages::send(owner, "Other", "want_menu"),
        "An invalid page is rejected before actor access");
    tests\support\checks::expect(!scripts\apparition\features\messages::send(owner, "Advertisements Messages", "welcome"),
        "A nonplayer cannot request a native global message");
}

find_entry(entries, id)
{
    foreach (item in entries)
    {
        if (item.id == id)
            return item;
    }
    return spawnstruct();
}
