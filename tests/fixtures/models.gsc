// Model fixtures expose only the fields read by native model discovery

model(asset, origin)
{
    model = spawnstruct();
    model.model = asset;
    model.origin = origin;
    return model;
}
