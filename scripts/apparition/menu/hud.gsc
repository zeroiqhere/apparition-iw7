// Client HUD elements use the owner's applied Apparition appearance
// Retained option groups move while each entering edge gets fresh native elements

create(layout)
{
    hud = spawnstruct();
    hud.owner = self;
    hud.released = false;
    hud.credits = undefined;
    hud.keyboard = undefined;
    hud.theme_animation_running = false;
    // Requested targets remain stable while native HUD colors are fading
    hud.requested_colors = [];
    hud.requested_chrome_alpha = [];
    hud.chrome = [];
    frame = scripts\apparition\menu\design::frame(layout, 1, undefined);
    // The design plan defines the pool roles as well as their later geometry
    foreach (name, role in frame.roles)
    {
        if (isDefined(role.width))
            element = rectangle(role.x, role.y, role.width, role.height, (1, 1, 1), 0, role.sort, self);
        else
            element = text(role.x, role.y, role.align_x, role.scale, (1, 1, 1), role.sort, self);
        element.alpha = 0;
        hud.chrome[name] = element;
        hud.requested_chrome_alpha[name] = 0;
    }
    hud.description = text(layout.x + 4, layout.y + 203, "left", 0.65, (1, 1, 1), 7, self);
    // Counter slots remain allocated when the setting changes while the HUD is open
    hud.counter_separator = text(0, 0, "center", 1, (1, 1, 1), 7, self);
    hud.counter_index = text(0, 0, "right", 1, (1, 1, 1), 7, self);
    hud.counter_total = text(0, 0, "left", 1, (1, 1, 1), 7, self);
    hud.counter_separator setText("/");
    hud.editor_instructions = text(layout.x + 4, layout.y + 25, "left", 1, (1, 1, 1), 5, self);
    hud.editor_offset_label = text(layout.x + 4, layout.y + 98, "left", 1, (1, 1, 1), 5, self);
    hud.editor_offset_value = text(layout.x + 48, layout.y + 98, "left", 1, (0, 1, 0), 5, self);
    hud.editor_instructions.alpha = 0;
    hud.editor_offset_label.alpha = 0;
    hud.editor_offset_value.alpha = 0;
    hud.fixed_elements = [hud.description, hud.counter_separator, hud.counter_index, hud.counter_total,
        hud.editor_instructions, hud.editor_offset_label, hud.editor_offset_value];
    foreach (element in hud.chrome)
        hud.fixed_elements[hud.fixed_elements.size] = element;
    hud.rows = [];
    // The outgoing group exists only while an edge fade needs it
    hud.spare = undefined;
    return hud;
}

create_row(index, layout, model)
{
    row = spawnstruct();
    row.elements = [];
    // Requested targets travel with the physical elements during rotation
    row.requested_scale = 1;
    row.requested_alpha = [0, 0, 0, 0];
    row.requested_colors = spawnstruct();
    row.requested_colors.text = (1, 1, 1);
    y = scripts\apparition\menu\layout::row_y(index, layout);
    row.requested_y = y;
    foreach (role in scripts\apparition\menu\row_elements::roles(model, layout))
    {
        if (role == "label" || role == "value")
        {
            x = role == "label" ? layout.x + 4 : scripts\apparition\menu\layout::value_x(layout);
            element = text(x, y, role == "label" ? "left" : "right", 1, (1, 1, 1), 5, self);
            element.alpha = 0;
        }
        else if (role == "invalid_line")
        {
            // Source spacer lines start visible even before an opening animation
            element = rectangle(layout.x + layout.width / 2, y, layout.width - 60, 1, layout.accent, 0.4, 5, self);
            element.alignX = "center";
            element.alignY = "middle";
            row.requested_colors.line = layout.accent;
            row.requested_alpha[3] = 0.4;
        }
        else
        {
            fill = role == "fill";
            size = fill ? 8 : 10;
            element = rectangle(layout.x + layout.width - 8, y, size, size,
                fill ? (0, 0, 0) : (0.25, 0.25, 0.25), 0, fill ? 6 : 5, self);
            element.alignX = "center";
            element.alignY = "middle";
            if (fill)
                row.requested_colors.fill = (0, 0, 0);
        }
        row.elements[role] = element;
    }
    return row;
}

