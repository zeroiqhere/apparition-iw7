// Menu descriptors are inspected without creating a HUD or invoking game actions

run()
{
    god_hints_explain_personal_and_mixed_lobby_toggle_direction();
    perk_hints_explain_each_native_inventory_toggle_direction();
    retention_hints_explain_snapshot_discard_and_mixed_enable();
    fun_insta_kill_routes_the_selected_actor_without_caching_damage_state();
    sound_pages_route_stable_perk_requests_to_the_selected_actor();
    fun_scripts_routes_the_source_action_to_the_selected_actor();
    fun_health_bar_routes_a_configured_toggle_without_caching_native_state();
    fun_frog_jump_routes_configured_intent_to_the_selected_player();
    lobby_teleport_keeps_source_slider_position_and_lobby_scope();
    cohost_lobby_rows_follow_source_permissions_without_expanding_iw_extensions();
    server_modifications_route_owner_scoped_global_rows();
    basic_god_mode_binds_the_selected_player_and_callback();
    god_mode_rows_reflect_flags_without_changing_them();
    god_mode_checkbox_supports_recovery_after_hook_loss();
    god_mode_lobby_rows_validate_actor_snapshot_before_reading_flags();
    god_mode_guest_lobby_denial_precedes_invalid_roster_reason();
    basic_explosive_protection_keeps_its_source_position_and_personal_scope();
    explosive_protection_rows_follow_its_flag_without_changing_god_mode();
    explosive_protection_rows_allow_hook_loss_cleanup_but_reject_enable();
    explosive_protection_does_not_appear_in_quick_or_lobby_menus();
    invisibility_row_keeps_source_position_and_personal_toggle();
    invisibility_checkbox_reports_configuration_without_changing_flags();
    hud_visibility_row_keeps_source_position_and_saved_intent();
    sprint_fire_keeps_source_position_and_reports_tracked_perk();
    multi_jump_keeps_source_position_and_input_setup_admission();
    custom_crosshairs_keep_source_position_and_personal_scope();
    teleport_navigation_keeps_source_position_and_selected_target();
    score_slider_keeps_source_scope_and_literal_preview();
    score_rows_reject_missing_and_invalid_native_snapshots();
    movement_slider_keeps_source_position_range_and_default();
    movement_slider_separates_preview_from_configured_absolute_scale();
    personal_rows_reject_actor_snapshots_before_reading_target_fields();
    stale_target_rows_leave_saved_settings_unchanged();
    personal_rows_reject_missing_and_malformed_actor_reasons();
    perk_controls_gate_inventory_reads_and_actions_on_actor_snapshots();
    lobby_perk_controls_reject_invalid_actor_snapshots_before_inventory_reads();
    basic_target_controls_keep_their_source_page_scope();
    basic_and_quick_equipment_rows_bind_personal_settings();
    lobby_equipment_row_binds_current_roster_and_host_scope();
    equipment_rendering_preserves_flags_and_empty_rosters_fail_closed();
    equipment_personal_setting_remains_configurable_while_dead();
    equipment_status_explains_readiness_without_overriding_configuration();
    equipment_status_defaults_to_unknown_without_blocking_configuration();
    ammo_row_keeps_all_three_source_modes();
    ammo_lobby_configuration_requires_a_valid_roster_snapshot();
    ammo_lobby_guest_denial_precedes_roster_status();
    actor_snapshot_reason_is_shared_by_setting_rows();
    revive_rows_preserve_source_positions_and_bind_scopes();
    revive_pending_and_missing_snapshots_fail_closed();
    revive_lobby_host_reason_precedes_missing_snapshot();
    revive_rendering_preserves_snapshot_and_quick_life_filter();
    unsupported_source_rows_have_no_gameplay_callback();
    lobby_actions_bind_lobby_scope();
    spaceland_and_stage_zero_share_the_native_dj_parts_action();
    dj_parts_controls_reject_stale_and_wrong_stage_snapshots();
    spaceland_scripts_puts_native_power_first();
    spaceland_scripts_links_to_ghosts_n_skulls_controls();
    ghosts_controls_bind_host_face_action_and_readonly_steps();
    ghosts_final_step_requires_native_activation_separate_from_arena_activity();
    ghosts_status_keeps_wave_counts_and_arena_results_distinct();
    dance_assist_rows_bind_host_start_cancel_and_worker_status();
    dance_assist_context_gates_start_without_blocking_cancel();
    dance_assist_guest_and_missing_snapshots_fail_closed();
    floating_skull_action_binds_host_and_preserves_native_progress();
    floating_skull_actions_fail_closed_for_guests_and_pending_hits();
    floating_skull_missing_snapshots_are_unknown_and_disabled();
    brute_cabinet_action_binds_host_and_native_progress();
    brute_cabinet_action_gates_guest_context_and_running_input();
    brute_cabinet_missing_snapshots_fail_closed_and_status_stays_readonly();
    brute_cabinet_routes_show_initial_unlock_reactivation_and_unavailable();
    ghosts_page_fails_closed_and_guests_keep_progress_visible();
    quick_menu_keeps_the_source_row_order();
    quick_menu_filters_alive_rows_and_preserves_host_controls();
    perk_rows_show_full_mixed_and_empty_roster_reasons();
    guest_lobby_perk_rows_show_host_reason();
    perk_rows_use_selected_callback_readiness();
    malformed_native_callback_shapes_disable_perks_without_hiding_ownership();
    personal_perk_rows_require_a_living_target_without_hiding_ownership();
    personal_perk_rows_reject_malformed_inventory_but_keep_missing_inventory_configurable();
    lobby_perk_rows_use_inventory_rejection_without_blocking_a_valid_personal_target();
    downed_personal_perk_rows_preserve_ownership_and_future_retention();
    a_downed_lobby_player_blocks_the_whole_immediate_perk_selection();
    personal_perk_rows_fail_closed_for_missing_or_malformed_readiness();
    personal_perk_rows_report_actor_denial_before_temporary_readiness();
    temporary_perk_window_blocks_immediate_rows_but_preserves_native_ownership();
    retain_perks_rows_bind_target_and_lobby_scope();
    retain_perks_checkmarks_read_current_roster_records_without_mutation();
    retain_perks_follow_hook_host_and_actor_readiness();
    checked_retention_rows_remain_available_for_disabling_after_hook_loss();
    ufo_final_stage_is_unchecked_until_native_completion();
    malformed_ufo_stage_data_keeps_all_stage_actions_unavailable();
    the_portal_stage_binds_native_entry_and_explains_the_wave_wait();
    spaceland_navigation_opens_portal_controls_without_starting_travel();
    side_portal_controls_bind_native_progress_and_actions();
    portal_controls_require_the_host_and_an_idle_visit_slot();
    current_speaker_defense_stages_open_guest_viewable_controls();
    dj_request_rows_explain_native_denials_and_missing_snapshots();
    speaker_defense_controls_bind_host_actions_and_native_status();
    speaker_defense_controls_follow_readiness_and_job_state();
    speaker_defense_controls_show_unknown_native_values_clearly();
    the_current_wave_stage_opens_guest_viewable_controls_without_completing();
    native_wave_controls_bind_host_actions_and_read_native_progress();
    native_wave_controls_follow_readiness_job_and_guest_state();
    native_wave_controls_distinguish_unknown_counters_and_explain_events();
    the_current_generator_stage_binds_native_placement();
    the_current_tone_stage_opens_controls_without_claiming_completion();
    tone_controls_bind_start_cancel_and_current_job_status();
    tone_controls_require_a_ready_host_and_one_background_job();
    the_bomber_stage_opens_host_controls_without_marking_completion();
    bomber_controls_bind_native_progress_and_start_cancel_permissions();
    the_grey_stage_opens_fight_controls_without_claiming_completion();
    grey_fuse_controls_bind_host_actions_and_explain_the_remaining_fight();
    full_grey_controls_share_one_job_and_show_spawn_readiness();
    the_final_stage_opens_controls_without_completing_the_ufo();
    finale_controls_bind_collection_to_current_host_and_native_fuse_progress();
    fuse_insertion_controls_require_a_ready_host_and_keep_native_progress();
    final_node_controls_bind_host_actions_and_native_progress();
    completed_final_stage_keeps_reward_controls_reachable();
    soul_key_controls_bind_native_pickup_and_explain_lobby_effects();
    an_empty_display_gets_an_inert_placeholder();
    open_controls_routes_to_the_binding_editor();
    menu_instructions_build_the_source_customization_page();
}

fun_insta_kill_routes_the_selected_actor_without_caching_damage_state()
{
    view = basic_view();
    view.insta_kill = spawnstruct();
    view.insta_kill.reason = "";
    view.insta_kill.mode = "Melee";
    view.insta_kill.hook_reason = "";
    rows = scripts\apparition\menu\model::build("Fun Scripts", view);
    row = rows[6];
    tests\support\checks::expect(rows.size == 37 && row.label == "Insta-Kill"
        && row.kind == "slider" && row.enabled && row.initial_index == 0
        && row.active_value == "Melee" && row.target == view.target && !row.lobby
        && row.callback == scripts\apparition\menu\actions::set_insta_kill,
        "The seventh source Fun row binds the selected actor and keeps preview separate from configured mode");
    tests\support\checks::expect(row.values.size == 3 && row.values[0] == "Disable"
        && row.values[1] == "All" && row.values[2] == "Melee"
        && !isDefined(row.checked) && !isDefined(row.menu_grant)
        && !isDefined(row.enemy) && !isDefined(row.damage),
        "The slider keeps source choices without a kill checkbox or cached damage packet");
    tests\support\checks::expect(view.insta_kill.mode == "Melee"
        && !isDefined(view.target.apparition_insta_kill),
        "Rendering the configured mode does not publish player damage settings");
}

sound_pages_route_stable_perk_requests_to_the_selected_actor()
{
    view = basic_view();
    view.perk_sounds = spawnstruct();
    view.perk_sounds.reason = "";
    entry = spawnstruct();
    perks = scripts\apparition\maps\spaceland\perks::catalog();
    entry.id = perks[0].id;
    entry.label = perks[0].label;
    entry.jingle_reason = "";
    entry.quote_reason = "Native sound alias is unavailable";
    view.perk_sounds.entries = [entry];

    rows = scripts\apparition\menu\model::build("Sounds & Jingles", view);
    tests\support\checks::expect(rows.size >= 1 && rows[0].label == "Perk Jingles & Quotes"
        && rows[0].kind == "submenu" && rows[0].enabled
        && rows[0].destination == "Perk Jingles & Quotes" && rows[0].target == view.target,
        "The source sound parent opens the perk page for the same selected actor");
    rows = scripts\apparition\menu\model::build("Perk Jingles & Quotes", view);
    tests\support\checks::expect(rows.size == 2 && rows[0].enabled && !rows[1].enabled
        && rows[0].target == view.target && !rows[0].lobby
        && rows[0].callback == scripts\apparition\menu\actions::play_perk_sound
        && rows[0].perk_id == entry.id && rows[0].sound_kind == "Jingle"
        && rows[1].perk_id == entry.id && rows[1].sound_kind == "Quote",
        "The sound model routes independent native readiness to stable selected-player actions");
    tests\support\checks::expect(!isDefined(rows[0].alias) && !isDefined(rows[0].jingle)
        && !isDefined(rows[0].quote) && !isDefined(rows[0].checked),
        "Sound rows retain neither aliases nor synthetic playback state");
}

teleport_navigation_keeps_source_position_and_selected_target()
{
    view = basic_view();
    view.owner = spawnstruct();
    rows = scripts\apparition\menu\model::build("Main", view);
    tests\support\checks::expect(rows[3].label == "Teleport Menu" && rows[3].kind == "submenu"
        && rows[3].enabled && rows[3].destination == "Teleport Menu"
        && rows[3].target == view.target && !rows[3].lobby,
        "The fourth source root option opens teleports for the selected player");
    rows = scripts\apparition\menu\model::build("Teleport Menu", view);
    tests\support\checks::expect(rows.size == 10 && rows[3].label == "Teleport"
        && rows[8].label == "Teleport To Self" && rows[9].label == "Teleport To Player",
        "The remote target reaches the personal teleport descriptors through the model");
    tests\support\checks::expect(!rows[3].enabled && !rows[6].enabled && !rows[7].enabled,
        "Navigation without a travel snapshot does not authorize movement or saving");
}

basic_god_mode_binds_the_selected_player_and_callback()
{
    view = basic_view();
    view.target.playerGodmode = true;
    view.god_ready = false;
    rows = scripts\apparition\menu\model::build("Basic Scripts", view);

    tests\support\checks::expect(rows[0].label == "God Mode", "The personal God Mode label is retained");
    tests\support\checks::expect(rows[0].target == view.target, "God Mode targets the selected player");
    tests\support\checks::expect(rows[0].callback == scripts\apparition\menu\actions::toggle_god, "God Mode dispatches its feature callback");
    tests\support\checks::expect(rows[0].checked && rows[0].enabled, "A checked setting remains available to clear after hook loss");
    tests\support\checks::expect(rows[0].description == "Disable the saved God Mode setting; damage protection is not confirmed", "A stored flag is not presented as active damage protection");
    tests\support\checks::expect(view.target.playerGodmode, "Rendering leaves the selected player's saved flag unchanged");
}

god_mode_rows_reflect_flags_without_changing_them()
{
    personal_view = basic_view();
    personal_view.target.playerGodmode = true;
    personal_rows = scripts\apparition\menu\model::build("Basic Scripts", personal_view);
    tests\support\checks::expect(personal_rows[0].checked && personal_rows[0].enabled, "An active damage hook keeps the configured personal setting available");
    tests\support\checks::expect(personal_view.target.playerGodmode, "Reading personal God Mode does not change its configured flag");

    view = basic_view();
    view.host = true;
    view.access = "Host";
    first = spawnstruct();
    first.playerGodmode = true;
    second = spawnstruct();
    second.playerGodmode = true;
    view.players = [first, second];
    view.actor_reason = "";
    rows = scripts\apparition\menu\model::build("All Players", view);
    tests\support\checks::expect(rows[5].checked && rows[5].enabled, "An all-enabled roster has a checked ready lobby row");
    tests\support\checks::expect(!isDefined(rows[5].target), "Lobby God Mode does not retain a selected-player target");
    tests\support\checks::expect(first.playerGodmode && second.playerGodmode, "Rendering an all-enabled roster does not toggle its flags");

    second.playerGodmode = false;
    rows = scripts\apparition\menu\model::build("All Players", view);
    tests\support\checks::expect(!rows[5].checked && rows[5].enabled, "A mixed roster remains unchecked but can be changed when the hook is ready");
    tests\support\checks::expect(first.playerGodmode && !second.playerGodmode, "Rendering a mixed roster leaves each player's flag unchanged");

    view.players = [];
    rows = scripts\apparition\menu\model::build("All Players", view);
    tests\support\checks::expect(!rows[5].checked && !rows[5].enabled, "An empty roster cannot be checked or toggled");
    tests\support\checks::expect(rows[5].description == "No current players are available", "An empty roster shows the shared feature reason");

}

ammo_row_keeps_all_three_source_modes()
{
    rows = scripts\apparition\menu\model::build("Basic Scripts", basic_view());
    tests\support\checks::expect(rows[5].label == "Unlimited Ammo", "The source ammo label and position are retained");
    tests\support\checks::expect(rows[5].values.size == 3, "The ammo slider has three modes");
    tests\support\checks::expect(rows[5].values[0] == "Continuous", "Continuous is the first source mode");
    tests\support\checks::expect(rows[5].values[1] == "Reload", "Reload is the second source mode");
    tests\support\checks::expect(rows[5].values[2] == "Disable", "Disable is the final source mode");
}

ammo_lobby_configuration_requires_a_valid_roster_snapshot()
{
    view = basic_view();
    view.host = true;
    view.access = "Host";
    view.target.apparition_ammo_mode = "Reload";
    view.players = [view.target, spawnstruct()];
    view.actor_reason = "";
    rows = scripts\apparition\menu\model::build("All Players", view);
    tests\support\checks::expect(rows[11].enabled && rows[11].active_value == "Mixed",
        "An admitted nonempty roster snapshot displays its mixed configured ammo modes");
    tests\support\checks::expect(rows[11].lobby && !isDefined(rows[11].target)
        && rows[11].callback == scripts\apparition\menu\actions::set_ammo,
        "Lobby ammo delegates current-selection application without retaining a player target");
    tests\support\checks::expect(rows[11].description == "Use applies the selection; active: Mixed; current roster only, later joins keep their own mode",
        "Lobby ammo separates preview from active mode and explains current-roster scope");

    view.players = [];
    rows = scripts\apparition\menu\model::build("All Players", view);
    tests\support\checks::expect(!rows[11].enabled && rows[11].active_value == "Unavailable"
        && rows[11].description == "No current players are available",
        "An empty roster cannot display a uniform disabled setting or accept an ammo apply");
    view.players = [view.target];
    view.actor_reason = undefined;
    rows = scripts\apparition\menu\model::build("All Players", view);
    tests\support\checks::expect(!rows[11].enabled && rows[11].active_value == "Unavailable"
        && rows[11].description == "Wait for a valid player roster",
        "A missing admission snapshot cannot authorize lobby ammo or display an active mode");
    view.actor_reason = "Wait for a valid player roster";
    rows = scripts\apparition\menu\model::build("All Players", view);
    tests\support\checks::expect(!rows[11].enabled && rows[11].description == view.actor_reason,
        "A failed current-roster actor snapshot is shown directly");

    rows = scripts\apparition\menu\model::build("Basic Scripts", view);
    tests\support\checks::expect(rows[5].enabled && rows[5].active_value == "Reload" && !rows[5].lobby,
        "Personal ammo remains configurable while down and does not depend on lobby admission");
    tests\support\checks::expect(view.target.apparition_ammo_mode == "Reload",
        "Reading personal and lobby rows never applies the selected ammo preview");
}

ammo_lobby_guest_denial_precedes_roster_status()
{
    view = basic_view();
    view.host = false;
    view.access = "VIP";
    view.players = [];
    rows = scripts\apparition\menu\model::build("All Players", view);
    tests\support\checks::expect(!rows[11].enabled && rows[11].active_value == "Unavailable",
        "A guest cannot apply a mode to an empty lobby");
    tests\support\checks::expect(rows[11].description == "Only the current host can change lobby ammo",
        "Lobby host authority is clearer than an additional roster denial");
    view.players = [view.target];
    view.actor_reason = "";
    view.target.apparition_ammo_mode = "Continuous";
    rows = scripts\apparition\menu\model::build("All Players", view);
    tests\support\checks::expect(!rows[11].enabled && rows[11].active_value == "Continuous",
        "A guest may read a valid configured lobby mode without changing it");
}

actor_snapshot_reason_is_shared_by_setting_rows()
{
    view = basic_view();
    view.players = [view.target];
    view.actor_reason = "";
    tests\support\checks::expect(scripts\apparition\menu\model::actor_snapshot_reason(view) == "",
        "A nonempty roster with a supplied admitted snapshot enables setting controls");
    view.players = [];
    tests\support\checks::expect(scripts\apparition\menu\model::actor_snapshot_reason(view) == "No current players are available",
        "An empty roster cannot be admitted by a stale successful actor snapshot");
    view.players = undefined;
    tests\support\checks::expect(scripts\apparition\menu\model::actor_snapshot_reason(view) == "Wait for a valid player roster",
        "An absent roster cannot use a captured admission reason");
    view.players = "invalid";
    tests\support\checks::expect(scripts\apparition\menu\model::actor_snapshot_reason(view) == "Wait for a valid player roster",
        "A malformed roster is rejected before interpreting its size");
    view.players = [view.target];
    view.actor_reason = undefined;
    tests\support\checks::expect(scripts\apparition\menu\model::actor_snapshot_reason(view) == "Wait for a valid player roster",
        "Missing captured admission is unavailable");
    view.actor_reason = 1;
    tests\support\checks::expect(scripts\apparition\menu\model::actor_snapshot_reason(view) == "Wait for a valid player roster",
        "A nontext admission value cannot authorize a setting");
}

revive_rows_preserve_source_positions_and_bind_scopes()
{
    view = basic_view();
    view.host = true;
    view.access = "Host";
    view.revive = revive_snapshot("", "A native revive target is available", [view.target]);

    rows = scripts\apparition\menu\model::build("Basic Scripts", view);
    tests\support\checks::expect(rows[29].label == "Revive" && rows[29].kind == "action",
        "Basic Scripts keeps Revive at its original source position as an action");
    tests\support\checks::expect(rows[29].enabled && rows[29].callback == scripts\apparition\menu\actions::revive
        && rows[29].target == view.target && !rows[29].lobby,
        "Basic Scripts dispatches the selected target through personal scope");
    tests\support\checks::expect(rows[29].description == "A native revive target is available",
        "A ready personal snapshot displays its native hint");

    rows = scripts\apparition\menu\model::build("Quick Menu", view);
    tests\support\checks::expect(rows.size == 12 && rows[11].label == "Revive"
        && rows[11].callback == scripts\apparition\menu\actions::revive,
        "Living Quick Menu preserves the Revive position and original guest row count");
    tests\support\checks::expect(rows[11].enabled && rows[11].target == view.target && !rows[11].lobby,
        "Quick Menu revive remains scoped to its selected player");

    view.players = [view.target];
    rows = scripts\apparition\menu\model::build("All Players", view);
    tests\support\checks::expect(rows.size == 14 && rows[8].label == "Down"
        && rows[9].label == "Revive" && rows[10].label == "Respawn" && rows[11].label == "Unlimited Ammo",
        "All Players preserves Revive between Down and Respawn without shifting later rows");
    tests\support\checks::expect(rows[9].enabled && rows[9].callback == scripts\apparition\menu\actions::revive
        && rows[9].lobby && !isDefined(rows[9].target),
        "All Players dispatches revive with a fresh host-level scope and no selected target");
}

