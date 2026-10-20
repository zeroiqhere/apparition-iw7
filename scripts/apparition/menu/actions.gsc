// Every gameplay callback rechecks session and target permissions at execution

face_spawn_balloon(row, value)
{
    if (!row.lobby || !authorized(row))
        return false;
    // The feature resolves this exact object in a fresh native query before aiming
    return scripts\apparition\maps\spaceland\balloons::face(self, row.balloon_point);
}

open_page(row, value)
{
    if (scripts\apparition\runtime\player_control::reason(self, row.target) != "")
    {
        // Lobby navigation has no single actor, but still requires the host
        if (row.destination != "All Players Perks"
            || !scripts\apparition\runtime\context::can_dispatch(self, undefined, true))
            return false;
    }
    if ((row.destination == "Weaponry" || row.destination == "Weapon Options")
        && scripts\apparition\features\weapons::access_reason(self, row.target) != "")
        return false;
    // Recheck native host identity when a previously captured Host Menu link is selected
    if (row.destination == "Host Menu" && scripts\apparition\features\show_origin::reason(self) != "")
        return false;
    self scripts\apparition\menu\controller::push(row.destination, row.target);
    return true;
}

take_current_weapon(row, value)
{
    if (row.lobby)
        return false;
    // The provider resolves current permission, native phases and held weapon at execution
    return scripts\apparition\features\weapons::take_current(self, row.target);
}

set_host_fov(row, value)
{
    if (row.lobby || row.target != self)
        return false;
    // The feature rechecks the native host and reads the current setting before Use writes
    return scripts\apparition\features\fov::request(self, value);
}

toggle_server_cheats(row, value)
{
    if (row.lobby || !isDefined(row.target) || row.target != self)
        return false;
    // The feature rechecks current host authority and the live native setting
    return scripts\apparition\features\server_cheats::toggle(self);
}

toggle_show_origin(row, value)
{
    if (row.lobby || !isDefined(row.target) || row.target != self)
        return false;
    // The provider checks the current session and actual host before touching display state
    return scripts\apparition\features\show_origin::toggle(self);
}

open_doheart(row, value)
{
    if (!isDefined(row) || !isstruct(row) || !isDefined(row.target) || row.target != self
        || !isDefined(row.destination) || row.destination != "Doheart Options")
        return false;
    // Page entry owns default capture; rendering this page stays read-only
    if (!scripts\apparition\features\server\doheart::initialize(self))
        return false;
    self scripts\apparition\menu\controller::push(row.destination, row.target);
    return true;
}

toggle_doheart(row, value)
{
    if (!row.lobby)
        return false;
    // The provider repeats the source Co-Host permission with current native actors
    return scripts\apparition\features\server\doheart::toggle(self);
}

configure_doheart(row, value)
{
    if (!row.lobby)
        return false;
    if (row.setting == "text" && isDefined(value) && value == "Custom")
        return scripts\apparition\menu\keyboard::begin(self, "doheart");
    return scripts\apparition\features\server\doheart::configure(self, row.setting, value);
}

toggle_god(row, value)
{
    if (!player_authorized(row))
        return false;
    // Current players must pass actor admission before hook readiness or flag changes
    players = row.lobby ? level.players : [row.target];
    if (scripts\apparition\runtime\context::actor_reason(players) != "")
        return false;
    return scripts\apparition\features\god_mode::toggle(players,
        scripts\apparition\runtime\damage::active());
}

toggle_demi_god(row, value)
{
    if (row.lobby || !authorized(row))
        return false;
    if (scripts\apparition\runtime\context::actor_reason([row.target]) != ""
        || !scripts\apparition\runtime\context::in_roster(level.players, row.target))
        return false;

    // Disabling a saved setting must not depend on native effect readiness
    feedback_reason = "";
    if (!scripts\apparition\features\demi_god::enabled(row.target))
        feedback_reason = scripts\apparition\features\demi_god::feedback_reason(row.target);
    return scripts\apparition\features\demi_god::toggle(row.target,
        scripts\apparition\runtime\damage::active(), feedback_reason);
}

