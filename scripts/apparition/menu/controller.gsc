// A single monitor owns each player's menu, input snapshot, and HUD pool

start()
{
    self endon("disconnect");
    self endon("apparition_stop_menu");
    level endon("game_ended");
    self.apparition_open = false;
    self.apparition_action_busy = false;
    self.apparition_sessions = scripts\apparition\menu\state::create_sessions(self);
    // The source restores settings during first spawned setup, after connection
    if (!isAlive(self))
        self waittill("spawned_player");
    self.apparition_layout = scripts\apparition\menu\customization\storage::load(self);
    self thread scripts\apparition\menu\instruction_hud::run();
    was_alive = scripts\apparition\menu\life::is_alive(self);
    next_command = 0;
    next_refresh = 0;
    seen_access = scripts\apparition\runtime\access::current(self);
    seen_grant = self.apparition_access;
    for (;;)
    {
        owner_alive = scripts\apparition\menu\life::is_alive(self);
        if (!scripts\apparition\runtime\context::supported())
        {
            scripts\apparition\features\show_origin::release(self);
            scripts\apparition\features\health_bar::release(self);
            scripts\apparition\features\frog_jump::release(self);
            scripts\apparition\features\crosshairs::release(self);
            scripts\apparition\features\teleport_gun::release(self);
            scripts\apparition\features\position_shortcuts::release(self);
            self close();
            wait 0.05;
            continue;
        }
        current_access = scripts\apparition\runtime\access::current(self);
        current_grant = self.apparition_access;
        if (current_access != seen_access
            || !scripts\apparition\runtime\access::same_grant(current_grant, seen_grant))
        {
            // Any role change retires navigation captured under the earlier grant
            self close();
            self.apparition_sessions = scripts\apparition\menu\state::create_sessions(self);
            seen_access = current_access;
            seen_grant = current_grant;
        }
        if (!scripts\apparition\runtime\access::can_open(self))
        {
            self close();
            wait 0.05;
            continue;
        }
        buttons = self scripts\apparition\menu\input::read();
        // Start one shared source phase when the first live host becomes available
        if (!isDefined(level.RGBFadeColor) && self isHost() && isAlive(self))
            scripts\apparition\menu\customization\theme::start_rgb_fade();
        // A disconnected selected actor closes the menu without retargeting a row
        if (self.apparition_open && (!isDefined(self.apparition_state.target) || !isPlayer(self.apparition_state.target)))
        {
            self close();
            self iPrintLn("Selected player disconnected");
        }
        // Death closes main pages while the existing quick session remains usable
        if (self.apparition_open && !scripts\apparition\menu\state::session_allowed(
            self.apparition_sessions, self.apparition_state, owner_alive))
            self close();
        else if (self.apparition_open && owner_alive != was_alive)
        {
            // Preserve a surviving row so Respawn cannot become God Mode on return
            self refresh_current("update");
            next_refresh = getTime() + 250;
        }
        was_alive = owner_alive;
        loop_delay = 0.05;
        // The modal owns input until Melee exits or its original session closes
        if (self.apparition_open && self.apparition_state.page == "Credits")
        {
            active_credits = self.apparition_hud.credits;
            if (!scripts\apparition\menu\credits::can_continue(self, active_credits))
                self close();
            else if (scripts\apparition\menu\credits::exit_requested(active_credits, buttons))
            {
                // Close retires the roll and pops its page before the same-session reopen
                reopened = self reopen(false);
                if (isDefined(reopened))
                    wait 0.1;
                next_command = getTime();
                next_refresh = getTime() + 250;
            }
            loop_delay = 0.025;
        }
        else if (self.apparition_open && isDefined(self.apparition_hud.keyboard))
        {
            active_keyboard = self.apparition_hud.keyboard;
            keyboard_status = scripts\apparition\menu\keyboard::tick(self, active_keyboard, buttons);
            if (keyboard_status == "Invalid")
                self close();
            else if (keyboard_status == "Finished")
            {
                // Source SoftUnlock recreates this same menu and settles for one tenth
                reopened = self reopen(false);
                if (isDefined(reopened))
                    wait 0.1;
                next_command = getTime();
                next_refresh = getTime() + 250;
            }
            loop_delay = 0.05;
        }
        else if (self.apparition_open && isDefined(self.apparition_layout.active_editor))
        {
            if (!scripts\apparition\menu\customization\editor::can_continue(self))
                self close();
            else
            {
                active_editor = self.apparition_layout.active_editor;
                mode = active_editor.mode;
                editor_command = scripts\apparition\menu\input::editor_command(buttons, mode);
                if (!scripts\apparition\menu\customization\editor::input_ready(active_editor, getTime()))
                    editor_command = "none";
                if (editor_command == "exit")
                {
                    if (mode == "instructions")
                        wait 0.1;
                    // A settle wait cannot close a replacement editor or a revoked session
                    if (self.apparition_layout.active_editor != active_editor)
                        continue;
                    if (!scripts\apparition\runtime\access::can_open(self)
                        || !scripts\apparition\menu\customization\editor::can_continue(self))
                    {
                        self close();
                        continue;
                    }
                    scripts\apparition\menu\customization\editor::end(self);
                    reopened = self reopen(false);
                    if (isDefined(reopened))
                        wait 0.1;
                    next_command = getTime();
                    next_refresh = getTime() + 250;
                    loop_delay = 0.05;
                }
                else
                {
                    scripts\apparition\menu\customization\editor::apply(self, editor_command);
                    loop_delay = scripts\apparition\menu\input::editor_delay_ms(editor_command) / 1000.0;
                }
            }
        }
        else
        {
            cursor = self.apparition_open ? scripts\apparition\menu\state::cursor(self.apparition_state) : 0;
            slider = self.apparition_open && self.apparition_rows[cursor].kind == "slider";
            command = scripts\apparition\menu\input::command(buttons, self.apparition_open, slider, self.apparition_layout, owner_alive);
            now = getTime();
            skip_refresh = false;
            redraw_delay = undefined;
            if (now < next_command || isDefined(self.apparition_open_request))
                command = "none";
            if (command == "open" || command == "quick")
            {
                opening_delay = self open(command == "quick");
                now = getTime();
                if (isDefined(opening_delay))
                    next_refresh = now + int(opening_delay * 1000 + 0.5);
            }
            else if (self.apparition_open)
            {
                if (command == "up" || command == "down")
                {
                    direction = command == "up" ? -1 : 1;
                    scroll_delay = self scripts\apparition\menu\scroll::run(direction);
                    // Spacer waits finish before the source command cooldown begins
                    now = getTime();
                    if (isDefined(scroll_delay))
                        next_refresh = now + int(scroll_delay * 1000 + 0.5);
                    else
                    {
                        command = "none";
                        skip_refresh = true;
                    }
                }
                else if (command == "left" || command == "right")
                {
                    row = self.apparition_rows[cursor];
                    scripts\apparition\menu\state::adjust_slider(self.apparition_state, row, command == "left" ? -1 : 1);
                    self refresh_current("update");
                }
                else if (command == "select")
                {
                    redraw_delay = self select();
                    if (isDefined(redraw_delay))
                        next_refresh = max(next_refresh, now + int(redraw_delay * 1000 + 0.5));
                }
                else if (command == "back")
                {
                    held_page = self.apparition_state.page;
                    held_quick_exit = self.apparition_layout.quick_exit;
                    action = scripts\apparition\menu\input::back_action(held_page, held_quick_exit, undefined);
                    if (action == "hold")
                    {
                        // Match the source ten-sample hold test before choosing back or close
                        held_target = self.apparition_state.target;
                        held_cursor = scripts\apparition\menu\state::cursor(self.apparition_state);
                        held_parent_count = self.apparition_state.parents.size;
                        held_samples = 0;
                        while (self meleeButtonPressed())
                        {
                            held_samples++;
                            if (held_samples >= 10)
                                break;
                            wait 0.01;
                        }
                        now = getTime();
                        state_unchanged = false;
                        if (isDefined(self.apparition_state))
                        {
                            state_unchanged = isDefined(held_target) && isDefined(self.apparition_state.target)
                                && self.apparition_state.page == held_page
                                && self.apparition_state.target == held_target
                                && self.apparition_state.parents.size == held_parent_count
                                && scripts\apparition\menu\state::cursor(self.apparition_state) == held_cursor;
                        }
                        if (!scripts\apparition\menu\input::can_resume_hold(self.apparition_open && scripts\apparition\runtime\access::can_open(self),
                            isDefined(self.apparition_hud), scripts\apparition\menu\state::session_allowed(
                                self.apparition_sessions, self.apparition_state, scripts\apparition\menu\life::is_alive(self)), state_unchanged))
                        {
                            command = "none";
                            skip_refresh = true;
                        }
                        else
                            action = scripts\apparition\menu\input::back_action(held_page, held_quick_exit, held_samples);
                    }
                    if (command != "none")
                    {
                        if (action == "close")
                            self close();
                        else if (scripts\apparition\menu\state::pop(self.apparition_state))
                            self refresh("redraw", undefined);
                        else
                            self close();
                    }
                }
                if (!skip_refresh && self.apparition_open && isDefined(self.apparition_hud)
                    && scripts\apparition\menu\state::session_allowed(self.apparition_sessions, self.apparition_state, scripts\apparition\menu\life::is_alive(self))
                    && now >= next_refresh)
                {
                    self refresh_current("update");
                    next_refresh = now + 250;
                }
            }
            if (command != "none")
                next_command = now + scripts\apparition\menu\input::cooldown(command, self.apparition_layout.scroll_time, redraw_delay);
        }
        if (loop_delay > 0)
            wait loop_delay;
    }
}