revive_pending_and_missing_snapshots_fail_closed()
{
    view = basic_view();
    view.revive = revive_snapshot("Revive submitted; native laststand exit is unconfirmed",
        "Revive submitted; native laststand exit is unconfirmed", [view.target]);
    rows = scripts\apparition\menu\model::build("Basic Scripts", view);
    tests\support\checks::expect(!rows[29].enabled
        && rows[29].description == "Revive submitted; native laststand exit is unconfirmed",
        "A submitted revive stays unavailable until native laststand exit is observed");

    view.revive = undefined;
    rows = scripts\apparition\menu\model::build("Basic Scripts", view);
    tests\support\checks::expect(!rows[29].enabled && rows[29].description == "Wait for native revive data",
        "A missing personal snapshot cannot enable the native action");

    view.revive = spawnstruct();
    view.revive.reason = 1;
    rows = scripts\apparition\menu\model::build("Quick Menu", view);
    tests\support\checks::expect(!rows[11].enabled && rows[11].description == "Wait for native revive data",
        "A malformed reason cannot enable the living Quick Menu action");
    view.revive = revive_snapshot("", "No actual candidates", []);
    rows = scripts\apparition\menu\model::build("Basic Scripts", view);
    tests\support\checks::expect(!rows[29].enabled && rows[29].description == "Wait for native revive data",
        "An empty target list cannot advertise an actionable native revive");
}

revive_lobby_host_reason_precedes_missing_snapshot()
{
    view = basic_view();
    view.players = [view.target];
    view.revive = undefined;
    rows = scripts\apparition\menu\model::build("All Players", view);
    tests\support\checks::expect(!rows[9].enabled && rows[9].lobby && !isDefined(rows[9].target)
        && rows[9].description == "Co-Host access is required to revive current players",
        "Lobby role permission stays clear even when the revive snapshot is missing");

    view.host = true;
    view.access = "Host";
    rows = scripts\apparition\menu\model::build("All Players", view);
    tests\support\checks::expect(!rows[9].enabled && rows[9].description == "Wait for native revive data",
        "The host receives the missing native-data reason");
}

revive_rendering_preserves_snapshot_and_quick_life_filter()
{
    view = basic_view();
    view.revive = revive_snapshot("", "A native revive target is available", [view.target]);
    rows = scripts\apparition\menu\model::build("Basic Scripts", view);
    tests\support\checks::expect(view.revive.reason == "" && view.revive.hint == "A native revive target is available"
        && view.revive.targets.size == 1 && view.revive.targets[0] == view.target,
        "Rendering leaves the native revive snapshot unchanged");

    view.owner_alive = false;
    rows = scripts\apparition\menu\model::build("Quick Menu", view);
    tests\support\checks::expect(rows.size == 1 && rows[0].label == "Respawn",
        "Dead guest Quick Menu keeps only Respawn and does not expose Revive");

    view.host = true;
    view.access = "Host";
    rows = scripts\apparition\menu\model::build("Quick Menu", view);
    tests\support\checks::expect(rows.size == 3 && rows[0].label == "Respawn"
        && rows[1].label == "Restart Game" && rows[2].label == "Disconnect",
        "Dead host Quick Menu keeps its original host-only rows without Revive");
}

revive_snapshot(reason, hint, targets)
{
    snapshot = spawnstruct();
    snapshot.reason = reason;
    snapshot.hint = hint;
    snapshot.targets = targets;
    return snapshot;
}

unsupported_source_rows_have_no_gameplay_callback()
{
    rows = scripts\apparition\menu\model::build("Basic Scripts", basic_view());
    tests\support\checks::expect(rows[2].label == "Noclip", "The original third row is retained");
    tests\support\checks::expect(!rows[2].enabled, "An unported row is disabled");
    tests\support\checks::expect(!isDefined(rows[2].callback), "An unported row cannot invoke an action");
    tests\support\checks::expect(isDefined(rows[2].description), "The unavailable row explains its status");
}

lobby_actions_bind_lobby_scope()
{
    view = basic_view();
    view.players = [view.target];
    view.actor_reason = "";
    rows = scripts\apparition\menu\model::build("All Players", view);
    tests\support\checks::expect(rows[5].lobby, "All Players God Mode uses lobby authorization");
    tests\support\checks::expect(rows[5].callback == scripts\apparition\menu\actions::toggle_god, "Both scopes share one God Mode callback");
    tests\support\checks::expect(!isDefined(rows[5].target), "Lobby God Mode does not retain a selected-player target");
}

god_mode_checkbox_supports_recovery_after_hook_loss()
{
    view = basic_view();
    view.god_ready = false;
    rows = scripts\apparition\menu\model::build("Basic Scripts", view);
    tests\support\checks::expect(!rows[0].checked && !rows[0].enabled, "An unchecked personal setting cannot be enabled after hook loss");
    tests\support\checks::expect(rows[0].description == "Enable requires the active Apparition damage callback", "An unchecked personal setting shows the shared hook reason");

    view = basic_view();
    view.host = true;
    view.access = "Host";
    view.god_ready = false;
    enabled = spawnstruct();
    enabled.playerGodmode = true;
    disabled = spawnstruct();
    disabled.playerGodmode = false;
    view.players = [enabled];
    view.actor_reason = "";
    rows = scripts\apparition\menu\model::build("All Players", view);
    tests\support\checks::expect(rows[5].checked && rows[5].enabled, "A uniformly checked lobby row can disable its stored flags after hook loss");
    tests\support\checks::expect(rows[5].description == "Disable the saved God Mode setting; damage protection is not confirmed", "A lost hook distinguishes settings from confirmed protection");

    view.players = [enabled, disabled];
    rows = scripts\apparition\menu\model::build("All Players", view);
    tests\support\checks::expect(!rows[5].checked && !rows[5].enabled, "A mixed lobby row cannot enable settings after hook loss");
    tests\support\checks::expect(rows[5].description == "Enable requires the active Apparition damage callback; existing flags can be cleared through each player's Basic Scripts", "A mixed lost-hook roster explains how to clear its individual flags");

    view.players = [enabled];
    view.host = false;
    view.access = "VIP";
    rows = scripts\apparition\menu\model::build("All Players", view);
    tests\support\checks::expect(rows[5].checked && !rows[5].enabled, "A guest can inspect the checked lobby flag but cannot clear it");
    tests\support\checks::expect(rows[5].description == "Co-Host access is required to change lobby God Mode", "Lobby role denial takes precedence over hook recovery");
}

god_mode_lobby_rows_validate_actor_snapshot_before_reading_flags()
{
    view = basic_view();
    view.host = true;
    view.access = "Host";
    view.actor_reason = "";
    view.players = undefined;
    row = scripts\apparition\menu\model::god_row(view, true);
    tests\support\checks::expect(!row.checked && !row.enabled,
        "A missing lobby roster cannot advertise or enable God Mode");
    tests\support\checks::expect(row.description == "Wait for a valid player roster",
        "A missing lobby roster shows its actor admission reason");

    view.players = "invalid";
    row = scripts\apparition\menu\model::god_row(view, true);
    tests\support\checks::expect(!row.checked && !row.enabled
        && row.description == "Wait for a valid player roster",
        "A non-array lobby snapshot fails closed before feature flag inspection");

    view.players = [];
    row = scripts\apparition\menu\model::god_row(view, true);
    tests\support\checks::expect(!row.checked && !row.enabled
        && row.description == "No current players are available",
        "An empty lobby snapshot cannot reuse a stale successful actor reason");

    flagged = spawnstruct();
    flagged.playerGodmode = true;
    view.players = [flagged];
    view.actor_reason = undefined;
    row = scripts\apparition\menu\model::god_row(view, true);
    tests\support\checks::expect(!row.checked && !row.enabled
        && row.description == "Wait for a valid player roster",
        "A missing actor admission cannot expose an already flagged invalid actor");

    view.actor_reason = "Wait for a valid player roster";
    row = scripts\apparition\menu\model::god_row(view, true);
    tests\support\checks::expect(!row.checked && !row.enabled
        && row.description == view.actor_reason,
        "An invalid actor snapshot stays unchecked with its current admission reason");
    tests\support\checks::expect(flagged.playerGodmode,
        "Rendering invalid lobby data leaves existing God Mode flags unchanged");
}

god_mode_guest_lobby_denial_precedes_invalid_roster_reason()
{
    view = basic_view();
    view.host = false;
    view.access = "VIP";
    view.players = [];
    view.actor_reason = "";
    row = scripts\apparition\menu\model::god_row(view, true);
    tests\support\checks::expect(!row.checked && !row.enabled,
        "A guest cannot advertise or change God Mode for an invalid lobby snapshot");
    tests\support\checks::expect(row.description == "Co-Host access is required to change lobby God Mode",
        "Lobby host denial takes precedence over actor and hook reasons");
}

basic_explosive_protection_keeps_its_source_position_and_personal_scope()
{
    view = basic_view();
    rows = scripts\apparition\menu\model::build("Basic Scripts", view);

    tests\support\checks::expect(rows.size == 31, "Basic Scripts retains all 31 original source rows");
    tests\support\checks::expect(rows[22].label == "Custom Crosshairs"
        && rows[23].label == "No Explosive Damage"
        && rows[24].label == "Character Model Index",
        "No Explosive Damage stays at source position 23");
    tests\support\checks::expect(rows[23].kind == "toggle"
        && rows[23].callback == scripts\apparition\menu\actions::toggle_explosive_protection,
        "No Explosive Damage binds its personal toggle callback");
    tests\support\checks::expect(rows[23].target == view.target && !rows[23].lobby,
        "No Explosive Damage targets only the selected player");
    tests\support\checks::expect(rows[23].enabled,
        "The default active damage hook makes the personal explosive setting available");
    tests\support\checks::expect(rows[23].description == "Toggle explosive-only protection through Apparition's native damage callback",
        "The available row explains the native explosive-only protection");
}

explosive_protection_rows_follow_its_flag_without_changing_god_mode()
{
    view = basic_view();
    view.target.NoExplosiveDamage = true;
    rows = scripts\apparition\menu\model::build("Basic Scripts", view);

    tests\support\checks::expect(rows[23].checked && !rows[0].checked,
        "The explosive flag is read independently from the God Mode flag");
    tests\support\checks::expect(view.target.NoExplosiveDamage && !isDefined(view.target.playerGodmode),
        "Rendering the explosive row leaves both player flags unchanged");

    view.target.NoExplosiveDamage = false;
    view.target.playerGodmode = true;
    rows = scripts\apparition\menu\model::build("Basic Scripts", view);
    tests\support\checks::expect(!rows[23].checked && rows[0].checked,
        "God Mode cannot set the independent explosive protection checkbox");
    tests\support\checks::expect(!view.target.NoExplosiveDamage && view.target.playerGodmode,
        "Rendering does not change the explosive or God Mode flags");
}

explosive_protection_rows_allow_hook_loss_cleanup_but_reject_enable()
{
    view = basic_view();
    view.god_ready = false;
    rows = scripts\apparition\menu\model::build("Basic Scripts", view);
    tests\support\checks::expect(!rows[23].checked && !rows[23].enabled,
        "An unchecked explosive flag cannot be enabled after hook loss");
    tests\support\checks::expect(rows[23].description
        == scripts\apparition\features\explosive_protection::reason(view.target, false),
        "The unchecked row displays the shared hook admission reason");

    view.target.NoExplosiveDamage = true;
    rows = scripts\apparition\menu\model::build("Basic Scripts", view);
    tests\support\checks::expect(rows[23].checked && rows[23].enabled,
        "A checked explosive flag stays available for cleanup after hook loss");
    tests\support\checks::expect(rows[23].description == "Disable the saved explosive protection setting; damage protection is not confirmed",
        "A lost callback distinguishes clearing a saved flag from confirmed protection");
    tests\support\checks::expect(view.target.NoExplosiveDamage,
        "Rendering a hook-loss cleanup row leaves the saved flag unchanged");
}

explosive_protection_does_not_appear_in_quick_or_lobby_menus()
{
    view = basic_view();
    view.host = true;
    view.access = "Host";
    rows = scripts\apparition\menu\model::build("Quick Menu", view);
    tests\support\checks::expect(rows.size == 12,
        "Quick Menu keeps its existing row count");
    foreach (row in rows)
    {
        tests\support\checks::expect(row.label != "No Explosive Damage",
            "Quick Menu has no explosive protection row");
    }

    view.players = [view.target];
    rows = scripts\apparition\menu\model::build("All Players", view);
    tests\support\checks::expect(rows.size == 14,
        "All Players keeps its existing row count");
    foreach (row in rows)
    {
        tests\support\checks::expect(row.label != "No Explosive Damage",
            "All Players has no lobby explosive protection row");
    }
}

basic_and_quick_equipment_rows_bind_personal_settings()
{
    view = basic_view();
    view.target.apparition_equipment = true;
    view.equipment_status = "Full";
    rows = scripts\apparition\menu\model::build("Basic Scripts", view);
    tests\support\checks::expect(rows[6].label == "Unlimited Equipment" && rows[6].kind == "toggle", "Basic Scripts preserves the equipment label and source position as a toggle");
    tests\support\checks::expect(rows[6].enabled && rows[6].checked && rows[6].target == view.target && !rows[6].lobby, "The personal equipment row targets the selected player and reads its refill setting");
    tests\support\checks::expect(rows[6].callback == scripts\apparition\menu\actions::toggle_equipment, "The personal row binds the dedicated grenade-refill action");
    tests\support\checks::expect(rows[6].description == "Refill supported primary grenades; secondary powers and removed equipment are excluded; snapshot: Full", "The personal row names supported effects, limits and current readiness");
    tests\support\checks::expect(view.target.apparition_equipment, "Rendering does not change the personal refill setting");
    tests\support\checks::expect(rows[2].label == "Noclip" && !rows[2].enabled && !isDefined(rows[2].callback), "The adjacent unsupported Noclip row remains unavailable");

    rows = scripts\apparition\menu\model::build("Quick Menu", view);
    tests\support\checks::expect(rows[4].label == "Unlimited Equipment" && rows[4].kind == "toggle" && rows[4].callback == scripts\apparition\menu\actions::toggle_equipment, "Living Quick Menu keeps its equipment row order and callback");
    tests\support\checks::expect(rows[4].target == view.target && !rows[4].lobby && rows[4].checked && rows[4].enabled, "Quick Menu equipment uses the selected personal setting");

    rows = scripts\apparition\menu\model::build("Basic Scripts", view);
    tests\support\checks::expect(rows[6].enabled && rows[6].checked, "Basic Scripts can configure the future refill setting while its target is dead");
}

lobby_equipment_row_binds_current_roster_and_host_scope()
{
    view = basic_view();
    view.host = true;
    view.access = "Host";
    first = spawnstruct();
    first.apparition_equipment = true;
    second = spawnstruct();
    second.apparition_equipment = true;
    view.players = [first, second];
    view.actor_reason = "";
    view.equipment_status = "Ready 1, full 0, paused 1, off 0";
    rows = scripts\apparition\menu\model::build("All Players", view);
    tests\support\checks::expect(rows[11].label == "Unlimited Ammo" && rows[12].label == "Unlimited Equipment" && rows[13].label == "Perk Menu", "Lobby equipment is inserted after ammo and before perk navigation");
    tests\support\checks::expect(rows.size == 14 && rows[12].kind == "toggle" && rows[12].checked && rows[12].enabled, "An all-enabled current roster has a checked enabled equipment row");
    tests\support\checks::expect(rows[12].callback == scripts\apparition\menu\actions::toggle_equipment && rows[12].lobby && !isDefined(rows[12].target), "Lobby equipment binds host-level dispatch without a stale player target");
    tests\support\checks::expect(rows[12].description == "Refill supported primary grenades; secondary powers and removed equipment are excluded; snapshot: Ready 1, full 0, paused 1, off 0; current roster only, later joins keep their setting", "The lobby row explains current-roster scope, supported effects and aggregate readiness");

    view.host = false;
    view.access = "VIP";
    rows = scripts\apparition\menu\model::build("All Players", view);
    tests\support\checks::expect(rows[12].checked && !rows[12].enabled, "A guest can inspect an enabled lobby setting without changing it");
    tests\support\checks::expect(rows[12].description == "Only the current host can change lobby equipment refill; snapshot: Ready 1, full 0, paused 1, off 0", "Lobby equipment shows its host-only reason");
}

equipment_rendering_preserves_flags_and_empty_rosters_fail_closed()
{
    view = basic_view();
    view.host = true;
    view.access = "Host";
    first = spawnstruct();
    first.apparition_equipment = true;
    second = spawnstruct();
    view.players = [first, second];
    view.actor_reason = "";
    rows = scripts\apparition\menu\model::build("All Players", view);
    tests\support\checks::expect(!rows[12].checked && rows[12].enabled, "A mixed roster is unchecked but ready for a host update");
    tests\support\checks::expect(first.apparition_equipment && !isDefined(second.apparition_equipment), "Rendering a mixed roster preserves every player's setting");

    view.players = [];
    view.actor_reason = "No current players are available";
    rows = scripts\apparition\menu\model::build("All Players", view);
    tests\support\checks::expect(!rows[12].checked && !rows[12].enabled && rows[12].description == view.actor_reason, "An empty lobby roster fails closed with the actor reason");

    view.players = [first];
    view.actor_reason = undefined;
    rows = scripts\apparition\menu\model::build("All Players", view);
    tests\support\checks::expect(!rows[12].enabled && rows[12].description == "Wait for a valid player roster", "A missing actor-readiness snapshot fails closed");
}

equipment_personal_setting_remains_configurable_while_dead()
{
    view = basic_view();
    view.owner_alive = false;
    rows = scripts\apparition\menu\model::build("Quick Menu", view);
    tests\support\checks::expect(rows.size == 1 && rows[0].label == "Respawn", "Dead Quick Menu keeps its existing alive-only source rows hidden");

    rows = scripts\apparition\menu\model::build("Basic Scripts", view);
    tests\support\checks::expect(rows[6].enabled && rows[6].callback == scripts\apparition\menu\actions::toggle_equipment, "A dead target can still configure future grenade refills in Basic Scripts");
}

equipment_status_explains_readiness_without_overriding_configuration()
{
    view = basic_view();
    view.target.apparition_equipment = true;
    foreach (status in ["Ready", "Full", "Waiting", "Paused", "Unavailable", "Missing"])
    {
        view.equipment_status = status;
        rows = scripts\apparition\menu\model::build("Basic Scripts", view);
        tests\support\checks::expect(rows[6].checked && rows[6].enabled,
            "A configured refill setting stays checked and can be disabled in every readiness state");
        tests\support\checks::expect(rows[6].description == "Refill supported primary grenades; secondary powers and removed equipment are excluded; snapshot: " + status,
            "The equipment description reads the supplied live readiness snapshot");
        tests\support\checks::expect(view.target.apparition_equipment && view.equipment_status == status,
            "Rendering neither changes settings nor rewrites readiness data");
    }
    view.target.apparition_equipment = false;
    view.equipment_status = "Off";
    rows = scripts\apparition\menu\model::build("Quick Menu", view);
    tests\support\checks::expect(!rows[4].checked && rows[4].enabled,
        "An off refill setting remains available for enabling in living Quick Menu");
    tests\support\checks::expect(rows[4].description == "Refill supported primary grenades; secondary powers and removed equipment are excluded; snapshot: Off",
        "Living Quick Menu includes the sampled off state without adding a row");
}

equipment_status_defaults_to_unknown_without_blocking_configuration()
{
    view = basic_view();
    rows = scripts\apparition\menu\model::build("Basic Scripts", view);
    tests\support\checks::expect(rows[6].description == "Refill supported primary grenades; secondary powers and removed equipment are excluded; snapshot: Unknown",
        "An absent readiness snapshot cannot imply a ready refill");
    foreach (status in ["", 1])
    {
        view.equipment_status = status;
        rows = scripts\apparition\menu\model::build("Basic Scripts", view);
        tests\support\checks::expect(rows[6].enabled && !rows[6].checked,
            "Missing diagnostic data does not disable a future configuration setting");
        tests\support\checks::expect(rows[6].description == "Refill supported primary grenades; secondary powers and removed equipment are excluded; snapshot: Unknown",
            "Missing or malformed readiness text is shown as unknown");
    }
}

spaceland_and_stage_zero_share_the_native_dj_parts_action()
{
    view = basic_view();
    view.host = true;
    view.access = "Host";
    snapshot = spawnstruct();
    snapshot.reason = "";
    snapshot.collected = 2;
    snapshot.total = 3;
    snapshot.targets = [spawnstruct()];
    view.dj_parts = snapshot;

    rows = scripts\apparition\menu\model::build("Spaceland Scripts", view);
    parent_row = rows[1];
    view.ufo = scripts\apparition\maps\spaceland\quest::progress(tests\fixtures\spaceland::quest(0));
    rows = scripts\apparition\menu\model::build("UFO Quest Steps", view);
    stage_row = rows[0];

    tests\support\checks::expect(parent_row.enabled && parent_row.kind == "action"
        && stage_row.enabled && stage_row.kind == "toggle" && !stage_row.checked,
        "The parent action and active stage row share readiness while stage completion stays native-owned");
    tests\support\checks::expect(parent_row.callback == stage_row.callback
        && parent_row.callback == scripts\apparition\menu\actions::collect_dj_parts
        && parent_row.lobby && stage_row.lobby && !isDefined(parent_row.target)
        && !isDefined(stage_row.target),
        "Both entry points bind the same target-free host collection request");
    tests\support\checks::expect(parent_row.description == stage_row.description,
        "The parent and active-stage entries report the same captured progress");
}

dj_parts_controls_reject_stale_and_wrong_stage_snapshots()
{
    view = basic_view();
    view.host = true;
    view.access = "Host";
    view.dj_parts = spawnstruct();
    view.dj_parts.reason = "The native part registry is stale";
    view.dj_parts.collected = 1;
    view.dj_parts.total = 3;
    view.dj_parts.targets = [];
    view.ufo = scripts\apparition\maps\spaceland\quest::progress(tests\fixtures\spaceland::quest(0));

    rows = scripts\apparition\menu\model::build("Spaceland Scripts", view);
    parent_row = rows[1];
    rows = scripts\apparition\menu\model::build("UFO Quest Steps", view);
    stage_row = rows[0];
    tests\support\checks::expect(!parent_row.enabled && !stage_row.enabled
        && !stage_row.checked && parent_row.description == view.dj_parts.reason
        && stage_row.description == view.dj_parts.reason,
        "Stale readiness blocks both the parent and stage-zero action with the same reason");

    view.dj_parts.reason = "DJ parts are not the current quest step";
    view.ufo = scripts\apparition\maps\spaceland\quest::progress(tests\fixtures\spaceland::quest(1));
    rows = scripts\apparition\menu\model::build("Spaceland Scripts", view);
    parent_row = rows[1];
    rows = scripts\apparition\menu\model::build("UFO Quest Steps", view);
    stage_row = rows[0];
    tests\support\checks::expect(!parent_row.enabled && parent_row.description == view.dj_parts.reason
        && stage_row.checked && !stage_row.enabled && !isDefined(stage_row.callback),
        "Neither menu entry can invoke the step-zero native completion callback during a later stage");
}

