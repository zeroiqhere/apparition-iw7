// Credits planning preserves source text order and motion cadence

run()
{
    items_preserve_exact_source_order_and_text();
    title_scale_resets_after_each_blank_separator();
    source_stagger_and_motion_timing_are_preserved();
    exit_instruction_matches_the_source();
}

items_preserve_exact_source_order_and_text()
{
    items = scripts\apparition\menu\credits_plan::items();
    expected = [
        "^1Apparition",
        "The Biggest & Best Menu For ^1Black Ops 3 Zombies",
        "Developed By: ^1CF4_99",
        "Discord.gg/^1apparitionbo3",
        " ",
        "^1Extinct",
        "Ideas",
        "Suggestions",
        "Constructive Criticism",
        "His Spec-Nade",
        " ",
        "^1ItsFebiven",
        "Ideas",
        "Suggestions",
        " ",
        "^1CraftyCritter",
        "BO3 GSC Compiler",
        " ",
        "^1Joel",
        "Testing",
        "Breaking Shit",
        "Bug Reporting",
        " ",
        "^1Thanks For Choosing Apparition",
        "YouTube: ^1CF4_99",
        "Discord: ^1cf4_99"
    ];

    tests\support\checks::expect(items.size == expected.size, "The credits plan contains all 26 source entries");
    for (index = 0; index < expected.size; index++)
        tests\support\checks::expect(items[index].text == expected[index], "Credits preserve each exact source string and position");
}

title_scale_resets_after_each_blank_separator()
{
    items = scripts\apparition\menu\credits_plan::items();
    expected_scale = [1.4, 1.1, 1.1, 1.1, -1, 1.4, 1.1, 1.1, 1.1, 1.1, -1,
        1.4, 1.1, 1.1, -1, 1.4, 1.1, -1, 1.4, 1.1, 1.1, 1.1, -1, 1.4, 1.1, 1.1];

    for (index = 0; index < items.size; index++)
    {
        if (expected_scale[index] < 0)
            tests\support\checks::expect(!isDefined(items[index].scale), "Blank credit separators have no rendered text scale");
        else
            tests\support\checks::expect(items[index].scale == expected_scale[index], "Credit title sizing restarts after source blank separators");
    }
}

source_stagger_and_motion_timing_are_preserved()
{
    items = scripts\apparition\menu\credits_plan::items();
    text_delay = 10 / 12.0;
    blank_delay = 10 / 4.0;
    for (index = 0; index < items.size; index++)
    {
        expected_delay = items[index].text == " " ? blank_delay : text_delay;
        tests\support\checks::expect(abs(items[index].delay - expected_delay) < 0.0001, "Each credits row keeps the source reveal cadence");
    }
    tests\support\checks::expect(scripts\apparition\menu\credits_plan::motion_time() == 10, "Credits move for the source ten-second duration");
    tests\support\checks::expect(scripts\apparition\menu\credits_plan::fade_time() == 0.5, "Credits fade for the source half-second duration");
}

exit_instruction_matches_the_source()
{
    tests\support\checks::expect(scripts\apparition\menu\credits_plan::instructions() == "[{+melee}] - Exit Menu Credits",
        "Credits show the original Melee exit instruction");
}