set_vision(row, value)
{
    if (row.lobby || !authorized(row))
        return false;
    // Only the source selector crosses dispatch; native profile and reset data are fresh
    return scripts\apparition\features\vision::request(self, row.target, value);
}

set_movement(row, value)
{
    if (!authorized(row))
        return false;
    // The feature checks the current actor and value before replacing a worker
    return scripts\apparition\features\movement::set_scale(row.target, value);
}

toggle_invisibility(row, value)
{
    if (!authorized(row))
        return false;
    return scripts\apparition\features\invisibility::toggle(row.target);
}

toggle_hud_visibility(row, value)
{
    if (!authorized(row))
        return false;
    return scripts\apparition\features\hud_visibility::toggle(row.target);
}

toggle_multi_jump(row, value)
{
    if (!authorized(row))
        return false;
    return scripts\apparition\features\multi_jump::toggle(row.target);
}

toggle_sprint_fire(row, value)
{
    if (!authorized(row))
        return false;
    return scripts\apparition\features\sprint_fire::toggle(row.target);
}

modify_score(row, value)
{
    if (!authorized(row))
        return false;
    // The feature reads a fresh balance and cap before applying this delta
    return scripts\apparition\features\score::modify(row.target, value);
}

set_message_display(row, value)
{
    // The source setting belongs to the menu owner even on a remote player page
    if (row.lobby || row.target != self || !authorized(row))
        return false;
    return scripts\apparition\features\messages::set_display(self, value);
}

open_message_keyboard(row, value)
{
    if (row.lobby || row.target != self || !authorized(row))
        return false;
    return scripts\apparition\menu\keyboard::begin(self, "message");
}

open_player_message_keyboard(row, value)
{
    if (scripts\apparition\features\player_messages::reason(self, row.target, row.lobby) != "")
        return false;
    // A stale row cannot replace the recipient captured by the current menu page
    if (!isDefined(self.apparition_state) || self.apparition_state.target != row.target)
        return false;
    return scripts\apparition\menu\keyboard::begin(self, row.lobby ? "lobby_message" : "player_message");
}

send_message_preset(row, value)
{
    if (row.lobby || row.target != self || !authorized(row))
        return false;
    // Only the selector is captured; current names and delivery are read again
    return scripts\apparition\features\messages::send(self, row.message_page, row.message_id);
}

set_powerup_location(row, value)
{
    // Location is a personal owner preference even while viewing another player
    if (row.lobby || row.target != self || !authorized(row))
        return false;
    return scripts\apparition\features\powerups::set_location(self, value);
}

set_crosshair(row, value)
{
    if (row.lobby || !authorized(row))
        return false;
    // Authorization and the current target name are checked again at selection
    return scripts\apparition\features\crosshairs::set(row.target, value);
}

teleport(row, value)
{
    if (row.lobby)
        return false;
    // The feature owns fresh actor authorization and current movement admission
    return scripts\apparition\features\teleport::request(self, row.target, value);
}

teleport_lobby(row, value)
{
    if (!row.lobby || !player_authorized(row))
        return false;
    // The feature resolves the complete current selection again before movement
    return scripts\apparition\features\lobby_teleport::request(self, value);
}

toggle_teleport_gun(row, value)
{
    if (row.lobby)
        return false;
    // The feature rechecks grant authority before either configuration change
    return scripts\apparition\features\teleport_gun::toggle(self, row.target);
}

toggle_position_shortcuts(row, value)
{
    if (row.lobby)
        return false;
    // The selected player polls its own controls after this owner-scoped grant
    return scripts\apparition\features\position_shortcuts::toggle(self, row.target);
}