open(quick, show_animation, expected_state)
{
    if (!scripts\apparition\runtime\access::can_open(self))
        return;
    if (self.apparition_open)
        return;
    key = quick ? "quick" : "main";
    state = self.apparition_sessions[key];
    if (isDefined(expected_state) && state != expected_state)
        return;
    // Fresh opens may reset stale navigation; a reopen must preserve its exact state
    if (!isDefined(state.target) || !isPlayer(state.target)
        || scripts\apparition\runtime\player_control::reason(self, state.target) != "")
    {
        if (isDefined(expected_state))
            return;
        state = scripts\apparition\menu\state::create(self);
        if (quick)
            state.page = "Quick Menu";
        self.apparition_sessions[key] = state;
    }
    request = spawnstruct();
    request.session = state;
    request.page = state.page;
    request.target = state.target;
    request.access = scripts\apparition\runtime\access::current(self);
    request.grant = self.apparition_access;
    self.apparition_open_request = request;
    if (!quick)
        wait 0.05;
    // Closing, replacement or a changed grant cannot complete an earlier request
    admitted = scripts\apparition\runtime\access::can_open(self)
        && scripts\apparition\runtime\access::current(self) == request.access
        && scripts\apparition\runtime\access::same_grant(self.apparition_access, request.grant)
        && can_finish_open(self.apparition_open_request, request, self.apparition_sessions[key], self.apparition_open)
        && scripts\apparition\menu\state::session_allowed(self.apparition_sessions, state, scripts\apparition\menu\life::is_alive(self));
    if (admitted)
        admitted = isDefined(state.target) && isPlayer(state.target)
            && scripts\apparition\runtime\player_control::reason(self, state.target) == "";
    if (isDefined(self.apparition_open_request) && self.apparition_open_request == request)
        self.apparition_open_request = undefined;
    if (!admitted)
        return;
    self.apparition_state = state;
    self.apparition_hud = self scripts\apparition\menu\hud::create(self.apparition_layout);
    self.apparition_open = true;
    mode = isDefined(show_animation) && !show_animation ? "redraw" : "opening";
    self refresh(mode, undefined);
    if (mode == "redraw")
        return 0;
    // Passive snapshots wait for the longest visible fade; direct input stays immediate
    visible_count = min(self.apparition_rows.size, scripts\apparition\menu\layout::capacity(self.apparition_layout));
    return scripts\apparition\menu\appearance::opening_time(visible_count - 1);
}

