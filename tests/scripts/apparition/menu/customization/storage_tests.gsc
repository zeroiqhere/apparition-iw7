// Identity key checks use no native Dvar writes or profile changes

run()
{
    distinct_player_ids_use_distinct_namespaced_keys();
    absent_zero_and_unsafe_ids_cannot_share_an_anonymous_key();
}

distinct_player_ids_use_distinct_namespaced_keys()
{
    first = scripts\apparition\menu\customization\storage::key("76561198000000001");
    second = scripts\apparition\menu\customization\storage::key("76561198000000002");
    tests\support\checks::expect(first == "apparition_iw_settings_76561198000000001", "The player key is scoped to this menu's settings");
    tests\support\checks::expect(second == "apparition_iw_settings_76561198000000002" && first != second, "Different player identities cannot overwrite one settings record");
    tests\support\checks::expect(scripts\apparition\menu\customization\storage::key("ABC123def") == "apparition_iw_settings_ABC123def", "A native alphanumeric identity keeps its exact case and contents");
    tests\support\checks::expect(isDefined(scripts\apparition\menu\customization\storage::key("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789XY")), "The identity length boundary accepts sixty-four safe characters");
}

absent_zero_and_unsafe_ids_cannot_share_an_anonymous_key()
{
    foreach (identity in ["", "0", "0000000000000000", "a b", "a/b", "a|b", "a;b", "a\nb", "a.b", "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789XYZ"])
        tests\support\checks::expect(!isDefined(scripts\apparition\menu\customization\storage::key(identity)), "Invalid identities cannot create a fallback or command-like Dvar name");
    tests\support\checks::expect(!isDefined(scripts\apparition\menu\customization\storage::key(undefined)), "An absent identity cannot persist shared defaults");
    tests\support\checks::expect(!isDefined(scripts\apparition\menu\customization\storage::key(0)), "A non-string identity is rejected");
}
