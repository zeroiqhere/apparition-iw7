// Pure arithmetic for the source's bounded incremental sliders

bound(value, minimum, maximum)
{
    // Malformed bounds cannot define a slider range
    if (!isDefined(value) || !isnumber(value)
        || !isDefined(minimum) || !isnumber(minimum)
        || !isDefined(maximum) || !isnumber(maximum)
        || !(minimum <= maximum)
        || !(value >= minimum || value <= maximum))
        return undefined;

    // Source slider creation clamps the live start to its inclusive bounds
    if (value < minimum)
        return minimum;
    if (value > maximum)
        return maximum;
    return value;
}

move(value, direction, minimum, maximum, increment)
{
    if (!isDefined(direction) || !isnumber(direction) || !(direction == 1 || direction == -1)
        || !isDefined(increment) || !isnumber(increment) || !(increment > 0))
        return undefined;

    // Start from the same bounded value that addOptIncSlider initializes
    current = bound(value, minimum, maximum);
    if (!isDefined(current))
        return undefined;

    // Apparition clamps an overshoot to the crossed endpoint before stepping
    if (current < maximum && current + increment > maximum)
        current = maximum;
    else if (current > minimum && current - increment < minimum)
        current = minimum;
    else
        current += direction > 0 ? increment : increment * -1;

    // A step from an endpoint wraps to the opposite inclusive bound
    if (current > maximum)
        return minimum;
    if (current < minimum)
        return maximum;
    return current;
}
