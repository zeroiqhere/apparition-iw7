// HUD policy contracts avoid creating or changing real client elements

run()
{
    static_tint_uses_the_target_layout_instead_of_shared_rainbow();
    animated_tint_uses_the_live_shared_sample_even_when_the_menu_is_closed();
    missing_or_malformed_tint_data_uses_the_canonical_default();
    missing_hud_handles_cannot_receive_native_commands();
}

static_tint_uses_the_target_layout_instead_of_shared_rainbow()
{
    layout = spawnstruct();
    layout.accent = (0.1, 0.2, 0.3);
    layout.smooth_rainbow = false;
    tests\support\checks::expect(scripts\apparition\menu\crosshair_hud::tint(layout, (0.9, 0.8, 0.7))
        == (0.1, 0.2, 0.3), "Static crosshairs use the target's selected accent");
    tests\support\checks::expect(layout.accent == (0.1, 0.2, 0.3) && !layout.smooth_rainbow,
        "Reading a crosshair tint changes no layout preferences");
}

animated_tint_uses_the_live_shared_sample_even_when_the_menu_is_closed()
{
    layout = spawnstruct();
    layout.accent = (0.1, 0.2, 0.3);
    layout.smooth_rainbow = true;
    tests\support\checks::expect(scripts\apparition\menu\crosshair_hud::tint(layout, (0.95, 0.4, 0))
        == (0.95, 0.4, 0), "Rainbow crosshairs follow the live level color rather than a stale menu sample");
    tests\support\checks::expect(scripts\apparition\menu\crosshair_hud::tint(layout, undefined)
        == (0.1, 0.2, 0.3), "A missing shared phase retains the current valid accent");
    tests\support\checks::expect(scripts\apparition\menu\crosshair_hud::tint(layout, "rainbow")
        == (0.1, 0.2, 0.3), "A malformed shared sample is not sent as a HUD color");
}

missing_or_malformed_tint_data_uses_the_canonical_default()
{
    expected = (57 / 255.0, 152 / 255.0, 254 / 255.0);
    tests\support\checks::expect(scripts\apparition\menu\crosshair_hud::tint(undefined, undefined) == expected,
        "Missing target preferences use Apparition's default blue");
    tests\support\checks::expect(scripts\apparition\menu\crosshair_hud::tint("layout", undefined) == expected,
        "A malformed layout cannot be read as a native color");
    layout = spawnstruct();
    layout.accent = "blue";
    tests\support\checks::expect(scripts\apparition\menu\crosshair_hud::tint(layout, undefined) == expected,
        "A missing or malformed accent uses the same canonical fallback");
}

missing_hud_handles_cannot_receive_native_commands()
{
    tests\support\checks::expect(!isDefined(scripts\apparition\menu\crosshair_hud::create(undefined, "+", (1, 1, 1))),
        "A missing owner cannot allocate a client HUD element");
    tests\support\checks::expect(!scripts\apparition\menu\crosshair_hud::write(undefined, "+"),
        "A missing HUD handle cannot accept a text command");
    // These calls return before every native HUD operation
    scripts\apparition\menu\crosshair_hud::paint(undefined, (1, 1, 1));
    scripts\apparition\menu\crosshair_hud::destroy_element(undefined);
}
