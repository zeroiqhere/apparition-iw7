// Credits own one roll inside the current menu HUD and navigation session

can_begin(state, hud, layout, open, alive)
{
    // Only this owner's source customization path can allocate a new roll
    if (!open || !alive || !isDefined(state) || !isstruct(state)
        || !isDefined(hud) || !isstruct(hud) || !isDefined(layout) || !isstruct(layout)
        || !isDefined(hud.owner) || !isDefined(hud.released) || hud.released
        || !isDefined(state.page) || state.page != "Credits"
        || !isDefined(state.target) || state.target != hud.owner
        || !isDefined(state.parents) || !isarray(state.parents) || !state.parents.size
        || isDefined(layout.active_editor) || isDefined(hud.credits))
        return false;
    parent = state.parents[state.parents.size - 1];
    return isDefined(parent) && isstruct(parent) && isDefined(parent.page)
        && parent.page == "Menu Customization" && isDefined(parent.target)
        && parent.target == hud.owner;
}

create(state, hud, access, grant)
{
    active = spawnstruct();
    active.session = state;
    active.page = "Credits";
    active.hud = hud;
    active.menu_access = access;
    active.menu_grant = grant;
    active.state = "Playing";
    active.lines = [];
    return active;
}

valid(active, state, hud, access, grant)
{
    if (!isDefined(active) || !isstruct(active)
        || !isDefined(state) || !isstruct(state) || !isDefined(hud) || !isstruct(hud)
        || !isDefined(hud.owner) || !isDefined(hud.released) || hud.released
        || !isDefined(hud.credits) || hud.credits != active
        || !isDefined(state.target) || state.target != hud.owner
        || !isDefined(active.page) || active.page != "Credits"
        || !isDefined(active.state) || (active.state != "Playing" && active.state != "Complete")
        || !isDefined(active.lines) || !isarray(active.lines))
        return false;
    // Reuse the existing menu snapshot and exact-grant contracts
    return scripts\apparition\menu\dispatch::can_refresh(true, state, hud, active)
        && scripts\apparition\menu\dispatch::access_matches(active, access, grant);
}

can_continue(owner, active)
{
    if (!scripts\apparition\runtime\context::can_dispatch(owner, owner, false)
        || !scripts\apparition\runtime\access::can_open(owner))
        return false;
    if (!isDefined(owner.apparition_open) || !owner.apparition_open
        || !isDefined(owner.apparition_layout) || isDefined(owner.apparition_layout.active_editor)
        || !scripts\apparition\menu\life::is_alive(owner))
        return false;
    return valid(active, owner.apparition_state, owner.apparition_hud,
        scripts\apparition\runtime\access::current(owner), owner.apparition_access);
}

begin(hud, state, layout)
{
    if (!isDefined(hud) || !isstruct(hud) || !isDefined(hud.owner))
        return false;
    owner = hud.owner;
    if (!scripts\apparition\runtime\context::can_dispatch(owner, owner, false)
        || !scripts\apparition\runtime\access::can_open(owner)
        || owner.apparition_hud != hud || owner.apparition_state != state
        || owner.apparition_layout != layout)
        return false;
    // Repeated render requests must never reset the roll or its completion receipt
    if (isDefined(hud.credits))
        return can_continue(owner, hud.credits);
    if (!can_begin(state, hud, layout, owner.apparition_open,
        scripts\apparition\menu\life::is_alive(owner)))
        return false;

    active = create(state, hud, scripts\apparition\runtime\access::current(owner), owner.apparition_access);
    hud.credits = active;
    show_frame(hud, layout);
    // This producer can outlive the short navigation callback that entered the page
    owner thread run(active);
    return true;
}

show_frame(hud, layout)
{
    scripts\apparition\menu\ownership::release_rows(hud);
    scripts\apparition\menu\ownership::release_spare(hud);
    foreach (element in [hud.description, hud.counter_separator, hud.counter_index, hud.counter_total])
        element.alpha = 0;
    frame = scripts\apparition\menu\design::frame(layout, 1, "credits");
    scripts\apparition\menu\hud::apply_frame(hud, frame, false);
    // SoftLockMenu retains the customization heading and menu name
    hud.chrome["title"] setText("Menu Customization");
    hud.chrome["name"] setText("Apparition");
}

geometry(layout)
{
    result = spawnstruct();
    // Native movement follows the currently applied panel without storing a second layout
    result.x = layout.x + layout.width / 2;
    result.start_y = layout.y + scripts\apparition\menu\layout::fixed_panel_height("credits") - 8;
    result.end_y = layout.y + 12;
    return result;
}

run(active)
{
    self endon("disconnect");
    level endon("game_ended");
    active endon("apparition_credits_stop");
    foreach (item in scripts\apparition\menu\credits_plan::items())
    {
        // Every source pause returns through the same captured session boundary
        if (!can_continue(self, active))
        {
            release(active.hud, active);
            return;
        }
        if (item.text != " ")
        {
            path = geometry(self.apparition_layout);
            element = scripts\apparition\menu\hud::text(path.x, path.start_y,
                "center", item.scale, (1, 1, 1), 4, self);
            if (!isDefined(element))
            {
                release(active.hud, active);
                return;
            }
            element.font = "objective";
            element.alpha = 0;
            element setText(item.text);
            line = spawnstruct();
            line.element = element;
            active.lines[active.lines.size] = line;
            self childthread animate_line(active, line, path.end_y);
        }
        wait item.delay;
    }
    wait scripts\apparition\menu\credits_plan::motion_time();
    if (!can_continue(self, active))
    {
        release(active.hud, active);
        return;
    }
    // Completion records the actual producer wait rather than an estimated timer
    active.state = "Complete";
}

animate_line(active, line, end_y)
{
    self endon("disconnect");
    level endon("game_ended");
    active endon("apparition_credits_stop");
    if (!can_continue(self, active))
    {
        retire_line(line);
        return;
    }
    fade = scripts\apparition\menu\credits_plan::fade_time();
    motion = scripts\apparition\menu\credits_plan::motion_time();
    line.element fadeOverTime(fade);
    line.element.alpha = 1;
    line.element moveOverTime(motion);
    line.element.y = end_y;
    wait motion - fade;
    if (!can_continue(self, active))
    {
        retire_line(line);
        return;
    }
    line.element fadeOverTime(fade);
    line.element.alpha = 0;
    wait fade;
    retire_line(line);
}

exit_requested(active, buttons)
{
    // Other menu commands stay suspended until the producer finishes or Melee exits
    return active.state == "Complete" || buttons["+melee"];
}

retire_line(line)
{
    if (!isDefined(line) || !isstruct(line) || !isDefined(line.element))
        return;
    element = line.element;
    // Clear the sole handle before native destruction or a second cleanup
    line.element = undefined;
    element destroy();
}

release(hud, expected)
{
    if (!isDefined(hud) || !isstruct(hud) || !isDefined(hud.credits))
        return;
    active = hud.credits;
    if (isDefined(expected) && active != expected)
        return;
    hud.credits = undefined;
    active.state = "Retired";
    foreach (line in active.lines)
        retire_line(line);
    active.lines = [];
    // Notify last because the producer may be calling its own cleanup
    active notify("apparition_credits_stop");
}