spaceland_scripts_puts_native_power_first()
{
    view = basic_view();
    view.host = true;
    view.access = "Host";
    view.power = spawnstruct();
    view.power.reason = "";
    view.power.powered = 1;
    view.power.total = 2;
    rows = scripts\apparition\menu\model::build("Spaceland Scripts", view);
    tests\support\checks::expect(rows.size == 5 && rows[0].label == "Turn On Power"
        && rows[1].label == "Collect DJ Parts" && rows[2].label == "UFO Quest Steps"
        && rows[3].label == "Portal Controls" && rows[4].label == "Ghosts N Skulls",
        "The new power control leads Spaceland Scripts while preserving the remaining row order");
}

spaceland_scripts_links_to_ghosts_n_skulls_controls()
{
    view = basic_view();
    rows = scripts\apparition\menu\model::build("Spaceland Scripts", view);
    tests\support\checks::expect(rows[4].label == "Ghosts N Skulls" && rows[4].kind == "submenu", "Spaceland exposes Ghosts N Skulls as a control page");
    tests\support\checks::expect(rows[4].enabled && rows[4].destination == "Ghosts N Skulls", "Ghosts N Skulls progress remains viewable");
    tests\support\checks::expect(rows[4].callback == scripts\apparition\menu\actions::open_page && rows[4].target == view.target && !rows[4].lobby, "Opening the page cannot start or mutate the native quest");
}

ghosts_controls_bind_host_face_action_and_readonly_steps()
{
    view = ghost_view(1);
    view.host = true;
    view.access = "Host";
    view.ghost_progress.active = true;
    view.ghost_probe.reason = "";
    rows = scripts\apparition\menu\model::build("Ghosts N Skulls", view);
    tests\support\checks::expect(rows.size == 19, "The control page keeps Brute cabinet rows after the floating-skull controls");
    tests\support\checks::expect(rows[0].label == "Face Current Skull" && rows[0].enabled && rows[0].lobby, "A ready host can request the current native skull interaction");
    tests\support\checks::expect(!isDefined(rows[0].target) && rows[0].callback == scripts\apparition\menu\actions::face_ghost_skull, "Facing binds the host action without a stale actor target");
    tests\support\checks::expect(rows[0].description == "Face the skull, then keep it in view for the native 1.5-second check", "The face action explains the native sustained-look requirement");

    steps = scripts\apparition\maps\spaceland\ghosts::catalog();
    tests\support\checks::expect(steps.size == 7, "The native quest exposes seven source-ordered steps");
    for (index = 0; index < steps.size; index++)
    {
        row = rows[index + 1];
        completed = index < 1;
        tests\support\checks::expect(row.label == steps[index].label && row.kind == "toggle", "Ghost step rows follow the native catalog order");
        tests\support\checks::expect(!row.enabled && !isDefined(row.callback), "Native step checkboxes are progress-only");
        tests\support\checks::expect(row.checked == completed, "Only stages before the current native step are checked");
    }
    tests\support\checks::expect(rows[1].checked && !rows[2].checked, "Only the step before the native spell stage reads as complete");
    tests\support\checks::expect(rows[8].label == "Native Arena Active" && rows[8].checked && !rows[8].enabled && !isDefined(rows[8].callback), "Arena activity is a separate read-only native checkbox");
}

ghosts_final_step_requires_native_activation_separate_from_arena_activity()
{
    view = ghost_view(6);
    view.ghost_progress.active = true;
    view.ghost_progress.activated = false;
    view.ghost_progress.last_result = "Won";
    rows = scripts\apparition\menu\model::build("Ghosts N Skulls", view);
    tests\support\checks::expect(!rows[7].checked && rows[8].checked, "Arena activity and a prior win cannot complete the unobserved final quest step");
    tests\support\checks::expect(rows[10].label == "Last Recorded Arena Result: Won", "The last arena result remains distinct from quest completion");

    view.ghost_progress.activated = true;
    rows = scripts\apparition\menu\model::build("Ghosts N Skulls", view);
    tests\support\checks::expect(rows[7].checked, "Only the observed native final activation completes the final step");

    view.ghost_progress.step = 5;
    rows = scripts\apparition\menu\model::build("Ghosts N Skulls", view);
    tests\support\checks::expect(!rows[7].checked, "Final activation outside the final step cannot complete the last checkbox");
}

ghosts_status_keeps_wave_counts_and_arena_results_distinct()
{
    view = ghost_view(4);
    view.ghost_progress.waves = 9;
    view.ghost_progress.last_result = "Failed";
    rows = scripts\apparition\menu\model::build("Ghosts N Skulls", view);
    tests\support\checks::expect(rows[9].label == "Map Waves Started: 9", "The status counts native started waves across retries without a per-run denominator");
    tests\support\checks::expect(rows[9].description == "Counts started native waves across all arena attempts", "The counter explains its map-wide scope");
    tests\support\checks::expect(rows[10].label == "Last Recorded Arena Result: Failed", "The last recorded arena outcome is visible with its actual result");
    tests\support\checks::expect(rows[10].description == "This result may be from an earlier arena game", "The result row warns that its record can be stale");
    tests\support\checks::expect(rows.size == 19, "Dance, floating-skull and Brute cabinet rows remain visible when their native stage is inactive");

    view.ghost_progress.step = 2;
    view.ghost_progress.next_floor = "Blue";
    view.ghost_progress.remaining_kills = 4;
    rows = scripts\apparition\menu\model::build("Ghosts N Skulls", view);
    tests\support\checks::expect(rows.size == 21 && rows[11].label == "Next Dance Color: Blue" && rows[12].label == "Dance Kills Remaining: 4", "Native dance observations appear before worker and floating-skull controls");

    view.ghost_progress.waves = -1;
    view.ghost_progress.next_floor = "";
    view.ghost_progress.remaining_kills = -1;
    rows = scripts\apparition\menu\model::build("Ghosts N Skulls", view);
    tests\support\checks::expect(rows[9].label == "Map Waves Started: unknown", "An unknown native started-wave count is not shown as zero");
    tests\support\checks::expect(rows[11].label == "Next Dance Color: unknown" && rows[12].label == "Dance Kills Remaining: unknown", "Unobserved dance values are displayed as unknown");
}

dance_assist_rows_bind_host_start_cancel_and_worker_status()
{
    view = ghost_view(2);
    view.host = true;
    view.access = "Host";
    view.dance_hint = "";
    view.dance_running = false;
    view.dance_status = "Idle";
    rows = scripts\apparition\menu\model::build("Ghosts N Skulls", view);

    tests\support\checks::expect(rows.size == 21, "Dance, floating-skull and Brute cabinet rows follow the two native dance observations");
    tests\support\checks::expect(rows[13].label == "Start Dance Kill Assist" && rows[13].enabled, "A ready living host can start dance assistance");
    tests\support\checks::expect(rows[13].callback == scripts\apparition\menu\actions::start_dance && rows[13].lobby && !isDefined(rows[13].target), "Start uses host-level action scope");
    tests\support\checks::expect(rows[13].description == "The host must move to each indicated native tile; only normal eligible enemies are attacked while it matches, and the native quest must advance the stage", "Start explains movement, eligible attacks and native completion ownership");
    tests\support\checks::expect(rows[14].label == "Cancel Dance Kill Assist" && !rows[14].enabled && rows[14].callback == scripts\apparition\menu\actions::cancel_dance, "An idle worker has a bound but disabled cancel action");
    tests\support\checks::expect(rows[14].lobby && !isDefined(rows[14].target), "Cancel uses the same fresh host-level action scope");
    tests\support\checks::expect(rows[15].label == "Dance Assist Status: Idle" && !rows[15].enabled && !isDefined(rows[15].callback), "Worker status is read-only and separate from native quest rows");
    tests\support\checks::expect(rows[12].label == "Dance Kills Remaining: 4" && !rows[12].enabled, "Native dance counters remain read-only beside worker state");
}

dance_assist_context_gates_start_without_blocking_cancel()
{
    view = ghost_view(3);
    view.host = true;
    view.access = "Host";
    view.dance_hint = "The native dance floor is not active";
    view.dance_running = true;
    view.dance_status = "Active";
    rows = scripts\apparition\menu\model::build("Ghosts N Skulls", view);
    tests\support\checks::expect(!rows[11].enabled && rows[11].description == view.dance_hint, "A changed native stage blocks a new assist with its current reason");
    tests\support\checks::expect(rows[12].enabled, "An active job remains cancellable after its native context changes");
    tests\support\checks::expect(!rows[4].checked, "A running worker cannot check the current native quest stage");

    view.dance_status = "Cancelling";
    rows = scripts\apparition\menu\model::build("Ghosts N Skulls", view);
    tests\support\checks::expect(!rows[12].enabled, "A cancellation already in progress cannot be queued again");

    view.dance_status = "Active";
    view.host = false;
    view.access = "VIP";
    rows = scripts\apparition\menu\model::build("Ghosts N Skulls", view);
    tests\support\checks::expect(!rows[11].enabled && !rows[12].enabled, "Guests can inspect an active worker without starting or canceling it");
    tests\support\checks::expect(rows[11].description == "Only the current living host can assist dance kills" && rows[12].description == rows[11].description, "Both guest actions show the same host permission reason");
}

dance_assist_guest_and_missing_snapshots_fail_closed()
{
    view = ghost_view(2);
    view.host = false;
    view.access = "VIP";
    view.dance_hint = "Only the current living host can assist dance kills";
    view.dance_running = false;
    view.dance_status = "Idle";
    rows = scripts\apparition\menu\model::build("Ghosts N Skulls", view);
    tests\support\checks::expect(rows[13].label == "Start Dance Kill Assist" && !rows[13].enabled && !rows[14].enabled, "Guests cannot control the worker");
    tests\support\checks::expect(rows[1].checked && rows[12].label == "Dance Kills Remaining: 4", "Guests retain native quest and dance counter visibility");

    view = ghost_view(2);
    view.dance_hint = undefined;
    view.dance_running = undefined;
    view.dance_status = undefined;
    rows = scripts\apparition\menu\model::build("Ghosts N Skulls", view);
    tests\support\checks::expect(!rows[13].enabled && rows[13].description == "Wait for native dance assist readiness data", "Missing actor readiness fails closed for Start");
    tests\support\checks::expect(!rows[14].enabled && rows[15].label == "Dance Assist Status: Unknown", "Missing job data cannot enable Cancel or invent an idle status");
}

floating_skull_action_binds_host_and_preserves_native_progress()
{
    view = ghost_view(2);
    view.host = true;
    view.access = "Host";
    view.floating_probe.reason = "";
    view.floating_probe.target = "native-skull-actor";
    view.floating_running = false;
    view.floating_status = "Idle";
    rows = scripts\apparition\menu\model::build("Ghosts N Skulls", view);

    tests\support\checks::expect(rows.size == 21, "The Brute cabinet rows follow the floating-skull controls");
    tests\support\checks::expect(rows[13].label == "Start Dance Kill Assist" && rows[15].label == "Dance Assist Status: Idle", "Existing dance rows retain their labels and ordering");
    tests\support\checks::expect(rows[16].label == "Hit Floating Skull" && rows[16].enabled, "A ready host can request one floating-skull hit");
    tests\support\checks::expect(rows[16].callback == scripts\apparition\menu\actions::hit_floating_skull && rows[16].lobby && !isDefined(rows[16].target), "The hit action uses fresh host-level scope without a stale actor target");
    tests\support\checks::expect(rows[16].description == "Submit one sign-laser-type damage request; native glasses and quest checks remain required, and an unconfirmed submitted hit is not repeated", "The action explains native requirements and the one-request retry rule");
    tests\support\checks::expect(rows[17].label == "Floating Skull Input: Idle" && !rows[17].enabled && !isDefined(rows[17].callback), "Floating-skull input status is read-only");
    tests\support\checks::expect(!rows[5].checked && rows[5].label == "Hit Floating Skull", "The native floating-skull quest step remains unchecked until native progress advances it");
}

floating_skull_actions_fail_closed_for_guests_and_pending_hits()
{
    view = ghost_view(1);
    view.host = false;
    view.access = "VIP";
    view.floating_probe.reason = "";
    view.floating_running = false;
    view.floating_status = "Idle";
    rows = scripts\apparition\menu\model::build("Ghosts N Skulls", view);
    tests\support\checks::expect(!rows[14].enabled && rows[14].description == "Only the current host can request a floating-skull hit", "Guests can inspect status but cannot submit the hit");
    tests\support\checks::expect(rows[15].label == "Floating Skull Input: Idle" && !rows[15].enabled, "Guest status remains read-only");

    view.host = true;
    view.access = "Host";
    view.floating_probe.reason = "Wait for native glasses and a visible floating skull";
    rows = scripts\apparition\menu\model::build("Ghosts N Skulls", view);
    tests\support\checks::expect(!rows[14].enabled && rows[14].description == view.floating_probe.reason, "The current native probe reason blocks an unready hit");

    view.floating_probe.reason = "";
    view.floating_running = true;
    view.floating_status = "Observing";
    rows = scripts\apparition\menu\model::build("Ghosts N Skulls", view);
    tests\support\checks::expect(!rows[14].enabled && rows[14].description == "A floating-skull hit is already pending", "A submitted hit cannot be repeated while its result is pending");
    tests\support\checks::expect(rows[15].label == "Floating Skull Input: Observing", "The pending input state is shown separately from native quest progress");
}

floating_skull_missing_snapshots_are_unknown_and_disabled()
{
    view = ghost_view(1);
    view.host = true;
    view.access = "Host";
    view.floating_probe = undefined;
    view.floating_running = undefined;
    view.floating_status = undefined;
    rows = scripts\apparition\menu\model::build("Ghosts N Skulls", view);

    tests\support\checks::expect(!rows[14].enabled && rows[14].description == "Wait for floating-skull readiness data", "Missing probe and worker snapshots fail closed");
    tests\support\checks::expect(rows[15].label == "Floating Skull Input: Unknown" && !rows[15].enabled, "Missing worker status is shown as unknown without adding a callback");

    view.floating_probe = spawnstruct();
    view.floating_probe.reason = "";
    rows = scripts\apparition\menu\model::build("Ghosts N Skulls", view);
    tests\support\checks::expect(!rows[14].enabled && rows[14].description == "Wait for floating-skull worker status", "Missing job state blocks a hit even when the probe is ready");
}

brute_cabinet_action_binds_host_and_native_progress()
{
    view = ghost_view(5);
    view.host = true;
    view.access = "Host";
    view.brute_cabinet_probe = spawnstruct();
    view.brute_cabinet_probe.reason = "";
    view.brute_cabinet_probe.route = "Initial Unlock";
    view.brute_cabinet_probe.target = "cabinet-model";
    view.brute_cabinet_probe.attacker = "living-brute";
    view.brute_cabinet_running = false;
    view.brute_cabinet_status = "Idle";
    rows = scripts\apparition\menu\model::build("Ghosts N Skulls", view);

    tests\support\checks::expect(rows.size == 19, "Brute cabinet route status is appended after existing Ghosts controls");
    tests\support\checks::expect(rows[14].label == "Hit Floating Skull" && rows[15].label == "Floating Skull Input: Idle", "Floating-skull rows remain ahead of the Brute cabinet rows");
    tests\support\checks::expect(rows[16].label == "Hit Cabinet With Brute" && rows[16].enabled, "A ready host can request the cabinet hit");
    tests\support\checks::expect(rows[16].callback == scripts\apparition\menu\actions::hit_brute_cabinet && rows[16].lobby && !isDefined(rows[16].target), "The cabinet action uses fresh host-level scope without stale model targets");
    tests\support\checks::expect(rows[16].description == "At a ready native cabinet stage, submit one direct bullet-type hit on the cabinet credited to a real living Brute; the native quest must advance, and an ambiguous submitted hit is not replayed", "The action covers either native route without claiming beam or quest completion");
    tests\support\checks::expect(rows[17].label == "Brute Cabinet Input: Idle" && !rows[17].enabled && !isDefined(rows[17].callback), "Cabinet input status is read-only");
    tests\support\checks::expect(rows[18].label == "Cabinet Route: Initial Unlock" && rows[18].description == "The native cabinet route is at its initial unlock stage" && !rows[18].enabled, "The read-only route row distinguishes the initial unlock path");
    tests\support\checks::expect(rows[6].label == "Brute Laser at Cabinet" && !rows[6].checked, "The native cabinet quest step remains unchecked until native progress advances it");
}

brute_cabinet_action_gates_guest_context_and_running_input()
{
    view = ghost_view(5);
    view.host = false;
    view.access = "VIP";
    view.brute_cabinet_probe = spawnstruct();
    view.brute_cabinet_probe.reason = "";
    view.brute_cabinet_running = false;
    view.brute_cabinet_status = "Idle";
    rows = scripts\apparition\menu\model::build("Ghosts N Skulls", view);
    tests\support\checks::expect(!rows[16].enabled && rows[16].description == "Only the current host can hit the cabinet with a Brute", "Guests can inspect cabinet status without submitting a hit");

    view.host = true;
    view.access = "Host";
    view.brute_cabinet_probe.reason = "Wait for the initial native unlock stage and a living Brute";
    rows = scripts\apparition\menu\model::build("Ghosts N Skulls", view);
    tests\support\checks::expect(!rows[16].enabled && rows[16].description == view.brute_cabinet_probe.reason, "The current native context reason disables the hit");

    view.brute_cabinet_probe.reason = "";
    view.brute_cabinet_running = true;
    view.brute_cabinet_status = "Observing";
    rows = scripts\apparition\menu\model::build("Ghosts N Skulls", view);
    tests\support\checks::expect(!rows[16].enabled && rows[16].description == "A Brute cabinet hit is already pending", "An active observer prevents a duplicate hit");
    tests\support\checks::expect(rows[17].label == "Brute Cabinet Input: Observing", "Running state is shown separately from native quest progress");

    view.brute_cabinet_running = false;
    view.brute_cabinet_probe.reason = "A cabinet hit was submitted; ambiguous native history prevents replay";
    view.brute_cabinet_status = "Pending";
    rows = scripts\apparition\menu\model::build("Ghosts N Skulls", view);
    tests\support\checks::expect(!rows[16].enabled && rows[16].description == view.brute_cabinet_probe.reason, "A pending ambiguous submission cannot be replayed after the observer stops");
    tests\support\checks::expect(rows[17].label == "Brute Cabinet Input: Pending", "Pending input remains distinct from native completion");
}

brute_cabinet_missing_snapshots_fail_closed_and_status_stays_readonly()
{
    view = ghost_view(5);
    view.host = true;
    view.access = "Host";
    view.brute_cabinet_probe = undefined;
    view.brute_cabinet_running = undefined;
    view.brute_cabinet_status = undefined;
    rows = scripts\apparition\menu\model::build("Ghosts N Skulls", view);
    tests\support\checks::expect(!rows[16].enabled && rows[16].description == "Wait for Brute cabinet readiness data", "Missing probe and worker data fail closed");
    tests\support\checks::expect(rows[17].label == "Brute Cabinet Input: Unknown" && !rows[17].enabled, "Missing status is shown as unknown and read-only");
    tests\support\checks::expect(rows[18].label == "Cabinet Route: Unknown" && !rows[18].enabled, "A missing probe shows an unknown read-only route");

    view.brute_cabinet_probe = spawnstruct();
    view.brute_cabinet_probe.reason = "";
    rows = scripts\apparition\menu\model::build("Ghosts N Skulls", view);
    tests\support\checks::expect(!rows[16].enabled && rows[16].description == "Wait for Brute cabinet input status", "Missing observer state blocks an otherwise-ready hit");
    tests\support\checks::expect(rows[18].label == "Cabinet Route: Unknown", "A missing route field uses the same unknown fallback");

    foreach (status in ["Completed", "Unavailable"])
    {
        view.brute_cabinet_status = status;
        rows = scripts\apparition\menu\model::build("Ghosts N Skulls", view);
        tests\support\checks::expect(rows[17].label == "Brute Cabinet Input: " + status && !rows[17].enabled, "Terminal observer outcomes remain read-only status");
    }
}

brute_cabinet_routes_show_initial_unlock_reactivation_and_unavailable()
{
    view = ghost_view(0);
    view.host = true;
    view.access = "Host";
    view.brute_cabinet_probe = spawnstruct();
    view.brute_cabinet_probe.reason = "";
    view.brute_cabinet_probe.route = "Reactivation";
    view.brute_cabinet_running = false;
    view.brute_cabinet_status = "Idle";
    rows = scripts\apparition\menu\model::build("Ghosts N Skulls", view);

    tests\support\checks::expect(rows[16].enabled && rows[16].description == "At a ready native cabinet stage, submit one direct bullet-type hit on the cabinet credited to a real living Brute; the native quest must advance, and an ambiguous submitted hit is not replayed", "A valid reactivation route can enable the same native-context action");
    tests\support\checks::expect(rows[18].label == "Cabinet Route: Reactivation" && rows[18].description == "A native Brute reactivation attempt was observed", "The route row identifies a native reactivation attempt");
    tests\support\checks::expect(!rows[1].checked && rows[1].label == "Pop Spawn Balloons", "Route reporting does not invent native quest completion");

    view.brute_cabinet_probe.route = "Unavailable";
    view.brute_cabinet_probe.reason = "No supported native cabinet route is ready";
    rows = scripts\apparition\menu\model::build("Ghosts N Skulls", view);
    tests\support\checks::expect(!rows[16].enabled && rows[16].description == view.brute_cabinet_probe.reason, "Unavailable routes keep the hit disabled with the native reason");
    tests\support\checks::expect(rows[18].label == "Cabinet Route: Unavailable" && rows[18].description == "No supported native cabinet route is available", "An unavailable route is distinct from an unknown route");
}

