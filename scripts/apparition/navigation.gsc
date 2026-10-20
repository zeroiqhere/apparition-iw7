// Cursor rules derived from CF4_99's Apparition draw and scrolling paths
// The renderer inserts its inert placeholder before passing a row count here

normalize_cursor(cursor, row_count)
{
    if (!isDefined(cursor))
        return 0;

    // Rebuilding a shorter menu keeps the final remaining row selected
    if (cursor >= row_count)
        return row_count - 1;

    return cursor;
}

move_cursor(cursor, direction, row_count)
{
    next_cursor = cursor + direction;

    if (next_cursor < 0)
        return row_count - 1;

    // Scrolling wraps independently of the rebuild-time cursor clamp
    if (next_cursor >= row_count)
        return 0;

    return next_cursor;
}

visible_start(cursor, row_count, page_size)
{
    if (row_count <= page_size)
        return 0;

    rows_above = int((page_size - 1) / 2);
    rows_below = int((page_size + 1) / 2);

    if (cursor <= rows_above)
        return 0;

    // Pin the viewport to its final complete page near the bottom
    if (cursor >= row_count - rows_below)
        return row_count - page_size;

    return cursor - rows_above;
}
