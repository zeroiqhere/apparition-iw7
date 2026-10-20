// Three numeric client HUD elements retain the original Show Origin layout

positions()
{
    return [(320, 315, 0), (320, 331, 0), (320, 347, 0)];
}

create(owner)
{
    if (!isDefined(owner) || !isPlayer(owner))
        return undefined;
    record = spawnstruct();
    record.elements = [];
    foreach (position in positions())
    {
        // Shared text placement supplies default font, middle alignment and client ownership
        element = scripts\apparition\menu\hud::text(position[0], position[1], "center", 1, (1, 1, 1), 1, owner);
        if (!isDefined(element))
        {
            destroy_record(record);
            return undefined;
        }
        record.elements[record.elements.size] = element;
        element setValue(0);
    }
    return record;
}

paint(record, position)
{
    if (!scripts\apparition\features\show_origin::valid_position(position)
        || !isDefined(record) || !isstruct(record)
        || !isDefined(record.elements) || !isarray(record.elements) || record.elements.size != 3)
        return false;
    // Check every handle before any native numeric update
    for (index = 0; index < 3; index++)
    {
        if (!isDefined(record.elements[index]))
            return false;
    }
    for (index = 0; index < 3; index++)
        record.elements[index] setValue(position[index]);
    return true;
}

destroy_record(record)
{
    if (!isDefined(record) || !isstruct(record)
        || !isDefined(record.elements) || !isarray(record.elements))
        return;
    handles = record.elements;
    // Consume ownership before destroying handles so repeated cleanup sees an empty list
    record.elements = [];
    scripts\apparition\menu\ownership::destroy_elements(handles);
}