ghosts_page_fails_closed_and_guests_keep_progress_visible()
{
    view = ghost_view(1);
    view.host = false;
    view.access = "VIP";
    view.ghost_progress.active = true;
    view.ghost_probe.reason = "";
    rows = scripts\apparition\menu\model::build("Ghosts N Skulls", view);
    tests\support\checks::expect(!rows[0].enabled && rows[0].description == "Only the current host can face the native skull", "Guests see the host permission reason for the face action");
    tests\support\checks::expect(rows[1].checked && rows[8].checked, "Guests retain read-only native quest and arena progress");

    view.host = true;
    view.access = "Host";
    view.ghost_probe.reason = "The current native skull is not visible";
    rows = scripts\apparition\menu\model::build("Ghosts N Skulls", view);
    tests\support\checks::expect(!rows[0].enabled && rows[0].description == view.ghost_probe.reason, "The native probe reason disables and explains facing");

    view = basic_view();
    rows = scripts\apparition\menu\model::build("Ghosts N Skulls", view);
    tests\support\checks::expect(rows[0].label == "Face Current Skull" && !rows[0].enabled, "Missing probe and progress snapshots keep the face action closed");
    for (index = 1; index <= 7; index++)
        tests\support\checks::expect(!rows[index].checked && !rows[index].enabled && !isDefined(rows[index].callback), "Missing progress cannot invent a completed or actionable step");
    tests\support\checks::expect(!rows[8].checked && rows[9].label == "Map Waves Started: unknown" && rows[10].label == "Last Recorded Arena Result: Unconfirmed", "Missing native observations remain clearly unknown");
}

ghost_view(step)
{
    view = basic_view();
    view.host = true;
    view.access = "Host";
    view.ghost_progress = spawnstruct();
    view.ghost_progress.step = step;
    view.ghost_progress.activated = false;
    view.ghost_progress.active = false;
    view.ghost_progress.last_result = "Unconfirmed";
    view.ghost_progress.waves = 0;
    view.ghost_progress.next_floor = "";
    view.ghost_progress.remaining_kills = -1;
    view.ghost_probe = spawnstruct();
    view.ghost_probe.reason = "Wait for a visible native skull";
    view.dance_hint = "The native dance floor is not active";
    view.dance_running = false;
    view.dance_status = "Idle";
    view.floating_probe = spawnstruct();
    view.floating_probe.reason = "The native floating skull is not available";
    view.floating_running = false;
    view.floating_status = "Idle";
    return view;
}

quick_menu_keeps_the_source_row_order()
{
    view = basic_view();
    rows = scripts\apparition\menu\model::build("Quick Menu", view);
    expected = ["God Mode", "Noclip", "Bind Noclip To [{+frag}]", "Unlimited Ammo", "Unlimited Equipment",
        "Modify Score", "Perk Menu", "No Target", "Reduced Spread", "Unlimited Sprint", "Respawn", "Revive"];
    tests\support\checks::expect(rows.size == 12, "A living guest sees ten alive-only rows plus Respawn and Revive");
    for (index = 0; index < expected.size; index++)
        tests\support\checks::expect(rows[index].label == expected[index], "Living Quick Menu rows retain exact source order");
}

quick_menu_filters_alive_rows_and_preserves_host_controls()
{
    view = basic_view();
    view.host = true;
    view.access = "Host";
    rows = scripts\apparition\menu\model::build("Quick Menu", view);
    tests\support\checks::expect(rows.size == 14 && rows[12].label == "Restart Game" && rows[13].label == "Disconnect", "A living host gets only the two host-only rows after source controls");

    view = basic_view();
    view.owner_alive = false;
    rows = scripts\apparition\menu\model::build("Quick Menu", view);
    tests\support\checks::expect(rows.size == 1 && rows[0].label == "Respawn" && !isDefined(rows[0].callback), "A dead guest sees only the inert Respawn source row");

    view = basic_view();
    view.owner_alive = false;
    view.host = true;
    view.access = "Host";
    rows = scripts\apparition\menu\model::build("Quick Menu", view);
    tests\support\checks::expect(rows.size == 3 && rows[0].label == "Respawn" && rows[1].label == "Restart Game" && rows[2].label == "Disconnect", "A dead host keeps Respawn and the two host-only rows");
    foreach (row in rows)
        tests\support\checks::expect(!isDefined(row.callback), "Dead Quick Menu rows cannot invoke living-player actions");
}

perk_rows_show_full_mixed_and_empty_roster_reasons()
{
    view = perk_view();
    ids = scripts\apparition\maps\spaceland\perks::ids();
    rows = scripts\apparition\menu\model::build("All Players Perks", view);
    tests\support\checks::expect(rows[0].enabled && rows[0].checked && rows[2].enabled && rows[2].checked, "A full live host roster can apply ready perks and shows native ownership");
    tests\support\checks::expect(rows[0].description == "Use removes all ten perks from every current player; later joins keep their own perks" && rows[2].description == "Use removes this perk from every current player; later joins keep their own perks", "Lobby success descriptions limit changes to the current roster");

    mixed_player = tests\fixtures\perks::owned_player(ids);
    mixed_player.zombies_perks[ids[0]] = undefined;
    view.players = [view.target, mixed_player];
    view.perk_roster_reason = "Players must be alive and out of spectator mode for native perk changes";
    rows = scripts\apparition\menu\model::build("All Players Perks", view);
    tests\support\checks::expect(!rows[0].enabled && !rows[0].checked && rows[0].description == view.perk_roster_reason, "A mixed roster reason disables lobby changes and remains visible");
    tests\support\checks::expect(!rows[2].checked && rows[3].checked, "Lobby ownership uses all selected players' native inventory");

    view.players = [];
    view.perk_roster_reason = scripts\apparition\features\perks::roster_reason(view.players);
    view.actor_reason = scripts\apparition\runtime\context::actor_reason(view.players);
    rows = scripts\apparition\menu\model::build("All Players Perks", view);
    tests\support\checks::expect(view.perk_roster_reason == "No current players are available", "An empty roster uses the native preflight's exact reason");
    tests\support\checks::expect(!rows[0].enabled && !rows[0].checked && rows[0].description == "No current players are available", "An empty roster cannot check or dispatch All Perks");
    tests\support\checks::expect(!rows[2].enabled && !rows[2].checked && rows[2].description == "No current players are available", "An empty roster also disables individual lobby perk rows");

    view = perk_view();
    view.perk_roster_reason = undefined;
    rows = scripts\apparition\menu\model::build("All Players Perks", view);
    tests\support\checks::expect(!rows[0].enabled && rows[0].checked
        && rows[0].description == "Wait for native perk readiness",
        "A missing readiness snapshot blocks a valid lobby roster without hiding ownership");
    view.perk_roster_reason = 17;
    rows = scripts\apparition\menu\model::build("All Players Perks", view);
    tests\support\checks::expect(!rows[0].enabled && !rows[2].enabled
        && rows[0].description == "Wait for native perk readiness" && rows[1].enabled,
        "Malformed lobby readiness blocks immediate changes while retention remains configurable");
}

guest_lobby_perk_rows_show_host_reason()
{
    view = perk_view();
    view.host = false;
    view.access = "VIP";
    view.perk_roster_reason = undefined;
    rows = scripts\apparition\menu\model::build("All Players Perks", view);
    tests\support\checks::expect(!rows[0].enabled && rows[0].description == "Only the current host can change lobby perks", "Host denial takes precedence over an absent lobby snapshot");
    rows = scripts\apparition\menu\model::build("Perk Menu", view);
    tests\support\checks::expect(rows[0].enabled && rows[2].enabled, "A living guest can still manage personal perks through ready native callbacks");
}

perk_rows_use_selected_callback_readiness()
{
    view = perk_view();
    ids = scripts\apparition\maps\spaceland\perks::ids();
    view.perk_callbacks[ids[2]] = undefined;
    rows = scripts\apparition\menu\model::build("Perk Menu", view);
    tests\support\checks::expect(!rows[0].enabled && rows[0].description == "Wait for native perk callbacks", "All Perks requires callbacks for every selected perk");
    tests\support\checks::expect(rows[2].enabled && rows[2].checked && !rows[4].enabled && rows[4].description == "Wait for native perk callbacks", "A missing per-ID callback disables only rows that select it");

    view = perk_view();
    view.perk_callbacks[ids[0]].set = undefined;
    rows = scripts\apparition\menu\model::build("Perk Menu", view);
    tests\support\checks::expect(!rows[2].enabled && rows[2].description == "Wait for native perk callbacks" && rows[3].enabled, "A missing set callback disables only its selected perk");

    view = perk_view();
    view.perk_callbacks[ids[1]].unset = undefined;
    rows = scripts\apparition\menu\model::build("Perk Menu", view);
    tests\support\checks::expect(!rows[3].enabled && rows[3].description == "Wait for native perk callbacks" && rows[2].enabled, "A missing unset callback disables only its selected perk");

    view = perk_view();
    view.perk_callbacks = undefined;
    rows = scripts\apparition\menu\model::build("Perk Menu", view);
    tests\support\checks::expect(!rows[0].enabled && rows[0].description == "Wait for native perk callbacks", "An absent callback snapshot fails closed with a reason");
}

malformed_native_callback_shapes_disable_perks_without_hiding_ownership()
{
    ids = scripts\apparition\maps\spaceland\perks::ids();
    foreach (page in ["Perk Menu", "All Players Perks"])
    {
        view = perk_view();
        view.perk_callbacks = "invalid registry";
        rows = scripts\apparition\menu\model::build(page, view);
        tests\support\checks::expect(!rows[0].enabled && rows[0].checked
            && rows[0].description == "Wait for native perk callbacks",
            "A malformed native registry disables the selection without hiding known native inventory");
        for (index = 0; index < ids.size; index++)
            tests\support\checks::expect(!rows[index + 2].enabled && rows[index + 2].checked
                && rows[index + 2].description == "Wait for native perk callbacks",
                "Each personal or lobby perk row uses the shared callback shape reason");
        view = perk_view();
        view.perk_callbacks[ids[1]] = [];
        rows = scripts\apparition\menu\model::build(page, view);
        tests\support\checks::expect(!rows[0].enabled && rows[0].checked && rows[2].enabled && rows[2].checked
            && !rows[3].enabled && rows[3].checked && rows[3].description == "Wait for native perk callbacks",
            "A malformed entry blocks All Perks and its own row while another ready perk remains selectable");
        tests\support\checks::expect(scripts\apparition\features\perks::all_owned(view.players, ids),
            "Readiness inspection preserves all native ownership entries");
    }
}

personal_perk_rows_require_a_living_target_without_hiding_ownership()
{
    view = perk_view();
    ids = scripts\apparition\maps\spaceland\perks::ids();
    view.target.inlaststand = 1;
    view.perk_target_reason = scripts\apparition\features\perks::life_reason(false, view.target.inlaststand);
    rows = scripts\apparition\menu\model::build("Perk Menu", view);
    tests\support\checks::expect(!rows[0].enabled && rows[0].checked && rows[0].description == view.perk_target_reason, "A captured dead-target reason disables All Perks but preserves current ownership");
    for (index = 0; index < ids.size; index++)
        tests\support\checks::expect(!rows[index + 2].enabled && rows[index + 2].checked, "Dead personal perk rows remain readable and inactive");
    foreach (perk_id in ids)
        tests\support\checks::expect(scripts\apparition\features\perks::owns(view.target, perk_id), "Rendering perk rows does not change native ownership");

    view.host = true;
    view.access = "Host";
    view.players = [tests\fixtures\perks::owned_player(ids)];
    view.perk_roster_reason = "";
    rows = scripts\apparition\menu\model::build("All Players Perks", view);
    tests\support\checks::expect(rows[0].enabled && rows[2].enabled, "Lobby preflight depends on the current roster rather than the personal target life flag");
}

personal_perk_rows_reject_malformed_inventory_but_keep_missing_inventory_configurable()
{
    view = perk_view();
    ids = scripts\apparition\maps\spaceland\perks::ids();
    view.target.zombies_perks = "malformed inventory";
    view.perk_target_reason = scripts\apparition\features\perks::inventory_reason(view.target.zombies_perks);
    rows = scripts\apparition\menu\model::build("Perk Menu", view);
    tests\support\checks::expect(!rows[0].enabled && !rows[0].checked
        && rows[0].description == "Wait for native perk inventory",
        "All Perks is blocked before ownership reads when target inventory has the wrong container type");
    for (index = 0; index < ids.size; index++)
        tests\support\checks::expect(!rows[index + 2].enabled && !rows[index + 2].checked
            && rows[index + 2].description == "Wait for native perk inventory",
            "Individual perk controls share malformed inventory admission");
    tests\support\checks::expect(rows[1].enabled,
        "Future retention remains configurable because it does not mutate live native inventory");

    // Native grant initializes a missing inventory array, so it remains actionable
    view.target.zombies_perks = undefined;
    view.perk_target_reason = scripts\apparition\features\perks::inventory_reason(view.target.zombies_perks);
    rows = scripts\apparition\menu\model::build("Perk Menu", view);
    tests\support\checks::expect(rows[0].enabled && !rows[0].checked && rows[2].enabled,
        "Undefined inventory stays valid and appears unowned until the native grant initializes it");
}

lobby_perk_rows_use_inventory_rejection_without_blocking_a_valid_personal_target()
{
    view = perk_view();
    ids = scripts\apparition\maps\spaceland\perks::ids();
    other = tests\fixtures\perks::owned_player(ids);
    other.zombies_perks = spawnstruct();
    view.players = [view.target, other];
    // The real capture supplies this reason after complete native actor/life admission
    view.perk_roster_reason = scripts\apparition\features\perks::inventory_reason(other.zombies_perks);
    rows = scripts\apparition\menu\model::build("All Players Perks", view);
    tests\support\checks::expect(!rows[0].enabled && !rows[0].checked
        && rows[0].description == "Wait for native perk inventory",
        "A later malformed inventory keeps the lobby batch unavailable and unconfirmed");
    for (index = 0; index < ids.size; index++)
        tests\support\checks::expect(!rows[index + 2].enabled && !rows[index + 2].checked
            && rows[index + 2].description == view.perk_roster_reason,
            "Every lobby perk row uses the captured whole-roster inventory reason");
    tests\support\checks::expect(rows[1].enabled
        && scripts\apparition\features\perks::all_owned([view.target], ids),
        "Future retention remains configurable and the valid first inventory is unchanged");
    rows = scripts\apparition\menu\model::build("Perk Menu", view);
    tests\support\checks::expect(rows[0].enabled && rows[0].checked && rows[2].enabled,
        "Another player's malformed inventory cannot block a valid personal perk command");
    view.host = false;
    view.access = "VIP";
    rows = scripts\apparition\menu\model::build("All Players Perks", view);
    tests\support\checks::expect(!rows[0].enabled && rows[0].description == "Only the current host can change lobby perks",
        "The lobby authority reason remains ahead of the inventory snapshot");
}

downed_personal_perk_rows_preserve_ownership_and_future_retention()
{
    view = perk_view();
    view.target.inlaststand = 1;
    view.target.health = 1;
    view.perk_target_reason = scripts\apparition\features\perks::life_reason(true, view.target.inlaststand);
    rows = scripts\apparition\menu\model::build("Perk Menu", view);
    for (index = 0; index < rows.size; index++)
    {
        if (index == 1)
            continue;
        tests\support\checks::expect(!rows[index].enabled && rows[index].checked
            && rows[index].description == "Wait until players are out of last stand for native perk changes",
            "Downed personal All Perks and individual rows keep ownership but reject native changes");
    }
    tests\support\checks::expect(rows[1].enabled && rows[1].callback == scripts\apparition\menu\actions::toggle_retention,
        "A downed player can still configure future perk retention");
    tests\support\checks::expect(view.target.health == 1 && view.target.inlaststand == 1,
        "Rendering a blocked perk page leaves the native last-stand data untouched");
    // The same target becomes editable after its normal life state returns
    view.target.inlaststand = 0;
    view.perk_target_reason = "";
    rows = scripts\apparition\menu\model::build("Perk Menu", view);
    tests\support\checks::expect(rows[0].enabled && rows[2].enabled,
        "Leaving last stand restores immediate personal perk controls");
}

a_downed_lobby_player_blocks_the_whole_immediate_perk_selection()
{
    view = perk_view();
    ids = scripts\apparition\maps\spaceland\perks::ids();
    downed = tests\fixtures\perks::owned_player(ids);
    downed.inlaststand = 1;
    view.players[view.players.size] = downed;
    view.perk_roster_reason = scripts\apparition\features\perks::life_reason(true, downed.inlaststand);
    rows = scripts\apparition\menu\model::build("All Players Perks", view);
    for (index = 0; index < rows.size; index++)
    {
        if (index == 1)
            continue;
        tests\support\checks::expect(!rows[index].enabled && rows[index].checked
            && rows[index].description == view.perk_roster_reason,
            "A downed lobby member blocks all immediate perk changes without hiding shared ownership");
    }
    tests\support\checks::expect(rows[1].enabled,
        "The current lobby can configure future retention while a member is down");
    view.host = false;
    view.access = "VIP";
    rows = scripts\apparition\menu\model::build("All Players Perks", view);
    tests\support\checks::expect(rows[0].description == "Only the current host can change lobby perks",
        "Guest permission still precedes a downed roster's perk readiness");
}

personal_perk_rows_fail_closed_for_missing_or_malformed_readiness()
{
    view = perk_view();
    view.perk_target_reason = undefined;
    rows = scripts\apparition\menu\model::build("Perk Menu", view);
    tests\support\checks::expect(!rows[0].enabled && rows[0].checked
        && rows[0].description == "Wait for native perk readiness"
        && !rows[2].enabled && rows[2].checked,
        "A missing per-target reason blocks edits without hiding current native ownership");

    view.perk_target_reason = 17;
    rows = scripts\apparition\menu\model::build("Perk Menu", view);
    tests\support\checks::expect(!rows[0].enabled && rows[0].checked
        && rows[0].description == "Wait for native perk readiness"
        && !rows[2].enabled && rows[2].checked,
        "A malformed per-target reason fails closed while current ownership stays visible");
}

personal_perk_rows_report_actor_denial_before_temporary_readiness()
{
    view = perk_view();
    view.target = 17;
    view.target_actor_reason = "Co-Host access is required to change another player";
    view.perk_target_reason = "Wait until native temporary perk handling is finished";
    rows = scripts\apparition\menu\model::build("Perk Menu", view);
    foreach (row in rows)
        tests\support\checks::expect(!row.enabled && !row.checked
            && row.description == view.target_actor_reason,
            "Selected-target permission denial wins before per-target readiness or inventory reads");
}

temporary_perk_window_blocks_immediate_rows_but_preserves_native_ownership()
{
    ids = scripts\apparition\maps\spaceland\perks::ids();
    view = perk_view();
    view.target = tests\fixtures\perks::retaining_player(ids);
    view.target.apparition_perk_retention.saved = [ids[0], ids[1]];
    view.target.zombies_perks[ids[0]] = undefined;
    view.players = [view.target];
    view.perk_target_reason = "Wait until native temporary perk handling is finished";
    rows = scripts\apparition\menu\model::build("Perk Menu", view);
    tests\support\checks::expect(!rows[0].enabled && !rows[0].checked
        && rows[0].description == view.perk_target_reason,
        "All Perks stays disabled and reflects current native inventory during arena ownership");
    tests\support\checks::expect(!rows[2].enabled && !rows[2].checked
        && rows[2].description == view.perk_target_reason
        && !rows[3].enabled && rows[3].checked,
        "Individual rows keep native ownership checkmarks while immediate changes are paused");
    tests\support\checks::expect(rows[1].enabled && rows[1].checked
        && rows[1].callback == scripts\apparition\menu\actions::toggle_retention,
        "Future retention remains configurable and distinct from a saved pre-arena perk list");
    tests\support\checks::expect(!isDefined(view.target.zombies_perks[ids[0]])
        && view.target.apparition_perk_retention.saved[0] == ids[0],
        "Rendering does not restore or mutate native inventory from the retained pre-arena snapshot");

    second = tests\fixtures\perks::retaining_player(ids);
    second.zombies_perks[ids[0]] = undefined;
    view.host = true;
    view.access = "Host";
    view.players = [view.target, second];
    view.actor_reason = "";
    view.perk_roster_reason = "Wait until native temporary perk handling is finished";
    rows = scripts\apparition\menu\model::build("All Players Perks", view);
    tests\support\checks::expect(!rows[0].enabled && !rows[0].checked
        && rows[0].description == view.perk_roster_reason
        && !rows[2].enabled && !rows[2].checked
        && rows[2].description == view.perk_roster_reason,
        "A busy lobby roster blocks All Perks and individual writes without substituting retained ownership");
    tests\support\checks::expect(rows[1].enabled && rows[1].checked,
        "The host can configure future retention during native temporary perk ownership");

    view.perk_target_reason = "";
    rows = scripts\apparition\menu\model::build("Perk Menu", view);
    tests\support\checks::expect(rows[0].enabled && !rows[0].checked
        && rows[2].enabled && !rows[2].checked && rows[3].enabled && rows[3].checked,
        "A restored empty reason enables callbacks while checkmarks still follow native inventory");
}

retain_perks_rows_bind_target_and_lobby_scope()
{
    view = perk_view();
    ids = scripts\apparition\maps\spaceland\perks::ids();
    view.target = tests\fixtures\perks::retaining_player(ids);
    view.retention_ready = true;
    rows = scripts\apparition\menu\model::build("Perk Menu", view);
    tests\support\checks::expect(rows[1].label == "Retain Perks" && rows[1].kind == "toggle", "Retain Perks occupies its source position as a toggle");
    tests\support\checks::expect(rows[1].enabled && rows[1].checked, "The personal retention toggle reads its active record");
    tests\support\checks::expect(rows[1].callback == scripts\apparition\menu\actions::toggle_retention && rows[1].target == view.target && !rows[1].lobby, "Personal retention targets the selected player through the dedicated action");
    tests\support\checks::expect(rows[1].description == "Use disables retention; saved snapshots are discarded; owned perks stay", "The personal row explains when perks are captured and restored");

    view.players = [view.target];
    view.host = true;
    view.access = "Host";
    view.actor_reason = "";
    rows = scripts\apparition\menu\model::build("All Players Perks", view);
    tests\support\checks::expect(rows[1].callback == scripts\apparition\menu\actions::toggle_retention && rows[1].target == view.target && rows[1].lobby, "Lobby retention uses the selected target with fresh lobby authorization");
    tests\support\checks::expect(rows[1].enabled && rows[1].checked, "A ready host can read and configure retention for the current roster");
    tests\support\checks::expect(rows[1].description == "Use disables retention for every current player; saved snapshots are discarded; owned perks stay", "Lobby retention explains its current-roster scope and later joins");

    view.host = false;
    view.access = "VIP";
    rows = scripts\apparition\menu\model::build("All Players Perks", view);
    tests\support\checks::expect(!rows[1].enabled && rows[1].description == "Only the current host can change lobby perks", "A guest can inspect lobby retention but cannot change it");
}

