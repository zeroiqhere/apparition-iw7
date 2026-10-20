// Discovery requires one matching native model across the full source-site set

select(models, asset, origins)
{
    selected = undefined;
    foreach (model in models)
    {
        if (!isDefined(model) || !isDefined(model.model) || model.model != asset
            || !isDefined(model.origin))
            continue;
        foreach (origin in origins)
        {
            if (distanceSquared(model.origin, origin) != 0)
                continue;
            if (isDefined(selected))
                return undefined;
            selected = model;
            // Duplicate positions must not count the same model more than once
            break;
        }
    }
    return selected;
}
