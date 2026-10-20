# Apparition IW7

A GSC adaptation of [CF4x99's Apparition](https://github.com/CF4x99/Apparition)
for Steam Infinite Warfare, starting with private, normal Zombies in Spaceland.

**Current snapshot: `bfcb3d12`. This is an unfinished test candidate.**
Native gameplay, HUD rendering, input, co-op behavior and full 1:1 parity have
not been verified in the game. Freeze and several original controls remain
unavailable. No custom DLL injector or external live-memory reader is included.

## Current scope

- Personal and current-lobby God Mode, ammo modes, perk controls and perk retention
- Host verification before guests can open the menu
- Spaceland quest-stage controls and assistance, with completion based on native progress
- Apparition-style menus, customization, selected-player controls and text input
- Optional, bounded host ammo/inventory observations for later game testing

The default menu chord is **hold ADS and press Melee**. The text keyboard retains
**Frag to add a space**; native game input, including grenade handling, remains active.
Lobby Down and All Players Teleport exclude only the current host. Insta-Kill
retains protections for special enemies.

## Install and test

Use an IW7-compatible script loader such as
[IW7-Mod](https://github.com/auroramod/iw7-mod). GSC Tool is a compiler, not a loader.
The BO3 injector and BO3-compiled Apparition script are incompatible with IW7.

The packaged Linux/Steam loader is available with the
[test-candidate downloads](https://github.com/zeroiqhere/apparition-iw7/releases).
Follow its `START_HERE.txt`; close the game before changing installed scripts,
and start with a fresh solo private Spaceland match. Existing managed installs
must be removed before installing a different package.

For source deployment, keep `custom_scripts/cp/apparition.gsc` and the complete
`scripts/apparition/` tree together under the loader's script root. Do not install
the `tests/` tree as an additional auto-starting game script. Avoid loading other
CP menu entries alongside this candidate.

Optional trace startup options:

```text
+set apparition_trace_ammo 1
```

Value `1` enables ammo observations; `2` adds bounded inventory details; `0` disables
tracing. The observer is off by default. These are script-visible observations,
not external game-memory reads. Detailed limits and interpretation are in
[README.txt](README.txt).

## Source and checks

| Path | Contents |
| --- | --- |
| `custom_scripts/cp/` | Single CP menu entry point |
| `scripts/apparition/` | 186 supporting production GSC modules |
| `tests/` | 189 GSC test files, including the optional contract runner |
| [CHECK_RESULTS.txt](CHECK_RESULTS.txt) | Compilation records and source hashes |
| [PORTING_NOTES.txt](PORTING_NOTES.txt) | Implementation evidence and known gaps |
| [README.txt](README.txt) | Detailed controls and feature limits |

The snapshot contains **376 GSC files**: 187 production files and 189 test files.
Normal/developer compilation and disassembly passed with GSC Tool 1.6.1.363.
Its 172 registered suites contain 4,928 retained assertion sites; **these GSC
assertions have not run in the game VM**. Separately, 105 local Python checks for
deployment and source validation passed. Their supporting research workspace is
not bundled in this GSC source repository.

## Credits

Original Apparition: **CF4_99 / CF4x99**, version 1.6.0.9.
Original contributors credited by the author: **Extinct, CraftyCritter,
ItsFebiven and Joel**. See [NOTICE.txt](NOTICE.txt).

This repository is an Infinite Warfare adaptation and is not an official
release by the original Apparition author. No new license grant is asserted
for upstream material.