retain_perks_checkmarks_read_current_roster_records_without_mutation()
{
    ids = scripts\apparition\maps\spaceland\perks::ids();
    first = tests\fixtures\perks::retaining_player(ids);
    second = tests\fixtures\perks::retaining_player(ids);
    first.apparition_perk_retention.saved = [ids[0], ids[1]];
    players = [first, second];

    view = perk_view();
    view.target = first;
    view.players = players;
    view.host = true;
    view.access = "Host";
    view.retention_ready = true;
    view.actor_reason = "";
    rows = scripts\apparition\menu\model::build("All Players Perks", view);
    tests\support\checks::expect(rows[1].checked && rows[1].enabled, "The lobby row reflects enabled records for the current roster");
    tests\support\checks::expect(first.apparition_perk_retention.saved.size == 2 && first.apparition_perk_retention.saved[0] == ids[0] && first.apparition_perk_retention.saved[1] == ids[1], "Rendering preserves the captured perk snapshot");

    second.apparition_perk_retention = undefined;
    rows = scripts\apparition\menu\model::build("All Players Perks", view);
    tests\support\checks::expect(!rows[1].checked, "Mixed retention records are rendered unchecked");

    players = [];
    view.players = players;
    view.actor_reason = "No current players are available";
    rows = scripts\apparition\menu\model::build("All Players Perks", view);
    tests\support\checks::expect(!rows[1].checked && !rows[1].enabled && rows[1].description == view.actor_reason, "An empty current roster stays unchecked and explains why it cannot be changed");
}

retain_perks_follow_hook_host_and_actor_readiness()
{
    view = perk_view();
    ids = scripts\apparition\maps\spaceland\perks::ids();
    view.target = tests\fixtures\perks::owned_player(ids);
    view.retention_ready = false;
    rows = scripts\apparition\menu\model::build("Perk Menu", view);
    tests\support\checks::expect(!rows[1].enabled && rows[1].description == "Retain Perks requires the active Apparition last-stand callback", "The personal toggle reports a missing native hook");

    view.retention_ready = true;
    view.host = false;
    view.access = "VIP";
    view.actor_reason = undefined;
    rows = scripts\apparition\menu\model::build("Perk Menu", view);
    tests\support\checks::expect(rows[1].enabled && !rows[1].checked, "Personal retention can be configured for a dead target without an actor roster");

    view.players = [view.target];
    view.host = false;
    view.access = "VIP";
    rows = scripts\apparition\menu\model::build("All Players Perks", view);
    tests\support\checks::expect(!rows[1].enabled && rows[1].description == "Only the current host can change lobby perks", "Lobby host permission is checked before an absent actor snapshot");

    view.host = true;
    view.access = "Host";
    view.actor_reason = "Every selected player must be a valid native actor";
    rows = scripts\apparition\menu\model::build("All Players Perks", view);
    tests\support\checks::expect(!rows[1].enabled && rows[1].description == view.actor_reason, "Lobby actor preflight reasons are shown directly");

    view.actor_reason = undefined;
    rows = scripts\apparition\menu\model::build("All Players Perks", view);
    tests\support\checks::expect(!rows[1].enabled && rows[1].description == "Wait for a valid player roster", "A missing actor snapshot fails closed with a useful reason");

    view.retention_ready = false;
    view.actor_reason = "";
    rows = scripts\apparition\menu\model::build("All Players Perks", view);
    tests\support\checks::expect(!rows[1].enabled && rows[1].description == "Enable requires the active last-stand callback; disable existing settings in each player's Perk Menu", "The lobby toggle explains how to disable existing records without the hook");
}

checked_retention_rows_remain_available_for_disabling_after_hook_loss()
{
    ids = scripts\apparition\maps\spaceland\perks::ids();
    first = tests\fixtures\perks::retaining_player(ids);
    view = perk_view();
    view.target = first;
    view.retention_ready = false;
    rows = scripts\apparition\menu\model::build("Perk Menu", view);
    tests\support\checks::expect(rows[1].checked && rows[1].enabled, "A personal setting can still be disabled after callback ownership is lost");
    tests\support\checks::expect(rows[1].description == "Use disables retention; saved snapshots are discarded; owned perks stay; capture callback is inactive", "The personal row explains that only disabling remains available");

    second = tests\fixtures\perks::retaining_player(ids);
    view.players = [first, second];
    view.host = true;
    view.access = "Host";
    view.actor_reason = "";
    rows = scripts\apparition\menu\model::build("All Players Perks", view);
    tests\support\checks::expect(rows[1].checked && rows[1].enabled, "A uniformly enabled lobby setting can still be disabled after callback ownership is lost");
    tests\support\checks::expect(rows[1].description == "Use disables retention for every current player; saved snapshots are discarded; owned perks stay; capture callback is inactive", "The lobby row gives the same safe disable-only explanation");

    second.apparition_perk_retention = undefined;
    rows = scripts\apparition\menu\model::build("All Players Perks", view);
    tests\support\checks::expect(!rows[1].checked && !rows[1].enabled, "Mixed settings cannot be enabled or changed after callback ownership is lost");
    tests\support\checks::expect(rows[1].description == "Enable requires the active last-stand callback; disable existing settings in each player's Perk Menu", "A mixed lobby row directs cleanup to each player's Perk Menu");
}

malformed_ufo_stage_data_keeps_all_stage_actions_unavailable()
{
    view = basic_view();
    view.host = true;
    view.access = "Host";
    native = tests\fixtures\spaceland::quest(8);
    native._id_13F1B["ufo"] = 8.5;
    view.ufo = scripts\apparition\maps\spaceland\quest::progress(native);
    rows = scripts\apparition\menu\model::build("UFO Quest Steps", view);
    tests\support\checks::expect(view.ufo.step == -1 && !view.ufo.finished && rows.size == 12,
        "Invalid native stage data stays unknown while the complete source stage list remains visible");
    foreach (row in rows)
        tests\support\checks::expect(!row.enabled && !row.checked && !isDefined(row.callback)
            && row.description == "The Spaceland UFO quest is not initialized",
            "An unknown UFO stage cannot offer a quest action or claim native completion");
}

ufo_final_stage_is_unchecked_until_native_completion()
{
    view = basic_view();
    native = tests\fixtures\spaceland::quest(11);
    view.ufo = scripts\apparition\maps\spaceland\quest::progress(native);
    rows = scripts\apparition\menu\model::build("UFO Quest Steps", view);
    tests\support\checks::expect(rows.size == 12, "All twelve registered UFO stages are displayed");
    tests\support\checks::expect(rows[10].checked && !rows[11].checked, "The active final stage remains incomplete");
    native.flag["ufo_quest_finished"] = 1;
    view.ufo = scripts\apparition\maps\spaceland\quest::progress(native);
    rows = scripts\apparition\menu\model::build("UFO Quest Steps", view);
    tests\support\checks::expect(rows[11].checked, "The final checkbox reads the native completion flag");
}

the_portal_stage_binds_native_entry_and_explains_the_wave_wait()
{
    view = basic_view();
    view.host = true;
    view.access = "Host";
    view.portal_ready = true;
    view.portal_hint = "Transport the host through the native Pack-a-Punch route";
    view.ufo = scripts\apparition\maps\spaceland\quest::progress(tests\fixtures\spaceland::quest(1));
    rows = scripts\apparition\menu\model::build("UFO Quest Steps", view);
    tests\support\checks::expect(rows[1].enabled && rows[1].lobby, "Native portal entry requires a ready host");
    tests\support\checks::expect(rows[1].callback == scripts\apparition\menu\actions::enter_pap, "The current portal stage selects the native entry adapter");
    tests\support\checks::expect(!rows[1].checked, "Entry availability alone cannot complete the stage");
    view.portal_ready = false;
    view.portal_hint = "Portal used; wait for the next wave";
    rows = scripts\apparition\menu\model::build("UFO Quest Steps", view);
    tests\support\checks::expect(!rows[1].enabled && !rows[1].checked, "A used portal still waits for native quest advancement");
    tests\support\checks::expect(rows[1].description == view.portal_hint, "The footer explains why the native portal stage remains pending");
    view.portal_ready = true;
    view.host = false;
    view.access = "VIP";
    rows = scripts\apparition\menu\model::build("UFO Quest Steps", view);
    tests\support\checks::expect(!rows[1].enabled, "A guest cannot transport the host through the quest menu");
}

spaceland_navigation_opens_portal_controls_without_starting_travel()
{
    view = basic_view();
    rows = scripts\apparition\menu\model::build("Spaceland Scripts", view);
    tests\support\checks::expect(rows[3].label == "Portal Controls" && rows[3].kind == "submenu", "Spaceland exposes the native portal controls page");
    tests\support\checks::expect(rows[3].destination == "Portal Controls" && rows[3].callback == scripts\apparition\menu\actions::open_page, "Navigation cannot submit a portal trip by itself");
}

side_portal_controls_bind_native_progress_and_actions()
{
    view = portal_view();
    view.portal_sides["moon"].used = true;
    view.portal_sides["moon"].ready = false;
    rows = scripts\apparition\menu\model::build("Portal Controls", view);
    expected = ["arcade", "moon", "europa", "mars"];
    tests\support\checks::expect(rows.size == 6, "Portal controls show four side visits, native PAP entry and status");
    for (index = 0; index < expected.size; index++)
    {
        tests\support\checks::expect(rows[index].area == expected[index] && rows[index].label == "Use Side Portal " + (index + 1), "Each side control retains its native identity and stable display order");
        tests\support\checks::expect(rows[index].callback == scripts\apparition\menu\actions::visit_portal && rows[index].lobby && !isDefined(rows[index].target), "Side visits bind the host quest action instead of a selected remote actor");
    }
    tests\support\checks::expect(!rows[0].checked && rows[1].checked && !rows[1].enabled, "Native side-use fields drive progress without offering completed visits again");
    tests\support\checks::expect(rows[4].callback == scripts\apparition\menu\actions::enter_pap && rows[4].kind == "action", "The final action uses the same native PAP adapter as the UFO stage");
    tests\support\checks::expect(rows[5].label == "Visit Status: Idle" && !rows[5].enabled && !isDefined(rows[5].callback), "The worker status is read-only");
}

portal_controls_require_the_host_and_an_idle_visit_slot()
{
    view = portal_view();
    view.host = false;
    view.access = "VIP";
    rows = scripts\apparition\menu\model::build("Portal Controls", view);
    for (index = 0; index < 5; index++)
        tests\support\checks::expect(!rows[index].enabled, "Guest portal controls cannot submit host travel");
    view.host = true;
    view.access = "Host";
    view.portal_running = true;
    rows = scripts\apparition\menu\model::build("Portal Controls", view);
    for (index = 0; index < 5; index++)
        tests\support\checks::expect(!rows[index].enabled, "An active side visit prevents another portal request");
}

portal_view()
{
    view = basic_view();
    view.host = true;
    view.access = "Host";
    view.portal_ready = true;
    view.portal_hint = "Transport the host through the native Pack-a-Punch route";
    view.portal_running = false;
    view.portal_status = "Idle";
    view.portal_sides = [];
    foreach (area in ["arcade", "moon", "europa", "mars"])
    {
        side = spawnstruct();
        side.used = false;
        side.ready = true;
        side.hint = "Use this powered side portal";
        view.portal_sides[area] = side;
    }
    return view;
}

current_speaker_defense_stages_open_guest_viewable_controls()
{
    view = basic_view();
    foreach (step in [2, 3, 4])
    {
        view.ufo = scripts\apparition\maps\spaceland\quest::progress(tests\fixtures\spaceland::quest(step));
        rows = scripts\apparition\menu\model::build("UFO Quest Steps", view);
        tests\support\checks::expect(rows[step].kind == "submenu" && rows[step].enabled, "The current defense stage opens its controls for guests to inspect");
        tests\support\checks::expect(rows[step].destination == "Speaker Defense Controls" && rows[step].callback == scripts\apparition\menu\actions::open_page, "Stage navigation opens the defense page without requesting a speaker");
        tests\support\checks::expect(!rows[step].checked && !rows[step].lobby, "Opening controls does not claim native completion or require host privileges");
        for (future = step + 1; future <= 4; future++)
            tests\support\checks::expect(!rows[future].enabled && !isDefined(rows[future].callback), "A future defense stage remains unavailable until native quest progress advances");
    }
    view.ufo = scripts\apparition\maps\spaceland\quest::progress(tests\fixtures\spaceland::quest(3));
    rows = scripts\apparition\menu\model::build("UFO Quest Steps", view);
    tests\support\checks::expect(rows[2].checked && !rows[2].enabled && !isDefined(rows[2].callback), "Completed defense checkboxes continue to follow native quest progress only");

    view.host = true;
    view.access = "Host";
    view.dj = spawnstruct();
    view.dj.reason = "";
    view.dj.kind = "tone";
    view.ufo = scripts\apparition\maps\spaceland\quest::progress(tests\fixtures\spaceland::quest(6));
    rows = scripts\apparition\menu\model::build("UFO Quest Steps", view);
    tests\support\checks::expect(rows[6].enabled && rows[6].callback == scripts\apparition\menu\actions::request_dj, "The later tone-generator DJ request keeps its existing native action");
}

speaker_defense_controls_bind_host_actions_and_native_status()
{
    view = speaker_view();
    rows = scripts\apparition\menu\model::build("Speaker Defense Controls", view);
    tests\support\checks::expect(rows.size == 10, "Speaker defense controls show request, placement, assist, pickup and native status");
    tests\support\checks::expect(rows[0].label == "Request/Retry Speaker" && rows[0].callback == scripts\apparition\menu\actions::request_dj, "Request and retry use the existing native DJ door action");
    tests\support\checks::expect(rows[0].speaker_defense, "The speaker request is scoped to its native defense stages");
    tests\support\checks::expect(rows[1].label == "Place Speaker" && rows[1].callback == scripts\apparition\menu\actions::place_speaker, "Speaker placement uses its native interaction worker");
    tests\support\checks::expect(rows[2].label == "Assist Active Speaker" && rows[2].callback == scripts\apparition\menu\actions::start_speakers, "Defense assistance starts through its host-level action");
    tests\support\checks::expect(rows[3].label == "Collect Defended Speaker" && rows[3].callback == scripts\apparition\menu\actions::collect_speaker, "Collection uses the recorded native speaker pickup action");
    tests\support\checks::expect(rows[4].label == "Cancel Speaker Job" && rows[4].callback == scripts\apparition\menu\actions::cancel_speakers, "The shared speaker job can be canceled through its host-level action");
    for (index = 0; index < 5; index++)
        tests\support\checks::expect(rows[index].lobby && !isDefined(rows[index].target), "Gameplay actions use fresh host-level authorization without a selected-player target");
    tests\support\checks::expect(rows[5].label == "Placement Status: Idle" && rows[6].label == "Speaker Job Status: Idle", "Placement and shared speaker job statuses remain visible");
    tests\support\checks::expect(!rows[5].enabled && !rows[6].enabled && !isDefined(rows[5].callback) && !isDefined(rows[6].callback), "Job status rows are read-only");
    tests\support\checks::expect(!rows[7].enabled && !rows[8].enabled && !rows[9].enabled, "Native timer, speaker health and pickup requirements are read-only");
    tests\support\checks::expect(rows[9].label == "Native Wave Required" && rows[9].description == "The actual speaker is recorded during active defense; no model scan or timer skip is used, and native pickup plus a regular wave remain required", "The page explains recorded pickup history and native completion requirements");
}

speaker_defense_controls_follow_readiness_and_job_state()
{
    view = speaker_view();
    rows = scripts\apparition\menu\model::build("Speaker Defense Controls", view);
    tests\support\checks::expect(rows[0].enabled && rows[1].enabled && rows[2].enabled && !rows[3].enabled && !rows[4].enabled, "A ready host can request, place and assist while idle");
    view.ufo = scripts\apparition\maps\spaceland\quest::progress(tests\fixtures\spaceland::quest(6));
    rows = scripts\apparition\menu\model::build("Speaker Defense Controls", view);
    tests\support\checks::expect(!rows[0].enabled, "A still-open speaker page cannot turn its request into the later tone-generator action");
    view = speaker_view();

    view.speaker_pickup_hint = "No successful active-defense speaker capture is recorded";
    rows = scripts\apparition\menu\model::build("Speaker Defense Controls", view);
    tests\support\checks::expect(!rows[3].enabled && rows[3].description == view.speaker_pickup_hint, "Missing speaker history disables collection with a clear reason");
    view.speaker_pickup_hint = "The recorded speaker pickup was already submitted";
    rows = scripts\apparition\menu\model::build("Speaker Defense Controls", view);
    tests\support\checks::expect(!rows[3].enabled && rows[3].description == view.speaker_pickup_hint, "A submitted pickup cannot be collected again");
    view.speaker_pickup_ready = true;
    view.speaker_pickup_hint = "";
    rows = scripts\apparition\menu\model::build("Speaker Defense Controls", view);
    tests\support\checks::expect(rows[3].enabled, "A ready host can collect the recorded defended speaker");
    view.ufo = scripts\apparition\maps\spaceland\quest::progress(tests\fixtures\spaceland::quest(5));
    rows = scripts\apparition\menu\model::build("Speaker Defense Controls", view);
    tests\support\checks::expect(!rows[3].enabled, "Recorded pickup history cannot enable collection outside a current speaker defense stage");
    view.ufo = scripts\apparition\maps\spaceland\quest::progress(tests\fixtures\spaceland::quest(2));

    view.speaker_place_running = true;
    view.speaker_place_status = "Placing";
    view.speaker_running = true;
    view.speaker_status = "Awaiting pickup";
    rows = scripts\apparition\menu\model::build("Speaker Defense Controls", view);
    tests\support\checks::expect(!rows[1].enabled && !rows[2].enabled && !rows[3].enabled && rows[4].enabled, "The shared reservation prevents placement, assist and collection while allowing cancellation");
    tests\support\checks::expect(rows[5].label == "Placement Status: Placing" && rows[6].label == "Speaker Job Status: Awaiting pickup", "Placement and the shared job report their own live states");
    quest_rows = scripts\apparition\menu\model::build("UFO Quest Steps", view);
    tests\support\checks::expect(!quest_rows[2].checked && quest_rows[2].kind == "submenu", "An awaiting pickup job does not complete the native speaker checkbox");

    view.speaker_status = "Cancelling";
    rows = scripts\apparition\menu\model::build("Speaker Defense Controls", view);
    tests\support\checks::expect(!rows[4].enabled && rows[6].label == "Speaker Job Status: Cancelling", "A pending shared-job cancellation cannot be queued again");

    view = speaker_view();
    view.speaker_place_ready = false;
    view.speaker_place_hint = "The host must be alive and near the native speaker spot";
    view.speaker_ready = false;
    view.speaker_hint = "The active native speaker is not available";
    view.speaker_pickup_ready = false;
    view.speaker_pickup_hint = "No successful active-defense speaker capture is recorded";
    rows = scripts\apparition\menu\model::build("Speaker Defense Controls", view);
    tests\support\checks::expect(!rows[1].enabled && rows[1].description == view.speaker_place_hint, "Placement keeps its actor readiness explanation");
    tests\support\checks::expect(!rows[2].enabled && rows[2].description == view.speaker_hint, "Defense assist keeps its missing-speaker explanation");
    tests\support\checks::expect(!rows[3].enabled && rows[3].description == view.speaker_pickup_hint, "Collection keeps its missing-capture explanation");

    view.host = false;
    view.access = "VIP";
    rows = scripts\apparition\menu\model::build("Speaker Defense Controls", view);
    for (index = 0; index < 5; index++)
        tests\support\checks::expect(!rows[index].enabled, "Guests can inspect the page but cannot submit speaker actions");
    tests\support\checks::expect(rows[0].description == "Only the current host can control the native speaker" && rows[1].description == rows[0].description, "Guest actions clearly explain the host requirement");
    tests\support\checks::expect(rows[2].description == rows[0].description && rows[3].description == rows[0].description && rows[4].description == rows[0].description, "Guest defense, collection and cancellation controls explain the host requirement");
}

speaker_defense_controls_show_unknown_native_values_clearly()
{
    view = speaker_view();
    view.speaker_timer = undefined;
    view.speaker_health = -1;
    rows = scripts\apparition\menu\model::build("Speaker Defense Controls", view);
    tests\support\checks::expect(rows[6].label == "Native Defense Timer: unknown", "An unavailable native timer is shown as unknown rather than zero");
    tests\support\checks::expect(rows[7].label == "Native Speaker Health: unknown", "A missing speaker actor is shown as unknown rather than zero health");

    view.speaker_timer = -1;
    rows = scripts\apparition\menu\model::build("Speaker Defense Controls", view);
    tests\support\checks::expect(rows[6].label == "Native Defense Timer: unknown", "A negative timer sentinel is not presented as a native reading");

    view.speaker_timer = 0;
    view.speaker_health = 0;
    rows = scripts\apparition\menu\model::build("Speaker Defense Controls", view);
    tests\support\checks::expect(rows[6].label == "Native Defense Timer: 0 seconds", "A real native timer value of zero remains visible");
    tests\support\checks::expect(rows[7].label == "Native Speaker Health: 0/10", "A live actor with zero health is distinct from an unknown actor");
}

speaker_view()
{
    view = basic_view();
    view.host = true;
    view.access = "Host";
    view.ufo = scripts\apparition\maps\spaceland\quest::progress(tests\fixtures\spaceland::quest(2));
    view.dj = spawnstruct();
    view.dj.reason = "";
    view.dj.kind = "defense";
    view.speaker_place_ready = true;
    view.speaker_place_running = false;
    view.speaker_place_status = "Idle";
    view.speaker_place_hint = "Place the active native speaker at the selected quest location";
    view.speaker_ready = true;
    view.speaker_running = false;
    view.speaker_status = "Idle";
    view.speaker_hint = "Assist the active native speaker defense";
    view.speaker_pickup_ready = false;
    view.speaker_pickup_hint = "No successful active-defense speaker capture is recorded";
    view.speaker_timer = 30;
    view.speaker_health = 10;
    return view;
}

