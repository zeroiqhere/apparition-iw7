// Menu history stores the displayed actor so back navigation cannot retarget it

run()
{
    nested_sound_pages_restore_the_selected_actor_and_source_fun_cursor();
    weapon_options_return_through_weaponry_to_the_selected_player();
    duplicate_labels_preserve_the_selected_target_identity();
    renamed_and_reordered_player_rows_keep_the_selected_reference();
    stable_keys_do_not_match_a_replacement_or_another_target();
    duplicate_machine_labels_preserve_the_selected_native_point();
    back_restores_the_parent_actor_and_cursor();
    popping_the_root_requests_close();
    numeric_previews_capture_the_first_live_seed_and_preserve_fractional_steps();
    invalid_numeric_ranges_never_write_a_preview();
    slider_selection_wraps_without_applying_a_feature();
    slider_defaults_and_saved_choices_keep_their_precedence();
    shortened_slider_choices_clamp_without_overwriting_saved_navigation();
    revisiting_a_page_restores_its_last_cursor();
    main_and_quick_sessions_keep_separate_navigation();
    death_preserves_the_quick_session_independently_of_its_page_name();
    rebuilding_rows_retains_the_selected_label_or_clamps_the_cursor();
}

nested_sound_pages_restore_the_selected_actor_and_source_fun_cursor()
{
    owner = spawnstruct();
    selected = spawnstruct();
    state = scripts\apparition\menu\state::create(owner);
    state.page = "Fun Scripts";
    state.target = selected;
    state.cursors[state.page] = 4;
    scripts\apparition\menu\state::push(state, "Sounds & Jingles", selected);
    state.cursors[state.page] = 0;
    scripts\apparition\menu\state::push(state, "Perk Jingles & Quotes", selected);
    tests\support\checks::expect(state.target == selected && state.parents.size == 2,
        "Both sound subpages retain the selected remote actor");
    tests\support\checks::expect(scripts\apparition\menu\state::pop(state)
        && state.page == "Sounds & Jingles" && state.target == selected
        && scripts\apparition\menu\state::cursor(state) == 0,
        "Back from a perk request returns to its sound parent without retargeting");
    tests\support\checks::expect(scripts\apparition\menu\state::pop(state)
        && state.page == "Fun Scripts" && state.target == selected
        && scripts\apparition\menu\state::cursor(state) == 4,
        "Back from Sounds returns to the original Fun row and selected actor");
}

renamed_and_reordered_player_rows_keep_the_selected_reference()
{
    first = spawnstruct();
    selected = spawnstruct();
    first_row = scripts\apparition\menu\model::link("Same Name", "Options", first);
    first_row.selection_key = first;
    selected_row = scripts\apparition\menu\model::link("New Name", "Options", selected);
    selected_row.selection_key = selected;
    state = scripts\apparition\menu\state::create(first);
    state.page = "Players";
    state.cursors[state.page] = 1;
    tests\support\checks::expect(scripts\apparition\menu\state::cursor_after_rebuild(state,
        [selected_row, first_row], "Same Name", selected, selected) == 0,
        "A renamed and reordered player retains the selected reference instead of the old row number");
    tests\support\checks::expect(state.cursors[state.page] == 1,
        "Resolving a renamed player leaves navigation writes to the controller");
}

stable_keys_do_not_match_a_replacement_or_another_target()
{
    target = spawnstruct();
    other_target = spawnstruct();
    selected_key = spawnstruct();
    replacement = scripts\apparition\menu\model::link("Same Name", "Options", target);
    replacement.selection_key = spawnstruct();
    different_target = scripts\apparition\menu\model::link("Same Name", "Options", other_target);
    different_target.selection_key = selected_key;
    retained = scripts\apparition\menu\model::link("Changed Name", "Options", target);
    retained.selection_key = selected_key;
    state = scripts\apparition\menu\state::create(target);
    state.cursors[state.page] = 0;
    tests\support\checks::expect(scripts\apparition\menu\state::cursor_after_rebuild(state,
        [replacement, different_target, retained], "Same Name", target, selected_key) == 2,
        "A stable key overrides display text while still requiring the original actor");
    state.cursors[state.page] = 4;
    tests\support\checks::expect(scripts\apparition\menu\state::cursor_after_rebuild(state,
        [replacement], "Same Name", target, selected_key) == 0,
        "A departed key falls back to a bounded visible cursor");
}

