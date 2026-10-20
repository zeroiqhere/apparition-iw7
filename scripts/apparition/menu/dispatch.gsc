// Gameplay callbacks run independently so waits cannot stall the input monitor

can_start(row, busy, value)
{
    if (busy || !isDefined(row) || !isstruct(row)
        || !isDefined(row.enabled) || !row.enabled || !isDefined(row.callback))
        return false;
    return scripts\apparition\menu\availability::choice_reason(row, value) == "";
}

execute(row, value, request)
{
    self endon("disconnect");
    level endon("game_ended");
    plan = request.plan;
    succeeded = false;
    // The worker rechecks access after scheduling and before entering any callback
    if (scripts\apparition\runtime\access::can_open(self)
        && access_matches(row, scripts\apparition\runtime\access::current(self), self.apparition_access))
        succeeded = self [[row.callback]](row, value);
    // These bool callbacks own their full reopen before the source redraw timer
    if (succeeded && isDefined(row.setting)
        && (row.setting == "option_counter" || row.setting == "stealth_ui"))
        request.hud = self.apparition_hud;
    self.apparition_action_busy = false;
    if (!succeeded)
        self iPrintLn("Action unavailable or incomplete; current state remains visible");
    // The callback result never directly sets a checkbox or active-mode label
    if (scripts\apparition\runtime\access::can_open(self)
        && can_refresh(self.apparition_open, self.apparition_state, self.apparition_hud, request)
        && (plan.delay == 0 || plan.color_update))
    {
        // Theme callbacks start colors now; their bool redraw has its own timer
        mode = plan.color_update ? "theme" : plan.mode;
        self scripts\apparition\menu\controller::refresh_current(mode);
    }
}

refresh_plan(row)
{
    plan = spawnstruct();
    plan.mode = row.kind == "toggle" ? "redraw" : "update";
    plan.delay = row.kind == "toggle" ? 0.18 : 0;
    plan.color_update = false;
    if (isDefined(row.setting))
    {
        if (row.setting == "bool_display" || row.setting == "bool_location")
            plan.mode = "redraw";
        plan.color_update = row.setting == "theme" || row.setting == "smooth_rainbow";
    }
    return plan;
}

can_refresh(open, current, hud, request)
{
    return open && isDefined(current) && current == request.session && current.page == request.page
        && isDefined(hud) && hud == request.hud;
}

delayed_redraw(request)
{
    self endon("disconnect");
    level endon("game_ended");
    wait request.plan.delay;
    if (!scripts\apparition\runtime\access::can_open(self)
        || !can_refresh(self.apparition_open, self.apparition_state, self.apparition_hud, request))
        return;
    self scripts\apparition\menu\controller::refresh_current("redraw");
}

access_matches(row, access, grant)
{
    return isDefined(row) && isstruct(row) && isDefined(row.menu_access)
        && isstring(row.menu_access) && isDefined(access) && isstring(access)
        && row.menu_access == access && scripts\apparition\runtime\access::has_menu(access)
        && scripts\apparition\runtime\access::same_grant(row.menu_grant, grant);
}