the_current_wave_stage_opens_guest_viewable_controls_without_completing()
{
    view = basic_view();
    view.ufo = scripts\apparition\maps\spaceland\quest::progress(tests\fixtures\spaceland::quest(5));
    rows = scripts\apparition\menu\model::build("UFO Quest Steps", view);
    tests\support\checks::expect(rows[5].label == "Wait One Wave" && rows[5].kind == "submenu" && rows[5].enabled, "The current wave stage opens its native controls for guests");
    tests\support\checks::expect(rows[5].destination == "Native Wave Controls" && rows[5].callback == scripts\apparition\menu\actions::open_page, "Navigation opens the wave page without clearing actors");
    tests\support\checks::expect(!rows[5].checked && !rows[5].lobby, "Opening wave controls leaves native completion pending and does not require host privileges");
    tests\support\checks::expect(!rows[6].enabled && !isDefined(rows[6].callback), "The next quest stage stays locked until native wave progression advances");

    view.ufo = scripts\apparition\maps\spaceland\quest::progress(tests\fixtures\spaceland::quest(4));
    rows = scripts\apparition\menu\model::build("UFO Quest Steps", view);
    tests\support\checks::expect(!rows[5].enabled && !isDefined(rows[5].callback), "A future wave stage cannot start early");
    view.ufo = scripts\apparition\maps\spaceland\quest::progress(tests\fixtures\spaceland::quest(6));
    rows = scripts\apparition\menu\model::build("UFO Quest Steps", view);
    tests\support\checks::expect(rows[5].checked && !rows[5].enabled && !isDefined(rows[5].callback), "Completed wave progress remains a native-only checkbox");
}

native_wave_controls_bind_host_actions_and_read_native_progress()
{
    view = wave_view();
    rows = scripts\apparition\menu\model::build("Native Wave Controls", view);
    tests\support\checks::expect(rows.size == 6, "Wave controls show clear, cancel, status, counters and the native completion explanation");
    tests\support\checks::expect(rows[0].label == "Clear to Next Regular Wave" && rows[0].callback == scripts\apparition\menu\actions::start_wave, "Clear starts the native wave worker");
    tests\support\checks::expect(rows[1].label == "Cancel Wave Clearing" && rows[1].callback == scripts\apparition\menu\actions::cancel_wave, "Cancel stops future wave-clear input through its host action");
    tests\support\checks::expect(rows[0].lobby && rows[1].lobby && !isDefined(rows[0].target) && !isDefined(rows[1].target), "Both gameplay actions use host-level authorization");
    tests\support\checks::expect(rows[2].label == "Wave Job Status: Idle" && !rows[2].enabled && !isDefined(rows[2].callback), "Wave job status is read-only");
    tests\support\checks::expect(rows[3].label == "Native Wave Number: 0" && rows[4].label == "Native Deaths: 0/4", "Wave and death counters display native progress");
    tests\support\checks::expect(!rows[3].enabled && !rows[4].enabled && !rows[5].enabled && !isDefined(rows[3].callback) && !isDefined(rows[4].callback) && !isDefined(rows[5].callback), "Native counters and completion explanation are read-only");
    tests\support\checks::expect(rows[5].label == "Native Wave Required" && rows[5].description == "A normal event or clown round may run first; protected or non-counting actors remain untouched, and only native quest advancement confirms completion", "The page explains event handling, exclusions and native completion ownership");
}

native_wave_controls_follow_readiness_job_and_guest_state()
{
    view = wave_view();
    rows = scripts\apparition\menu\model::build("Native Wave Controls", view);
    tests\support\checks::expect(rows[0].enabled && !rows[1].enabled, "A ready host can start one idle wave clear");

    view.wave_running = true;
    view.wave_ready = false;
    view.wave_status = "Active";
    rows = scripts\apparition\menu\model::build("Native Wave Controls", view);
    tests\support\checks::expect(!rows[0].enabled && rows[1].enabled && rows[2].label == "Wave Job Status: Active", "An active worker blocks a second start and permits cancellation");
    view.wave_status = "Cancelling";
    rows = scripts\apparition\menu\model::build("Native Wave Controls", view);
    tests\support\checks::expect(!rows[1].enabled && rows[2].label == "Wave Job Status: Cancelling", "A pending cancellation cannot be repeated");

    view = wave_view();
    view.wave_ready = false;
    view.wave_hint = "A native event round is still running";
    rows = scripts\apparition\menu\model::build("Native Wave Controls", view);
    tests\support\checks::expect(!rows[0].enabled && rows[0].description == view.wave_hint, "Native readiness keeps its specific blocking explanation");

    view.host = false;
    view.access = "VIP";
    rows = scripts\apparition\menu\model::build("Native Wave Controls", view);
    tests\support\checks::expect(!rows[0].enabled && !rows[1].enabled, "Guests can inspect wave state but cannot control the host worker");
    tests\support\checks::expect(rows[0].description == "Only the current host can control native wave clearing" && rows[1].description == rows[0].description, "Guest controls explain the host requirement");
}

native_wave_controls_distinguish_unknown_counters_and_explain_events()
{
    view = wave_view();
    view.wave_progress.wave = -1;
    view.wave_progress.kills = -1;
    rows = scripts\apparition\menu\model::build("Native Wave Controls", view);
    tests\support\checks::expect(rows[3].label == "Native Wave Number: unknown" && rows[4].label == "Native Deaths: unknown", "Unknown native counters are not shown as zero");

    view.wave_progress.wave = 3;
    view.wave_progress.kills = view.wave_progress.goal;
    view.wave_status = "Active";
    rows = scripts\apparition\menu\model::build("Native Wave Controls", view);
    tests\support\checks::expect(rows[4].label == "Native Deaths: 4/4" && rows[2].label == "Wave Job Status: Active", "A full counter alone does not advertise worker completion");
    quest_rows = scripts\apparition\menu\model::build("UFO Quest Steps", view);
    tests\support\checks::expect(!quest_rows[5].checked && quest_rows[5].kind == "submenu", "A full death counter leaves the wave checkbox pending until native quest advancement");
    tests\support\checks::expect(rows[5].description == "A normal event or clown round may run first; protected or non-counting actors remain untouched, and only native quest advancement confirms completion", "Normal event waves, actor exclusions and native quest advancement stay explicit");
}

wave_view()
{
    view = basic_view();
    view.host = true;
    view.access = "Host";
    view.ufo = scripts\apparition\maps\spaceland\quest::progress(tests\fixtures\spaceland::quest(5));
    view.wave_hint = "Clear unprotected native blockers to reach the next regular wave";
    view.wave_ready = true;
    view.wave_running = false;
    view.wave_status = "Idle";
    view.wave_progress = spawnstruct();
    view.wave_progress.wave = 0;
    view.wave_progress.kills = 0;
    view.wave_progress.goal = 4;
    return view;
}

the_current_generator_stage_binds_native_placement()
{
    view = basic_view();
    view.host = true;
    view.access = "Host";
    view.generators_ready = true;
    view.generators_hint = "Place missing generators";
    view.ufo = scripts\apparition\maps\spaceland\quest::progress(tests\fixtures\spaceland::quest(7));
    rows = scripts\apparition\menu\model::build("UFO Quest Steps", view);
    tests\support\checks::expect(rows[7].enabled && rows[7].lobby, "Ready generator placement requires host scope");
    tests\support\checks::expect(rows[7].callback == scripts\apparition\menu\actions::place_generators, "The generator row selects its native interaction adapter");
}

the_current_tone_stage_opens_controls_without_claiming_completion()
{
    view = basic_view();
    native = tests\fixtures\spaceland::tones();
    view.ufo = scripts\apparition\maps\spaceland\quest::progress(native);
    rows = scripts\apparition\menu\model::build("UFO Quest Steps", view);
    tests\support\checks::expect(rows[8].kind == "submenu" && rows[8].enabled, "The current tone stage opens its controls");
    tests\support\checks::expect(rows[8].destination == "UFO Tone Controls", "Tone navigation selects the control page");
    tests\support\checks::expect(rows[8].callback == scripts\apparition\menu\actions::open_page, "Opening tone controls does not send native notes");
    tests\support\checks::expect(!rows[8].checked && !rows[9].enabled, "An open control page does not complete or unlock later stages");
    native._id_13F1B["ufo"] = 9;
    view.ufo = scripts\apparition\maps\spaceland\quest::progress(native);
    rows = scripts\apparition\menu\model::build("UFO Quest Steps", view);
    tests\support\checks::expect(rows[8].kind == "toggle" && rows[8].checked && !rows[8].enabled, "A completed tone stage displays native progress instead of starting another job");
}

tone_controls_bind_start_cancel_and_current_job_status()
{
    view = basic_view();
    view.host = true;
    view.access = "Host";
    view.tones_ready = true;
    view.tones_running = false;
    view.tone_status = "Idle";
    rows = scripts\apparition\menu\model::build("UFO Tone Controls", view);
    tests\support\checks::expect(rows.size == 3, "Tone controls expose start, cancel and status");
    tests\support\checks::expect(rows[0].callback == scripts\apparition\menu\actions::start_tones && rows[0].lobby, "Start uses the host-authorized tone adapter");
    tests\support\checks::expect(rows[1].callback == scripts\apparition\menu\actions::cancel_tones && rows[1].lobby, "Cancel uses the host-authorized cancellation adapter");
    tests\support\checks::expect(!isDefined(rows[0].target) && !isDefined(rows[1].target), "Tone jobs affect the native quest instead of a selected player");
    tests\support\checks::expect(rows[2].label == "Tone Status: Idle" && !rows[2].enabled && !isDefined(rows[2].callback), "The status row is read-only and reflects the current job");
}

tone_controls_require_a_ready_host_and_one_background_job()
{
    view = basic_view();
    view.host = true;
    view.access = "Host";
    view.tones_ready = true;
    view.tones_running = false;
    view.tone_status = "Idle";
    rows = scripts\apparition\menu\model::build("UFO Tone Controls", view);
    tests\support\checks::expect(rows[0].enabled && !rows[1].enabled, "A ready idle job allows Start only");
    view.tones_running = true;
    view.tone_status = "Waiting for fresh round";
    rows = scripts\apparition\menu\model::build("UFO Tone Controls", view);
    tests\support\checks::expect(!rows[0].enabled && rows[1].enabled, "An active worker prevents a second job and allows Cancel");
    view.tone_status = "Cancelling";
    rows = scripts\apparition\menu\model::build("UFO Tone Controls", view);
    tests\support\checks::expect(!rows[0].enabled && !rows[1].enabled, "Pending cleanup prevents repeated commands");
    view.host = false;
    view.access = "VIP";
    view.tone_status = "Playing tones";
    rows = scripts\apparition\menu\model::build("UFO Tone Controls", view);
    tests\support\checks::expect(!rows[0].enabled && !rows[1].enabled, "A guest can inspect status but cannot control the quest job");
    view.host = true;
    view.access = "Host";
    view.tones_running = false;
    view.tones_ready = false;
    rows = scripts\apparition\menu\model::build("UFO Tone Controls", view);
    tests\support\checks::expect(!rows[0].enabled && !rows[1].enabled, "An unready native stage cannot start a new job");
}

an_empty_display_gets_an_inert_placeholder()
{
    rows = scripts\apparition\menu\model::for_display([]);
    tests\support\checks::expect(rows.size == 1, "An empty menu displays one placeholder row");
    tests\support\checks::expect(rows[0].label == "No Options Found", "The original placeholder text is retained");
    tests\support\checks::expect(!rows[0].enabled, "The placeholder is not an enabled action");
    tests\support\checks::expect(!isDefined(rows[0].callback), "The placeholder has no gameplay callback");
}

the_bomber_stage_opens_host_controls_without_marking_completion()
{
    view = basic_view();
    view.ufo = scripts\apparition\maps\spaceland\quest::progress(tests\fixtures\spaceland::quest(9));
    rows = scripts\apparition\menu\model::build("UFO Quest Steps", view);
    tests\support\checks::expect(rows[9].kind == "submenu" && rows[9].destination == "UFO Bomber Controls", "The active bomber stage opens its controls rather than directly damaging an actor");
    tests\support\checks::expect(!rows[9].checked && !rows[9].lobby, "Navigation alone does not claim native completion or host-only viewing");
}

bomber_controls_bind_native_progress_and_start_cancel_permissions()
{
    view = basic_view();
    view.host = true;
    view.access = "Host";
    view.bomber_ready = true;
    view.bomber_running = false;
    view.bomber_status = "Idle";
    view.bomber_hint = "";
    view.bombers = spawnstruct();
    view.bombers.kills = 12;
    view.bombers.goal = 50;
    rows = scripts\apparition\menu\model::build("UFO Bomber Controls", view);
    tests\support\checks::expect(rows.size == 4 && rows[0].callback == scripts\apparition\menu\actions::start_bombers && rows[0].enabled, "A ready host can start one bomber worker");
    tests\support\checks::expect(rows[1].callback == scripts\apparition\menu\actions::cancel_bombers && !rows[1].enabled, "An idle job has no enabled cancellation");
    tests\support\checks::expect(rows[0].lobby && rows[1].lobby && !isDefined(rows[0].target), "Start and Cancel bind fresh host-level authorization");
    tests\support\checks::expect(rows[2].label == "Bombers defeated: 12/50" && !isDefined(rows[2].callback), "The displayed progress is a read-only native count");
    view.bomber_running = true;
    view.bomber_status = "Active";
    rows = scripts\apparition\menu\model::build("UFO Bomber Controls", view);
    tests\support\checks::expect(!rows[0].enabled && rows[1].enabled, "A running job allows Cancel while rejecting another Start");
    view.bomber_status = "Cancelling";
    rows = scripts\apparition\menu\model::build("UFO Bomber Controls", view);
    tests\support\checks::expect(!rows[1].enabled, "An accepted cancellation cannot be queued twice");
    view.host = false;
    view.access = "VIP";
    view.bomber_status = "Active";
    rows = scripts\apparition\menu\model::build("UFO Bomber Controls", view);
    tests\support\checks::expect(!rows[0].enabled && !rows[1].enabled, "Guests can inspect progress without controlling the host job");
    tests\support\checks::expect(rows[0].description == "Only the current host can control the bomber worker" && rows[1].description == rows[0].description, "Both disabled guest controls explain host permission rather than host health");
    view.bombers.kills = -1;
    rows = scripts\apparition\menu\model::build("UFO Bomber Controls", view);
    tests\support\checks::expect(rows[2].label == "Bombers defeated: waiting for native counter", "An uninitialized native counter is not advertised as zero");
    view.host = true;
    view.access = "Host";
    view.bomber_ready = false;
    view.bomber_running = false;
    view.bomber_hint = "Wait for the native bomber counter to initialize";
    rows = scripts\apparition\menu\model::build("UFO Bomber Controls", view);
    tests\support\checks::expect(!rows[0].enabled && rows[0].description == view.bomber_hint, "An uninitialized host action preserves its specific native phase hint");
}

the_grey_stage_opens_fight_controls_without_claiming_completion()
{
    view = basic_view();
    view.ufo = scripts\apparition\maps\spaceland\quest::progress(tests\fixtures\spaceland::quest(10));
    rows = scripts\apparition\menu\model::build("UFO Quest Steps", view);
    tests\support\checks::expect(rows[10].kind == "submenu" && rows[10].destination == "Grey Fight Controls", "The current Grey stage opens fight controls without submitting damage");
    tests\support\checks::expect(!rows[10].checked && !rows[10].lobby, "Guest viewing and native completion remain separate from the host assist");
}

grey_fuse_controls_bind_host_actions_and_explain_the_remaining_fight()
{
    view = basic_view();
    view.host = true;
    view.access = "Host";
    view.grey_fuse_ready = true;
    view.grey_running = false;
    view.grey_status = "Idle";
    view.grey_fuse_hint = "";
    rows = scripts\apparition\menu\model::build("Grey Fuse Controls", view);
    tests\support\checks::expect(rows.size == 4 && rows[0].enabled && rows[0].callback == scripts\apparition\menu\actions::start_grey_fuses, "A ready host can start the exposed-fuse assist");
    tests\support\checks::expect(!rows[1].enabled && rows[1].callback == scripts\apparition\menu\actions::cancel_greys, "An idle assist cannot be canceled");
    tests\support\checks::expect(rows[0].lobby && rows[1].lobby && !isDefined(rows[0].target), "Both actions require fresh host-level permission");
    tests\support\checks::expect(rows[2].label == "Fuse Assist Status: Idle" && !isDefined(rows[2].callback), "The background job status is read-only");
    tests\support\checks::expect(rows[3].label == "Fuse-only mode" && !rows[3].enabled && !isDefined(rows[3].callback), "The UI explains that fuse assistance does not defeat the bosses");
    view.grey_running = true;
    view.grey_status = "Active";
    rows = scripts\apparition\menu\model::build("Grey Fuse Controls", view);
    tests\support\checks::expect(!rows[0].enabled && rows[1].enabled, "An active assist permits Cancel without another Start");
    view.grey_status = "Cancelling";
    rows = scripts\apparition\menu\model::build("Grey Fuse Controls", view);
    tests\support\checks::expect(!rows[1].enabled, "An accepted cancellation cannot be queued twice");
    view.host = false;
    view.access = "VIP";
    rows = scripts\apparition\menu\model::build("Grey Fuse Controls", view);
    tests\support\checks::expect(!rows[0].enabled && !rows[1].enabled, "Guests cannot control the host's fuse worker");
    tests\support\checks::expect(rows[0].description == "Only the current host can control the Grey assist" && rows[1].description == rows[0].description, "Guest controls explain their permission requirement");
    view.host = true;
    view.access = "Host";
    view.grey_running = false;
    view.grey_fuse_ready = false;
    view.grey_fuse_hint = "Wait for the first native Grey registration";
    rows = scripts\apparition\menu\model::build("Grey Fuse Controls", view);
    tests\support\checks::expect(!rows[0].enabled && rows[0].description == view.grey_fuse_hint, "A native initialization gate keeps its specific explanation");
}

the_final_stage_opens_controls_without_completing_the_ufo()
{
    view = basic_view();
    view.ufo = scripts\apparition\maps\spaceland\quest::progress(tests\fixtures\spaceland::quest(11));
    rows = scripts\apparition\menu\model::build("UFO Quest Steps", view);
    tests\support\checks::expect(rows[11].kind == "submenu" && rows[11].destination == "UFO Finale Controls", "The final stage opens native progress and collection controls");
    tests\support\checks::expect(!rows[11].checked && !rows[11].lobby, "Viewing the final controls cannot complete the UFO quest or require host permission");
}

finale_controls_bind_collection_to_current_host_and_native_fuse_progress()
{
    view = finale_view();
    rows = scripts\apparition\menu\model::build("UFO Finale Controls", view);
    tests\support\checks::expect(rows.size == 7 && rows[0].enabled && rows[0].callback == scripts\apparition\menu\actions::collect_fuses, "The ready host gets the single native pickup action");
    tests\support\checks::expect(rows[0].lobby && !isDefined(rows[0].target), "Collection always binds the current host rather than a selected remote actor");
    tests\support\checks::expect(rows[1].label == "Fuse Collection Status: Idle" && !isDefined(rows[1].callback), "Job status is read-only");
    tests\support\checks::expect(!rows[2].checked && !rows[3].checked && !isDefined(rows[2].callback) && rows[3].callback == scripts\apparition\menu\actions::insert_fuses, "Unknown native progress cannot advertise collected or inserted fuses");
    view.fuse_pickup_running = true;
    rows = scripts\apparition\menu\model::build("UFO Finale Controls", view);
    tests\support\checks::expect(!rows[0].enabled, "An active observer holds the menu's pickup reservation");
    view.fuse_pickup_running = false;
    view.fuse_pickup_ready = false;
    view.fuse_pickup_hint = "Collect the fuses after the Grey fight";
    rows = scripts\apparition\menu\model::build("UFO Finale Controls", view);
    tests\support\checks::expect(!rows[0].enabled && rows[0].description == view.fuse_pickup_hint, "A missing native pickup keeps its specific disabled explanation");
    view.host = false;
    view.access = "VIP";
    rows = scripts\apparition\menu\model::build("UFO Finale Controls", view);
    tests\support\checks::expect(!rows[0].enabled && rows[0].description == "Only the current host can collect quest fuses", "Guest controls explain host permission");
    view.fuses.held = 1;
    rows = scripts\apparition\menu\model::build("UFO Finale Controls", view);
    tests\support\checks::expect(rows[2].checked && !rows[3].checked, "The collected pair reads native possession rather than job status");
    view.fuses.held = 0;
    view.fuses.inserted = true;
    rows = scripts\apparition\menu\model::build("UFO Finale Controls", view);
    tests\support\checks::expect(rows[2].checked && rows[3].checked, "Insertion preserves completed collection after the native count is consumed");
    tests\support\checks::expect(rows[5].kind == "submenu" && rows[5].destination == "Final Power Nodes", "Node controls open separately without submitting a hit");
}

fuse_insertion_controls_require_a_ready_host_and_keep_native_progress()
{
    view = finale_view();
    view.fuses.held = 1;
    view.insert_fuse_ready = true;
    rows = scripts\apparition\menu\model::build("UFO Finale Controls", view);
    tests\support\checks::expect(rows[3].enabled && rows[3].lobby && rows[3].callback == scripts\apparition\menu\actions::insert_fuses, "A ready host can start the native fuse insertion transaction");
    tests\support\checks::expect(!rows[3].checked && rows[4].label == "Fuse Insertion Status: Idle", "Available insertion is not confused with native completion");
    view.insert_fuse_running = true;
    view.insert_fuse_status = "Inserting";
    rows = scripts\apparition\menu\model::build("UFO Finale Controls", view);
    tests\support\checks::expect(!rows[3].enabled && rows[4].label == "Fuse Insertion Status: Inserting", "A committed transaction cannot be started again or canceled halfway through cleanup");
    view.fuses.inserted = true;
    rows = scripts\apparition\menu\model::build("UFO Finale Controls", view);
    tests\support\checks::expect(rows[3].checked, "The native inserted flag is visible while the callback completes its cleanup");
    view.host = false;
    view.access = "VIP";
    rows = scripts\apparition\menu\model::build("UFO Finale Controls", view);
    tests\support\checks::expect(!rows[3].enabled && rows[3].description == "Only the current host can insert quest fuses", "Guest admission explains its host restriction");
}