duplicate_machine_labels_preserve_the_selected_native_point()
{
    target = spawnstruct();
    first = spawnstruct();
    second = spawnstruct();
    first_row = scripts\apparition\menu\model::action("Up N' Atoms",
        scripts\apparition\menu\actions::entity_teleport, target, false);
    second_row = scripts\apparition\menu\model::action("Up N' Atoms",
        scripts\apparition\menu\actions::entity_teleport, target, false);
    first_row.selection_key = first;
    second_row.selection_key = second;
    state = scripts\apparition\menu\state::create(target);
    state.page = "Entity Teleports";
    state.cursors[state.page] = 1;
    resolved = scripts\apparition\menu\state::cursor_after_rebuild(state,
        [first_row, second_row], "Up N' Atoms", target, second);
    tests\support\checks::expect(resolved == 1,
        "Equal machine labels and player targets preserve the selected native point");
    resolved = scripts\apparition\menu\state::cursor_after_rebuild(state,
        [second_row, first_row], "Up N' Atoms", target, second);
    tests\support\checks::expect(resolved == 0,
        "Reordered same-label machines keep the exact selected destination");
}

duplicate_labels_preserve_the_selected_target_identity()
{
    first = spawnstruct();
    second = spawnstruct();
    first_row = scripts\apparition\menu\model::link("Same Name", "Options", first);
    second_row = scripts\apparition\menu\model::link("Same Name", "Options", second);
    state = scripts\apparition\menu\state::create(first);
    state.page = "Players";
    state.cursors[state.page] = 1;
    resolved = scripts\apparition\menu\state::cursor_after_rebuild(state,
        [first_row, second_row], "Same Name", second);
    tests\support\checks::expect(resolved == 1,
        "Matching names do not redirect selection to the first player");
    resolved = scripts\apparition\menu\state::cursor_after_rebuild(state,
        [second_row, first_row], "Same Name", second);
    tests\support\checks::expect(resolved == 0,
        "A reordered list preserves the same selected player's identity");
}

back_restores_the_parent_actor_and_cursor()
{
    owner = spawnstruct();
    selected = spawnstruct();
    state = scripts\apparition\menu\state::create(owner);
    state.cursors["Main"] = 7;
    scripts\apparition\menu\state::push(state, "Basic Scripts", selected);
    state.cursors["Basic Scripts"] = 3;
    tests\support\checks::expect(scripts\apparition\menu\state::pop(state), "A submenu has a parent");
    tests\support\checks::expect(state.page == "Main" && state.target == owner, "Back restores the original page and actor");
    tests\support\checks::expect(scripts\apparition\menu\state::cursor(state) == 7 && state.parents.size == 0, "Back restores the cursor and consumes one parent");
}

popping_the_root_requests_close()
{
    tests\support\checks::expect(!scripts\apparition\menu\state::pop(scripts\apparition\menu\state::create(spawnstruct())), "The root has no parent");
}

slider_selection_wraps_without_applying_a_feature()
{
    state = scripts\apparition\menu\state::create(spawnstruct());
    row = spawnstruct();
    row.label = "Unlimited Ammo";
    row.values = ["Continuous", "Reload", "Disable"];
    scripts\apparition\menu\state::adjust_slider(state, row, -1);
    tests\support\checks::expect(scripts\apparition\menu\state::slider_value(state, row) == "Disable", "Left from the first mode wraps to Disable");
    scripts\apparition\menu\state::adjust_slider(state, row, 1);
    tests\support\checks::expect(scripts\apparition\menu\state::slider_value(state, row) == "Continuous", "Right from the final mode wraps to Continuous");
}

slider_defaults_and_saved_choices_keep_their_precedence()
{
    state = scripts\apparition\menu\state::create(spawnstruct());
    row = spawnstruct();
    row.label = "Choice";
    row.values = ["First", "Second", "Third"];
    row.initial_index = 1;
    tests\support\checks::expect(scripts\apparition\menu\state::slider_value(state, row) == "Second",
        "An unset slider uses its source initial index");
    state.choices[state.page] = [];
    state.choices[state.page][row.label] = 0;
    tests\support\checks::expect(scripts\apparition\menu\state::slider_value(state, row) == "First",
        "A valid saved choice takes precedence over the source initial index");
}