official_spawn(row, value)
{
    if (row.lobby)
        return false;
    // Resolve the displayed index in its captured identity list, never a new list
    point = scripts\apparition\maps\spaceland\spawn_points::select(row.spawn_points, value);
    if (!isDefined(point))
        return false;
    return scripts\apparition\features\teleport::official(self, row.target, point);
}

entity_teleport(row, value)
{
    if (row.lobby)
        return false;
    // The feature rechecks the captured native object before reading its vectors
    return scripts\apparition\features\teleport::entity(self, row.target, row.teleport_entry);
}

player_death(row, value)
{
    // Kill remains a disabled preview until its separate native binding is established
    if (row.lobby || !isDefined(value) || !isstring(value) || value != "Down"
        || !authorized(row))
        return false;
    return scripts\apparition\features\down::request([row.target]);
}

down_players(row, value)
{
    if (!row.lobby || !player_authorized(row))
        return false;
    // The feature excludes the actual host and rechecks each current recipient
    return scripts\apparition\features\down::request_lobby(self);
}

save_location(row, value)
{
    if (row.lobby)
        return false;
    return scripts\apparition\features\teleport::save(self, row.target);
}

load_location(row, value)
{
    if (row.lobby)
        return false;
    return scripts\apparition\features\teleport::load(self, row.target);
}

teleport_to_self(row, value)
{
    if (row.lobby)
        return false;
    // The source action moves the selected player to the menu owner
    return scripts\apparition\features\teleport::exchange(self, row.target, true);
}

teleport_to_player(row, value)
{
    if (row.lobby)
        return false;
    // The opposite source action moves the owner to the selected player
    return scripts\apparition\features\teleport::exchange(self, row.target, false);
}

drop_powerup(row, value)
{
    if (!authorized(row))
        return false;
    // Dispatch resolves the current host's point again instead of reusing the view
    return scripts\apparition\features\powerups::request(self, row.powerup_id);
}

toggle_explosive_protection(row, value)
{
    if (!authorized(row))
        return false;
    // Dispatch rechecks hook ownership after the row was rendered
    return scripts\apparition\features\explosive_protection::toggle(row.target,
        scripts\apparition\runtime\damage::active());
}

set_ammo(row, value)
{
    if (!authorized(row))
        return false;
    // Both scopes validate their complete fresh selection before changing workers
    players = row.lobby ? level.players : [row.target];
    return scripts\apparition\features\ammo::set_mode(players, value);
}

revive(row, value)
{
    if (!player_authorized(row))
        return false;
    // The view only previews eligibility; requests inspect the current selection
    if (row.lobby)
        return scripts\apparition\features\revive::request_lobby(self);
    return scripts\apparition\features\revive::request([row.target]);
}

toggle_equipment(row, value)
{
    if (!authorized(row))
        return false;
    players = row.lobby ? level.players : [row.target];
    return scripts\apparition\features\equipment::toggle(players);
}

set_insta_kill(row, value)
{
    if (row.lobby || !authorized(row))
        return false;
    // Current access and native hook ownership are checked again before applying
    return scripts\apparition\features\insta_kill::set_mode(self, row.target, value);
}

toggle_frog_jump(row, value)
{
    if (row.lobby || !authorized(row))
        return false;
    // A fresh actor, input and access check precedes worker configuration
    return scripts\apparition\features\frog_jump::toggle(self, row.target);
}

toggle_health_bar(row, value)
{
    if (row.lobby || !authorized(row))
        return false;
    // The feature rechecks access and reads current life and health before creation
    return scripts\apparition\features\health_bar::toggle(self, row.target);
}

play_perk_sound(row, value)
{
    if (row.lobby || !authorized(row))
        return false;
    // Stable selectors are resolved against current native machines and voice data
    return scripts\apparition\features\perk_sounds::request(self, row.target, row.perk_id, row.sound_kind);
}

send_earthquake(row, value)
{
    if (!authorized(row))
        return false;
    // The feature probes current access and position before one global native request
    return scripts\apparition\features\earthquake::request(self, row.target);
}

