// Row-pool contracts cover identity-safe viewport transitions without HUD calls

run()
{
    transition_uses_canonical_windows_for_supported_capacities();
    transition_uses_the_applied_duration();
    transition_requires_matching_context_and_retained_identity();
    rotation_preserves_every_visible_group_reference();
    redraw_policy_distinguishes_opening_cursor_and_snapshot_updates();
    zero_duration_cursor_motion_still_retains_eligible_rows();
    single_row_cursor_wrap_retains_the_existing_option_group();
}

single_row_cursor_wrap_retains_the_existing_option_group()
{
    layout = tests\fixtures\layout::for_capacity(10);
    rows = row_list(1);
    motion = scripts\apparition\menu\row_pool::transition(rows, rows, 0, 0, layout);
    tests\support\checks::expect(motion.start == 0 && motion.shift == 0 && motion.time == 0
        && !motion.redraw,
        "Wrapping the only option leaves its live group in place without a viewport move");
}

redraw_policy_distinguishes_opening_cursor_and_snapshot_updates()
{
    layout = tests\fixtures\layout::for_capacity(10);
    before = row_list(20);
    after = copy_rows(before);
    motion = scripts\apparition\menu\row_pool::transition(before, after, 0, 1, layout);
    foreach (mode in ["opening", "redraw"])
        tests\support\checks::expect(scripts\apparition\menu\row_pool::needs_redraw(mode, before, after, motion),
            "Opening and explicit refresh replace option handles even when row identities match");
    tests\support\checks::expect(!scripts\apparition\menu\row_pool::needs_redraw("cursor", before, after, motion),
        "An admitted cursor transition retains its matching option groups");
    tests\support\checks::expect(!scripts\apparition\menu\row_pool::needs_redraw("cursor_pending", before, after, motion),
        "A pending blank step retains its matching geometry without ordinary selection styling");
    motion = scripts\apparition\menu\row_pool::transition(before, after, 19, 0, layout);
    tests\support\checks::expect(scripts\apparition\menu\row_pool::needs_redraw("cursor", before, after, motion),
        "A long-page cursor wrap replaces option handles");
    tests\support\checks::expect(scripts\apparition\menu\row_pool::needs_redraw("cursor_pending", before, after, motion),
        "A pending geometry request cannot bypass the long-wrap redraw rule");
    tests\support\checks::expect(!scripts\apparition\menu\row_pool::needs_redraw("update", before, after, motion),
        "A stable snapshot update does not inherit a cursor redraw decision");
    after[5].checked = true;
    after[5].enabled = false;
    after[5].description = "Current state changed";
    tests\support\checks::expect(!scripts\apparition\menu\row_pool::needs_redraw("update", before, after, motion),
        "Checked, enabled and description updates retain matching handles");
    after[5].target = spawnstruct();
    tests\support\checks::expect(scripts\apparition\menu\row_pool::needs_redraw("update", before, after, motion),
        "A changed snapshot actor requires a fresh option draw");
    tests\support\checks::expect(scripts\apparition\menu\row_pool::needs_redraw("update", before, row_list(19), motion)
        && scripts\apparition\menu\row_pool::needs_redraw("update", undefined, after, motion),
        "Changed counts and missing previous snapshots require fresh option groups");
}

zero_duration_cursor_motion_still_retains_eligible_rows()
{
    layout = tests\fixtures\layout::for_capacity(10);
    layout.scroll_time = 0;
    rows = row_list(20);
    motion = scripts\apparition\menu\row_pool::transition(rows, rows, 4, 5, layout);
    tests\support\checks::expect(!motion.redraw && motion.time == 0 && motion.shift == 1,
        "Zero duration remains an admitted edge transition rather than a redraw fallback");
    tests\support\checks::expect(!scripts\apparition\menu\row_pool::needs_redraw("cursor", rows, rows, motion),
        "Zero-duration scrolling preserves the retained native group identities");
}

