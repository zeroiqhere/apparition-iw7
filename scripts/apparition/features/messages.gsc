// Message presets retain source text while disabling unsupported delivery paths

types()
{
    return ["Notify", "Print Bold"];
}

configured(owner)
{
    if (!isDefined(owner)
        || (!isstruct(owner) && scripts\apparition\runtime\context::actor_reason([owner]) != ""))
        return "Unknown";
    if (!isDefined(owner.MessageDisplay))
        return "Notify";

    mode = owner.MessageDisplay;
    if (!isstring(mode)
        || !scripts\engine\utility::array_contains(types(), mode))
        return "Unknown";
    return mode;
}

delivery_reason(mode)
{
    if (!isDefined(mode) || !isstring(mode))
        return "Wait for a valid message display setting";
    if (mode == "Print Bold")
        return "";
    if (mode == "Notify")
        return "Notify typewriter messages are not ported to IW7";
    return "Wait for a valid message display setting";
}

set_display(owner, value)
{
    // Reject every unported or malformed setting before actor admission
    if (!isDefined(value) || !isstring(value) || value != "Print Bold")
        return false;
    if (!isDefined(owner) || scripts\apparition\runtime\context::actor_reason([owner]) != "")
        return false;
    if (!scripts\apparition\runtime\context::can_dispatch(owner, owner, false)
        || !scripts\apparition\runtime\access::can_open(owner))
        return false;

    owner.MessageDisplay = value;
    return true;
}

presets(page, owner_name, host_name)
{
    entries = [];
    if (!valid_page(page))
        return entries;

    // Inspection and dispatch share this single name cleanup
    owner_name = scripts\apparition\player_name::clean(owner_name);
    host_name = scripts\apparition\player_name::clean(host_name);

    if (page == "Miscellaneous Messages")
    {
        entries[entries.size] = make_entry("want_menu", "Want Menu?", "Want Menu?", "");
        entries[entries.size] = make_entry("whos_modding", "Who's Modding?", "Who's Modding?", "");
        owner_label = owner_name != "" ? owner_name : "Unnamed Player";
        owner_reason = owner_name != "" ? "" : "The owner name is unavailable";
        owner_text = owner_name != "" ? owner_name + " <3" : "";
        entries[entries.size] = make_entry("owner_name", owner_label, owner_text, owner_reason);
        entries[entries.size] = make_entry("deranked", "Deranked", "You've Been ^1Deranked", "");
        entries[entries.size] = make_entry("vial_icon", "BO3 Vial Icon",
            "^BBUTTON_ZM_VIAL_ICON^ ^BBUTTON_ZM_VIAL_ICON^ ^BBUTTON_ZM_VIAL_ICON^",
            "The BO3 vial icon glyph is unavailable in IW7");
        host_reason = host_name != "" ? "" : "The current host name is unavailable";
        host_text = host_name != "" ? "Your Host Today Is " + host_name : "";
        entries[entries.size] = make_entry("host", "Host", host_text, host_reason);
        return entries;
    }

    entries[entries.size] = make_entry("welcome", "Welcome", "Welcome To Apparition", "");
    entries[entries.size] = make_entry("discord", "Discord Server", "Discord Server: discord.gg/apparitionbo3", "");
    entries[entries.size] = make_entry("apparition", "Apparition",
        "Apparition Is The Biggest & Best Menu For BO3 Zombies", "");
    entries[entries.size] = make_entry("developer", "Developer", "Apparition Was Developed By CF4_99", "");
    entries[entries.size] = make_entry("youtube", "YouTube", "YouTube: CF4_99", "");
    return entries;
}

probe(owner, page)
{
    result = spawnstruct();
    result.reason = "";
    result.mode = "Unknown";
    result.entries = [];

    // Validate the route before checking actor authority or reading names
    if (!valid_probe_page(page))
    {
        result.reason = "Wait for a valid message page";
        return result;
    }
    // Reject malformed actors before the session helper performs native queries
    if (!isDefined(owner) || scripts\apparition\runtime\context::actor_reason([owner]) != "")
    {
        result.reason = "Only an admitted player can inspect messages";
        return result;
    }
    if (!scripts\apparition\runtime\context::can_dispatch(owner, owner, false))
    {
        result.reason = "Only an admitted player can inspect messages";
        return result;
    }
    if (!scripts\apparition\runtime\access::can_open(owner))
    {
        result.reason = "Menu access is required to inspect messages";
        return result;
    }

    // Settings and names are read only after both fresh actor and access checks
    result.mode = configured(owner);
    if (page == "Message Menu")
        return result;

    owner_name = undefined;
    host_name = undefined;
    if (page == "Miscellaneous Messages")
    {
        owner_name = owner.name;
        host = scripts\apparition\runtime\context::current_host(level);
        if (isDefined(host))
            host_name = host.name;
    }

    result.entries = presets(page, owner_name, host_name);
    return result;
}

send(owner, page, id)
{
    // Invalid route and identifier shapes cannot reach actor or native calls
    if (!valid_page(page) || !isDefined(id) || !isstring(id))
        return false;

    snapshot = probe(owner, page);
    if (snapshot.reason != "" || snapshot.mode != "Print Bold")
        return false;

    // Resolve the ID against this fresh snapshot rather than trusting a rendered row
    foreach (item in snapshot.entries)
    {
        if (item.id != id || item.reason != "")
            continue;

        iprintlnbold(item.text);
        // The native builtin provides no receipt for global delivery
        return true;
    }
    return false;
}

send_custom(owner, text)
{
    if (!scripts\apparition\menu\keyboard_model::valid_text(text))
        return false;
    // Confirmation uses the current recipient admission and configured delivery mode
    current = probe(owner, "Message Menu");
    if (current.reason != "" || current.mode != "Print Bold")
        return false;
    iprintlnbold(text);
    return true;
}

valid_page(page)
{
    return isDefined(page) && isstring(page)
        && (page == "Miscellaneous Messages" || page == "Advertisements Messages");
}

valid_probe_page(page)
{
    return valid_page(page) || (isDefined(page) && isstring(page) && page == "Message Menu");
}

make_entry(id, label, text, reason)
{
    item = spawnstruct();
    item.id = id;
    item.label = label;
    item.text = text;
    item.reason = reason;
    return item;
}
