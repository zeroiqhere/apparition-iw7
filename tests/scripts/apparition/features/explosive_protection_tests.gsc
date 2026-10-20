// The saved setting changes only this player's explosive-damage policy
// Native classification is checked separately through the damage router

run()
{
    an_unset_setting_is_disabled_and_can_be_enabled_with_the_hook();
    toggling_an_enabled_setting_clears_it();
    hook_loss_rejects_enabling_without_changing_other_protection();
    hook_loss_still_allows_clearing_an_enabled_setting();
    the_setting_does_not_change_other_players_or_god_modes();
    a_missing_player_is_unchecked_and_rejected();
}

an_unset_setting_is_disabled_and_can_be_enabled_with_the_hook()
{
    player = spawnstruct();
    tests\support\checks::expect(!scripts\apparition\features\explosive_protection::enabled(player), "An unset explosive setting is disabled");
    tests\support\checks::expect(scripts\apparition\features\explosive_protection::reason(player, true) == "", "An active hook admits enabling");
    tests\support\checks::expect(scripts\apparition\features\explosive_protection::toggle(player, true), "The explosive setting is accepted");
    tests\support\checks::expect(player.NoExplosiveDamage, "The original named setting is enabled");
}

toggling_an_enabled_setting_clears_it()
{
    player = spawnstruct();
    player.NoExplosiveDamage = true;
    tests\support\checks::expect(scripts\apparition\features\explosive_protection::toggle(player, true), "The enabled setting can be cleared");
    // Disabled Apparition settings use an undefined flag
    tests\support\checks::expect(!isDefined(player.NoExplosiveDamage), "Disabling clears the explosive setting");
}

hook_loss_rejects_enabling_without_changing_other_protection()
{
    player = spawnstruct();
    player.NoExplosiveDamage = false;
    player.playerGodmode = true;
    player.PlayerDemiGod = true;
    tests\support\checks::expect(scripts\apparition\features\explosive_protection::reason(player, false) != "", "Enabling requires callback ownership");
    tests\support\checks::expect(!scripts\apparition\features\explosive_protection::toggle(player, false), "A lost hook rejects enabling");
    tests\support\checks::expect(!player.NoExplosiveDamage, "Rejection leaves the explicit false setting unchanged");
    tests\support\checks::expect(player.playerGodmode && player.PlayerDemiGod, "Rejection leaves the other protection flags unchanged");
}

hook_loss_still_allows_clearing_an_enabled_setting()
{
    player = spawnstruct();
    player.NoExplosiveDamage = true;
    tests\support\checks::expect(scripts\apparition\features\explosive_protection::reason(player, false) == "", "Hook loss still admits clearing");
    tests\support\checks::expect(scripts\apparition\features\explosive_protection::toggle(player, false), "Hook loss accepts clearing the saved setting");
    tests\support\checks::expect(!isDefined(player.NoExplosiveDamage), "The saved setting is cleared after hook loss");
}

the_setting_does_not_change_other_players_or_god_modes()
{
    player = spawnstruct();
    other = spawnstruct();
    player.playerGodmode = true;
    player.PlayerDemiGod = true;
    other.NoExplosiveDamage = true;
    scripts\apparition\features\explosive_protection::toggle(player, true);
    tests\support\checks::expect(player.playerGodmode && player.PlayerDemiGod, "Explosive protection does not toggle either God Mode flag");
    tests\support\checks::expect(other.NoExplosiveDamage, "The personal action leaves another player unchanged");
}

a_missing_player_is_unchecked_and_rejected()
{
    tests\support\checks::expect(!scripts\apparition\features\explosive_protection::enabled(undefined), "A missing player is unchecked");
    tests\support\checks::expect(scripts\apparition\features\explosive_protection::reason(undefined, true) != "", "A missing player has an availability reason");
    tests\support\checks::expect(!scripts\apparition\features\explosive_protection::toggle(undefined, true), "A missing player cannot change a setting");
}
