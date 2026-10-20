// A fixed version-one record makes restore expectations independent of encoding

record()
{
    return "1|0|85|260|Apparition|Boxes|Right|120|0|0|1|1|0|0|Dodger Blue|+speed_throw,+melee|+speed_throw,+smoke";
}

change(index, value)
{
    fields = strTok(record(), "|");
    fields[index] = value;
    text = "";
    for (position = 0; position < fields.size; position++)
        text += (position == 0 ? "" : "|") + fields[position];
    return text;
}