toggle_perk(row, value)
{
    if (!authorized(row))
        return false;
    // The current roster is captured at dispatch rather than retained by the row
    players = row.lobby ? level.players : [row.target];
    return scripts\apparition\features\perks::toggle(players, [row.perk_id]);
}

toggle_all_perks(row, value)
{
    if (!authorized(row))
        return false;
    players = row.lobby ? level.players : [row.target];
    return scripts\apparition\features\perks::toggle(players, scripts\apparition\maps\spaceland\perks::ids());
}

toggle_retention(row, value)
{
    if (!authorized(row))
        return false;
    // This configures future down/spawn behavior without changing current perks
    players = row.lobby ? level.players : [row.target];
    return scripts\apparition\features\perk_retention::toggle(players);
}

face_ghost_skull(row, value)
{
    if (!authorized(row))
        return false;
    return scripts\apparition\maps\spaceland\ghosts::face(self);
}

start_dance(row, value)
{
    if (!authorized(row))
        return false;
    return scripts\apparition\maps\spaceland\dance::start(self);
}

hit_floating_skull(row, value)
{
    if (!authorized(row))
        return false;
    return scripts\apparition\maps\spaceland\floating_skull::start(self);
}

hit_brute_cabinet(row, value)
{
    if (!authorized(row))
        return false;
    return scripts\apparition\maps\spaceland\brute_cabinet::start(self);
}

cancel_dance(row, value)
{
    if (!authorized(row))
        return false;
    // Current host authority can stop a worker even after its original owner changes
    return scripts\apparition\maps\spaceland\dance::cancel();
}

collect_dj_parts(row, value)
{
    if (!row.lobby || !authorized(row))
        return false;
    // The backend repeats stage, roster and living-host admission before collection
    return scripts\apparition\maps\spaceland\dj_parts::collect(self);
}

turn_on_power(row, value)
{
    if (!row.lobby || !authorized(row))
        return false;
    // The native module resolves each remaining generator from current map state
    return scripts\apparition\maps\spaceland\power::start(self);
}

set_server_timescale(row, value)
{
    if (!row.lobby)
        return false;
    // The provider validates the choice and reads the current global dvar again
    return scripts\apparition\features\server\timescale::request(self, value);
}

toggle_server_movement(row, value)
{
    if (!row.lobby)
        return false;
    // A canonical setting ID resolves fresh native state and its owned inverse
    return scripts\apparition\features\server\movement::toggle(self, row.setting);
}

request_end_game(row, value)
{
    if (!row.lobby)
        return false;
    // The level-owned native wrapper owns all terminal state and match cleanup
    return scripts\apparition\features\server\end_game::request(self);
}

toggle_auto_revive(row, value)
{
    if (!row.lobby)
        return false;
    // The provider rechecks current Co-Host access and configured worker state
    return scripts\apparition\features\server\auto_revive::toggle(self);
}

toggle_newsbar(row, value)
{
    if (!row.lobby)
        return false;
    // Recheck current Co-Host access and setting without retaining a HUD handle
    return scripts\apparition\features\server\newsbar::toggle(self);
}

toggle_lobby_timer(row, value)
{
    if (!row.lobby)
        return false;
    return scripts\apparition\features\server\lobby_timer::toggle(self);
}

configure_lobby_timer(row, value)
{
    if (!row.lobby)
        return false;
    // Applying the current value deliberately restarts an enabled countdown
    return scripts\apparition\features\server\lobby_timer::configure(self, value);
}

authorized(row)
{
    // World and port-added lobby controls retain native-host authority
    if (row.lobby)
        return scripts\apparition\runtime\context::can_dispatch(self, row.target, true);
    return player_authorized(row);
}

player_authorized(row)
{
    // Only the four source lobby player actions call this path directly
    if (row.lobby)
        return scripts\apparition\runtime\player_control::lobby_reason(self) == "";
    return scripts\apparition\runtime\player_control::reason(self, row.target) == "";
}

