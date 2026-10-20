// Source player-message rows retain their recipient and fresh snapshot permissions

build(view, lobby)
{
    target = undefined;
    if (isDefined(view) && isstruct(view))
        target = lobby ? view.owner : view.target;
    row = scripts\apparition\menu\model::action("Send Message",
        scripts\apparition\menu\actions::open_player_message_keyboard, target, lobby);
    row.enabled = false;
    row.description = "Co-Host access is required to send player messages";
    if (!isDefined(view) || !isstruct(view)
        || !scripts\apparition\runtime\player_control::can_manage(view.access))
        return row;

    if (!lobby)
        blocked = scripts\apparition\menu\player_rows::selection_reason(view);
    else
    {
        blocked = scripts\apparition\menu\player_rows::roster_reason(view);
        if (blocked == "" && !scripts\apparition\runtime\context::in_roster(view.players, view.owner))
            blocked = "The sender must belong to the current roster";
        if (blocked == "")
        {
            recipients = scripts\apparition\runtime\context::other_players(view.players, view.owner);
            if (!recipients.size)
                blocked = "No other current players can receive a message";
        }
    }
    row.enabled = blocked == "";
    row.description = blocked != "" ? blocked : lobby
        ? "Open the source keyboard; confirm sends to all current players except the sender"
        : "Open the source keyboard; confirm sends only to the selected current player";
    return row;
}