render(hud, state, rows, layout, mode, view, previous_cursor, previous_rows)
{
    if (isDefined(hud.keyboard))
        return;
    if (!normal_render_allowed(layout))
        return;
    // Credits keep the same chrome but suspend ordinary row rendering
    if (state.page == "Credits")
    {
        scripts\apparition\menu\credits::begin(hud, state, layout);
        return 0;
    }
    opening = mode == "opening";
    pending = mode == "cursor_pending";
    scrolling = mode == "cursor" || pending;
    if (layout.smooth_rainbow)
    {
        // The level color remains shared with every player's theme
        scripts\apparition\menu\customization\theme::start_rgb_fade();
        scripts\apparition\menu\customization\theme::sample(layout, level.RGBFadeColor);
    }
    else if (hud.theme_animation_running)
    {
        // Static selection ends the owner's sampler before starting its fades
        hud.owner notify("apparition_theme_static_selected");
        hud.theme_animation_running = false;
    }
    fade_theme = layout.theme_fade_pending && !layout.smooth_rainbow
        && !opening && hud.requested_colors.size > 0;
    layout.theme_fade_pending = false;
    cursor = scripts\apparition\menu\state::cursor(state);
    capacity = scripts\apparition\menu\layout::capacity(layout);
    motion = scripts\apparition\menu\row_pool::transition(previous_rows, rows, previous_cursor, cursor, layout);
    start = motion.start;
    entering = undefined;
    redraw = scripts\apparition\menu\row_pool::needs_redraw(mode, previous_rows, rows, motion)
        || hud.rows.size != min(capacity, rows.size);
    // Compare retained groups at their future positions before allocating or rotating
    if (!redraw && !scripts\apparition\menu\row_elements::window_matches(hud.rows, rows, start,
        scrolling ? motion.shift : 0, layout))
        redraw = true;
    if (redraw)
    {
        scripts\apparition\menu\ownership::release_rows(hud);
        // Only visible groups are allocated for a fresh source-style option draw
        for (index = 0; index < min(capacity, rows.size); index++)
            hud.rows[index] = hud.owner create_row(index, layout, rows[start + index]);
    }
    else if (scrolling && motion.shift != 0)
    {
        entering = motion.shift > 0 ? capacity - 1 : 0;
        // Retire any interrupted outgoing group before allocating the new edge
        scripts\apparition\menu\ownership::release_spare(hud);
        hud.spare = hud.owner create_row(entering, layout, rows[start + entering]);
        rotated = scripts\apparition\menu\row_pool::rotate(hud, motion.shift);
        hud.rows = rotated.rows;
        hud.spare = rotated.spare;
        if (motion.time > 0)
        {
            sync_visuals(hud.spare, undefined, [0, 0, 0, 0], 0, 0, motion.time, 0);
            hud.owner thread scripts\apparition\menu\ownership::retire_spare(hud, hud.spare, motion.time);
        }
        else
            scripts\apparition\menu\ownership::release_spare(hud);
    }
    // Wraps and changed row identities also snap the scroller
    animate = scrolling && !redraw && motion.time > 0;
    if (!scrolling || redraw)
        motion.time = 0;
    // Every present role follows edge geometry before an invalid-row wait
    for (index = 0; index < hud.rows.size; index++)
    {
        row_time = isDefined(entering) && index == entering ? 0 : motion.time;
        move_row(hud.rows[index], scripts\apparition\menu\layout::row_y(index, layout), row_time);
    }
    if (!pending)
    {
        sync_chrome(hud, layout, fade_theme);
        frame = scripts\apparition\menu\design::frame(layout, rows.size, undefined);
        apply_frame(hud, frame, animate);
        hud.description.y = frame.description_y;
        hud.description.alpha = 1;
        counter = scripts\apparition\menu\appearance::counter(cursor, rows.size, layout, frame);
        hud.counter_separator.x = counter.x;
        hud.counter_index.x = counter.x - 3;
        hud.counter_total.x = counter.x + 3;
        foreach (element in [hud.counter_separator, hud.counter_index, hud.counter_total])
        {
            element.y = counter.y;
            element.alpha = counter.alpha;
        }
        hud.counter_index setValue(counter.index);
        hud.counter_total setValue(counter.total);
        hud.chrome["title"] setText(scripts\apparition\menu\design::page_title(state.page, layout.design, view));
        name = layout.design == "AIO" ? "Status: " + view.access : "Apparition";
        hud.chrome["name"] setText(name);
        // The footer follows the selected slider value without changing stored settings
        selected_row = rows[cursor];
        selected_value = selected_row.kind == "slider"
            ? scripts\apparition\menu\state::slider_value(state, selected_row) : undefined;
        description = scripts\apparition\menu\availability::description(selected_row, selected_value);
        hud.description setText(scripts\apparition\menu\layout::wrap_description(description, 48));
        if (animate)
            hud.chrome["scroller"] moveOverTime(layout.scroll_time);
        hud.chrome["scroller"].y = frame.roles["scroller"].y + (cursor - start) * layout.row_height;
    }
    for (index = 0; index < hud.rows.size; index++)
    {
        slot = hud.rows[index];
        // Source creates and fades an entering edge before checking a blank cursor
        is_entering = isDefined(entering) && index == entering;
        if (pending && !is_entering && !redraw)
            continue;
        row_time = is_entering ? 0 : motion.time;
        row = rows[start + index];
        selected = start + index == cursor;
        opening_index = opening ? index : undefined;
        style = scripts\apparition\menu\appearance::row_style(row, selected, layout);
        choice_blocked = false;
        selected_value = undefined;
        selected_index = 0;
        if (row.kind == "slider")
        {
            if (isDefined(row.range))
                selected_value = scripts\apparition\menu\state::slider_value(state, row);
            else
            {
                selected_index = scripts\apparition\menu\state::slider_index(state, row);
                selected_value = row.values[selected_index];
            }
            choice_blocked = scripts\apparition\menu\availability::choice_reason(row, selected_value) != "";
        }
        slot.elements["label"].x = style.label_x;
        if (isDefined(slot.elements["value"]))
            slot.elements["value"].x = scripts\apparition\menu\layout::value_x(layout);
        if (isDefined(slot.elements["box"]))
        {
            slot.elements["box"].x = style.box_x;
            slot.elements["fill"].x = style.box_x;
        }
        if (isDefined(slot.elements["invalid_line"]))
            slot.elements["invalid_line"].x = layout.x + layout.width / 2;
        sync_scale(slot, style.scale, row_time);
        alpha = scripts\apparition\menu\appearance::opacity(row, selected, style, choice_blocked);
        checked_boxes = style.boxes && row.kind == "toggle" && row.checked;
        // Fresh redraw elements receive their final colors before any opening fade
        fresh_style = redraw || is_entering;
        if (isDefined(slot.elements["invalid_line"]))
            alpha[3] = scripts\apparition\menu\appearance::line_opacity(slot.requested_alpha[3], style.alpha, opening, fresh_style);
        times = scripts\apparition\menu\appearance::fade_times(motion.time, opening_index, fresh_style,
            fade_theme, layout.smooth_rainbow, checked_boxes);
        sync_visuals(slot, style, alpha, times.text, times.fill, times.alpha, times.line);
        slot.elements["label"] setText(row.label);
        if (isDefined(slot.elements["value"]))
        {
            value = row.kind == "slider"
                ? scripts\apparition\menu\appearance::slider_text(row, selected_value, selected_index) : style.value;
            slot.elements["value"] setText(value);
        }
    }
    if (layout.smooth_rainbow && !hud.theme_animation_running)
    {
        hud.theme_animation_running = true;
        hud.owner thread scripts\apparition\menu\hud::animate_theme(hud, layout);
    }
    return motion.time;
}

