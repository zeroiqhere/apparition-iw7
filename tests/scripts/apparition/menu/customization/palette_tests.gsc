// Palette contracts keep source names, order and HUD color values together

run()
{
    palette = scripts\apparition\menu\customization\palette::catalog();
    tests\support\checks::expect(palette.size == 36, "The original 36 named colors remain available");
    tests\support\checks::expect(palette[0].name == "Red" && palette[0].color == (1, 0, 0), "The first source color is normalized Red");
    tests\support\checks::expect(palette[6].name == "Dodger Blue" && palette[6].color == (57 / 255.0, 152 / 255.0, 254 / 255.0), "The default source accent keeps its name and value");
    tests\support\checks::expect(palette[35].name == "Emerald" && palette[35].color == (0, 201 / 255.0, 87 / 255.0), "The final source color keeps its native HUD range");
    tests\support\checks::expect(scripts\apparition\menu\customization\palette::color("Black") == (0, 0, 0), "Black is a valid color rather than a missing result");
    tests\support\checks::expect(!isDefined(scripts\apparition\menu\customization\palette::color("Unknown")), "Unknown theme names have no color");
    tests\support\checks::expect(!isDefined(scripts\apparition\menu\customization\palette::color(undefined)), "A missing theme name has no color");
}