shortened_slider_choices_clamp_without_overwriting_saved_navigation()
{
    state = scripts\apparition\menu\state::create(spawnstruct());
    state.choices[state.page] = [];
    state.choices[state.page]["Choice"] = 2;
    row = spawnstruct();
    row.label = "Choice";
    row.values = ["First", "Second"];
    tests\support\checks::expect(scripts\apparition\menu\state::slider_index(state, row) == 1
        && scripts\apparition\menu\state::slider_value(state, row) == "Second",
        "A saved index beyond a shortened list resolves to its last remaining choice");
    tests\support\checks::expect(state.choices[state.page][row.label] == 2,
        "Reading the shortened preview preserves navigation for a later larger list");
    scripts\apparition\menu\state::adjust_slider(state, row, 1);
    tests\support\checks::expect(state.choices[state.page][row.label] == 0
        && scripts\apparition\menu\state::slider_value(state, row) == "First",
        "Scrolling starts from the clamped visible choice and wraps consistently");
}

revisiting_a_page_restores_its_last_cursor()
{
    owner = spawnstruct();
    state = scripts\apparition\menu\state::create(owner);
    scripts\apparition\menu\state::push(state, "Basic Scripts", owner);
    state.cursors["Basic Scripts"] = 5;
    scripts\apparition\menu\state::pop(state);
    scripts\apparition\menu\state::push(state, "Basic Scripts", owner);
    tests\support\checks::expect(scripts\apparition\menu\state::cursor(state) == 5, "A page retains its cursor when entered again");
}

main_and_quick_sessions_keep_separate_navigation()
{
    owner = spawnstruct();
    sessions = scripts\apparition\menu\state::create_sessions(owner);
    sessions["main"].cursors["Main"] = 9;
    sessions["quick"].cursors["Quick Menu"] = 3;
    tests\support\checks::expect(sessions["quick"].page == "Quick Menu", "Quick navigation starts at its own root");
    tests\support\checks::expect(scripts\apparition\menu\state::cursor(sessions["main"]) == 9, "Quick navigation does not overwrite the main cursor");
    tests\support\checks::expect(scripts\apparition\menu\state::cursor(sessions["quick"]) == 3, "Quick navigation keeps its own cursor");
}

death_preserves_the_quick_session_independently_of_its_page_name()
{
    owner = spawnstruct();
    sessions = scripts\apparition\menu\state::create_sessions(owner);
    tests\support\checks::expect(scripts\apparition\menu\state::session_allowed(sessions, sessions["main"], true), "A living owner can keep the main menu open");
    tests\support\checks::expect(!scripts\apparition\menu\state::session_allowed(sessions, sessions["main"], false), "Death closes the main session");
    tests\support\checks::expect(scripts\apparition\menu\state::session_allowed(sessions, sessions["quick"], false), "Death keeps the Quick Menu session available");
    scripts\apparition\menu\state::push(sessions["quick"], "Perk Menu", owner);
    tests\support\checks::expect(scripts\apparition\menu\state::session_allowed(sessions, sessions["quick"], false), "A nested Quick page remains the same allowed session while dead");
    sessions["main"].page = "Quick Menu";
    tests\support\checks::expect(!scripts\apparition\menu\state::session_allowed(sessions, sessions["main"], false), "A matching page name cannot turn the main session into a dead Quick session");
    tests\support\checks::expect(!scripts\apparition\menu\state::session_allowed(sessions, undefined, false), "An absent state is not an allowed dead session");
    tests\support\checks::expect(sessions["quick"].parents.size == 1 && sessions["quick"].page == "Perk Menu", "Availability checks preserve the saved quick hierarchy");
}

rebuilding_rows_retains_the_selected_label_or_clamps_the_cursor()
{
    state = scripts\apparition\menu\state::create(spawnstruct());
    state.page = "Quick Menu";
    state.cursors[state.page] = 0;
    living_rows = [];
    foreach (label in ["God Mode", "Unlimited Ammo", "Perk Menu", "Respawn", "Revive"])
    {
        row = spawnstruct();
        row.label = label;
        living_rows[living_rows.size] = row;
    }
    tests\support\checks::expect(scripts\apparition\menu\state::cursor_after_rebuild(state, living_rows, "Respawn") == 3, "Respawn keeps selection when living-only rows return ahead of it");
    tests\support\checks::expect(scripts\apparition\menu\state::cursor_after_rebuild(state, living_rows, undefined) == 0, "Ordinary refresh keeps the current numeric cursor");
    dead_row = spawnstruct();
    dead_row.label = "Respawn";
    state.cursors[state.page] = 4;
    tests\support\checks::expect(scripts\apparition\menu\state::cursor_after_rebuild(state, [dead_row], "Revive") == 0, "A removed living-only selection clamps to the surviving dead row");
    tests\support\checks::expect(state.cursors[state.page] == 4, "Computing a rebuilt cursor does not change navigation until the controller commits it");
}


