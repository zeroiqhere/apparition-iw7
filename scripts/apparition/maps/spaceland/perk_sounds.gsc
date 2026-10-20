// Native perk aliases are mapped onto the shared Spaceland machine catalog

aliases(id, solo, voice_prefix)
{
    if (!isDefined(id) || !isString(id) || id == "")
        return undefined;

    // Keep asset spellings from the native perk sound switch
    result = spawnstruct();
    switch (id)
    {
        case "perk_machine_revive":
            result.jingle = "mus_zmb_upnatoms_purchase";
            result.quote = undefined;
            if (isDefined(solo) && isnumber(solo) && (solo == 0 || solo == 1))
                result.quote = solo == 1
                    ? "purchase_perk_revive_solo" : "purchase_perk_upnatoms";
            break;
        case "perk_machine_tough":
            result.jingle = "mus_zmb_tuffnuff_purchase";
            result.quote = "purchase_perk_tuffnuff";
            break;
        case "perk_machine_rat_a_tat":
            result.jingle = "mus_zmb_bangbangs_purchase";
            result.quote = "purchase_perk_bangbangs";
            break;
        case "perk_machine_flash":
            result.jingle = "mus_zmb_quickies_purchase";
            result.quote = "purchase_perk_quickies";
            break;
        case "perk_machine_run":
            result.jingle = "mus_zmb_racinstripes_purchase";
            result.quote = "purchase_perk_racinstripes";
            break;
        case "perk_machine_boom":
            result.jingle = "mus_zmb_bombstoppers_purchase";
            result.quote = "purchase_perk_bombstoppers";
            break;
        case "perk_machine_more":
            result.jingle = "mus_zmb_mulemunchies_purchase";
            result.quote = "purchase_perk_nulemunchies";
            break;
        case "perk_machine_zap":
            result.jingle = "mus_zmb_bluebolts_purchase";
            result.quote = "purchase_perk_bluebolts";
            break;
        case "perk_machine_fwoosh":
            result.jingle = "mus_zmb_trailblazer_purchase";
            result.quote = "purchase_perk_trailblazers";
            break;
        case "perk_machine_smack":
            result.jingle = "mus_zmb_slappytaffy_purchase";
            result.quote = "purchase_perk_slappytaffy";
            break;
    }
    if (!isDefined(result.jingle))
        return undefined;

    // Only quotes use the native character prefix
    if (isDefined(result.quote) && isDefined(voice_prefix)
        && isString(voice_prefix) && voice_prefix != "")
        result.quote = voice_prefix + result.quote;
    else
        result.quote = undefined;
    return result;
}

inspect(state, solo, voice_prefix)
{
    result = spawnstruct();
    result.reason = "Wait for native perk sound machines";
    result.entries = [];

    // The native map registry must be ready before any rows can be trusted
    if (!isDefined(state) || !isDefined(state.struct_class_names)
        || !isArray(state.struct_class_names))
        return result;
    groups = state.struct_class_names["script_noteworthy"];
    if (!isDefined(groups) || !isArray(groups))
        return result;

    entries = [];
    foreach (perk in scripts\apparition\maps\spaceland\perks::catalog())
    {
        machines = groups[perk.id];
        if (!isDefined(machines))
            continue;
        if (!isArray(machines))
            return result;
        if (!machines.size)
            continue;

        // Validate every native index before publishing this perk row
        for (index = 0; index < machines.size; index++)
        {
            machine = machines[index];
            if (!isDefined(machine) || !isStruct(machine)
                || !isDefined(machine.script_noteworthy)
                || !isString(machine.script_noteworthy)
                || machine.script_noteworthy != perk.id)
                return result;
        }

        sound = aliases(perk.id, solo, voice_prefix);
        if (!isDefined(sound))
            return result;
        row = spawnstruct();
        row.id = perk.id;
        row.label = perk.label;
        row.jingle = sound.jingle;
        row.quote = sound.quote;
        entries[entries.size] = row;
    }

    // Only a complete validation pass can publish menu data
    result.reason = "";
    result.entries = entries;
    return result;
}
