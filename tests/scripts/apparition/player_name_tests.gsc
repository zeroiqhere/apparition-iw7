// Shared player-name cleanup follows the source formatting-token catalog

run()
{
    clean_name_removes_color_tokens_without_skipping_adjacent_text();
    unknown_tokens_and_incomplete_suffixes_remain_visible();
}

clean_name_removes_color_tokens_without_skipping_adjacent_text()
{
    tests\support\checks::expect(scripts\apparition\player_name::clean("^A^B^F^H^I^0^1^2^3^4^5^6^7^8^9j=") == "",
        "Every original two-character formatting token is removed");
    tests\support\checks::expect(scripts\apparition\player_name::clean("^A^BPlayer^9") == "Player",
        "Adjacent formatting tokens do not remove the first following name character");
    tests\support\checks::expect(scripts\apparition\player_name::clean("A^B^FZ") == "AZ",
        "Formatting tokens between visible characters are removed");
    tests\support\checks::expect(scripts\apparition\player_name::clean("PlainName") == "PlainName",
        "A name without formatting remains unchanged");
    tests\support\checks::expect(scripts\apparition\player_name::clean(undefined) == "",
        "An unavailable player name cleans to empty");
    tests\support\checks::expect(scripts\apparition\player_name::clean(7) == "",
        "A non-string player name is rejected");
}

unknown_tokens_and_incomplete_suffixes_remain_visible()
{
    tests\support\checks::expect(scripts\apparition\player_name::clean("^Z^aJ=Name^") == "^Z^aJ=Name^",
        "Only exact source tokens are removed and a trailing caret remains visible");
    tests\support\checks::expect(scripts\apparition\player_name::clean("") == "",
        "An empty name stays empty for caller-specific display fallback");
}