transition_uses_canonical_windows_for_supported_capacities()
{
    foreach (capacity in [5, 8, 9, 10, 11, 12, 14])
    {
        layout = tests\fixtures\layout::for_capacity(capacity);
        rows = row_list(30);

        result = scripts\apparition\menu\row_pool::transition(rows, rows, 0, 1, layout);
        tests\support\checks::expect(result.start == scripts\apparition\navigation::visible_start(1, rows.size, capacity)
            && result.shift == 0 && result.time == layout.scroll_time,
            "Adjacent down movement inside one viewport animates without rotating slots");
        result = scripts\apparition\menu\row_pool::transition(rows, rows, 1, 0, layout);
        tests\support\checks::expect(result.start == 0 && result.shift == 0 && result.time == layout.scroll_time,
            "Adjacent up movement inside one viewport animates without rotating slots");

        boundary = int((capacity - 1) / 2);
        result = scripts\apparition\menu\row_pool::transition(rows, rows, boundary, boundary + 1, layout);
        tests\support\checks::expect(result.start == scripts\apparition\navigation::visible_start(boundary + 1, rows.size, capacity)
            && result.shift == 1 && result.time == layout.scroll_time,
            "Crossing one row into the next viewport requests one forward slot rotation");
        result = scripts\apparition\menu\row_pool::transition(rows, rows, boundary + 1, boundary, layout);
        tests\support\checks::expect(result.start == scripts\apparition\navigation::visible_start(boundary, rows.size, capacity)
            && result.shift == -1 && result.time == layout.scroll_time,
            "Crossing one row back into the prior viewport requests one reverse slot rotation");

        short_rows = row_list(5);
        result = scripts\apparition\menu\row_pool::transition(short_rows, short_rows, 4, 0, layout);
        tests\support\checks::expect(result.start == 0 && result.shift == 0 && result.time == layout.scroll_time,
            "A short-menu wrap animates within its unchanged viewport");

        // A long-page wrap can move the viewport only one row when the page barely overflows
        overflow_rows = row_list(capacity + 1);
        result = scripts\apparition\menu\row_pool::transition(overflow_rows, overflow_rows, capacity, 0, layout);
        tests\support\checks::expect(result.start == 0 && result.shift == 0 && result.time == 0,
            "A wrap on a page one row longer than capacity redraws instead of sliding backward");
        result = scripts\apparition\menu\row_pool::transition(overflow_rows, overflow_rows, 0, capacity, layout);
        tests\support\checks::expect(result.start == 1 && result.shift == 0 && result.time == 0,
            "A reverse wrap on a barely overflowing page redraws instead of sliding forward");

        result = scripts\apparition\menu\row_pool::transition(rows, rows, 29, 0, layout);
        tests\support\checks::expect(result.start == 0 && result.shift == 0 && result.time == 0,
            "A long-menu wrap across distant viewports redraws without slot rotation");
    }
}

transition_uses_the_applied_duration()
{
    rows = row_list(30);
    layout = tests\fixtures\layout::for_capacity(10);
    layout.scroll_time = 0;
    result = scripts\apparition\menu\row_pool::transition(rows, rows, 0, 1, layout);
    tests\support\checks::expect(result.shift == 0 && result.time == 0,
        "A same-window cursor move respects a configured zero duration");

    layout.scroll_time = 0.25;
    result = scripts\apparition\menu\row_pool::transition(rows, rows, 0, 1, layout);
    tests\support\checks::expect(result.shift == 0 && result.time == 0.25,
        "A same-window cursor move uses the configured quarter-second duration");
}

