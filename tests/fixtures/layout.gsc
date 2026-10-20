// Valid applied preferences supply each distinct source viewport size

for_capacity(capacity)
{
    layout = scripts\apparition\menu\layout::defaults();
    layout.bool_display = capacity == 5 || capacity == 12 || capacity == 14 ? "Text" : "Boxes";
    layout.stealth_ui = capacity == 5;
    layout.option_counter = capacity == 8 || capacity == 9;
    layout.disable_instructions = capacity == 9 || capacity == 11 || capacity == 14;
    return layout;
}