apply_frame(hud, frame, animate, preserve_scroller)
{
    foreach (name, role in frame.roles)
    {
        // The modal borrows this handle and owns its current size and position
        if (name == "scroller" && isDefined(preserve_scroller) && preserve_scroller)
            continue;
        element = hud.chrome[name];
        element.x = role.x;
        if (name != "scroller" || !animate)
            element.y = role.y;
        // A passive geometry refresh must leave an unchanged color fade alone
        if (hud.requested_chrome_alpha[name] != role.alpha)
        {
            element.alpha = role.alpha;
            hud.requested_chrome_alpha[name] = role.alpha;
        }
        element.sort = role.sort;
        element.alignX = role.align_x;
        if (isDefined(role.width))
            element setShader("white", role.width, role.height);
        else
            element.fontScale = role.scale;
    }
}

normal_render_allowed(layout)
{
    return !isDefined(layout.active_editor);
}

show_editor(hud, layout, mode, instructions, offset, instructions_y, offset_y, value_x)
{
    if (!isDefined(hud) || hud.released)
        return false;
    hud.description.alpha = 0;
    hud.counter_separator.alpha = 0;
    hud.counter_index.alpha = 0;
    hud.counter_total.alpha = 0;
    scripts\apparition\menu\ownership::release_rows(hud);
    frame = scripts\apparition\menu\design::frame(layout, 1, mode);
    apply_frame(hud, frame, false);
    if (mode == "instructions")
    {
        // This mode displays its guide in the persistent instruction HUD
        hide_editor(hud);
        return true;
    }
    hud.editor_instructions.x = layout.x + 4;
    hud.editor_instructions.y = instructions_y;
    hud.editor_instructions setText(instructions);
    hud.editor_offset_label.x = layout.x + 4;
    hud.editor_offset_label.y = offset_y;
    hud.editor_offset_label setText("Offset Value: ");
    hud.editor_offset_value.x = value_x;
    hud.editor_offset_value.y = offset_y;
    hud.editor_offset_value setValue(offset);
    hud.editor_instructions.alpha = 1;
    hud.editor_offset_label.alpha = 1;
    hud.editor_offset_value.alpha = 1;
    return true;
}

