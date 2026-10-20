// Keyboard input belongs to one current owner session and fixed source routes

page_for_kind(kind)
{
    if (!isDefined(kind) || !isstring(kind))
        return undefined;
    if (kind == "message")
        return "Message Menu";
    if (kind == "doheart")
        return "Doheart Options";
    if (kind == "player_message")
        return "Options";
    if (kind == "lobby_message")
        return "All Players";
    if (kind == "zombie_health")
        return "Zombie Options";
    return undefined;
}

target_matches(page, target, owner)
{
    // Only selected-player messages may keep a recipient separate from the HUD owner
    if (!isDefined(target) || !isDefined(owner))
        return false;
    if (page == page_for_kind("player_message"))
        return true;
    return (page == page_for_kind("message") || page == page_for_kind("doheart")
        || page == page_for_kind("lobby_message") || page == page_for_kind("zombie_health")) && target == owner;
}

can_begin(kind, state, hud, layout, open, alive)
{
    page = page_for_kind(kind);
    if (!open || !alive || !isDefined(page)
        || !isDefined(state) || !isstruct(state)
        || !isDefined(hud) || !isstruct(hud)
        || !isDefined(layout) || !isstruct(layout))
        return false;
    // A delayed callback cannot borrow a different page, target or modal slot
    return isDefined(state.page) && state.page == page
        && target_matches(page, state.target, hud.owner)
        && isDefined(hud.released) && !hud.released
        && isDefined(hud.chrome) && isarray(hud.chrome) && isDefined(hud.chrome["scroller"])
        && !isDefined(hud.keyboard) && !isDefined(hud.credits)
        && !isDefined(layout.active_editor);
}

create_session(kind, state, hud, access, grant)
{
    page = page_for_kind(kind);
    if (!isDefined(page))
        return undefined;
    active = spawnstruct();
    active.session = state;
    active.page = page;
    active.target = state.target;
    active.hud = hud;
    active.menu_access = access;
    active.menu_grant = grant;
    active.model = page == page_for_kind("zombie_health")
        ? scripts\apparition\menu\numberpad_model::create()
        : scripts\apparition\menu\keyboard_model::create();
    // Undefined deadline keeps input paused until the visible entry sequence ends
    active.ready_at = undefined;
    active.elements = [];
    return active;
}

valid(active, state, hud, access, grant)
{
    if (!isDefined(active) || !isstruct(active)
        || !isDefined(state) || !isstruct(state)
        || !isDefined(hud) || !isstruct(hud)
        || !isDefined(hud.owner) || !isDefined(hud.released) || hud.released
        || !isDefined(hud.keyboard) || hud.keyboard != active
        || !isDefined(active.page)
        || !target_matches(active.page, active.target, hud.owner)
        || !isDefined(state.target) || state.target != active.target
        || !isDefined(active.model) || !isstruct(active.model)
        || active.model.status != "Editing")
        return false;
    if (active.page == page_for_kind("zombie_health") && access != "Host")
        return false;
    if ((active.page == "Options" || active.page == "All Players")
        && !scripts\apparition\runtime\player_control::can_manage(access))
        return false;
    return scripts\apparition\menu\dispatch::can_refresh(true, state, hud, active)
        && scripts\apparition\menu\dispatch::access_matches(active, access, grant);
}

can_continue(owner, active)
{
    // Reject fixture or missing actors before reading player or native level state
    if (scripts\apparition\runtime\player_control::reason(owner, owner) != "")
        return false;
    if (!isDefined(owner.apparition_open) || !owner.apparition_open
        || !isDefined(owner.apparition_layout) || isDefined(owner.apparition_layout.active_editor)
        || !scripts\apparition\menu\life::is_alive(owner))
        return false;
    if (!valid(active, owner.apparition_state, owner.apparition_hud,
        scripts\apparition\runtime\access::current(owner), owner.apparition_access))
        return false;
    if (active.page == "Options" || active.page == "All Players")
        return scripts\apparition\features\player_messages::reason(owner, active.target,
            active.page == "All Players") == "";
    if (active.page == page_for_kind("zombie_health"))
    {
        current = scripts\apparition\maps\spaceland\zombie_health::probe(owner);
        return current.reason == "";
    }
    return true;
}

