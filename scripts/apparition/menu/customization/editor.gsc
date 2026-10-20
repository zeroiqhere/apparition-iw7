// Customization editors share one temporary owner-scoped modal

begin(row, value)
{
    if (!scripts\apparition\runtime\context::can_dispatch(self, self, false))
        return false;
    owner_open = isDefined(self.apparition_open) && self.apparition_open;
    owner_alive = isAlive(self);
    layout = self.apparition_layout;
    state = self.apparition_state;
    hud = self.apparition_hud;
    if (!can_begin(row, state, hud, layout, owner_open, owner_alive))
        return false;
    mode = mode_for_setting(row.setting);
    layout.active_editor = create_session(mode, state);
    active = layout.active_editor;
    active.hud = hud;
    active.access = scripts\apparition\runtime\access::current(self);
    active.grant = self.apparition_access;
    if (mode == "instructions")
        active.ready_at = getTime() + 100;
    // Width and menu movement start at one pixel; instructions use a fixed eight-pixel step
    visible = scripts\apparition\menu\hud::show_editor(hud, layout, mode, instructions(mode), active.offset,
        instructions_y(layout, mode), offset_y(layout, mode), offset_value_x(layout));
    if (!visible)
    {
        layout.active_editor = undefined;
        return false;
    }
    return true;
}

can_begin(row, state, hud, layout, owner_open, owner_alive)
{
    if (!owner_open || !owner_alive)
        return false;
    if (!isDefined(row) || !isDefined(state) || !isDefined(hud) || !isDefined(layout))
        return false;
    if (!isDefined(row.setting) || !isDefined(mode_for_setting(row.setting)))
        return false;
    if (!isDefined(hud.owner) || !isDefined(row.target) || row.target != hud.owner)
        return false;
    if (!isDefined(row.hud) || row.hud != hud)
        return false;
    if (!isDefined(row.session) || row.session != state || !isDefined(state.page) || state.page != page_for_mode(mode_for_setting(row.setting)))
        return false;
    if (!isDefined(state.target) || state.target != hud.owner)
        return false;
    if (row.setting == "reposition_instructions" && layout.disable_instructions)
        return false;
    // A released HUD or an active editor cannot be reused by a delayed callback
    return isDefined(hud.released) && !hud.released && !isDefined(layout.active_editor);
}

can_continue(owner)
{
    if (!isDefined(owner.apparition_layout) || !isDefined(owner.apparition_state) || !isDefined(owner.apparition_hud))
        return false;
    layout = owner.apparition_layout;
    state = owner.apparition_state;
    hud = owner.apparition_hud;
    if (!isDefined(layout.active_editor))
        return false;
    active = layout.active_editor;
    // Captured ownership and access must survive every input or settle wait
    return same_session(active, state, hud, scripts\apparition\runtime\access::current(owner), owner.apparition_access)
        && owner.apparition_open && isAlive(owner) && state.target == owner
        && (active.mode != "instructions" || !layout.disable_instructions);
}

input_ready(active, now)
{
    return !isDefined(active.ready_at) || now >= active.ready_at;
}

same_session(active, state, hud, access, grant)
{
    return active.session == state && active.hud == hud && !hud.released
        && isDefined(page_for_mode(active.mode)) && state.page == page_for_mode(active.mode)
        && active.access == access && scripts\apparition\runtime\access::same_grant(active.grant, grant);
}

apply(owner, command)
{
    if (!can_continue(owner))
        return false;
    layout = owner.apparition_layout;
    hud = owner.apparition_hud;
    active = layout.active_editor;
    if (active.mode == "width" && (command == "width_increase" || command == "width_decrease"))
    {
        direction = command == "width_increase" ? "increase" : "decrease";
        width = width_after(layout.width, active.offset, direction);
        if (width != layout.width)
        {
            layout.width = width;
            scripts\apparition\menu\hud::scale_width(hud, layout);
        }
        return true;
    }
    if (active.mode != "instructions" && (command == "offset_decrease" || command == "offset_increase"))
    {
        direction = command == "offset_decrease" ? "decrease" : "increase";
        active.offset = offset_after(active.offset, direction);
        scripts\apparition\menu\hud::update_editor_offset(hud, active.offset);
        return true;
    }
    if (active.mode == "instructions" && (command == "move_up" || command == "move_down"
        || command == "move_left" || command == "move_right"))
    {
        position = position_after(layout.instructions_x, layout.instructions_y, command, active.offset);
        layout.instructions_x = position.x;
        layout.instructions_y = position.y;
        return true;
    }
    if (active.mode == "reposition" && (command == "move_up" || command == "move_down"
        || command == "move_left" || command == "move_right"))
    {
        position = position_after(layout.x, layout.y, command, active.offset);
        delta_x = position.x - layout.x;
        delta_y = position.y - layout.y;
        if (!scripts\apparition\menu\hud::translate(hud, delta_x, delta_y))
            return false;
        layout.x = position.x;
        layout.y = position.y;
        return true;
    }
    return false;
}

