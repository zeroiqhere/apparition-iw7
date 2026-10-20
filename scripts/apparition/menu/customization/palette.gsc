// Each source color keeps its name beside its normalized HUD value

catalog()
{
    return [
        entry("Red", 255, 0, 0), entry("Green", 0, 255, 0), entry("Blue", 0, 0, 255),
        entry("Black", 0, 0, 0), entry("White", 255, 255, 255), entry("Gray", 128, 128, 128),
        entry("Dodger Blue", 57, 152, 254), entry("Ocean Blue", 0, 100, 200), entry("Deep Blue", 0, 0, 139),
        entry("Midnight Blue", 25, 25, 112), entry("Sky Blue", 135, 206, 250), entry("Cyan", 0, 255, 255),
        entry("Aqua", 0, 255, 200), entry("Teal", 0, 128, 128), entry("Pink", 255, 110, 255),
        entry("AIO Pink", 255, 150, 255), entry("Hot Pink", 255, 20, 147), entry("Rose", 255, 102, 204),
        entry("Fuchsia", 255, 0, 255), entry("Purple", 128, 0, 255), entry("Lavender", 200, 162, 255),
        entry("Violet", 238, 130, 238), entry("Indigo", 75, 0, 130), entry("Plasma Purple", 200, 0, 255),
        entry("Neon Purple", 170, 0, 255), entry("Crimson", 220, 20, 60), entry("Fire Red", 255, 30, 30),
        entry("Ruby", 224, 17, 95), entry("Orange", 255, 128, 0), entry("Deep Orange", 255, 80, 0),
        entry("Yellow", 255, 255, 0), entry("Gold", 255, 215, 0), entry("Mint", 152, 255, 152),
        entry("Lime", 150, 255, 0), entry("Toxic Green", 0, 255, 100), entry("Emerald", 0, 201, 87)
    ];
}

entry(name, red, green, blue)
{
    entry = spawnstruct();
    entry.name = name;
    // HUD colors use fractions while the reference catalog uses byte values
    entry.color = (red / 255.0, green / 255.0, blue / 255.0);
    return entry;
}

color(name)
{
    if (!isDefined(name))
        return undefined;
    foreach (entry in catalog())
    {
        if (entry.name == name)
            return entry.color;
    }
    return undefined;
}