request_dj(row, value)
{
    if (!authorized(row))
        return false;
    // A stale speaker page cannot submit the later tone-generator request
    if (isDefined(row.speaker_defense))
    {
        step = scripts\apparition\maps\spaceland\quest::current_step(level);
        if (step < 2 || step > 4)
            return false;
    }
    return scripts\apparition\maps\spaceland\dj::request(self);
}

place_speaker(row, value)
{
    if (!authorized(row))
        return false;
    return scripts\apparition\maps\spaceland\speaker_placement::start(self);
}

start_speakers(row, value)
{
    if (!authorized(row))
        return false;
    return scripts\apparition\maps\spaceland\speakers::start(self, false);
}

collect_speaker(row, value)
{
    if (!authorized(row))
        return false;
    return scripts\apparition\maps\spaceland\speakers::start(self, true);
}

cancel_speakers(row, value)
{
    if (!authorized(row))
        return false;
    return scripts\apparition\maps\spaceland\speakers::cancel();
}

start_wave(row, value)
{
    if (!authorized(row))
        return false;
    return scripts\apparition\maps\spaceland\wave::start(self);
}

cancel_wave(row, value)
{
    if (!authorized(row))
        return false;
    return scripts\apparition\maps\spaceland\wave::cancel();
}

place_generators(row, value)
{
    if (!authorized(row))
        return false;
    return scripts\apparition\maps\spaceland\generators::place(self);
}

start_tones(row, value)
{
    if (!authorized(row))
        return false;
    // The background job keeps menu navigation responsive during UFO travel
    return scripts\apparition\maps\spaceland\tones::start(self);
}

cancel_tones(row, value)
{
    if (!authorized(row))
        return false;
    return scripts\apparition\maps\spaceland\tones::cancel();
}

enter_pap(row, value)
{
    if (!authorized(row))
        return false;
    outcome = scripts\apparition\maps\spaceland\portal_travel::enter(self);
    if (outcome == "Pending")
        self iPrintLn("Entry not confirmed yet; native travel may still finish");
    // Handled pending input receives its own message without claiming quest completion
    return outcome != "Unavailable";
}

visit_portal(row, value)
{
    if (!authorized(row))
        return false;
    return scripts\apparition\maps\spaceland\portal_travel::start_visit(self, row.area);
}

set_appearance(row, value)
{
    // Appearance belongs to the menu owner even when another player was selected
    if (!scripts\apparition\runtime\context::can_dispatch(self, self, false))
        return false;
    choice = isDefined(row.choice) ? row.choice : value;
    old_design = self.apparition_layout.design;
    old_counter = self.apparition_layout.option_counter;
    if (!scripts\apparition\menu\customization\preferences::apply(self.apparition_layout, row.setting, choice))
        return false;
    if (!scripts\apparition\menu\customization\storage::save(self))
        self iPrintLn("Settings applied for this connection; saving was unavailable");
    if (scripts\apparition\menu\customization\preferences::reopen_required(row.setting, old_design, self.apparition_layout.design, old_counter))
    {
        delay = self scripts\apparition\menu\controller::reopen(true);
        return isDefined(delay);
    }
    // Disabling the guide changes the current page capacity immediately
    if (row.setting == "disable_instructions")
        self scripts\apparition\menu\controller::refresh_current("redraw");
    return true;
}

set_binding_selection(row, value)
{
    if (!scripts\apparition\runtime\context::can_dispatch(self, self, false) || row.target != self)
        return false;
    // Binding selectors have their own validated path outside appearance preferences
    return scripts\apparition\menu\customization\bindings::select(self.apparition_layout, row.setting, value);
}

