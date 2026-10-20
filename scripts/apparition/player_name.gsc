// Player names share one source formatting-token cleanup across all controls

clean(name)
{
    if (!isDefined(name) || !isstring(name))
        return "";

    tokens = ["^A", "^B", "^F", "^H", "^I", "^0", "^1", "^2", "^3", "^4",
        "^5", "^6", "^7", "^8", "^9", "j="];
    cleaned = "";
    index = 0;
    while (index < name.size)
    {
        // Consume both characters of a format token and keep scanning adjacent input
        if (index + 1 < name.size
            && scripts\engine\utility::array_contains(tokens, getSubStr(name, index, index + 2)))
        {
            index += 2;
            continue;
        }

        cleaned += getSubStr(name, index, index + 1);
        index++;
    }
    return cleaned;
}
