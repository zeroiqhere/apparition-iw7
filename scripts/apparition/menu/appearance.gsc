// One row plan controls indicator placement, colors, opacity and selected scale

slider_text(row, value, index)
{
    text = "< " + (isDefined(value) ? value : "Unknown") + " >";
    if (!isDefined(row.range))
        text += " [" + (index + 1) + "/" + row.values.size + "]";
    return text;
}

opening_time(visible_index)
{
    // The same duration controls native row fades and the first passive refresh
    return isDefined(visible_index) ? visible_index * 0.1 : 0;
}

fade_times(scroll_time, opening_index, entering, theme_change, rainbow, checked_boxes)
{
    times = spawnstruct();
    times.text = 0;
    times.fill = 0;
    times.line = 0;
    times.alpha = isDefined(opening_index) ? opening_time(opening_index) : scroll_time;
    // Fresh elements and rainbow samples receive their color before any opacity fade
    if (isDefined(opening_index) || entering || rainbow)
        return times;
    if (scroll_time > 0)
        times.text = scroll_time;
    else if (theme_change)
    {
        times.text = 1;
        times.fill = checked_boxes ? 0.5 : 0;
        times.line = 0.5;
    }
    return times;
}

row_style(row, selected, layout)
{
    style = spawnstruct();
    colored = layout.colored_cursor && layout.design != "Native" && layout.design != "Classic";
    style.color = selected && colored ? layout.accent : (1, 1, 1);
    style.alpha = !selected && layout.spotlight_cursor ? 0.4 : 1;
    style.scale = selected && layout.large_cursor ? 1.2 : 1;
    style.label_x = layout.x + 4;
    style.box_x = layout.bool_location == "Left" ? layout.x + 9 : layout.x + layout.width - 8;
    style.fill_color = (0, 0, 0);
    style.line_color = layout.accent;
    style.boxes = false;
    style.value = "";
    if (row.kind == "toggle")
    {
        style.boxes = layout.bool_display == "Boxes";
        style.fill_color = row.checked ? layout.accent : (0, 0, 0);
        if (style.boxes && layout.bool_location == "Left")
            style.label_x = style.box_x + 9;
        else if (layout.bool_display == "Text")
            style.value = row.checked ? "ON" : "OFF";
        else if (layout.bool_display == "Text Color" && row.checked)
            // Checked green takes priority over both selected and unselected text colors
            style.color = (0, 1, 0);
    }
    else if (row.kind == "submenu")
        style.value = ">";
    return style;
}

opacity(row, selected, style, choice_blocked)
{
    label_alpha = style.alpha;
    value_alpha = style.alpha;
    // A row-level block dims its label while its preview or saved state stays readable
    if (!row.enabled)
        label_alpha = selected ? 0.65 : 0.3;
    else if (choice_blocked)
    {
        // An unavailable choice dims both present text elements after spotlight
        label_alpha *= 0.65;
        value_alpha *= 0.65;
    }
    if (style.boxes || (row.kind != "slider" && style.value == ""))
        value_alpha = 0;
    box_alpha = style.boxes ? style.alpha : 0;
    return [label_alpha, value_alpha, box_alpha, 0];
}

line_opacity(previous, row_alpha, opening, fresh)
{
    if (opening)
        return row_alpha;
    // Retained lines keep the opening target because source cursor styling skips them
    return fresh ? 0.4 : previous;
}

counter(cursor, row_count, layout, frame)
{
    counter = spawnstruct();
    counter.index = cursor + 1;
    counter.total = row_count;
    counter.x = layout.x + layout.width - (row_count >= 10 ? 16 : 12);
    // Reuse the drawn title or bottom line rather than copying their design offsets
    beside_title = layout.design == "Classic" || layout.design == "Native";
    counter.y = beside_title ? frame.roles["title"].y : frame.roles["bottom"].y + 8;
    counter.alpha = layout.option_counter && layout.design != "AIO" && layout.design != "Basic"
        ? (beside_title ? frame.roles["title"].alpha : 0.7) : 0;
    return counter;
}