begin(owner, kind)
{
    if (scripts\apparition\runtime\player_control::reason(owner, owner) != "")
        return false;
    state = owner.apparition_state;
    hud = owner.apparition_hud;
    layout = owner.apparition_layout;
    if (!can_begin(kind, state, hud, layout, owner.apparition_open,
        scripts\apparition\menu\life::is_alive(owner)))
        return false;
    if (kind == "message")
    {
        current = scripts\apparition\features\messages::probe(owner, "Message Menu");
        if (current.reason != "" || current.mode != "Print Bold")
            return false;
    }
    else if (kind == "doheart")
    {
        current = scripts\apparition\features\server\doheart::probe(owner);
        if (current.reason != "" || !current.settings_ready
            || scripts\apparition\features\server\doheart::change_reason(current.configured,
                current.text, current.style, "text", "Custom") != "")
            return false;
    }
    else if (kind == "zombie_health")
    {
        current = scripts\apparition\maps\spaceland\zombie_health::probe(owner);
        if (current.reason != "")
            return false;
    }
    else if (scripts\apparition\features\player_messages::reason(owner, state.target,
        kind == "lobby_message") != "")
        return false;
    // Publish one captured owner before any native animation or entry wait
    active = create_session(kind, state, hud, scripts\apparition\runtime\access::current(owner),
        owner.apparition_access);
    hud.keyboard = active;
    scripts\apparition\menu\keyboard_hud::resize_cursor(hud, kind == "zombie_health" ? 14 : 16);
    wait 0.1;
    if (!can_continue(owner, active))
    {
        release(hud, active);
        return false;
    }
    scripts\apparition\menu\keyboard_hud::show_frame(hud, layout,
        kind == "zombie_health" ? "numberpad" : "keyboard");
    elements = kind == "zombie_health"
        ? scripts\apparition\menu\numberpad_hud::create(owner, layout)
        : scripts\apparition\menu\keyboard_hud::create(owner, layout);
    if (!isDefined(elements))
    {
        release(hud, active);
        return false;
    }
    active.elements = elements;
    if (kind == "zombie_health")
        scripts\apparition\menu\numberpad_hud::place_cursor(hud, layout);
    else
        scripts\apparition\menu\keyboard_hud::place_cursor(hud, layout);
    wait 0.01;
    if (!can_continue(owner, active))
    {
        release(hud, active);
        return false;
    }
    // The source's half-second input delay starts after its cursor placement wait
    active.ready_at = getTime() + 500;
    return true;
}

tick(owner, active, buttons)
{
    if (!can_continue(owner, active))
        return "Invalid";
    now = getTime();
    if (!isDefined(active.ready_at) || now < active.ready_at)
        return "Editing";
    gamepad = owner usinggamepad();
    if (active.page == page_for_kind("zombie_health"))
    {
        action = scripts\apparition\menu\numberpad_input::command(buttons, gamepad);
        scripts\apparition\menu\numberpad_model::apply(active.model, action);
    }
    else
    {
        action = scripts\apparition\menu\input::keyboard_command(buttons, gamepad);
        limit = scripts\apparition\menu\keyboard_model::apply(active.model, action);
        if (limit)
            owner iPrintLnBold("^1ERROR: ^7Max String Size Reached");
    }

    // Terminal actions run before repeat timing; empty cancel has no backspace wait
    if (active.model.status != "Editing")
    {
        if (active.model.status == "Confirmed")
        {
            // Each consumer rechecks current authority and typed text at confirmation
            if (active.page == page_for_kind("message"))
                accepted = scripts\apparition\features\messages::send_custom(owner, active.model.text);
            else if (active.page == page_for_kind("doheart"))
                accepted = scripts\apparition\features\server\doheart::configure(owner, "custom_text", active.model.text);
            else if (active.page == page_for_kind("zombie_health"))
            {
                // Parse literal digits before conversion can overflow or wrap
                value = scripts\apparition\menu\customization\settings::integer(active.model.text);
                if (!isDefined(value))
                {
                    active.model.status = "Editing";
                    owner iPrintLn("Health must be between 0 and 2147483647; edit the number to continue");
                    active.ready_at = now + 150;
                    return "Editing";
                }
                accepted = scripts\apparition\maps\spaceland\zombie_health::request(owner, value);
            }
            else
                accepted = scripts\apparition\features\player_messages::send(owner, active.target,
                    active.model.text, active.page == "All Players");
            if (!accepted)
                owner iPrintLn(active.page == page_for_kind("zombie_health")
                    ? "Health request was not accepted; current settings remain visible"
                    : "Custom text was not applied; current settings remain visible");
            else if (active.page == page_for_kind("zombie_health"))
                owner iPrintLn("Custom health request queued");
        }
        release(active.hud, active);
        return "Finished";
    }
    if (active.page == page_for_kind("zombie_health"))
        scripts\apparition\menu\numberpad_hud::update(active.elements,
            owner.apparition_layout, active.model, action, active.hud);
    else
        scripts\apparition\menu\keyboard_hud::update(active.elements,
            owner.apparition_layout, active.model, action, active.hud);
    active.ready_at = now + scripts\apparition\menu\keyboard_model::delay_ms(action);
    return "Editing";
}

release(hud, expected)
{
    if (!isDefined(hud) || !isstruct(hud) || !isDefined(hud.keyboard))
        return;
    active = hud.keyboard;
    if (isDefined(expected) && active != expected)
        return;
    hud.keyboard = undefined;
    active.model.status = "Retired";
    // Cleanup owns only keyboard elements and never changes native input flags
    scripts\apparition\menu\keyboard_hud::release_elements(active.elements);
    active.elements = [];
}

instructions(page)
{
    if (isDefined(page) && page == page_for_kind("zombie_health"))
        return ["[{+actionslot 3}]/[{+actionslot 4}] - Scroll", "[{+activate}] - Select",
            "[{+gostand}] - Confirm", "[{+melee}] - Backspace/Cancel"];
    return ["[{+actionslot 1}]/[{+actionslot 2}]/[{+actionslot 3}]/[{+actionslot 4}] - Scroll",
        "[{+activate}] - Select", "[{+frag}] - Add Space", "[{+gostand}] - Confirm",
        "[{+melee}] - Backspace/Cancel"];
}
