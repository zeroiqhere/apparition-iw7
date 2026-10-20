// Opening admission uses isolated session and request identities

run()
{
    only_the_current_pending_open_can_allocate_a_hud();
    cancelled_replaced_or_already_open_requests_are_rejected();
    changed_page_or_target_cannot_finish_an_earlier_open();
    customization_reopen_rejects_quick_and_closed_sessions();
    closing_credits_restores_the_parent_even_before_a_hud_is_allocated();
}

closing_credits_restores_the_parent_even_before_a_hud_is_allocated()
{
    owner = spawnstruct();
    state = scripts\apparition\menu\state::create(owner);
    state.page = "Menu Customization";
    state.cursors[state.page] = 0;
    scripts\apparition\menu\state::push(state, "Credits", owner);
    owner.apparition_state = state;
    owner.apparition_open = false;
    owner scripts\apparition\menu\controller::close();
    tests\support\checks::expect(state.page == "Menu Customization" && state.parents.size == 0
        && state.target == owner && scripts\apparition\menu\state::cursor(state) == 0,
        "Closing a pending credit roll cannot leave its modal page saved for the next open");
    owner scripts\apparition\menu\controller::close();
    tests\support\checks::expect(state.page == "Menu Customization" && state.parents.size == 0,
        "Repeated close does not pop the source customization page twice");
}

customization_reopen_rejects_quick_and_closed_sessions()
{
    owner = spawnstruct();
    owner.apparition_sessions = scripts\apparition\menu\state::create_sessions(owner);
    owner.apparition_state = owner.apparition_sessions["quick"];
    owner.apparition_open = true;
    hud = spawnstruct();
    owner.apparition_hud = hud;
    result = owner scripts\apparition\menu\controller::reopen(true);
    tests\support\checks::expect(!isDefined(result) && owner.apparition_open
        && owner.apparition_hud == hud && owner.apparition_state == owner.apparition_sessions["quick"],
        "Quick Menu cannot enter the main customization reopen path or release its HUD");
    owner.apparition_state = owner.apparition_sessions["main"];
    owner.apparition_open = false;
    result = owner scripts\apparition\menu\controller::reopen(false);
    tests\support\checks::expect(!isDefined(result) && !owner.apparition_open && owner.apparition_hud == hud,
        "A closed main session cannot revive through a stale customization callback");
}

only_the_current_pending_open_can_allocate_a_hud()
{
    session = opening_session();
    request = opening_request(session);
    tests\support\checks::expect(scripts\apparition\menu\controller::can_finish_open(request, request, session, false),
        "The current request and saved session can complete while no HUD is open");
    tests\support\checks::expect(!scripts\apparition\menu\controller::can_finish_open(spawnstruct(), request, session, false),
        "An older request cannot complete after a newer opening replaces it");
}

cancelled_replaced_or_already_open_requests_are_rejected()
{
    session = opening_session();
    request = opening_request(session);
    tests\support\checks::expect(!scripts\apparition\menu\controller::can_finish_open(undefined, request, session, false),
        "Close cancels pending allocation even before a HUD exists");
    tests\support\checks::expect(!scripts\apparition\menu\controller::can_finish_open(request, request, spawnstruct(), false),
        "Replacing the saved session rejects an earlier opening request");
    tests\support\checks::expect(!scripts\apparition\menu\controller::can_finish_open(request, request, session, true),
        "A request cannot allocate a second HUD over an already open one");
}

changed_page_or_target_cannot_finish_an_earlier_open()
{
    session = opening_session();
    request = opening_request(session);
    session.page = "Players";
    tests\support\checks::expect(!scripts\apparition\menu\controller::can_finish_open(request, request, session, false),
        "Changing the saved page invalidates its pending opening");
    session.page = request.page;
    session.target = spawnstruct();
    tests\support\checks::expect(!scripts\apparition\menu\controller::can_finish_open(request, request, session, false),
        "Changing the selected target invalidates its pending opening");
    session.target = undefined;
    tests\support\checks::expect(!scripts\apparition\menu\controller::can_finish_open(request, request, session, false),
        "A removed target rejects pending allocation before any target comparison");
}

opening_session()
{
    session = spawnstruct();
    session.page = "Menu Preferences";
    session.target = spawnstruct();
    return session;
}

opening_request(session)
{
    request = spawnstruct();
    request.session = session;
    request.page = session.page;
    request.target = session.target;
    return request;
}
