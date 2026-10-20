// The controller starts one guide worker that also runs while the main menu is closed

run()
{
    self endon("disconnect");
    self endon("apparition_stop_menu");
    level endon("game_ended");
    for (;;)
    {
        layout = self.apparition_layout;
        if (!scripts\apparition\runtime\context::supported()
            || !scripts\apparition\runtime\access::can_open(self) || layout.disable_instructions)
            release(self);
        else
        {
            alive = scripts\apparition\menu\life::is_alive(self);
            open = self.apparition_open;
            editing = isDefined(layout.active_editor) && layout.active_editor.mode == "instructions";
            // Adaptive placement remains active during the source entry settle
            repositioning = editing && scripts\apparition\menu\customization\editor::input_ready(layout.active_editor, getTime());
            override = editing ? scripts\apparition\menu\customization\editor::instructions("instructions") : undefined;
            if (open && isDefined(self.apparition_state) && self.apparition_state.page == "Credits")
                override = scripts\apparition\menu\credits_plan::instructions();
            if (open && isDefined(self.apparition_hud) && isDefined(self.apparition_hud.keyboard)
                && isDefined(self.apparition_hud.keyboard.ready_at))
                override = scripts\apparition\menu\keyboard::instructions(self.apparition_hud.keyboard.page);
            message = scripts\apparition\menu\instructions::text(layout, alive, open, override);
            if (message == "")
                release(self);
            else
            {
                panel = undefined;
                if (open && isDefined(self.apparition_hud) && !self.apparition_hud.released)
                    panel = self.apparition_hud.chrome["panel"];
                // IW7 exposes the input mode directly on the current player
                gamepad = self usinggamepad();
                gamepad = isDefined(gamepad) && gamepad;
                scripts\apparition\menu\customization\theme::sample(layout, level.RGBFadeColor);
                plan = scripts\apparition\menu\instructions::plan(layout, message, gamepad, panel, open, repositioning);
                render(self, layout, plan, alive);
            }
        }
        wait 0.01;
    }
}

matches(pool, plan, alive)
{
    if (!isDefined(pool) || pool.shape != plan.shape || pool.alive != alive)
        return false;
    if (!isDefined(pool.elements["string"]))
        return false;
    return !plan.background || (isDefined(pool.elements["background"]) && isDefined(pool.elements["outline"]));
}

render(owner, layout, plan, alive)
{
    pool = owner.apparition_instructions;
    if (!matches(pool, plan, alive))
    {
        release(owner);
        pool = create(owner, layout, plan, alive);
        owner.apparition_instructions = pool;
    }
    previous = pool.plan;
    if (previous.message != plan.message)
        pool.elements["string"] setText(plan.message);
    if (previous.text_x != plan.text_x || previous.text_y != plan.text_y)
    {
        pool.elements["string"].x = plan.text_x;
        pool.elements["string"].y = plan.text_y;
    }
    if (plan.background)
    {
        if (previous.x != plan.x || previous.y != plan.y)
            position_rectangles(pool, plan);
        if (previous.width != plan.width || previous.height != plan.height)
        {
            pool.elements["background"] setShader("white", plan.width, plan.height);
            pool.elements["outline"] setShader("white", plan.width + 2, plan.height + 2);
        }
        if (scripts\apparition\menu\customization\theme::color_target_changed(pool.accent, layout.accent))
        {
            // Named colors fade once; the shared rainbow writes each new phase directly
            element = pool.elements[plan.color_role];
            if (!layout.smooth_rainbow)
                element fadeOverTime(0.5);
            element.color = layout.accent;
            pool.accent = layout.accent;
        }
    }
    // Requested geometry avoids native reads while earlier fades are in progress
    pool.plan = plan;
}

create(owner, layout, plan, alive)
{
    pool = spawnstruct();
    pool.elements = [];
    pool.shape = plan.shape;
    pool.alive = alive;
    pool.accent = layout.accent;
    if (plan.background)
    {
        pool.elements["background"] = scripts\apparition\menu\hud::rectangle(plan.x, plan.y,
            plan.width, plan.height, plan.bg_color, plan.bg_alpha, 2, owner);
        pool.elements["outline"] = scripts\apparition\menu\hud::rectangle(plan.outline_x, plan.outline_y,
            plan.width + 2, plan.height + 2, layout.accent, 1, 1, owner);
        if (plan.align == "CENTER")
        {
            pool.elements["background"].alignX = "center";
            pool.elements["background"].alignY = "middle";
            pool.elements["outline"].alignX = "center";
            pool.elements["outline"].alignY = "middle";
        }
        if (layout.smooth_rainbow)
            pool.elements[plan.color_role].color = layout.accent;
    }
    alignment = plan.text_align == "CENTER" ? "center" : "left";
    pool.elements["string"] = scripts\apparition\menu\hud::text(plan.text_x, plan.text_y,
        alignment, 1.1, (1, 1, 1), 3, owner);
    pool.elements["string"] setText(plan.message);
    pool.plan = plan;
    return pool;
}

position_rectangles(pool, plan)
{
    pool.elements["background"].x = plan.x;
    pool.elements["background"].y = plan.y;
    // Centered rectangles grow equally in both directions around the same origin
    pool.elements["outline"].x = plan.outline_x;
    pool.elements["outline"].y = plan.outline_y;
}

release(owner)
{
    if (!isDefined(owner.apparition_instructions))
        return;
    pool = owner.apparition_instructions;
    // Clearing ownership first makes repeated lifecycle cleanup harmless
    owner.apparition_instructions = undefined;
    scripts\apparition\menu\ownership::destroy_elements(pool.elements);
}
