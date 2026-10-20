// Apparition source by CF4_99, version 1.6.0.9
// Original credits: Extinct, CraftyCritter, ItsFebiven, Joel
// IW7 adaptation uses GSC modules and the existing IW7-Mod script loader

init()
{
    level thread scripts\apparition\runtime\lifecycle::start();
    // The optional observer returns immediately unless its diagnostic Dvar is set
    scripts\apparition\runtime\diagnostics\ammo::start();
}