final_node_controls_bind_host_actions_and_native_progress()
{
    view = basic_view();
    view.host = true;
    view.access = "Host";
    view.node_ready = true;
    view.node_running = false;
    view.node_status = "Idle";
    view.node_hint = "Submit one native hit per uncharged node";
    view.node_values = [false, true, false, false, false];
    view.ufo_destroyed = false;
    rows = scripts\apparition\menu\model::build("Final Power Nodes", view);
    tests\support\checks::expect(rows.size == 9 && rows[0].enabled && rows[0].lobby && rows[0].callback == scripts\apparition\menu\actions::start_nodes, "A ready host can start the final-node worker");
    tests\support\checks::expect(!rows[1].enabled && rows[1].callback == scripts\apparition\menu\actions::cancel_nodes, "An idle final-node worker cannot be canceled");
    tests\support\checks::expect(!rows[3].checked && rows[4].checked && !rows[3].enabled && !isDefined(rows[3].callback), "Node checkboxes read native activation without offering direct flag writes");
    tests\support\checks::expect(!rows[8].checked && !rows[8].enabled, "Submitted inputs cannot advertise UFO destruction");
    view.node_running = true;
    view.node_status = "Active";
    rows = scripts\apparition\menu\model::build("Final Power Nodes", view);
    tests\support\checks::expect(!rows[0].enabled && rows[1].enabled, "One active worker holds the start reservation and allows cancel");
    view.node_status = "Cancelling";
    rows = scripts\apparition\menu\model::build("Final Power Nodes", view);
    tests\support\checks::expect(!rows[1].enabled, "A queued cancellation cannot be repeated");
    view.ufo_destroyed = true;
    rows = scripts\apparition\menu\model::build("Final Power Nodes", view);
    tests\support\checks::expect(rows[8].checked, "UFO destruction follows the native destruction flag");
    view.host = false;
    view.access = "VIP";
    rows = scripts\apparition\menu\model::build("Final Power Nodes", view);
    tests\support\checks::expect(!rows[0].enabled && !rows[1].enabled && rows[0].description == "Only the current host can control final-node inputs", "Guests receive an accurate host-only explanation");
}


completed_final_stage_keeps_reward_controls_reachable()
{
    view = basic_view();
    native = tests\fixtures\spaceland::quest(11);
    native.flag["ufo_quest_finished"] = 1;
    view.ufo = scripts\apparition\maps\spaceland\quest::progress(native);
    rows = scripts\apparition\menu\model::build("UFO Quest Steps", view);
    tests\support\checks::expect(rows[11].checked && rows[11].enabled && rows[11].kind == "toggle" && rows[11].destination == "UFO Finale Controls", "A completed final stage still opens native reward controls");
    tests\support\checks::expect(!rows[11].lobby && rows[11].callback == scripts\apparition\menu\actions::open_page, "Inspecting the completed stage remains navigation rather than a reward mutation");
    rows = scripts\apparition\menu\model::build("UFO Finale Controls", finale_view());
    tests\support\checks::expect(rows[6].destination == "Soul Key Controls" && rows[6].kind == "submenu", "Finale navigation reaches the separate reward action and receipt display");
}

soul_key_controls_bind_native_pickup_and_explain_lobby_effects()
{
    view = basic_view();
    view.host = true;
    view.access = "Host";
    view.soul_key_ready = true;
    view.soul_key_running = false;
    view.soul_key_status = "Idle";
    view.soul_key_hint = "Native pickup grants Soul Key ownership and achievement progress to the lobby";
    view.soul_key_receipt = spawnstruct();
    view.soul_key_receipt.total = 2;
    view.soul_key_receipt.known = 2;
    view.soul_key_receipt.owners = 1;
    rows = scripts\apparition\menu\model::build("Soul Key Controls", view);
    tests\support\checks::expect(rows.size == 4 && rows[0].enabled && rows[0].lobby && rows[0].callback == scripts\apparition\menu\actions::collect_soul_key, "A ready host gets the native shared reward pickup action");
    tests\support\checks::expect(rows[0].description == view.soul_key_hint, "The action describes native lobby ownership and achievement effects");
    tests\support\checks::expect(!rows[2].checked && !rows[2].enabled && !isDefined(rows[2].callback), "Partial current-roster ownership is read-only and unchecked");
    view.soul_key_receipt.owners = 2;
    view.soul_key_running = true;
    view.soul_key_status = "Collecting";
    rows = scripts\apparition\menu\model::build("Soul Key Controls", view);
    tests\support\checks::expect(!rows[0].enabled && rows[2].checked, "Native ownership and the running reservation remain independent");
    tests\support\checks::expect(rows[1].label == "Soul Key Status: Collecting", "The active observer has a separate visible status");
    view.host = false;
    view.access = "VIP";
    rows = scripts\apparition\menu\model::build("Soul Key Controls", view);
    tests\support\checks::expect(!rows[0].enabled && rows[0].description == "Only the current host can collect the shared Soul Key", "Guests receive the host-only reward explanation");
}

finale_view()
{
    view = basic_view();
    view.host = true;
    view.access = "Host";
    view.fuses = scripts\apparition\maps\spaceland\fuses::progress(tests\fixtures\spaceland::quest(11));
    view.fuse_pickup_ready = true;
    view.fuse_pickup_running = false;
    view.fuse_pickup_status = "Idle";
    view.fuse_pickup_hint = "Collect the dropped pair through its native pickup listener";
    view.insert_fuse_ready = false;
    view.insert_fuse_running = false;
    view.insert_fuse_status = "Idle";
    view.insert_fuse_hint = "Collect the dropped alien fuses first";
    return view;
}

basic_view()
{
    view = spawnstruct();
    view.access = "Verified";
    view.owner_alive = true;
    view.target = spawnstruct();
    view.target.apparition_jump_input = spawnstruct();
    view.target.apparition_jump_input.held = false;
    view.target.apparition_jump_input.bound = true;
    view.god_ready = true;
    view.demi_feedback_reason = "";
    view.target_actor_reason = "";
    // A ready score view contains only a captured native read
    view.score = spawnstruct();
    view.score.reason = "";
    view.score.balance = 500;
    view.score.cap = 999999;
    return view;
}

perk_view()
{
    view = basic_view();
    ids = scripts\apparition\maps\spaceland\perks::ids();
    view.target = tests\fixtures\perks::owned_player(ids);
    view.players = [view.target];
    view.host = true;
    view.access = "Host";
    view.perk_callbacks = tests\fixtures\perks::callbacks(ids);
    view.perk_roster_reason = "";
    view.actor_reason = "";
    view.target_actor_reason = "";
    view.perk_target_reason = "";
    view.retention_ready = true;
    return view;
}

open_controls_routes_to_the_binding_editor()
{
    view = basic_view();
    view.owner = spawnstruct();
    view.layout = scripts\apparition\menu\layout::defaults();
    view.owner.apparition_layout = view.layout;
    rows = scripts\apparition\menu\model::build("Open Controls", view);
    tests\support\checks::expect(rows.size >= 16 && rows[0].label == "Menu" && rows[0].setting == "binding_menu", "Open Controls builds the owner binding editor");
    tests\support\checks::expect(rows[0].target == view.owner && !rows[0].lobby && rows[0].callback == scripts\apparition\menu\actions::set_binding_selection, "Binding selection stays on the menu owner");
}

menu_instructions_build_the_source_customization_page()
{
    view = basic_view();
    view.owner = spawnstruct();
    view.owner.apparition_state = scripts\apparition\menu\state::create(view.owner);
    view.owner.apparition_hud = spawnstruct();
    view.layout = scripts\apparition\menu\layout::defaults();
    rows = scripts\apparition\menu\model::build("Menu Instructions", view);
    tests\support\checks::expect(rows.size == 6 && rows[0].label == "Disable" && rows[5].label == "Reset Position",
        "Menu Instructions routes to the source customization controls");
}

full_grey_controls_share_one_job_and_show_spawn_readiness()
{
    view = basic_view();
    view.host = true;
    view.access = "Host";
    view.grey_ready = true;
    view.grey_hint = "";
    view.grey_running = false;
    view.grey_status = "Idle";
    view.grey_sequence_status = "Ready";
    view.grey_count = 2;
    rows = scripts\apparition\menu\model::build("Grey Fight Controls", view);
    tests\support\checks::expect(rows.size == 6 && rows[0].enabled && rows[0].callback == scripts\apparition\menu\actions::start_greys, "A ready host can start the full native fight assist");
    tests\support\checks::expect(rows[0].lobby && !isDefined(rows[0].target) && rows[1].callback == scripts\apparition\menu\actions::cancel_greys && !rows[1].enabled, "Both modes bind the same fresh host-level cancellation");
    tests\support\checks::expect(rows[3].label == "Spawn Watch: Ready" && rows[4].label == "Native Greys: 2" && !isDefined(rows[4].callback), "Readiness and roster size are read-only observations");
    tests\support\checks::expect(rows[5].destination == "Grey Fuse Controls" && rows[5].kind == "submenu", "Fuse-only mode remains separately reachable");
    view.grey_count = -1;
    rows = scripts\apparition\menu\model::build("Grey Fight Controls", view);
    tests\support\checks::expect(rows[4].label == "Native Greys: waiting for registration", "An unknown native roster never advertises an observed zero count");
    view.grey_running = true;
    view.grey_status = "Active: full fight";
    rows = scripts\apparition\menu\model::build("Grey Fight Controls", view);
    tests\support\checks::expect(!rows[0].enabled && rows[1].enabled, "Any running mode prevents a competing start and admits cancellation");
    view.grey_status = "Cancelling";
    rows = scripts\apparition\menu\model::build("Grey Fight Controls", view);
    tests\support\checks::expect(!rows[1].enabled, "Accepted cancellation cannot be queued twice");
    view.grey_running = false;
    view.grey_ready = false;
    view.grey_hint = "Wait for the entire native initial Grey spawn sequence to return";
    rows = scripts\apparition\menu\model::build("Grey Fight Controls", view);
    tests\support\checks::expect(!rows[0].enabled && rows[0].description == view.grey_hint, "The native readiness gate keeps its specific explanation");
    view.host = false;
    view.access = "VIP";
    rows = scripts\apparition\menu\model::build("Grey Fight Controls", view);
    tests\support\checks::expect(!rows[0].enabled && !rows[1].enabled && rows[0].description == "Only the current host can control the Grey assist", "Guests see the actual host permission requirement");
}

movement_slider_keeps_source_position_range_and_default()
{
    view = basic_view();
    rows = scripts\apparition\menu\model::build("Basic Scripts", view);
    row = rows[11];
    tests\support\checks::expect(rows.size == 31 && rows[10].label == "Gobblegum Menu" && row.label == "Movement Speed" && rows[12].label == "Third Person", "Movement Speed keeps original Basic Scripts position 11");
    tests\support\checks::expect(row.kind == "slider" && row.enabled && row.callback == scripts\apparition\menu\actions::set_movement, "Movement Speed binds the supported slider callback");
    tests\support\checks::expect(row.target == view.target && !row.lobby, "Movement Speed changes only the selected player");
    tests\support\checks::expect(row.values.size == 7 && row.initial_index == 2
        && row.values[row.initial_index] == 1, "The seven-value source range starts its preview at literal scale one");
    tests\support\checks::expect(row.values[0] == 0 && row.values[6] == 3, "The movement slider exposes both source bounds");
    tests\support\checks::expect(row.active_value == 1, "An unset MovementSpeed field displays neutral configuration");
}

movement_slider_separates_preview_from_configured_absolute_scale()
{
    view = basic_view();
    view.target.MovementSpeed = 2.5;
    view.target.movespeedscaler = 0.9;
    view.god_ready = false;
    rows = scripts\apparition\menu\model::build("Basic Scripts", view);
    row = rows[11];
    state = scripts\apparition\menu\state::create(view.target);
    state.page = "Basic Scripts";
    scripts\apparition\menu\state::adjust_slider(state, row, 1);
    tests\support\checks::expect(scripts\apparition\menu\state::slider_value(state, row) == 1.5 && row.active_value == 2.5, "Slider preview does not replace the configured scale");
    tests\support\checks::expect(row.enabled && isSubStr(row.description, "absolute"), "Movement Speed explains the absolute override without requiring the damage hook");
    tests\support\checks::expect(view.target.MovementSpeed == 2.5 && view.target.movespeedscaler == 0.9, "Rendering and preview leave custom and native speed fields unchanged");
    // Invalid saved data is visible without blocking a valid replacement
    view.target.MovementSpeed = "invalid";
    rows = scripts\apparition\menu\model::build("Basic Scripts", view);
    tests\support\checks::expect(rows[11].enabled && rows[11].active_value == "Unknown", "An invalid saved scale is unknown and can be replaced");
}


basic_target_controls_keep_their_source_page_scope()
{
    view = basic_view();
    view.players = [view.target];
    view.actor_reason = "";
    view.host = true;
    view.access = "Host";
    foreach (page in ["Quick Menu", "All Players"])
    {
        rows = scripts\apparition\menu\model::build(page, view);
        foreach (row in rows)
            tests\support\checks::expect(row.label != "Movement Speed" && row.label != "Invisibility"
                && row.label != "Disable HUD" && row.label != "Multi-Jump"
                && row.label != "Custom Crosshairs" && row.label != "Shoot While Sprinting", "Basic target controls keep their original page scope");
    }
}


invisibility_row_keeps_source_position_and_personal_toggle()
{
    view = basic_view();
    view.god_ready = false;
    rows = scripts\apparition\menu\model::build("Basic Scripts", view);
    row = rows[13];
    tests\support\checks::expect(rows.size == 31 && rows[12].label == "Third Person" && row.label == "Invisibility" && rows[14].label == "Clone", "Invisibility keeps source Basic Scripts position 13");
    tests\support\checks::expect(row.kind == "toggle" && row.callback == scripts\apparition\menu\actions::toggle_invisibility, "Invisibility binds the supported toggle callback");
    tests\support\checks::expect(row.enabled && !row.checked && row.target == view.target && !row.lobby, "The personal invisibility setting does not depend on the damage hook");
    tests\support\checks::expect(row.description == "Saved off; Use hides once; native game code can override", "The unchecked row explains its next native command");
}

invisibility_checkbox_reports_configuration_without_changing_flags()
{
    view = basic_view();
    view.target.Invisibility = true;
    view.target.playerGodmode = true;
    rows = scripts\apparition\menu\model::build("Basic Scripts", view);
    tests\support\checks::expect(rows[13].checked && rows[13].enabled, "The invisibility checkbox reads the saved setting");
    tests\support\checks::expect(rows[13].description == "Saved on; Use shows once; native game code can override", "The checked row does not claim an observed engine visibility state");
    tests\support\checks::expect(view.target.Invisibility && view.target.playerGodmode, "Rendering leaves invisibility and damage protection unchanged");
    view.target.Invisibility = false;
    rows = scripts\apparition\menu\model::build("Basic Scripts", view);
    tests\support\checks::expect(!rows[13].checked && view.target.playerGodmode, "A false invisibility setting stays independent of God Mode");
}

hud_visibility_row_keeps_source_position_and_saved_intent()
{
    view = basic_view();
    view.god_ready = false;
    rows = scripts\apparition\menu\model::build("Basic Scripts", view);
    row = rows[18];
    tests\support\checks::expect(rows.size == 31 && rows[17].label == "Multi-Jump"
        && row.label == "Disable HUD" && rows[19].label == "Visual Effects", "Disable HUD keeps original Basic Scripts position 18");
    tests\support\checks::expect(row.kind == "toggle" && row.enabled && !row.checked
        && row.callback == scripts\apparition\menu\actions::toggle_hud_visibility
        && row.target == view.target && !row.lobby, "Disable HUD binds the selected player independently of the damage hook");
    tests\support\checks::expect(row.description == "Saved off; Use hides native HUD once; game code can override", "The unchecked HUD row explains the next command without claiming observed visibility");

    // Saved state describes the request and rendering leaves it unchanged
    view.target.DisablePlayerHUD = true;
    view.target.Invisibility = true;
    rows = scripts\apparition\menu\model::build("Basic Scripts", view);
    tests\support\checks::expect(rows[18].checked && rows[18].description == "Saved on; Use shows native HUD once; game code can override", "The checked HUD row explains its next native command");
    tests\support\checks::expect(view.target.DisablePlayerHUD && view.target.Invisibility, "HUD rendering leaves both visibility flags unchanged");
    view.target.DisablePlayerHUD = false;
    rows = scripts\apparition\menu\model::build("Basic Scripts", view);
    tests\support\checks::expect(!rows[18].checked && view.target.Invisibility, "A false HUD flag stays independent of player visibility");
}

sprint_fire_keeps_source_position_and_reports_tracked_perk()
{
    view = basic_view();
    view.god_ready = false;
    rows = scripts\apparition\menu\model::build("Basic Scripts", view);
    row = rows[26];
    tests\support\checks::expect(rows.size == 31 && rows[25].label == "Random Character Model Index"
        && row.label == "Shoot While Sprinting" && rows[27].label == "Unlimited Sprint", "Sprint fire keeps source Basic Scripts position 26");
    tests\support\checks::expect(row.kind == "toggle" && row.enabled && !row.checked
        && row.callback == scripts\apparition\menu\actions::toggle_sprint_fire
        && row.target == view.target && !row.lobby, "Sprint fire binds the selected player without damage-hook admission");
    tests\support\checks::expect(row.description == "Configured off; Use grants sprint fire; Racin' Stripes shares this effect", "Sprint fire describes the next command and shared machine effect");
    // Tracked perk presence is distinct from machine ownership and engine state
    view.target.perks = [];
    view.target.perks["specialty_sprintfire"] = 1;
    view.target.zombies_perks = [];
    view.target.zombies_perks["perk_machine_run"] = true;
    rows = scripts\apparition\menu\model::build("Basic Scripts", view);
    tests\support\checks::expect(rows[26].checked && rows[26].description == "Configured on; Use removes sprint fire; Racin' Stripes shares this effect", "The checked row reports CP-tracked configuration without a native getter claim");
    tests\support\checks::expect(view.target.perks["specialty_sprintfire"] == 1
        && view.target.zombies_perks["perk_machine_run"], "Rendering changes neither the tracked perk nor machine inventory");
}

multi_jump_keeps_source_position_and_input_setup_admission()
{
    view = basic_view();
    rows = scripts\apparition\menu\model::build("Basic Scripts", view);
    row = rows[17];
    tests\support\checks::expect(rows.size == 31 && rows[16].label == "Reduced Spread"
        && row.label == "Multi-Jump" && rows[18].label == "Disable HUD", "Multi-Jump keeps source Basic Scripts position 17");
    tests\support\checks::expect(row.kind == "toggle" && row.enabled && !row.checked
        && row.callback == scripts\apparition\menu\actions::toggle_multi_jump
        && row.target == view.target && !row.lobby, "Multi-Jump binds one selected player with input setup available");
    tests\support\checks::expect(row.description == "Saved off; Use enables; first airborne release arms, later releases boost +250 Z", "Multi-Jump explains the source arming and release behavior");
    view.target.apparition_jump_input = undefined;
    rows = scripts\apparition\menu\model::build("Basic Scripts", view);
    tests\support\checks::expect(!rows[17].enabled && rows[17].description == "Wait for jump input setup", "An unconfigured target cannot enable without its own command setup");
    view.target.MultiJump = true;
    rows = scripts\apparition\menu\model::build("Basic Scripts", view);
    tests\support\checks::expect(rows[17].enabled && rows[17].checked
        && rows[17].description == "Saved on; Use disables; jump input setup is unavailable", "A saved Multi-Jump flag stays clearable when input setup is lost");
    tests\support\checks::expect(view.target.MultiJump && !isDefined(view.target.apparition_jump_input), "Rendering does not repair the saved setting or invent an input receipt");
}

score_slider_keeps_source_scope_and_literal_preview()
{
    view = basic_view();
    rows = scripts\apparition\menu\model::build("Basic Scripts", view);
    row = rows[8];
    tests\support\checks::expect(rows.size == 31 && rows[7].label == "Unlimited Special Weapon"
        && row.label == "Modify Score" && rows[9].label == "Perk Menu", "Modify Score keeps original Basic Scripts position 8");
    tests\support\checks::expect(row.enabled && row.kind == "slider"
        && row.callback == scripts\apparition\menu\actions::modify_score
        && row.target == view.target && !row.lobby, "Modify Score binds one selected player to the score command");
    tests\support\checks::expect(row.values.size == 13 && row.values[0] == "1000000"
        && row.values[6] == "0" && row.values[12] == "-1000000", "The score slider retains its source choices and clear option");
    tests\support\checks::expect(row.description == "Live balance: 500/999999; Use applies the preview delta; 0 clears", "The footer separates the live balance from the preview delta");
    state = scripts\apparition\menu\state::create(view.target);
    state.page = "Basic Scripts";
    tests\support\checks::expect(scripts\apparition\menu\state::slider_value(state, row) == "1000000", "Score preview starts at the original first choice");
    scripts\apparition\menu\state::adjust_slider(state, row, 1);
    tests\support\checks::expect(scripts\apparition\menu\state::slider_value(state, row) == "100000"
        && view.score.balance == 500 && view.score.cap == 999999, "Changing the score preview leaves the captured balance unchanged");

    // Quick Menu keeps its source position and follows the owner's life state
    rows = scripts\apparition\menu\model::build("Quick Menu", view);
    tests\support\checks::expect(rows.size == 12 && rows[5].label == "Modify Score"
        && rows[5].callback == scripts\apparition\menu\actions::modify_score
        && rows[5].target == view.target && !rows[5].lobby, "Living Quick Menu binds the personal score command at position 5");
    view.owner_alive = false;
    rows = scripts\apparition\menu\model::build("Quick Menu", view);
    tests\support\checks::expect(rows.size == 1 && rows[0].label == "Respawn", "Dead Quick Menu retains its source filter without a score command");
    view.players = [view.target];
    view.actor_reason = "";
    view.host = true;
    view.access = "Host";
    rows = scripts\apparition\menu\model::build("All Players", view);
    foreach (lobby_row in rows)
        tests\support\checks::expect(lobby_row.label != "Modify Score", "Modify Score does not add an unsupported lobby row");
}

custom_crosshairs_keep_source_position_and_personal_scope()
{
    view = basic_view();
    view.target.name = "Test Player";
    rows = scripts\apparition\menu\model::build("Basic Scripts", view);
    row = rows[22];
    tests\support\checks::expect(rows.size == 31 && rows[21].label == "Zombie Charms"
        && row.label == "Custom Crosshairs" && rows[23].label == "No Explosive Damage",
        "Custom Crosshairs keeps source Basic Scripts position 22");
    tests\support\checks::expect(row.kind == "slider" && row.enabled && !row.lobby
        && row.target == view.target && row.callback == scripts\apparition\menu\actions::set_crosshair,
        "The original personal row delegates to the target's crosshair action");
    tests\support\checks::expect(row.values[0] == "Disable" && row.values[13] == "Test Player",
        "The integrated row uses the current selected player's cleaned name");
}

