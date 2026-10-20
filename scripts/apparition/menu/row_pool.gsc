// Viewport transitions keep each retained option attached to its HUD group

transition(previous_rows, rows, previous_cursor, cursor, layout)
{
    capacity = scripts\apparition\menu\layout::capacity(layout);
    plan = spawnstruct();
    plan.start = scripts\apparition\navigation::visible_start(cursor, rows.size, capacity);
    plan.shift = 0;
    plan.time = 0;
    plan.redraw = true;
    if (!isDefined(previous_rows) || !isDefined(previous_cursor)
        || previous_rows.size != rows.size)
        return plan;
    // A long-page wrap still redraws when its visible window shifts by only one
    if (rows.size > capacity && abs(cursor - previous_cursor) > 1)
        return plan;
    previous_start = scripts\apparition\navigation::visible_start(previous_cursor, previous_rows.size, capacity);
    shift = plan.start - previous_start;
    // Wraps and larger jumps use the source's immediate refresh path
    if (shift < -1 || shift > 1)
        return plan;
    first = max(previous_start, plan.start);
    end = min(min(previous_start, plan.start) + capacity, rows.size);
    for (index = first; index < end; index++)
    {
        // Rebuilt rows are new structs, so their visible identity is compared
        before = previous_rows[index];
        after = rows[index];
        if (!same_row(before, after))
            return plan;
    }
    plan.shift = shift;
    plan.time = previous_cursor == cursor ? 0 : layout.scroll_time;
    plan.redraw = false;
    return plan;
}

needs_redraw(mode, previous_rows, rows, motion)
{
    if (mode == "opening" || mode == "redraw")
        return true;
    if (mode == "cursor" || mode == "cursor_pending")
        return motion.redraw;
    if (!isDefined(previous_rows) || previous_rows.size != rows.size)
        return true;
    // Status and slider updates can retain handles only while their identities match
    for (index = 0; index < rows.size; index++)
    {
        if (!same_row(previous_rows[index], rows[index]))
            return true;
    }
    return false;
}

same_row(before, after)
{
    return before.label == after.label && before.kind == after.kind
        && same_optional(before.target, after.target)
        && same_optional(before.selection_key, after.selection_key)
        && same_optional(before.destination, after.destination)
        && same_optional(before.setting, after.setting);
}

same_optional(before, after)
{
    if (!isDefined(before) || !isDefined(after))
        return !isDefined(before) && !isDefined(after);
    return before == after;
}

rotate(pool, shift)
{
    rotated = spawnstruct();
    rotated.rows = [];
    capacity = pool.rows.size;
    // Read the old order until the complete replacement array has been built
    for (index = 0; index < pool.rows.size; index++)
    {
        if (shift > 0)
            slot = index == capacity - 1 ? pool.spare : pool.rows[index + 1];
        else
            slot = index == 0 ? pool.spare : pool.rows[index - 1];
        rotated.rows[index] = slot;
    }
    rotated.spare = pool.rows[shift > 0 ? 0 : capacity - 1];
    return rotated;
}