set_open_binding(row, value)
{
    if (!scripts\apparition\runtime\context::can_dispatch(self, self, false) || row.target != self)
        return false;
    layout = self.apparition_layout;
    if (!isDefined(row.binding_type) || !isDefined(row.binding_slot) || !isDefined(row.button))
        return false;
    // A delayed row cannot overwrite a different type or slot selected afterward
    if (row.binding_type != layout.binding_menu || row.binding_slot != layout.binding_slot)
        return false;
    if (!scripts\apparition\menu\customization\bindings::apply(layout, row.binding_type, row.binding_slot, row.button))
        return false;
    if (!scripts\apparition\menu\customization\storage::save(self))
        self iPrintLn("Settings applied for this connection; saving was unavailable");
    return true;
}

start_bombers(row, value)
{
    if (!authorized(row))
        return false;
    return scripts\apparition\maps\spaceland\bombers::start(self);
}

cancel_bombers(row, value)
{
    if (!authorized(row))
        return false;
    return scripts\apparition\maps\spaceland\bombers::cancel();
}

start_grey_fuses(row, value)
{
    if (!authorized(row))
        return false;
    return scripts\apparition\maps\spaceland\greys::start(self, false);
}

cancel_greys(row, value)
{
    if (!authorized(row))
        return false;
    return scripts\apparition\maps\spaceland\greys::cancel();
}

collect_fuses(row, value)
{
    if (!authorized(row))
        return false;
    return scripts\apparition\maps\spaceland\fuses::start(self);
}

insert_fuses(row, value)
{
    if (!authorized(row))
        return false;
    return scripts\apparition\maps\spaceland\pap_insert::start(self);
}

start_nodes(row, value)
{
    if (!authorized(row))
        return false;
    return scripts\apparition\maps\spaceland\nodes::start(self);
}

cancel_nodes(row, value)
{
    if (!authorized(row))
        return false;
    return scripts\apparition\maps\spaceland\nodes::cancel();
}

collect_soul_key(row, value)
{
    if (!authorized(row))
        return false;
    return scripts\apparition\maps\spaceland\soul_key::start(self);
}

start_greys(row, value)
{
    if (!authorized(row))
        return false;
    return scripts\apparition\maps\spaceland\greys::start(self, true);
}

set_verification(row, value)
{
    if (row.lobby)
        return false;
    return scripts\apparition\runtime\access::grant(self, row.target, row.access_level);
}

set_verification_all(row, value)
{
    if (!row.lobby || !scripts\apparition\runtime\access::can_open(self)
        || !scripts\apparition\runtime\context::can_dispatch(self, undefined, true)
        || scripts\apparition\runtime\context::actor_reason(level.players) != "")
        return false;
    changed = false;
    // Every recipient passes the same fresh single-player grant policy
    foreach (player in level.players)
    {
        if (scripts\apparition\runtime\access::grant(self, player, row.access_level))
            changed = true;
    }
    return changed;
}

set_zombie_movement(row, value)
{
    if (!row.lobby || !authorized(row))
        return false;
    // The feature resolves a fresh host and agent pass instead of the rendered snapshot
    return scripts\apparition\maps\spaceland\zombie_movement::request(self, value);
}

kill_zombies(row, value)
{
    // The feature also rechecks the current host and grant before each native hit
    if (!row.lobby || !isDefined(value) || !isstring(value) || value != "Death" || !authorized(row))
        return false;
    return scripts\apparition\maps\spaceland\zombie_kill::request(self, value);
}

set_zombie_health(row, value)
{
    // Reset stays unavailable until its native enemy-specific policy is established
    if (!row.lobby || !isDefined(value) || !isstring(value) || value != "Custom" || !authorized(row))
        return false;
    return scripts\apparition\menu\keyboard::begin(self, "zombie_health");
}


toggle_zombie_visibility(row, value)
{
    if (!row.lobby || isDefined(row.target))
        return false;
    // Dispatch rechecks actual host admission and selects fresh living enemies
    return scripts\apparition\maps\spaceland\zombie_visibility::toggle(self);
}