can_finish_open(pending, request, current, open)
{
    return isDefined(pending) && pending == request && !open
        && isDefined(current) && current == request.session
        && current.page == request.page && isDefined(current.target) && isDefined(request.target)
        && current.target == request.target;
}

reopen(show_animation)
{
    // Customization is a main-menu path in the source
    if (!self.apparition_open || self.apparition_state != self.apparition_sessions["main"])
        return;
    state = self.apparition_state;
    self close();
    return self open(false, show_animation, state);
}

close()
{
    // A close also cancels allocation during the opening delay
    self.apparition_open_request = undefined;
    // A modal page must not restart when this saved navigation session is reopened
    if (isDefined(self.apparition_state) && self.apparition_state.page == "Credits")
        scripts\apparition\menu\state::pop(self.apparition_state);
    if (isDefined(self.apparition_layout) && isDefined(self.apparition_layout.active_editor))
        scripts\apparition\menu\customization\editor::end(self);
    if (!isDefined(self.apparition_open) || !self.apparition_open)
        return;
    scripts\apparition\menu\hud::release(self.apparition_hud);
    self.apparition_hud = undefined;
    self.apparition_rows = undefined;
    self.apparition_open = false;
}

push(page, target)
{
    scripts\apparition\menu\state::push(self.apparition_state, page, target);
    self refresh("redraw", undefined);
}

