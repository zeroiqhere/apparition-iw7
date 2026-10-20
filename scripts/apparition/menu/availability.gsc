// Slider choices share one readiness contract across input and display

choice_reason(row, value)
{
    if (!isDefined(row) || !isstruct(row))
        return "Wait for choice availability";
    if (isDefined(row.range) && (!isDefined(value) || !isnumber(value)))
        return "Wait for a valid numeric preview";
    // Rows without a choice map retain their original command behavior
    if (!isDefined(row.choice_reasons))
        return "";
    reasons = row.choice_reasons;
    if (!isarray(reasons) || !isDefined(row.values) || !isarray(row.values)
        || !isDefined(value))
        return "Wait for choice availability";
    key = value;
    if (isnumber(value))
    {
        // Strict bounds precede the one conversion to a nonnegative integer map key
        if (!(value >= 0 && value < 2147483647))
            return "Wait for choice availability";
        key = int(value);
        if (key != value)
            return "Wait for choice availability";
    }
    else if (!isstring(value))
        return "Wait for choice availability";
    if (!scripts\engine\utility::array_contains(row.values, value))
        return "Wait for choice availability";
    if (!isDefined(reasons[key]) || !isstring(reasons[key]))
        return "Wait for choice availability";
    return reasons[key];
}

description(row, value)
{
    if (!isDefined(row) || !isstruct(row)
        || !isDefined(row.enabled)
        || !isDefined(row.description) || !isstring(row.description))
        return "Wait for choice availability";
    // A row-level block remains more important than any individual choice
    if (!row.enabled)
        return row.description;
    reason = choice_reason(row, value);
    if (reason != "")
        return reason;
    return row.description;
}
