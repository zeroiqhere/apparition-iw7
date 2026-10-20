// Credits data and timing come from the original menu sequence

items()
{
    menu_name = "Apparition";
    source = [
        "^1" + menu_name,
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
        "^1Thanks For Choosing " + menu_name,
        "YouTube: ^1CF4_99",
        "Discord: ^1cf4_99"
    ];

    result = [];
    title = true;
    foreach (text in source)
    {
        item = spawnstruct();
        item.text = text;
        if (text == " ")
        {
            // Source blank lines pause longer and restart the next title size
            title = true;
            item.delay = motion_time() / 4;
        }
        else
        {
            item.scale = title ? 1.4 : 1.1;
            item.delay = motion_time() / 12;
            title = false;
        }
        result[result.size] = item;
    }
    return result;
}

motion_time()
{
    return 10;
}

fade_time()
{
    return 0.5;
}

instructions()
{
    return "[{+melee}] - Exit Menu Credits";
}