update_editor_offset(hud, offset)
{
    if (isDefined(hud) && !hud.released)
        hud.editor_offset_value setValue(offset);
}

hide_editor(hud)
{
    if (!isDefined(hud) || hud.released)
        return;
    hud.editor_instructions.alpha = 0;
    hud.editor_offset_label.alpha = 0;
    hud.editor_offset_value.alpha = 0;
}

translate(hud, delta_x, delta_y)
{
    if (!isDefined(hud) || !isDefined(hud.released) || hud.released)
        return false;
    // Current ownership includes an outgoing fade without retaining old handles
    foreach (element in scripts\apparition\menu\ownership::elements(hud))
    {
        if (!isDefined(element))
            continue;
        element.x += delta_x;
        element.y += delta_y;
    }
    // The next normal render must agree with the translated native targets
    foreach (row in hud.rows)
        row.requested_y += delta_y;
    if (isDefined(hud.spare))
        hud.spare.requested_y += delta_y;
    return true;
}

scale_width(hud, layout)
{
    if (!isDefined(hud) || hud.released)
        return;
    frame = scripts\apparition\menu\design::frame(layout, 1, "width");
    // Source borders keep their own width additions and modal heights
    foreach (name, role in frame.roles)
    {
        if (isDefined(role.width) && role.alpha > 0)
            hud.chrome[name] ScaleOverTime(0.05, role.width, role.height);
    }
}


move_row(slot, target_y, fade_time)
{
    if (slot.requested_y == target_y)
        return;
    foreach (element in scripts\apparition\menu\row_elements::owned(slot))
    {
        if (fade_time > 0)
            element MoveOverTime(fade_time);
        element.y = target_y;
    }
    slot.requested_y = target_y;
}

sync_visuals(slot, style, targets, text_time, fill_time, alpha_time, line_time)
{
    text_changed = false;
    fill_changed = false;
    line_changed = false;
    if (isDefined(style))
    {
        text_changed = scripts\apparition\menu\customization\theme::color_target_changed(slot.requested_colors.text, style.color);
        fill_changed = isDefined(slot.elements["fill"])
            && scripts\apparition\menu\customization\theme::color_target_changed(slot.requested_colors.fill, style.fill_color);
        line_changed = isDefined(slot.elements["invalid_line"])
            && scripts\apparition\menu\customization\theme::color_target_changed(slot.requested_colors.line, style.line_color);
    }
    foreach (role, element in scripts\apparition\menu\row_elements::owned(slot))
    {
        // Named roles avoid position changes when a value or checkbox is absent
        channel = role == "label" ? 0 : role == "value" ? 1 : role == "invalid_line" ? 3 : 2;
        alpha_changed = slot.requested_alpha[channel] != targets[channel];
        color_changed = false;
        color_time = 0;
        color = undefined;
        if (isDefined(style))
        {
            if (role == "label" || role == "value")
            {
                color_changed = text_changed;
                color_time = text_time;
                color = style.color;
            }
            else if (role == "fill")
            {
                color_changed = fill_changed;
                color_time = fill_time;
                color = style.fill_color;
            }
            else if (role == "invalid_line")
            {
                color_changed = line_changed;
                color_time = line_time;
                color = style.line_color;
            }
        }
        if (!color_changed && !alpha_changed)
            continue;
        // Immediate properties are set before the other property starts its fade
        if (color_changed && color_time == 0)
            element.color = color;
        if (alpha_changed && alpha_time == 0)
            element.alpha = targets[channel];
        duration = color_changed ? color_time : 0;
        // The timing plan shares one positive duration when both properties change
        if (alpha_changed && alpha_time > 0)
            duration = alpha_time;
        if (duration > 0)
            element FadeOverTime(duration);
        if (color_changed && color_time > 0)
            element.color = color;
        if (alpha_changed && alpha_time > 0)
            element.alpha = targets[channel];
    }
    // Store targets after every present element has received the same request
    if (text_changed)
        slot.requested_colors.text = style.color;
    if (fill_changed)
        slot.requested_colors.fill = style.fill_color;
    if (line_changed)
        slot.requested_colors.line = style.line_color;
    slot.requested_alpha = targets;
}


