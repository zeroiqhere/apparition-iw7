// Isolated command snapshots share the production command catalog

buttons()
{
    buttons = [];
    foreach (command in scripts\apparition\menu\customization\bindings::catalog())
        buttons[command] = false;
    return buttons;
}
