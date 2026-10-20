// Number-pad editing keeps literal text for the shared checked integer parser

create()
{
    state = spawnstruct();
    state.cursor = 0;
    state.text = "0";
    state.status = "Editing";
    return state;
}

apply(state, action)
{
    if (state.status != "Editing")
        return;
    if (action == "left")
        state.cursor = state.cursor == 0 ? 9 : state.cursor - 1;
    else if (action == "right")
        state.cursor = state.cursor == 9 ? 0 : state.cursor + 1;
    else if (action == "select")
    {
        // The source replaces its default zero and silently holds at ten digits
        if (state.text.size == 10)
            return;
        if (state.text == "0")
            state.text = "";
        digits = "0123456789";
        state.text += getSubStr(digits, state.cursor, state.cursor + 1);
    }
    else if (action == "back")
    {
        if (state.text == "0")
            state.status = "Canceled";
        else if (state.text.size == 1)
            state.text = "0";
        else
            state.text = getSubStr(state.text, 0, state.text.size - 1);
    }
    else if (action == "confirm")
        state.status = "Confirmed";
}
