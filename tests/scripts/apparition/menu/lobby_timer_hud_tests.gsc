// Native timer HUD contracts never start a lobby countdown worker or request game end

run()
{
    invalid_recipients_and_duration_cannot_allocate_timer_huds();
    real_recipient_timer_is_released_without_waiting_for_its_display();
}

invalid_recipients_and_duration_cannot_allocate_timer_huds()
{
    tests\support\checks::expect(!isDefined(scripts\apparition\menu\lobby_timer_hud::create([], 60)),
        "No timer HUD is allocated for an empty activation roster");
    tests\support\checks::expect(!isDefined(scripts\apparition\menu\lobby_timer_hud::create([spawnstruct()], 60)),
        "Native timer allocation rejects a nonplayer recipient");
    tests\support\checks::expect(!isDefined(scripts\apparition\menu\lobby_timer_hud::create(undefined, undefined)),
        "Missing recipients and duration cannot allocate a timer HUD");
}

real_recipient_timer_is_released_without_waiting_for_its_display()
{
    player = tests\support\actors::first_player();
    tests\support\checks::expect(isDefined(player),
        "The opt-in timer HUD regression requires one current native player");
    if (!isDefined(player))
        return;
    foreach (seconds in [0, -1, 1801, "60"])
        tests\support\checks::expect(!isDefined(scripts\apparition\menu\lobby_timer_hud::create([player], seconds)),
            "Invalid native countdown durations are rejected before allocation");

    record = scripts\apparition\menu\lobby_timer_hud::create([player], 60);
    tests\support\checks::expect(isDefined(record) && isarray(record.timers) && record.timers.size == 1,
        "One activation recipient owns one native countdown HUD");
    if (!isDefined(record))
        return;
    if (isDefined(record.timers) && isarray(record.timers) && record.timers.size == 1)
    {
        element = record.timers[0];
        tests\support\checks::expect(isDefined(element) && element.elemType == "timer"
            && element.x == 25 && element.y == -20,
            "The HUD element keeps its native timer type and explicit lower-left IW7 adaptation");
        tests\support\checks::expect(element.horzAlign == "left" && element.vertAlign == "bottom"
            && element.alignX == "left" && element.alignY == "bottom",
            "The timer field readback retains its explicit IW7 anchors");
    }
    // Cleanup runs even after a failed native field assertion and yields no frame
    scripts\apparition\menu\lobby_timer_hud::destroy_record(record);
    tests\support\checks::expect(isarray(record.timers) && record.timers.size == 0,
        "Timer cleanup consumes its complete owned handle list");
    scripts\apparition\menu\lobby_timer_hud::destroy_record(record);
    tests\support\checks::expect(record.timers.size == 0,
        "Repeated timer cleanup leaves no retained native handle");
}