sync_scale(slot, target, fade_time)
{
    // Compare the requested target rather than an in-flight native field
    if (slot.requested_scale == target)
        return;
    foreach (role, element in scripts\apparition\menu\row_elements::owned(slot))
    {
        // Rectangles move with the group but never receive a font-scale request
        if (role != "label" && role != "value")
            continue;
        if (fade_time > 0)
            element ChangeFontScaleOverTime(fade_time);
        element.fontScale = target;
    }
    slot.requested_scale = target;
}

sync_chrome(hud, layout, fade_theme)
{
    foreach (name, color in scripts\apparition\menu\design::colors(layout))
    {
        // Source rainbow sampling leaves the modal's captured scroller color alone
        if (name == "scroller" && isDefined(hud.keyboard))
            continue;
        if (scripts\apparition\menu\customization\theme::color_target_changed(hud.requested_colors[name], color))
        {
            if (fade_theme)
                hud.chrome[name] FadeOverTime(0.5);
            hud.chrome[name].color = color;
            hud.requested_colors[name] = color;
        }
    }
}

sync_rainbow_rows(hud, state, rows, layout)
{
    cursor = scripts\apparition\menu\state::cursor(state);
    capacity = scripts\apparition\menu\layout::capacity(layout);
    start = scripts\apparition\navigation::visible_start(cursor, rows.size, capacity);
    for (index = 0; index < hud.rows.size; index++)
    {
        slot = hud.rows[index];
        row = rows[start + index];
        style = scripts\apparition\menu\appearance::row_style(row, start + index == cursor, layout);
        // A color sample never changes an opacity target or requests another fade
        sync_visuals(slot, style, slot.requested_alpha, 0, 0, 0, 0);
    }
}

animate_theme(hud, layout)
{
    self endon("disconnect");
    self endon("apparition_theme_static_selected");
    self endon("apparition_theme_hud_released");
    level endon("game_ended");
    for (;;)
    {
        if (!layout.smooth_rainbow || hud.released)
            break;
        color = level.RGBFadeColor;
        if (isDefined(color))
        {
            scripts\apparition\menu\customization\theme::sample(layout, color);
            if (isDefined(self.apparition_state) && isDefined(self.apparition_rows))
                sync_rainbow_rows(hud, self.apparition_state, self.apparition_rows, layout);
            sync_chrome(hud, layout, false);
        }
        wait 0.01;
    }
    hud.theme_animation_running = false;
}

release(hud)
{
    if (!isDefined(hud) || hud.released)
        return;
    scripts\apparition\menu\credits::release(hud);
    scripts\apparition\menu\keyboard::release(hud);
    hud.released = true;
    if (isDefined(hud.owner) && hud.theme_animation_running)
        hud.owner notify("apparition_theme_hud_released");
    scripts\apparition\menu\ownership::destroy_elements(scripts\apparition\menu\ownership::elements(hud));
    // Clear canonical owners so later retirement timers cannot revisit handles
    hud.fixed_elements = [];
    hud.rows = [];
    hud.spare = undefined;
}

base(x, y, sort, owner)
{
    element = newClientHudElem(owner);
    if (!isDefined(element))
        return undefined;
    element.horzAlign = "left";
    element.vertAlign = "top";
    element.alignX = "left";
    element.alignY = "middle";
    element.x = x;
    element.y = y;
    element.sort = sort;
    element.hideWhenInMenu = true;
    element.foreground = true;
    element.archived = false;
    return element;
}

rectangle(x, y, width, height, color, alpha, sort, owner)
{
    element = base(x, y, sort, owner);
    if (!isDefined(element))
        return undefined;
    element.alignY = "top";
    element.color = color;
    element.alpha = alpha;
    element setShader("white", width, height);
    return element;
}

text(x, y, alignment, scale, color, sort, owner)
{
    element = base(x, y, sort, owner);
    if (!isDefined(element))
        return undefined;
    element.alignX = alignment;
    element.font = "default";
    element.fontScale = scale;
    element.color = color;
    element.alpha = 1;
    element setText("");
    return element;
}