transition_requires_matching_context_and_retained_identity()
{
    layout = tests\fixtures\layout::for_capacity(10);
    previous_rows = row_list(30);
    rows = copy_rows(previous_rows);
    result = scripts\apparition\menu\row_pool::transition(undefined, rows, 4, 5, layout);
    tests\support\checks::expect(result.start == 1 && result.shift == 0 && result.time == 0,
        "Missing previous rows keep the canonical current start and disable animation");
    result = scripts\apparition\menu\row_pool::transition(previous_rows, rows, undefined, 5, layout);
    tests\support\checks::expect(result.start == 1 && result.shift == 0 && result.time == 0,
        "Missing previous cursor disables animation without changing the canonical start");
    result = scripts\apparition\menu\row_pool::transition(previous_rows, rows, 5, 5, layout);
    tests\support\checks::expect(result.start == 1 && result.shift == 0 && result.time == 0,
        "An unchanged cursor does not rotate or animate the pool");
    result = scripts\apparition\menu\row_pool::transition(previous_rows, row_list(29), 4, 5, layout);
    tests\support\checks::expect(result.start == 1 && result.shift == 0 && result.time == 0,
        "A changed row count disables rotation while keeping the current viewport start");

    // Absolute row 10 is entering and row 0 is leaving; neither is retained in both windows
    rows = copy_rows(previous_rows);
    previous_rows[0].label = "Leaving row changed";
    rows[10].label = "Entering row changed";
    result = scripts\apparition\menu\row_pool::transition(previous_rows, rows, 4, 5, layout);
    tests\support\checks::expect(result.start == 1 && result.shift == 1 && result.time == layout.scroll_time,
        "Only the overlap is checked when a one-row viewport shift enters and leaves slots");

    foreach (field in ["label", "kind", "target", "selection_key", "destination", "setting"])
    {
        previous_rows = row_list(30);
        rows = copy_rows(previous_rows);
        if (field == "label")
            rows[5].label = "Renamed retained row";
        else if (field == "kind")
            rows[5].kind = "submenu";
        else if (field == "target")
            rows[5].target = spawnstruct();
        else if (field == "selection_key")
            rows[5].selection_key = "new key";
        else if (field == "destination")
            rows[5].destination = "New page";
        else
            rows[5].setting = "new setting";

        result = scripts\apparition\menu\row_pool::transition(previous_rows, rows, 4, 5, layout);
        tests\support\checks::expect(result.start == 1 && result.shift == 0 && result.time == 0,
            "A changed retained row identity cancels both rotation and animation");
    }

    previous_rows = row_list(30);
    rows = copy_rows(previous_rows);
    previous_rows[5].target = spawnstruct();
    previous_rows[5].selection_key = "stable key";
    rows[5].selection_key = "stable key";
    result = scripts\apparition\menu\row_pool::transition(previous_rows, rows, 4, 5, layout);
    tests\support\checks::expect(result.shift == 0 && result.time == 0,
        "Removing a previously present optional actor field invalidates retained identity");

    previous_rows = row_list(30);
    previous_rows[5].target = spawnstruct();
    previous_rows[5].selection_key = "stable key";
    rows = copy_rows(previous_rows);
    result = scripts\apparition\menu\row_pool::transition(previous_rows, rows, 4, 5, layout);
    tests\support\checks::expect(result.shift == 1 && result.time == layout.scroll_time,
        "The same actor and selection key retain row identity across a rebuilt snapshot");

    previous_rows[5].destination = "Stable page";
    previous_rows[5].setting = "Stable setting";
    rows[5].destination = "Stable page";
    rows[5].setting = "Stable setting";
    result = scripts\apparition\menu\row_pool::transition(previous_rows, rows, 4, 5, layout);
    tests\support\checks::expect(result.shift == 1 && result.time == layout.scroll_time,
        "Matching submenu destination and settings key retain row identity");

    previous_rows[5].checked = false;
    previous_rows[5].enabled = true;
    previous_rows[5].description = "Before refresh";
    rows[5].checked = true;
    rows[5].enabled = false;
    rows[5].description = "After refresh";
    result = scripts\apparition\menu\row_pool::transition(previous_rows, rows, 4, 5, layout);
    tests\support\checks::expect(result.shift == 1 && result.time == layout.scroll_time,
        "Checked state, availability and description changes do not alter row identity");

    previous_rows = row_list(30);
    rows = copy_rows(previous_rows);
    temp = rows[5];
    rows[5] = rows[6];
    rows[6] = temp;
    result = scripts\apparition\menu\row_pool::transition(previous_rows, rows, 4, 5, layout);
    tests\support\checks::expect(result.shift == 0 && result.time == 0,
        "Reordering retained rows cancels a slot rotation");

    previous_rows = row_list(30);
    rows = copy_rows(previous_rows);
    rows[5].label = "Renamed retained row";
    result = scripts\apparition\menu\row_pool::transition(previous_rows, rows, 0, 1, layout);
    tests\support\checks::expect(result.start == 0 && result.shift == 0 && result.time == 0,
        "A retained identity change also disables same-window scale animation");
}

