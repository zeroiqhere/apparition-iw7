// The source character grid and editing rules have no native side effects

columns()
{
    return ["0ANan=", "1BObo.", "2CPcp<", "3DQdq$", "4ERer#", "5FSfs-",
        "6GTgt{", "7HUhu}", "8IViv@", "9JWjw/", "^KXkx_", "!LYly[", "?MZmz]"];
}

valid_text(value)
{
    if (!isDefined(value) || !isstring(value) || !value.size || value.size > 45)
        return false;
    allowed = " ";
    foreach (column in columns())
        allowed += column;
    // Confirmation accepts exactly the characters that this keyboard can produce
    for (index = 0; index < value.size; index++)
    {
        if (!isSubStr(allowed, value[index]))
            return false;
    }
    return true;
}

create()
{
    state = spawnstruct();
    state.x = 0;
    state.y = 0;
    state.text = "";
    state.status = "Editing";
    return state;
}

apply(state, action)
{
    if (state.status != "Editing")
        return false;
    switch (action)
    {
        case "up": state.y = (state.y + 5) % 6; break;
        case "down": state.y = (state.y + 1) % 6; break;
        case "left": state.x = (state.x + 12) % 13; break;
        case "right": state.x = (state.x + 1) % 13; break;
        case "select":
        case "space":
            if (state.text.size == 45)
                return true;
            grid = columns();
            state.text += action == "space" ? " " : grid[state.x][state.y];
            break;
        case "back":
            if (!state.text.size)
                state.status = "Cancelled";
            else
                state.text = getSubStr(state.text, 0, state.text.size - 1);
            break;
        case "confirm":
            state.status = state.text.size ? "Confirmed" : "Cancelled";
            break;
    }
    return false;
}

delay_ms(action)
{
    // Only an edit that continues reaches this source branch-plus-loop delay
    switch (action)
    {
        case "up":
        case "down":
        case "left":
        case "right": return 100;
        case "select": return 200;
        case "space":
        case "back": return 150;
        case "confirm": return 0;
    }
    return 50;
}
