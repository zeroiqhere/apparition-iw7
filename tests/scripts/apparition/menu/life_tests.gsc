// Menu life follows the source native-life and session-state predicate

run()
{
    living_non_spectator_sessions_are_active();
    spectators_and_unknown_session_state_use_the_dead_menu_path();
    native_death_cannot_be_overridden_by_session_state();
}

living_non_spectator_sessions_are_active()
{
    tests\support\checks::expect(scripts\apparition\menu\life::active(true, "playing"), "A living playing session can use normal menu controls");
    tests\support\checks::expect(scripts\apparition\menu\life::active(true, "intermission"), "The source accepts defined non-spectator states without a new playing-only restriction");
}

spectators_and_unknown_session_state_use_the_dead_menu_path()
{
    // Spectator health alone cannot select the living chord or living rows
    tests\support\checks::expect(!scripts\apparition\menu\life::active(true, "spectator"), "A spectator uses the dead menu path even when native life is true");
    tests\support\checks::expect(!scripts\apparition\menu\life::active(true, undefined), "Missing session state cannot advertise a living menu session");
}

native_death_cannot_be_overridden_by_session_state()
{
    tests\support\checks::expect(!scripts\apparition\menu\life::active(false, "playing"), "A playing session label cannot make a natively dead player active");
    tests\support\checks::expect(!scripts\apparition\menu\life::active(false, "spectator"), "A natively dead spectator remains on the dead menu path");
    tests\support\checks::expect(!scripts\apparition\menu\life::active(false, undefined), "Missing session state and native death remain inactive");
}
