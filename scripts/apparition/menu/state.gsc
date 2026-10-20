// Navigation and uncommitted slider selections belong to the menu session

create(owner)
{
    state = spawnstruct();
    state.page = "Main";
    state.target = owner;
    state.cursors = [];
    state.parents = [];
    state.choices = [];
    return state;
}

create_sessions(owner)
{
    sessions = [];
    sessions["main"] = create(owner);
    sessions["quick"] = create(owner);
    sessions["quick"].page = "Quick Menu";
    return sessions;
}

cursor(state)
{
    if (!isDefined(state.cursors[state.page]))
        return 0;
    return state.cursors[state.page];
}

push(state, page, target)
{
    parent = spawnstruct();
    parent.page = state.page;
    parent.target = state.target;
    state.parents[state.parents.size] = parent;
    state.page = page;
    if (isDefined(target))
        state.target = target;
}

pop(state)
{
    if (state.parents.size == 0)
        return false;
    parent = state.parents[state.parents.size - 1];
    remaining = [];
    for (index = 0; index < state.parents.size - 1; index++)
        remaining[remaining.size] = state.parents[index];
    state.parents = remaining;
    state.page = parent.page;
    state.target = parent.target;
    return true;
}

slider_index(state, row)
{
    if (isDefined(row.range))
        return undefined;
    index = row.initial_index;
    if (isDefined(state.choices[state.page]) && isDefined(state.choices[state.page][row.label]))
        index = state.choices[state.page][row.label];
    // Dynamic choices may shrink while the same page and row retain their selection
    return scripts\apparition\navigation::normalize_cursor(index, row.values.size);
}

slider_value(state, row)
{
    if (isDefined(row.range))
    {
        if (!isstruct(row.range))
            return undefined;
        value = row.range.start;
        if (isDefined(state.choices[state.page]) && isDefined(state.choices[state.page][row.label]))
            value = state.choices[state.page][row.label];
        return scripts\apparition\menu\numeric_slider::bound(value, row.range.minimum, row.range.maximum);
    }
    return row.values[slider_index(state, row)];
}

seed_slider(state, row)
{
    if (!isDefined(row.range))
        return;
    value = slider_value(state, row);
    if (!isDefined(value))
        return;
    if (!isDefined(state.choices[state.page]))
        state.choices[state.page] = [];
    // Rebuilds preserve an in-range choice and clamp only when its bounds changed
    if (!isDefined(state.choices[state.page][row.label]) || state.choices[state.page][row.label] != value)
        state.choices[state.page][row.label] = value;
}

adjust_slider(state, row, direction)
{
    if (isDefined(row.range))
    {
        if (!isstruct(row.range))
            return;
        next_value = scripts\apparition\menu\numeric_slider::move(slider_value(state, row), direction,
            row.range.minimum, row.range.maximum, row.range.increment);
        if (!isDefined(next_value))
            return;
    }
    else
        next_value = scripts\apparition\navigation::move_cursor(slider_index(state, row), direction, row.values.size);
    if (!isDefined(state.choices[state.page]))
        state.choices[state.page] = [];
    state.choices[state.page][row.label] = next_value;
}

session_allowed(sessions, state, alive)
{
    // Session identity still distinguishes Quick Menu after entering a nested page
    return alive || (isDefined(state) && state == sessions["quick"]);
}

cursor_after_rebuild(state, rows, selected_label, selected_target, selected_key)
{
    if (isDefined(selected_key) || isDefined(selected_label))
    {
        for (index = 0; index < rows.size; index++)
        {
            // Stable identities survive renamed rows while labels serve ordinary controls
            matches = isDefined(selected_key)
                ? isDefined(rows[index].selection_key) && rows[index].selection_key == selected_key
                : rows[index].label == selected_label;
            if (matches && (!isDefined(selected_target)
                || (isDefined(rows[index].target) && rows[index].target == selected_target)))
                return index;
        }
    }
    // A removed living-only option falls back to a valid row in the new list
    return scripts\apparition\navigation::normalize_cursor(cursor(state), rows.size);
}
