// Directional scrolling preserves source blank-row waits without recursive calls

plan(rows, cursor, direction, layout)
{
    steps = [];
    capacity = scripts\apparition\menu\layout::capacity(layout);
    // A complete pass bounds short pages containing only blank options
    for (attempt = 0; attempt < rows.size; attempt++)
    {
        previous = cursor;
        raw = cursor + direction;
        wrapped = raw < 0 || raw >= rows.size;
        cursor = scripts\apparition\navigation::move_cursor(cursor, direction, rows.size);
        if (wrapped && rows.size > capacity)
        {
            // Long-menu wraps return through RefreshMenu before the invalid check
            steps[steps.size] = step(cursor, previous, "redraw", 0);
            return steps;
        }
        old_start = scripts\apparition\navigation::visible_start(previous, rows.size, capacity);
        new_start = scripts\apparition\navigation::visible_start(cursor, rows.size, capacity);
        if (!scripts\apparition\menu\row_elements::invalid_label(rows[cursor].label))
        {
            steps[steps.size] = step(cursor, previous, "cursor", 0);
            return steps;
        }
        steps[steps.size] = step(cursor, previous, "cursor_pending", layout.scroll_time / 2);
        if (old_start != new_start)
        {
            // A shifted blank takes one more raw step and redraws without scanning it
            steps[steps.size] = step(cursor + direction, cursor, "redraw", 0);
            return steps;
        }
    }
    // Discard an all-blank short scan before any cursor write or wait is performed
    return [];
}

step(cursor, previous, mode, delay)
{
    item = spawnstruct();
    item.cursor = cursor;
    item.previous = previous;
    item.mode = mode;
    item.delay = delay;
    return item;
}

can_resume(request, open, current, hud, rows)
{
    if (!open || !isDefined(current) || current != request.session
        || current.page != request.page || !isDefined(current.target) || !isDefined(request.target)
        || current.target != request.target || !isDefined(hud) || hud != request.hud || hud.released
        || !isDefined(rows) || rows.size != request.rows.size
        || scripts\apparition\menu\state::cursor(current) != request.cursor)
        return false;
    // Compare the actual row objects rather than relying on whole-array equality
    for (index = 0; index < rows.size; index++)
    {
        if (rows[index] != request.rows[index])
            return false;
    }
    return true;
}

allowed(request)
{
    // The input monitor can yield while callbacks replace a HUD or its rows
    return scripts\apparition\runtime\access::can_open(self)
        && scripts\apparition\runtime\access::current(self) == request.access
        && scripts\apparition\runtime\access::same_grant(self.apparition_access, request.grant)
        && can_resume(request, self.apparition_open, self.apparition_state, self.apparition_hud, self.apparition_rows)
        && !isDefined(self.apparition_layout.active_editor)
        && scripts\apparition\menu\state::session_allowed(self.apparition_sessions, request.session,
            scripts\apparition\menu\life::is_alive(self))
        && scripts\apparition\runtime\player_control::reason(self, request.target) == "";
}

run(direction)
{
    if (!self.apparition_open || !isDefined(self.apparition_state) || !isDefined(self.apparition_hud))
        return;
    request = spawnstruct();
    request.session = self.apparition_state;
    request.page = request.session.page;
    request.target = request.session.target;
    request.cursor = scripts\apparition\menu\state::cursor(request.session);
    request.hud = self.apparition_hud;
    request.rows = self.apparition_rows;
    request.access = scripts\apparition\runtime\access::current(self);
    request.grant = self.apparition_access;
    if (!self allowed(request))
        return;
    steps = plan(request.rows, request.cursor, direction, self.apparition_layout);
    foreach (item in steps)
    {
        request.cursor = item.cursor;
        request.session.cursors[request.page] = item.cursor;
        if (item.mode == "cursor_pending")
        {
            // Edge geometry runs before the wait while selection styling stays put
            view = scripts\apparition\runtime\view::capture(self, request.target);
            scripts\apparition\menu\hud::render(request.hud, request.session, request.rows,
                self.apparition_layout, item.mode, view, item.previous, request.rows);
            wait item.delay;
            if (!self allowed(request))
                return;
        }
        else if (item.mode == "redraw")
            return self scripts\apparition\menu\controller::refresh("redraw", undefined);
        else
            return self scripts\apparition\menu\controller::refresh_current("cursor", item.previous);
    }
    return 0;
}