rotation_preserves_every_visible_group_reference()
{
    foreach (capacity in [5, 8, 9, 10, 11, 12, 14])
    {
        pool = row_pool_fixture(capacity);
        forward = scripts\apparition\menu\row_pool::rotate(pool, 1);
        tests\support\checks::expect(forward.rows.size == capacity && forward.spare == pool.rows[0],
            "A forward rotation moves the outgoing first slot into the spare");
        for (index = 0; index < capacity - 1; index++)
            tests\support\checks::expect(forward.rows[index] == pool.rows[index + 1],
                "A forward rotation shifts each retained visible slot by one");
        tests\support\checks::expect(forward.rows[capacity - 1] == pool.spare,
            "A forward rotation places the spare at the entering edge");
        expect_same_pool_references(pool, forward);
        tests\support\checks::expect(pool.rows[0].token == 0 && pool.spare.token == capacity,
            "Rotation leaves the input pool unchanged");

        backward = scripts\apparition\menu\row_pool::rotate(pool, -1);
        tests\support\checks::expect(backward.rows[0] == pool.spare
            && backward.spare == pool.rows[capacity - 1],
            "A reverse rotation moves the spare to the entering edge and outgoing slot");
        for (index = 1; index < capacity; index++)
            tests\support\checks::expect(backward.rows[index] == pool.rows[index - 1],
                "A reverse rotation shifts each retained visible slot by one");
        expect_same_pool_references(pool, backward);

        restored = scripts\apparition\menu\row_pool::rotate(forward, -1);
        expect_pool_equal(pool, restored);
        repeated = scripts\apparition\menu\row_pool::rotate(forward, 1);
        expect_same_pool_references(pool, repeated);
        tests\support\checks::expect(repeated.rows[0] == pool.rows[2]
            && repeated.rows[capacity - 2] == pool.spare
            && repeated.rows[capacity - 1] == pool.rows[0]
            && repeated.spare == pool.rows[1],
            "Repeated forward rotations advance only the active window while retaining every slot");
    }
}


row_list(count)
{
    rows = [];
    for (index = 0; index < count; index++)
    {
        row = spawnstruct();
        row.label = "Row " + index;
        row.kind = "action";
        rows[rows.size] = row;
    }
    return rows;
}

copy_rows(source)
{
    rows = [];
    foreach (source_row in source)
    {
        row = spawnstruct();
        row.label = source_row.label;
        row.kind = source_row.kind;
        if (isDefined(source_row.target))
            row.target = source_row.target;
        if (isDefined(source_row.selection_key))
            row.selection_key = source_row.selection_key;
        if (isDefined(source_row.destination))
            row.destination = source_row.destination;
        if (isDefined(source_row.setting))
            row.setting = source_row.setting;
        rows[rows.size] = row;
    }
    return rows;
}

row_pool_fixture(capacity)
{
    pool = spawnstruct();
    pool.rows = [];
    for (index = 0; index < capacity; index++)
    {
        slot = spawnstruct();
        slot.token = index;
        pool.rows[pool.rows.size] = slot;
    }
    pool.spare = spawnstruct();
    pool.spare.token = capacity;
    return pool;
}

expect_same_pool_references(expected, actual)
{
    tests\support\checks::expect(isDefined(actual) && isstruct(actual)
        && isDefined(actual.rows) && isarray(actual.rows) && actual.rows.size == expected.rows.size
        && isDefined(actual.spare), "A rotated pool retains its visible active slots and one spare");
    if (!isDefined(actual) || !isstruct(actual) || !isDefined(actual.rows)
        || !isarray(actual.rows) || actual.rows.size != expected.rows.size || !isDefined(actual.spare))
        return;

    references = [];
    for (index = 0; index < expected.rows.size; index++)
    {
        reference = actual.rows[index];
        tests\support\checks::expect(!scripts\engine\utility::array_contains(references, reference),
            "A row slot reference appears only once in the rotated pool");
        references[references.size] = reference;
    }
    tests\support\checks::expect(!scripts\engine\utility::array_contains(references, actual.spare),
        "The spare reference is distinct from every row slot");
    references[references.size] = actual.spare;

    for (index = 0; index < expected.rows.size; index++)
        tests\support\checks::expect(scripts\engine\utility::array_contains(references, expected.rows[index]),
            "Every original row slot reference remains owned after rotation");
    tests\support\checks::expect(scripts\engine\utility::array_contains(references, expected.spare),
        "The original spare reference remains owned after rotation");
}

expect_pool_equal(expected, actual)
{
    valid = isDefined(actual) && isstruct(actual) && isDefined(actual.rows)
        && isarray(actual.rows) && actual.rows.size == expected.rows.size && isDefined(actual.spare);
    tests\support\checks::expect(valid && actual.spare == expected.spare,
        "A reverse rotation restores the original spare and full row pool");
    if (!valid)
        return;
    for (index = 0; index < expected.rows.size; index++)
        tests\support\checks::expect(actual.rows[index] == expected.rows[index],
            "A reverse rotation restores each original HUD slot reference");
}