refresh_current(mode, previous_cursor)
{
    // Stable-page rebuilds retain the actor and any distinct native destination
    row = self.apparition_rows[scripts\apparition\menu\state::cursor(self.apparition_state)];
    previous_rows = self.apparition_rows;
    return self refresh(mode, row.label, row.target, row.selection_key, previous_cursor, previous_rows);
}

refresh(mode, selected_label, selected_target, selected_key, previous_cursor, previous_rows)
{
    view = scripts\apparition\runtime\view::capture(self, self.apparition_state.target);
    // Source theme fades use the existing option snapshot until the bool redraw
    if (mode != "theme")
    {
        self.apparition_rows = scripts\apparition\menu\model::build(self.apparition_state.page, view);
        // Only new rows receive captures; theme updates keep queued grants intact
        foreach (row in self.apparition_rows)
        {
            row.menu_access = view.access;
            row.menu_grant = view.menu_grant;
            scripts\apparition\menu\state::seed_slider(self.apparition_state, row);
        }
    }
    self.apparition_state.cursors[self.apparition_state.page] = scripts\apparition\menu\state::cursor_after_rebuild(self.apparition_state, self.apparition_rows, selected_label, selected_target, selected_key);
    return scripts\apparition\menu\hud::render(self.apparition_hud, self.apparition_state, self.apparition_rows, self.apparition_layout, mode, view, previous_cursor, previous_rows);
}

select()
{
    if (!scripts\apparition\runtime\access::can_open(self))
        return;
    row = self.apparition_rows[scripts\apparition\menu\state::cursor(self.apparition_state)];
    value = row.kind == "slider" ? scripts\apparition\menu\state::slider_value(self.apparition_state, row) : undefined;
    if (!scripts\apparition\menu\dispatch::can_start(row, self.apparition_action_busy, value))
    {
        reason = self.apparition_action_busy ? "An action is still running"
            : scripts\apparition\menu\availability::description(row, value);
        self iPrintLn(reason);
        return;
    }
    self.apparition_action_busy = true;
    request = spawnstruct();
    request.session = self.apparition_state;
    request.page = request.session.page;
    request.hud = self.apparition_hud;
    request.plan = scripts\apparition\menu\dispatch::refresh_plan(row);
    // The source bool timer starts at selection, independently of callback waits
    if (request.plan.delay > 0)
        self thread scripts\apparition\menu\dispatch::delayed_redraw(request);
    self thread scripts\apparition\menu\dispatch::execute(row, value, request);
    return request.plan.delay;
}