score_rows_reject_missing_and_invalid_native_snapshots()
{
    view = basic_view();
    view.score = undefined;
    foreach (page in ["Basic Scripts", "Quick Menu"])
    {
        rows = scripts\apparition\menu\model::build(page, view);
        index = page == "Basic Scripts" ? 8 : 5;
        tests\support\checks::expect(!rows[index].enabled && rows[index].description == "Wait for native currency data", "Missing native currency data disables either score row");
    }
    foreach (invalid in [7, "ready", [], spawnstruct()])
    {
        view.score = invalid;
        rows = scripts\apparition\menu\model::build("Basic Scripts", view);
        tests\support\checks::expect(!rows[8].enabled && rows[8].description == "Wait for native currency data", "Malformed score snapshots cannot enable the command");
    }
    view = basic_view();
    view.score.reason = 0;
    rows = scripts\apparition\menu\model::build("Basic Scripts", view);
    tests\support\checks::expect(!rows[8].enabled, "A nonstring score reason cannot claim readiness");
    view.score.reason = "The selected player is unavailable";
    rows = scripts\apparition\menu\model::build("Basic Scripts", view);
    tests\support\checks::expect(!rows[8].enabled && rows[8].description == view.score.reason, "Native probe admission failures keep their specific reason");
    view.score.reason = "";
    foreach (invalid_balance in ["500", -1, 0.5, 1000000])
    {
        view.score.balance = invalid_balance;
        rows = scripts\apparition\menu\model::build("Basic Scripts", view);
        tests\support\checks::expect(!rows[8].enabled && rows[8].description == "Wait for native currency data", "A ready reason cannot bypass validation of the captured balance");
    }
    view.score.balance = 500;
    view.score.cap = undefined;
    rows = scripts\apparition\menu\model::build("Basic Scripts", view);
    tests\support\checks::expect(!rows[8].enabled && !isDefined(view.score.cap), "A missing cap stays unavailable and is not replaced by a guessed value");
}

personal_rows_reject_actor_snapshots_before_reading_target_fields()
{
    view = basic_view();
    // A scalar cannot safely receive any saved-setting field or native helper read
    view.target = 17;
    foreach (reason in ["The player is no longer in the current roster", "Only the current host can change another player"])
    {
        view.target_actor_reason = reason;
        rows = scripts\apparition\menu\model::build("Basic Scripts", view);
        foreach (index in [0, 1, 6, 13, 17, 18, 22, 23, 26])
            tests\support\checks::expect(!rows[index].enabled && !rows[index].checked && rows[index].description == reason,
                "A rejected personal toggle is disabled and unchecked before target fields are read");
        tests\support\checks::expect(!rows[5].enabled && rows[5].active_value == "Unavailable" && rows[5].description == reason,
            "A rejected ammo target cannot advertise a configured mode or accept Use");
        tests\support\checks::expect(!rows[11].enabled && rows[11].active_value == "Unknown" && rows[11].description == reason,
            "A rejected movement target cannot expose a saved scale or enter its native helper");
    }
}

stale_target_rows_leave_saved_settings_unchanged()
{
    view = basic_view();
    view.target.playerGodmode = true;
    view.target.apparition_ammo_mode = "Continuous";
    view.target.apparition_equipment = true;
    view.target.MovementSpeed = 2.5;
    view.target.Invisibility = true;
    view.target.DisablePlayerHUD = true;
    view.target.MultiJump = true;
    view.target.NoExplosiveDamage = true;
    view.target.perks = [];
    view.target.perks["specialty_sprintfire"] = 1;
    view.target_actor_reason = "The player is no longer in the current roster";
    rows = scripts\apparition\menu\model::build("Basic Scripts", view);
    tests\support\checks::expect(!rows[0].enabled && !rows[0].checked
        && !rows[5].enabled && rows[5].active_value == "Unavailable"
        && !rows[6].enabled && !rows[6].checked,
        "A stale player's priority controls stop advertising readable active settings");
    tests\support\checks::expect(view.target.playerGodmode && view.target.apparition_ammo_mode == "Continuous"
        && view.target.apparition_equipment,
        "Rendering a rejected target does not disable its saved gameplay settings");
    foreach (index in [13, 17, 18, 23, 26])
        tests\support\checks::expect(!rows[index].enabled && !rows[index].checked,
            "A rejected target does not advertise any other saved personal toggle");
    tests\support\checks::expect(rows[11].active_value == "Unknown"
        && view.target.MovementSpeed == 2.5 && view.target.Invisibility
        && view.target.DisablePlayerHUD && view.target.MultiJump
        && view.target.NoExplosiveDamage && view.target.perks["specialty_sprintfire"] == 1,
        "Rejected rendering leaves movement, visibility, HUD, jump, protection and perk state unchanged");
}

personal_rows_reject_missing_and_malformed_actor_reasons()
{
    view = basic_view();
    view.target = 17;
    view.target_actor_reason = undefined;
    rows = scripts\apparition\menu\model::build("Basic Scripts", view);
    foreach (index in [0, 1, 5, 6, 11, 13, 17, 18, 22, 23, 26])
        tests\support\checks::expect(!rows[index].enabled && rows[index].description == "Wait for a valid player roster",
            "A missing personal actor snapshot rejects the complete Basic Scripts build");
    view.target_actor_reason = 17;
    rows = scripts\apparition\menu\model::build("Basic Scripts", view);
    foreach (index in [0, 1, 5, 6, 11, 13, 17, 18, 22, 23, 26])
        tests\support\checks::expect(!rows[index].enabled && rows[index].description == "Wait for a valid player roster",
            "A nonstring actor reason cannot reach a personal setting or CP helper");
}

perk_controls_gate_inventory_reads_and_actions_on_actor_snapshots()
{
    view = perk_view();
    view.target = 17;
    view.target_actor_reason = "The player is no longer in the current roster";
    rows = scripts\apparition\menu\model::build("Perk Menu", view);
    foreach (row in rows)
        tests\support\checks::expect(!row.enabled && !row.checked && row.description == view.target_actor_reason,
            "Every personal perk and retention control rejects a stale actor before reading its state");
    view.target_actor_reason = undefined;
    rows = scripts\apparition\menu\model::build("Perk Menu", view);
    foreach (row in rows)
        tests\support\checks::expect(!row.enabled && !row.checked && row.description == "Wait for a valid player roster",
            "Missing personal perk snapshots remain unavailable rather than guessing ownership");
}

lobby_perk_controls_reject_invalid_actor_snapshots_before_inventory_reads()
{
    view = perk_view();
    view.actor_reason = "Wait for a valid player roster";
    foreach (players in ["invalid", [17], []])
    {
        view.players = players;
        reason = scripts\apparition\menu\model::actor_snapshot_reason(view);
        rows = scripts\apparition\menu\model::build("All Players Perks", view);
        foreach (row in rows)
            tests\support\checks::expect(!row.enabled && !row.checked && row.description == reason,
                "An invalid lobby actor snapshot is rejected before perk or retention fields are read");
        view.host = false;
        view.access = "VIP";
        rows = scripts\apparition\menu\model::build("All Players Perks", view);
        foreach (row in rows)
            tests\support\checks::expect(!row.enabled && !row.checked
                && row.description == "Only the current host can change lobby perks",
                "Guest permission remains the visible reason ahead of an invalid lobby roster");
        view.host = true;
        view.access = "Host";
    }
}

fun_frog_jump_routes_configured_intent_to_the_selected_player()
{
    view = basic_view();
    view.frog_jump = spawnstruct();
    view.frog_jump.reason = "";
    view.frog_jump.configured = true;
    rows = scripts\apparition\menu\model::build("Fun Scripts", view);
    row = rows[21];
    tests\support\checks::expect(rows.size == 37 && row.label == "Frog Jump"
        && row.kind == "toggle" && row.enabled && row.checked
        && row.target == view.target && !row.lobby
        && row.callback == scripts\apparition\menu\actions::toggle_frog_jump,
        "The source Frog Jump position binds the current selected-player configuration");
    tests\support\checks::expect(!isDefined(row.angles) && !isDefined(row.velocity)
        && !isDefined(row.waiting_landing) && !isDefined(row.menu_grant),
        "The row captures neither motion commands nor worker phase or authority grants");
}

fun_health_bar_routes_a_configured_toggle_without_caching_native_state()
{
    view = basic_view();
    view.health_bar = spawnstruct();
    view.health_bar.reason = "";
    view.health_bar.configured = true;
    rows = scripts\apparition\menu\model::build("Fun Scripts", view);
    row = rows[23];
    tests\support\checks::expect(rows.size == 37 && row.label == "Health Bar"
        && row.kind == "toggle" && row.checked && row.enabled
        && row.target == view.target && !row.lobby
        && row.callback == scripts\apparition\menu\actions::toggle_health_bar,
        "The source Health Bar position maps to the selected player's configured toggle");
    tests\support\checks::expect(!isDefined(row.health) && !isDefined(row.maxhealth)
        && !isDefined(row.shape) && !isDefined(row.background) && !isDefined(row.fill),
        "Model rows retain neither raw health nor native handles or measured geometry");
    view.health_bar.reason = "VIP access is required for Fun Scripts";
    rows = scripts\apparition\menu\model::build("Fun Scripts", view);
    tests\support\checks::expect(!rows[23].enabled && rows[23].checked
        && rows[23].description == view.health_bar.reason,
        "A blocked snapshot preserves configured state while disabling the toggle");
}

fun_scripts_routes_the_source_action_to_the_selected_actor()
{
    view = basic_view();
    view.earthquake = spawnstruct();
    view.earthquake.reason = "";
    rows = scripts\apparition\menu\model::build("Fun Scripts", view);
    tests\support\checks::expect(rows.size == 37 && rows[0].label == "Earthquake"
        && rows[0].enabled && rows[0].target == view.target && !rows[0].lobby
        && rows[0].callback == scripts\apparition\menu\actions::send_earthquake,
        "The model routes Fun Scripts to the complete source list and selected-player quake callback");
    view.earthquake.reason = "VIP access is required for Fun Scripts";
    rows = scripts\apparition\menu\model::build("Fun Scripts", view);
    tests\support\checks::expect(!rows[0].enabled && rows[0].description == view.earthquake.reason,
        "Fresh feature admission controls both callback availability and the displayed reason");
}

lobby_teleport_keeps_source_slider_position_and_lobby_scope()
{
    view = basic_view();
    view.host = true;
    view.access = "Host";
    view.players = [view.target];
    view.actor_reason = "";
    view.lobby_teleport = spawnstruct();
    view.lobby_teleport.reason = "";
    view.lobby_teleport.owner_reason = "";
    view.lobby_teleport.targets = [view.target];
    rows = scripts\apparition\menu\model::build("All Players", view);
    tests\support\checks::expect(rows[1].label == "Teleport" && rows[1].kind == "slider"
        && rows[1].lobby && !isDefined(rows[1].target) && rows[1].enabled
        && rows[1].callback == scripts\apparition\menu\actions::teleport_lobby,
        "Lobby Teleport keeps the source second row with native-host authorization");
    tests\support\checks::expect(rows[1].values.size == 3 && rows[1].values[0] == "Self"
        && rows[1].values[1] == "Crosshairs" && rows[1].values[2] == "Sky"
        && rows[1].initial_index == 0 && !isDefined(rows[1].active_value),
        "Self is the uncommitted default followed by Crosshairs and Sky in source order");
}

cohost_lobby_rows_follow_source_permissions_without_expanding_iw_extensions()
{
    view = perk_view();
    view.host = false;
    view.access = "Co-Host";
    view.owner = view.target;
    view.down = spawnstruct();
    view.down.reason = "";
    view.down.hint = "Request native Down; native protection may block damage";
    view.down.targets = [view.target];
    view.revive = spawnstruct();
    view.revive.reason = "";
    view.revive.hint = "Request native revive for current players";
    view.revive.targets = [view.target];
    view.lobby_teleport = spawnstruct();
    view.lobby_teleport.reason = "";
    view.lobby_teleport.owner_reason = "";
    view.lobby_teleport.targets = [spawnstruct()];
    rows = scripts\apparition\menu\model::build("All Players", view);
    tests\support\checks::expect(rows.size == 14 && rows[1].label == "Teleport" && rows[1].enabled
        && rows[5].label == "God Mode" && rows[5].enabled
        && rows[8].label == "Down" && rows[8].enabled
        && rows[9].label == "Revive" && rows[9].enabled,
        "Co-Host can use source-backed lobby Teleport, God, Down and Revive controls");
    tests\support\checks::expect(!view.host && !rows[0].enabled && !rows[11].enabled
        && !rows[12].enabled && !rows[13].enabled,
        "Co-Host lobby parity leaves Verification, appended IW Ammo, Equipment and Perks native-Host-only");

    rows = scripts\apparition\menu\model::build("All Players Perks", view);
    tests\support\checks::expect(rows.size == 12 && !rows[0].enabled && !rows[1].enabled,
        "The appended lobby Perks and Retain Perks controls remain native-Host-only");

    rows = scripts\apparition\menu\model::build("Spaceland Scripts", view);
    tests\support\checks::expect(!rows[0].enabled && !rows[1].enabled,
        "Co-Host gameplay access does not enable an unrelated host-only world objective action");
}

server_modifications_route_owner_scoped_global_rows()
{
    view = spawnstruct();
    view.owner = spawnstruct();
    view.target = spawnstruct();
    view.access = "Host";
    view.host = true;
    view.server_timescale = spawnstruct();
    view.server_timescale.reason = "";
    view.server_timescale.current = 1;
    view.auto_revive = spawnstruct();
    view.auto_revive.reason = "";
    view.auto_revive.enabled = 0;
    view.auto_revive.native_reason = "";
    view.server_end_reason = "";

    rows = scripts\apparition\menu\model::build("Server Modifications", view);
    tests\support\checks::expect(rows.size == 22 && rows[3].label == "Timescale"
        && rows[3].enabled && rows[7].label == "Auto-Revive" && rows[7].enabled,
        "The model exposes Timescale and Auto-Revive in their source positions");
    tests\support\checks::expect(rows[3].lobby && rows[7].lobby
        && !isDefined(rows[3].target) && !isDefined(rows[7].target),
        "Both server mutations use lobby scope without a player target");
    tests\support\checks::expect(rows[21].label == "End Game" && rows[21].enabled
        && rows[21].lobby && !isDefined(rows[21].target) && !isDefined(rows[21].checked),
        "The server page routes End Game as a global request without completion state");

    view.access = "Co-Host";
    view.host = false;
    rows = scripts\apparition\menu\model::build("Server Modifications", view);
    tests\support\checks::expect(rows.size == 22 && rows[3].enabled && rows[7].enabled && rows[21].enabled,
        "The model routes supported source server controls for Co-Host access");
}

dj_request_rows_explain_native_denials_and_missing_snapshots()
{
    view = speaker_view();
    view.dj.reason = "Wait for the DJ to finish speaking";
    rows = scripts\apparition\menu\model::build("Speaker Defense Controls", view);
    tests\support\checks::expect(!rows[0].enabled && rows[0].description == view.dj.reason,
        "The disabled speaker request explains the native busy state");
    view.dj.reason = "Wait for the current DJ request cooldown";
    rows = scripts\apparition\menu\model::build("Speaker Defense Controls", view);
    tests\support\checks::expect(!rows[0].enabled && rows[0].description == view.dj.reason,
        "The disabled speaker request explains its cooldown");
    view.ufo = scripts\apparition\maps\spaceland\quest::progress(tests\fixtures\spaceland::quest(6));
    view.dj.reason = "";
    view.dj.kind = "tone";
    rows = scripts\apparition\menu\model::build("Speaker Defense Controls", view);
    tests\support\checks::expect(!rows[0].enabled && rows[0].description == "Speaker requests require a native speaker-defense stage",
        "A retained speaker page explains the stage boundary before DJ readiness");
    rows = scripts\apparition\menu\model::build("UFO Quest Steps", view);
    tests\support\checks::expect(rows[6].enabled && rows[6].description == "Collect tone generators from the selected DJ",
        "A ready tone request retains its intent and source stage position");
    view.dj.reason = "Wait for the native DJ quest request";
    rows = scripts\apparition\menu\model::build("UFO Quest Steps", view);
    tests\support\checks::expect(!rows[6].enabled && rows[6].description == view.dj.reason && !rows[6].checked,
        "A pending native callback explains why generators cannot be requested without claiming completion");
    view.host = false;
    view.dj = undefined;
    rows = scripts\apparition\menu\model::build("UFO Quest Steps", view);
    tests\support\checks::expect(!rows[6].enabled && rows[6].description == "Only the current host can request the native DJ",
        "Guest denial takes priority over absent native DJ data");
    view.host = true;
    foreach (snapshot in [false, 7, "ready", []])
    {
        view.dj = snapshot;
        rows = scripts\apparition\menu\model::build("UFO Quest Steps", view);
        tests\support\checks::expect(!rows[6].enabled && rows[6].description == "Wait for native DJ readiness data",
            "Malformed readiness cannot enable a DJ action");
    }
    view.dj = undefined;
    rows = scripts\apparition\menu\model::build("UFO Quest Steps", view);
    tests\support\checks::expect(!rows[6].enabled && rows[6].description == "Wait for native DJ readiness data",
        "Missing readiness cannot enable a DJ action");
    view.dj = spawnstruct();
    view.dj.reason = "";
    view.dj.kind = "defense";
    rows = scripts\apparition\menu\model::build("UFO Quest Steps", view);
    tests\support\checks::expect(!rows[6].enabled && rows[6].description == "Wait for the native DJ quest request",
        "A mismatched request kind cannot enable the tone-generator row");
}

// Direction follows the existing checkbox without adding a second state value

god_hints_explain_personal_and_mixed_lobby_toggle_direction()
{
    view = basic_view();
    off = view.target;
    on = spawnstruct();
    on.playerGodmode = true;
    row = scripts\apparition\menu\model::god_row(view, false);
    tests\support\checks::expect(row.enabled && !row.checked
        && row.description == "Use enables God Mode for this player",
        "An off personal God Mode setting describes the enable action");
    view.target = on;
    row = scripts\apparition\menu\model::god_row(view, false);
    tests\support\checks::expect(row.enabled && row.checked
        && row.description == "Use disables God Mode for this player",
        "An enabled personal God Mode setting describes the disable action");
    view.host = true;
    view.access = "Host";
    view.actor_reason = "";
    foreach (players in [[off], [on, off], [off, on]])
    {
        view.players = players;
        row = scripts\apparition\menu\model::god_row(view, true);
        tests\support\checks::expect(row.enabled && !row.checked
            && row.description == "Use enables God Mode for every current player; later joins keep their own state",
            "Off and mixed rosters describe one enable operation regardless of roster order");
    }
    view.players = [on];
    row = scripts\apparition\menu\model::god_row(view, true);
    tests\support\checks::expect(row.enabled && row.checked
        && row.description == "Use disables God Mode for every current player; later joins keep their own state",
        "A uniformly enabled roster describes one disable operation");
    tests\support\checks::expect(on.playerGodmode && !isDefined(off.playerGodmode),
        "Hint rendering cannot change the configured flags");
}

perk_hints_explain_each_native_inventory_toggle_direction()
{
    view = perk_view();
    ids = scripts\apparition\maps\spaceland\perks::ids();
    rows = scripts\apparition\menu\model::perk_rows(view, false);
    tests\support\checks::expect(rows[0].description == "Use removes all ten Spaceland machine perks"
        && rows[2].description == "Use removes this perk",
        "Fully owned personal inventory describes removal");
    other = tests\fixtures\perks::owned_player(ids);
    other.zombies_perks[ids[0]] = undefined;
    view.players = [view.target, other];
    rows = scripts\apparition\menu\model::perk_rows(view, true);
    tests\support\checks::expect(rows[0].enabled && !rows[0].checked
        && rows[0].description == "Use gives all ten perks to every current player; later joins keep their own perks",
        "One missing perk makes the lobby All Perks action grant the selection");
    tests\support\checks::expect(!rows[2].checked
        && rows[2].description == "Use gives this perk to every current player; later joins keep their own perks"
        && rows[3].checked
        && rows[3].description == "Use removes this perk from every current player; later joins keep their own perks",
        "Each individual lobby perk describes its own grant or removal direction");
    view.target = other;
    rows = scripts\apparition\menu\model::perk_rows(view, false);
    tests\support\checks::expect(rows[0].description == "Use gives all ten Spaceland machine perks"
        && rows[2].description == "Use gives this perk" && rows[3].description == "Use removes this perk",
        "A partial personal inventory describes grant and removal independently");
    tests\support\checks::expect(!isDefined(other.zombies_perks[ids[0]])
        && scripts\apparition\features\perks::all_owned([view.players[0]], ids),
        "Hint rendering leaves both native inventory snapshots untouched");
}

retention_hints_explain_snapshot_discard_and_mixed_enable()
{
    view = perk_view();
    ids = scripts\apparition\maps\spaceland\perks::ids();
    retaining = tests\fixtures\perks::retaining_player(ids);
    retaining.apparition_perk_retention.saved = [ids[0]];
    saved = retaining.apparition_perk_retention;
    view.players = [retaining, view.target];
    rows = scripts\apparition\menu\model::perk_rows(view, true);
    tests\support\checks::expect(rows[1].enabled && !rows[1].checked
        && rows[1].description == "Use enables retention for every current player; save at normal downs, restore after spawn; Ghosts N Skulls participants keep prior snapshots; later joins excluded",
        "A mixed retention roster describes enabling without implying current perk grants");
    view.players = [retaining];
    rows = scripts\apparition\menu\model::perk_rows(view, true);
    tests\support\checks::expect(rows[1].enabled && rows[1].checked
        && rows[1].description == "Use disables retention for every current player; saved snapshots are discarded; owned perks stay",
        "Uniform lobby retention describes discarding snapshots while preserving current perks");
    view.target = retaining;
    rows = scripts\apparition\menu\model::perk_rows(view, false);
    tests\support\checks::expect(rows[1].description == "Use disables retention; saved snapshots are discarded; owned perks stay",
        "Personal retention describes the same off behavior");
    view.target = tests\fixtures\perks::owned_player(ids);
    rows = scripts\apparition\menu\model::perk_rows(view, false);
    tests\support\checks::expect(rows[1].description == "Use enables retention; save at normal downs, restore after spawn; Ghosts N Skulls participants keep prior snapshots",
        "Personal retention enable describes capture and spawn restoration");
    tests\support\checks::expect(retaining.apparition_perk_retention == saved
        && saved.saved.size == 1 && saved.saved[0] == ids[0]
        && scripts\apparition\features\perks::all_owned([retaining], ids),
        "Rendering does not discard saved snapshots or alter owned perks");
}