end(owner)
{
    if (!isDefined(owner.apparition_layout))
        return;
    layout = owner.apparition_layout;
    if (!isDefined(layout.active_editor))
        return;
    layout.active_editor = undefined;
    // The controller restores normal rows on the next refresh
    if (isDefined(owner.apparition_hud))
        scripts\apparition\menu\hud::hide_editor(owner.apparition_hud);
    if (!scripts\apparition\menu\customization\storage::save(owner) && isAlive(owner))
        owner iPrintLn("Settings applied for this connection; saving was unavailable");
}

create_session(mode, state)
{
    if (!isDefined(page_for_mode(mode)))
        return undefined;
    active = spawnstruct();
    active.mode = mode;
    active.offset = mode == "instructions" ? 8 : 1;
    active.session = state;
    return active;
}

mode_for_setting(setting)
{
    if (setting == "reposition_instructions")
        return "instructions";
    if (setting == "width_editor")
        return "width";
    if (setting == "reposition_menu")
        return "reposition";
    return undefined;
}

page_for_mode(mode)
{
    if (mode == "instructions")
        return "Menu Instructions";
    if (mode == "width" || mode == "reposition")
        return "Menu Customization";
    return undefined;
}

width_after(width, offset, direction)
{
    if (direction == "increase")
        return width + min(offset, 500 - width);
    if (direction == "decrease")
        return width - min(offset, width - 200);
    return width;
}

offset_after(offset, direction)
{
    if (direction == "decrease" && offset > 1)
        return offset - 1;
    if (direction == "increase" && offset < 10)
        return offset + 1;
    return offset;
}

position_after(x, y, command, offset)
{
    position = spawnstruct();
    position.x = x;
    position.y = y;
    if (command == "move_up")
        position.y -= offset;
    else if (command == "move_down")
        position.y += offset;
    else if (command == "move_left")
        position.x -= offset;
    else if (command == "move_right")
        position.x += offset;
    return position;
}

instructions(mode)
{
    if (mode == "instructions")
        return "[{+actionslot 1}] - Move Up\n[{+actionslot 2}] - Move Down\n[{+actionslot 3}] - Move Left\n[{+actionslot 4}] - Move Right\n[{+melee}] - Exit";
    if (mode == "width")
        return "[{+attack}] - Increase Width\n[{+speed_throw}] - Decrease Width\n[{+actionslot 4}] - Increase Offset\n[{+actionslot 3}] - Decrease Offset\n[{+melee}] - Exit";
    if (mode == "reposition")
        return "[{+actionslot 1}] - Move Up\n[{+actionslot 2}] - Move Down\n[{+actionslot 3}] - Move Left\n[{+actionslot 4}] - Move Right\n[{+frag}] - Increase Offset\n[{+smoke}] - Decrease Offset\n[{+melee}] - Exit";
    return "";
}

instructions_y(layout, mode)
{
    if (mode == "width")
        return layout.y + 25;
    if (mode == "reposition")
        return layout.y + 22;
    return layout.y;
}

offset_y(layout, mode)
{
    // Source newline heights are derived from three plus fourteen per line
    if (mode == "width")
        return layout.y + 25 + 73;
    if (mode == "reposition")
        return layout.y + 22 + 101 - 10;
    return layout.y;
}

offset_value_x(layout)
{
    // The source text-width helper result at scale four is reduced by seven pixels
    return layout.x + 4 + 44;
}
