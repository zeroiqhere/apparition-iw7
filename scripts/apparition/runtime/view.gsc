// Each render starts one fresh common view before its page-specific snapshots

capture(owner, target)
{
    view = spawnstruct();
    view.owner = owner;
    view.layout = owner.apparition_layout;
    view.target = target;
    view.host = owner isHost();
    view.access = scripts\apparition\runtime\access::current(owner);
    view.menu_grant = owner.apparition_access;
    view.players = isDefined(level.players) ? level.players : [];
    // The page dispatcher owns all feature reads and keeps unrelated pages quiet
    scripts\apparition\runtime\view_pages::capture(owner.apparition_state.page, owner, target, view);
    return view;
}

unavailable_target(reason)
{
    snapshot = spawnstruct();
    snapshot.reason = reason;
    snapshot.hint = "";
    snapshot.targets = [];
    return snapshot;
}
