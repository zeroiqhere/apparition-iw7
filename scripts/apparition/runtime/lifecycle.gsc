// Only private, normal Spaceland matches start this GSC menu

start()
{
    level endon("game_ended");
    if (isDefined(level.apparition_started))
        return;
    level.apparition_started = true;
    // CP creates its session flags and damage callback during map initialization
    deadline = getTime() + 10000;
    while ((!isDefined(level.onlinegame) || !isDefined(level.callbackPlayerDamage)
        || !isDefined(level.laststand_enter_gamemodespecificaction)) && getTime() < deadline)
        wait 0.05;
    if (!scripts\apparition\runtime\context::supported())
    {
        printLn("Apparition: private normal Spaceland is required");
        return;
    }
    // Match the source's once-per-level movement baseline capture before menus open
    scripts\apparition\features\server\movement::initialize();
    level thread scripts\apparition\maps\spaceland\grey_sequence::start();
    level thread scripts\apparition\maps\spaceland\pap_cycles::start();
    level thread scripts\apparition\maps\spaceland\node_history::start();
    level thread scripts\apparition\maps\spaceland\speaker_history::start();
    level thread scripts\apparition\maps\spaceland\ghost_history::start();
    level thread scripts\apparition\maps\spaceland\arcade_history::start();
    level thread scripts\apparition\maps\spaceland\reactivation_history::start();
    // Installation happens once; later hooks cannot cause this wrapper to re-chain
    scripts\apparition\runtime\damage::install();
    scripts\apparition\runtime\perk_retention::install();
    level thread connect_players();
    if (isDefined(level.players))
    {
        foreach (player in level.players)
            player attach_player();
    }
    level thread end_cleanup();
}

connect_players()
{
    level endon("game_ended");
    for (;;)
    {
        level waittill("connected", player);
        player attach_player();
    }
}

attach_player()
{
    if (isDefined(self.apparition_attached))
        return;
    self.apparition_attached = true;
    // Multi-Jump and Frog Jump sample one player-owned press/release receipt
    self thread scripts\apparition\runtime\jump_input::observe_input();
    self thread scripts\apparition\menu\controller::start();
    self thread disconnect_cleanup();
}

disconnect_cleanup()
{
    level endon("game_ended");
    self waittill("disconnect");
    if (isDefined(self))
        scripts\apparition\maps\spaceland\zombie_health::retire(self);
    scripts\apparition\features\show_origin::release(self);
    scripts\apparition\features\health_bar::release(self);
    scripts\apparition\features\frog_jump::release(self);
    scripts\apparition\features\crosshairs::release(self);
    scripts\apparition\features\teleport_gun::release(self);
    scripts\apparition\features\position_shortcuts::release(self);
    scripts\apparition\menu\instruction_hud::release(self);
    scripts\apparition\menu\hud::release(self.apparition_hud);
}

end_cleanup()
{
    level waittill("game_ended");
    scripts\apparition\maps\spaceland\zombie_health::retire(undefined);
    // Ending the level stops enforcement without changing terminal enemy visibility
    scripts\apparition\maps\spaceland\zombie_visibility::stop(level.apparition_zombie_visibility);
    // Retire the global setting independently of the worker's game-end listener
    scripts\apparition\features\server\auto_revive::stop(level.apparition_auto_revive);
    // The global HUD pair has a lifetime independent of the worker endon
    scripts\apparition\features\server\newsbar::stop(level.apparition_newsbar);
    scripts\apparition\features\server\lobby_timer::stop(level.apparition_lobby_timer);
    scripts\apparition\features\server\doheart::stop(level.apparition_doheart);
    // The optional enemy hook is cleared only while its current value is still owned
    scripts\apparition\runtime\enemy_damage::release();
    if (isDefined(level.apparition_speaker_capture))
        scripts\apparition\maps\spaceland\speaker_history::retire(level.apparition_speaker_capture);
    level.apparition_speaker_capture = undefined;
    // End watchers stop independently while this owner destroys their HUD pools
    foreach (player in level.players)
    {
        scripts\apparition\features\show_origin::release(player);
        scripts\apparition\features\health_bar::release(player);
        scripts\apparition\features\frog_jump::release(player);
        scripts\apparition\features\crosshairs::release(player);
        scripts\apparition\features\teleport_gun::release(player);
        scripts\apparition\features\position_shortcuts::release(player);
        scripts\apparition\menu\instruction_hud::release(player);
        player scripts\apparition\menu\controller::close();
        player notify("apparition_stop_menu");
        player notify("apparition_stop_ammo");
        scripts\apparition\features\equipment::set_enabled(player, false);
        scripts\apparition\features\perk_retention::set_enabled(player, false);
    }
}