weapon_options_return_through_weaponry_to_the_selected_player()
{
    owner = spawnstruct();
    selected = spawnstruct();
    state = scripts\apparition\menu\state::create(owner);
    state.page = "Options";
    state.target = selected;
    state.cursors[state.page] = 4;
    scripts\apparition\menu\state::push(state, "Weaponry", selected);
    state.cursors[state.page] = 0;
    scripts\apparition\menu\state::push(state, "Weapon Options", selected);
    tests\support\checks::expect(state.target == selected && state.page == "Weapon Options",
        "Nested weapon controls retain the selected player rather than the menu owner");
    tests\support\checks::expect(scripts\apparition\menu\state::pop(state)
        && state.page == "Weaponry" && state.target == selected && scripts\apparition\menu\state::cursor(state) == 0,
        "Back restores the original root Options link and selected player");
    tests\support\checks::expect(scripts\apparition\menu\state::pop(state)
        && state.page == "Options" && state.target == selected && scripts\apparition\menu\state::cursor(state) == 4,
        "The next Back restores the selected-player Weaponry row in its original position");
}

numeric_previews_capture_the_first_live_seed_and_preserve_fractional_steps()
{
    state = scripts\apparition\menu\state::create(spawnstruct());
    state.page = "Host Menu";
    row = spawnstruct();
    row.label = "Field Of View Scale";
    row.range = scripts\apparition\features\fov::range();
    row.range.start = 70.5;
    tests\support\checks::expect(scripts\apparition\menu\state::slider_value(state, row) == 70.5
        && !isDefined(state.choices[state.page]),
        "Reading a numeric seed preserves its fraction without changing session state");
    scripts\apparition\menu\state::seed_slider(state, row);
    row.range.start = 80;
    tests\support\checks::expect(scripts\apparition\menu\state::slider_value(state, row) == 70.5,
        "A native setting change cannot replace the already captured uncommitted preview");
    scripts\apparition\menu\state::adjust_slider(state, row, 1);
    tests\support\checks::expect(scripts\apparition\menu\state::slider_value(state, row) == 71.5
        && row.range.start == 80,
        "Scrolling changes only the preview and retains the source fractional increment");
    scripts\apparition\menu\state::push(state, "Main", undefined);
    scripts\apparition\menu\state::pop(state);
    tests\support\checks::expect(scripts\apparition\menu\state::slider_value(state, row) == 71.5,
        "Returning to the host page preserves its numeric preview");
    row.range.maximum = 70;
    tests\support\checks::expect(scripts\apparition\menu\state::slider_value(state, row) == 70
        && state.choices[state.page][row.label] == 71.5,
        "Reading narrowed bounds clamps display without writing saved navigation");
    scripts\apparition\menu\state::seed_slider(state, row);
    tests\support\checks::expect(state.choices[state.page][row.label] == 70,
        "A real page rebuild updates an out-of-range saved preview once");
}

invalid_numeric_ranges_never_write_a_preview()
{
    state = scripts\apparition\menu\state::create(spawnstruct());
    row = spawnstruct();
    row.label = "Field Of View Scale";
    row.range = false;
    tests\support\checks::expect(!isDefined(scripts\apparition\menu\state::slider_value(state, row)),
        "Malformed numeric metadata has no reported preview");
    scripts\apparition\menu\state::seed_slider(state, row);
    scripts\apparition\menu\state::adjust_slider(state, row, 1);
    tests\support\checks::expect(!isDefined(state.choices[state.page]),
        "Malformed metadata cannot allocate or write numeric navigation");
    row.range = scripts\apparition\features\fov::range();
    scripts\apparition\menu\state::seed_slider(state, row);
    tests\support\checks::expect(!isDefined(state.choices[state.page]),
        "An unavailable live seed is not replaced with an invented default");
}
