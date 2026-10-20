Apparition IW7 - GSC source candidate

The downloaded official Linux GSC Tool 1.6.1 is working. This package contains
GSC source only for the menu and its tests; no native injector or replacement
loader is included. The default Apparition style and priority feature bindings
are implemented as a source candidate. Runtime behavior and full 1:1 parity
are not established. Read PORTING_NOTES.txt for concrete limits and evidence.

No game files have been changed and no game has been launched for this work.

Zombie Options > Invisibility now requests the source's broad enemy hide policy.
Only the current host can configure it. While enabled, a level-owned worker
queries all living Axis agents every 0.5 seconds and requests Hide(1) for active
agents, including special enemies and quest agents. The stock IW7 query handles
the living/team selection. Turning it off stops that worker and requests Show()
for the current living active Axis agents; earlier visibility is not restored.
The checkbox records configuration rather than measured rendering. The global
setting continues through menu closure and host life changes. Ending the level
stops enforcement without changing terminal enemy visibility. The native Hide(1)
argument uses IW7's stock call shape; its live Axis effect, visuals, replication
and co-op remain untested. It does not freeze enemies or change their damage,
health, movement, collision, spawning or quest progress.

God Mode, All Perks, individual perks and Retain Perks now describe the next
Use action. An unchecked mixed lobby setting enables or grants the selection
for the whole current roster; a fully checked selection disables or removes it.
Each perk uses its own ownership check. Disabling Retain Perks discards saved
snapshots and stops future restoration without removing currently owned perks.
Permission, native readiness and callback-loss messages still take precedence.
These are descriptions of the existing actions, not new gameplay behavior.

Text keyboards and Health Custom's numberpad now reshape the existing main menu
scroller, matching Apparition's entry sequence. The requested timing is a 100ms
resize, a 10ms move, then a 500ms input settle; native color fade starts after the
resize. Input stays paused until setup finishes. Close, death or access changes
retire that captured entry before further HUD work. The main HUD alone owns the
scroller, while the modal owns its key labels. Native animation and failure paths
remain untested. Text typing still uses Frag-to-space with native input active.

Down now explicitly states that it clears both God Mode and Demi-God before
requesting native damage. Native protection may still block the request. This
wording applies to the personal Death slider and lobby Down control.

Zombie Options > Health > Custom now opens the source ten-digit numberpad.
Action slots 3/4 scroll, Use selects a digit, Jump confirms, and Melee backspaces
or cancels zero. Numeric confirmation accepts zero; text keyboards still cancel
empty input and retain Frag-to-space. Values above 2147483647 stay editable with
an error instead of wrapping. Native game controls remain active while editing.

Only the living native host in private normal Spaceland can queue Custom Health.
After the source 0.1-second gap, it requests health and maximum health for current
active living Axis agents whose maximum differs from the number. Future coverage
is narrower: base generic zombies receive one deferred request after stock setup.
This does not continually enforce health or promise to beat later quest writers.
The menu displays the configured request, not a measured health success result.
Host disconnect/game end retire the owned callback; cleanup does not restore
current health. Reset remains unavailable while its IW7 special-enemy semantics
are unresolved. Native health, spawning, special enemies, input and co-op remain
untested. Start with a fresh solo custom match when testing this candidate.

Weaponry > Options > Take Current Weapon now requests removal of the selected
player's freshly held weapon. The main Weaponry link starts at VIP; Co-Host and
Host can also open it through selected-player Options. Base melee and names
containing _knife are preserved. IW7 temporary inventory owners, native switching
and linkage, and unfinished loadout initialization block the action with a reason.
It invokes stock Last Stand bookkeeping after removal without granting a fallback
weapon. The held name shown in the description is a snapshot; Use resolves the
current weapon again. Take All, Drop, Pack-a-Punch and weapon customization remain
unavailable. Native removal, active-slot behavior and co-op are untested.

Host Menu > Show Origin now displays live X, Y and Z values using the source's
three white numeric rows at x320, y315/331/347. It stays on through death and menu
closure. Use turns it off. Only the current native host in private normal
Spaceland can enable it; host/session loss or unreadable coordinates retire it.
Other host controls without a verified binding stay unavailable. Native placement, float formatting,
HUD persistence and co-op have not been tested. This uses script-visible player
coordinates, not an external live-memory reader.

Players Menu > Options > Send Message and All Players Menu > Send Message now
use that keyboard too. Selected-player messages go only to the current selected
recipient. All Players messages go to the current roster except the sender,
including the host. Both use Apparition's green sender-name prefix and require
Co-Host or Host access. They do not depend on Message Menu Display Type. A changed
recipient, departed player, lost access or replacement verification grant stops
stale keyboard work before delivery. An All Players message is unavailable solo.
Native per-client display and co-op delivery remain untested.

Custom Message and Doheart > Text > Custom now open the source keyboard.
It keeps the 13-column, six-row alphabet, 45-character limit and Frag-to-space
control. Action slots scroll, Use selects, Jump confirms, and Melee backspaces
or cancels empty input. Empty confirmation also cancels. Custom Message requires
Print Bold as the applied Display Type. Doheart confirmation preserves its current
role/style checks and allocation-before-replacement behavior. Cancel leaves the
consumer's text unchanged. Native game controls remain active during typing,
including grenade handling, as requested. Input, rendering and co-op are untested.

Basic Scripts > Set Vision now supports Default and IW7 analogues for
zombie_last_stand and zombie_noire. All ten source choices keep their original
order; the other seven show an unavailable reason. Default restores the current
game-owned base override, or the native empty-profile reset. Each Use submits
one request for the selected player. There is no saved-mode checkbox or active
profile claim; native events can replace the effect. Last Stand, Afterlife,
Ghosts N Skulls and worn Dischord glasses block changes. Native script references
and compilation are checked; profile rendering and BO3 visual parity are untested.

Menu refresh now reads feature data only for the page being rebuilt. A fresh
common view keeps player, access and layout data together, then one page dispatcher
fills the controls that use it. Main and customization pages no longer request
unrelated perk, quest or pickup snapshots. Quick Menu life behavior and shared
portal/quest readiness are preserved. Gameplay callbacks and worker lifetimes
are unchanged. Compilation and source checks pass; lower frame cost and native
GUI behavior have not been measured in the game.

Server Modifications opens from its source main-menu position. Low Gravity,
Super Speed, Timescale, Auto-Revive, Newsbar and End Game accept current Co-Host
and Host access, matching the reference. Lobby Timer and Doheart use the same
current-role admission. Every selection rechecks private-session membership
and verification. The 22 source labels stay in physical order. Lobby Timer Options opens its two source
controls and Doheart Options opens its three controls; the other 14 entries remain
unavailable. The three
conditional visibility rules for Mystery Box Options, Craftables and Zombie
Traps are still unported, so those entries are explicit unavailable candidates.

Doheart retains the source Co-Host and Host permission for its global HUD.
Entering its page captures missing defaults once: Pulsing and the current host's
cleaned name. Stored text stays captured after host changes; the first text
choice follows the current host. Changing a choice while off only saves it.
While on, a changed choice replaces the display, with allocation failure leaving
the old one intact. Selecting the same value does nothing. Both sliders start
their preview at the first source choice; the footer shows the saved choice.
Pulsing, Moving and Fade Effect retain their source sequences. Pulse Effect and
Type Writer stay visible but unavailable. Custom text uses the source keyboard.
The global text uses
explicit IW7 origins, so font metrics, pixels, animation, archive behavior and
co-op recipients still require game testing. This is a partial Doheart port.

Lobby Timer Options keeps the 1-30 minute choices and ten-minute default.
Enabling starts a countdown for the players present at activation. Applying a
duration while enabled restarts the full countdown, including the same value.
The timer continues after menu close or the enabling player's death/disconnect.
At expiry it resolves the current host and requests native game end once. A
rejected request leaves the setting on with Expired/error status and no retry.
Use can turn it off; a duration selection can restart it when ready. Countdown
text uses an explicit lower-left IW7 HUD adaptation. Rendering, timing, co-op
recipients and actual terminal behavior remain untested; no game was ended.

Newsbar now uses one global native HUD pair and a level-owned message worker.
It keeps the reference bar/text dimensions, colors and animation sequence, and
captures the actual current host name when enabled, including by a Co-Host. It continues through menu close or host
death/disconnect; switching it off releases both elements before stopping the
worker. Game-end cleanup releases them independently. The opening hint refers
to host verification and saved controls because players can choose different
chords. Explicit IW7 left/top screen origins are an adaptation; exact placement,
fonts, animation, archived-HUD behavior and co-op recipients remain untested.

Low Gravity and Super Speed keep the original startup-baseline toggle. The menu
captures the readable session values once before player attachment. Selection
sets gravity to 200 or speed to 500 when the current value equals that starting
value; any other current value selects the captured starting value. The footer
shows the exact next value. No default 800 or 190 is assumed, and neither setting
resets on menu close. Missing startup data disables the control; a starting
value already equal to the preset has no alternate value and is also disabled.
Checkboxes still show the current native target state when a baseline is missing.
IW7 gravity is captured as a float, preserving fractional starting values; this
intentionally differs from the reference's integer gravity reads. Speed uses
the native integer getter. Engine movement and co-op replication remain untested.

End Game requests the registered native host-end callback for all players in
the private game. Native code owns the usual game-over, score, intermission and
exit sequence. The row is available only after current Co-Host/Host admission and native
callback, reason-table, agent-registry and clock readiness. It has no completion
checkbox and carries no saved native callback pointer. The installed base and
patch bytecode were inspected offline; no terminal request has run in the game.

Auto-Revive is a global setting for current and future players, including the
host. Its level-owned worker survives menu closure and host down, reads the
current roster each pass, and uses the existing guarded native revive request.
Temporary roster or native revive unavailability pauses requests. An enabled
setting can still be turned off during a native pause. Turning it off stops
future requests; it cannot reverse a native revive already submitted. Unsupported
sessions and game end retire the worker. The checkbox reports configuration,
not a confirmed revival. The source wait of 0.1 game seconds is retained; its
wall-clock cadence, host-down behavior, joins and native revives remain untested.

Timescale retains the source choices from 0.5x to 5x in 0.5 steps, with 1x normal.
The row shows the current native float separately from the slider preview. Use
applies the preview after a fresh role/session check; unchanged values cause no write.
A live value outside the choices stays visible and a fresh preview defaults
to 1x. An explicitly moved preview follows the menu's existing saved-preview
behavior across rebuilds and reopen. Readback checks the requested dvar value;
actual game speed, client replication and persistence remain untested. Closing
the menu does not restore an earlier timescale.

Collect DJ Parts now uses one fresh native readiness check from both Spaceland
Scripts and the first UFO quest stage. Pending collection requires the native
fetch stage, a current living host, the complete current player roster and all
remaining model bindings. Invalid later data prevents the batch from starting.
The existing native pickup routine still owns part flags, model cleanup, quest
icons and any normal sticker achievement progress. Sampled counts and rejection
reasons replace the old readiness aliases; gameplay remains untested.

Spaceland Scripts now starts with Turn On Power. A living current host can request
the remaining native generators remotely in sequence. Each stock callback finishes
before the next generator is admitted. The row stays unchecked until every current
native generator reports powered; it never offers power-off. Closing the menu leaves
an already-started callback running. A later loss of authority or native readiness
stops further submissions and may leave partial progress. Native animation, timing,
gameplay and co-op behavior still require game testing.

The UFO progress reader now validates native registry/table/entry shapes and
bounded whole-number stage indices before lookup. Invalid data keeps the full
twelve-stage page visible with actions unavailable and no completion claims.
Final completion also requires a readable native flag array. These reader and
GUI contracts compile; their assertions and native behavior remain unrun.

Shared player admission now checks every numeric slot in a selected list.
Missing slots and named-only player maps are rejected before any feature work;
dense personal/lobby lists retain their existing behavior. The opt-in regression
uses one read-only native player reference and local proposed lists. It waits
up to ten seconds for a player, then records a test failure if none is available.
The regression has compiled but has not run in the game VM.

Fun Scripts

VIP, Admin, Co-Host and native Host roles can open Fun Scripts from the main
menu. A Co-Host can also open it for a selected non-Host player through Players
-> Options. The page keeps its source labels and order; Earthquake, Insta-Kill,
Health Bar, Frog Jump and the perk-sound branch of Sounds & Jingles are source
candidates. The other controls remain unavailable.

Insta-Kill keeps Disable, All and Melee at the seventh source Fun position.
Use applies the preview to the selected player; the configured mode is displayed
separately. All affects accepted outgoing enemy damage, while Melee requires the
native MOD_MELEE damage method. Brute and Grey protections are preserved, as
requested. Native rejection, armor and protected-phase checks still apply.

The setting survives menu closure and death. Each accepted callback rechecks the
requester and the original verification grant. A lost grant leaves the saved mode
inert until a fresh authorized application captures the current grant. Enabling
is blocked if another callback owns the optional native slot. Disable stays
available to clear
the saved setting after hook loss. The row reports configured intent rather than
confirmed kills; downstream native damage scaling can leave a hit unchanged.
No timed lobby power-up is substituted. Actual callback receiver behavior,
damage, scoring, quest progression and co-op lifetime require game testing.

Earthquake requests one global camera effect at the selected player's current
position, using Apparition's strength 1, duration 15 seconds and radius 750.
Nearby players may feel it too. Selection rechecks current verification, role,
target permission and position; the row carries no cached coordinates or active
checkbox. Closing the menu does not cancel the native timed request. The return
means submitted, with no confirmation of client visibility or reach. Repeated
requests, attenuation, timing and co-op display remain untested in the game.

Health Bar toggles a display for the selected player. It reads current native
health and maximum health, uses the original black border and white fill, and
caps the bar at 150 pixels using Apparition's proportional width formula. At
1 health out of 200 the source rounds fill to zero; the native adapter hides
that fill rather than sending a zero-width shader. No combat values change.

The bar uses an adapted native lower-left anchor, 24 units from the left and
60 above the bottom; original LUI pixel placement has not been reproduced.
The configured checkbox reports the owned display record, not confirmed client
visibility. Closing the mod menu keeps the bar; Use removes it. Observed death,
unreadable health, missing handles, unsupported session, disconnect and game end
retire its owned HUD pair. It does not return automatically after respawn.
Last stand is not excluded by the source life rule. Actual HUD rendering,
resolution/safe-area placement, stock-HUD overlap and co-op lifetime are untested.

Frog Jump uses the selected player's held Jump command while alive, airborne
and standing. It replaces velocity with view-forward X/Y times550 and Z400,
then waits for landing before another boost. Looking up or down reduces the
horizontal part as in the source. This differs from Multi-Jump's release-driven
vertical addition. Both controls share one per-player command receipt.

Its checkbox reports configured intent. Use cancels the worker immediately,
including while waiting for landing; it does not undo momentum already applied.
The setting survives menu closure and death, resuming when the source conditions
are met after respawn. Native slide, launch, ride, arcade, portal, link and phase
ownership can pause boosting. A native teleport-disable counter also pauses it,
covering geyser launch after its temporary flung marker expires. Loss of the
requester's original verification or
permission retires the grant. Native command registration, an already-held Jump
at registration, movement strength, co-op timing and movement-owner coverage
remain untested in-game. No teleport-enabled flag is treated as jump readiness.

Disable Earning Points and Points Multiplier remain unavailable. The inspected
IW7 currency callback cannot distinguish damage awards from refunds, ATM payouts
and other grants; using it would change the original controls' scope.

Rapid Fire remains unavailable. Native scripts show generic bullets and separate
player-attributed projectiles, but do not establish the combined current-player
weapon, muzzle and shot-event behavior needed by Apparition's repeated-shot loop.
The row explains that gap. No approximate firing toggle is exposed.

Earthquake, Health Bar and Frog Jump now share the same current actor, private
session, verification and VIP policy. Frog's continuous worker also rechecks its
original grant through that shared policy before reading input or moving.

Sounds & Jingles -> Perk Jingles & Quotes offers separate Jingle and Quote
requests for the ten supported perk types that have placed native machines.
Repeated machines produce one pair of rows, using the shared Spaceland perk
order. Each sound has its own readiness reason; a missing current character
voice can disable the quote while leaving the jingle available.

Selection resolves the current machine registry, selected player's voice,
solo/co-op revive quote and loaded sound alias again. It submits one native
sound on that player, preserving the original completion event name. Nearby
players may hear it. The action does not purchase a perk, alter currency or
request the native purchase routine's delayed follow-up quote. Closing the menu
does not stop a submitted sound, and the GUI shows no playing checkbox.

Sound actions use the same private-session, current verification, VIP and target
permission policy as the other Fun controls. Original general dialogue categories
remain unavailable until their Infinite Warfare mapping is established. Native
alias availability, audibility, completion events and repeated/co-op playback
remain untested in the game; successful submission does not confirm playback.

Zombie Counter remains unavailable. IW7 uses different regular-wave, reserved,
UFO and ghost accounting, and the original counter helper is absent from the
reference repository. Existing native wave/death status is not relabeled as
an exact Alive or Remaining For Round counter.

Files

custom_scripts/cp/apparition.gsc    IW7-Mod init entry point
scripts/apparition/menu/           Menu rows, input, navigation state and HUD
scripts/apparition/menu/customization/  Palette, preferences, bindings and settings storage
scripts/apparition/features/       Damage protection, ammo, movement, visibility, perks and revive
scripts/apparition/maps/spaceland/ Perks, UFO stages and native interactions
scripts/apparition/runtime/        Session guards, damage hook and lifecycle
tests/                            Separate opt-in GSC contract suite

Zombie Options

Zombie Options now follows Apparition's thirty-entry Spaceland layout. Kill
retains Death, Head Gib, Flame and Delete in source order. Death requests one
native damage pass over currently tracked, eligible ordinary zombies and clowns.
The host must be alive and out of last stand. Each target is rechecked before
its packet; reserved, protected, untracked, malformed or unknown-type actors are
excluded. Newly spawned enemies require a later request.

Movement retains Walk, Run, Sprint and Super Sprint in source order. The first
three choices submit a native mode request for current eligible ordinary zombies
and clowns. Super Sprint remains unavailable without a verified native mapping.
Locked, traversing, frozen, reserved, suicide-bomber and crawler actors are skipped;
special or uninitialized agents are excluded. Later spawns require another request.
Native movement callbacks and temporary effects can replace the requested mode,
so the slider has no global active-mode indicator. Actual movement and retention
remain untested in the game.

The footer describes requests rather than confirmed kills. IW7 still handles
accepted damage, death effects, scoring, drops, wave counters and quest listeners.
The host is supplied as attacker to keep clowns on their native player-attributed
death path. Native protection may reject damage. Head Gib, Flame, Delete and
the other unmapped zombie controls stay unavailable. Freeze retains its original
source position and an explanation that a reversible native binding is unresolved.
This pass has compiled and static coverage; gameplay and assertions remain unrun.

The installed base and patch scripts now confirm the speaker assist's exact
target field. This strengthens the native binding evidence without changing its
actions. The temporary native cryo helper was also inspected; its timer and
default-state reset do not provide a persistent reversible Freeze toggle.
No game was launched for these read-only checks.

Basic Scripts target checks

Movement Speed, Invisibility, Disable HUD, Multi-Jump, Shoot While Sprinting
and No Explosive Damage now check the shared target admission result before
reading saved state or calling the CP perk helper. A rejected target stays
unchecked, or Unknown for Movement Speed, with the current rejection reason.
Rendering never clears the rejected player's saved settings. Existing valid
actor behavior and damage-hook-loss cleanup remain unchanged.

Noclip and UFO Mode remain unavailable. Stock Spaceland grenade code has a
direct offhand lock outside the shared wrapper counters. Flight cleanup cannot
safely identify that lock through the available getters. The draft is withheld
rather than risking an unrelated lock being enabled. Source bindings were
investigated; no flight worker, anchor, weapon lease or menu lock is shipped.

Message Menu

Verified players can open Message Menu, select Print Bold under Display Type,
then send the original Miscellaneous and Advertisements presets to the private
lobby. Names are cleaned and resolved again when sending; Host uses the current
native host. The owner-name row retains its selection when that name changes.
Deranked sends text only. The original BO3 advertisement wording and credits
are retained, with an explanatory footer before sending.

Notify remains the source default but is unavailable until its typewriter
binding is established. Previewing Print Bold does not apply it; Use saves the
setting. Custom Message uses the source keyboard; the BO3 vial icon remains unavailable. The native
bold-text request has no delivery receipt; game display and co-op behavior
remain untested. No message queue or external messaging is added.
The source keyboard uses Frag for spaces, which can also reach stock grenade
handling. The requested binding is retained without changing native input state.

Menu Credits

Menu Customization -> Menu Credits now opens the original scrolling roll.
It retains all 26 entries, including the BO3 wording, original contributors,
title sizes, blank pauses and ten-second movement. The 220-pixel panel follows
the applied position, width and design; ordinary rows and the scroller are hidden.
Melee exits. Completion returns to Menu Customization after the producer's
actual final wait. The instruction guide shows the source exit prompt when enabled.

Each roll belongs to one owner, navigation session, HUD and exact access grant.
Closing, death or changed access retires its text handles before stopping its
threads. Reopening cannot restart a saved Credits page. Native font rendering,
animation, scheduling, input and visual parity still require game testing.

Menu verification

Guests start at None and cannot open either menu until the current host grants
access. The host uses Players Menu -> a player -> Verification, then selects
Verified, VIP, Admin or Co-Host. None revokes access. All Players Menu ->
Verification applies the selected level to eligible current guests through the
same guarded setter. Bots and the current host cannot be assigned a guest level.
Each changed grant notifies its recipient. Grants last for this session;
Save Verification remains visibly unavailable.

Main navigation follows Apparition's Verified, VIP, Admin and Co-Host groups.
Co-Host can open Players and All Players, then use Basic Scripts, Teleport and
Fun Scripts for current non-Host targets. A selected native Host remains
protected. The source lobby God Mode action includes the native Host; Down,
Teleport and Revive cover current players other than the native Host, including
a Co-Host requester. Crosshairs processes an included requester last. Appended
lobby Ammo, Equipment, Perks and Retain Perks, Verification, and unrelated
world/EE actions remain native-Host-only. These Co-Host controls do not change
the native-host identity used by other actions. Guests remain at None until the
current Host grants a session role. Developer identity and privileges remain
unported; no developer IDs are used.

Changing menu access does not add rollback for target-owned God/Ammo flags, Perk
ownership or Retain Perks settings; each keeps its feature-defined lifetime.
Grant-bound workers recheck the captured grant and current personal authority.
Any role change closes the old menu and clears both navigation histories. Input,
reopening and queued callbacks check current access again. Each callback keeps
the exact grant reference and is rejected after a changed grant, even if access
is restored to the same level. Revocation also stops the requester's Teleport
Gun input. Host-applied effects on an unverified guest remain separate from
menu access. Co-Host UI and permission checks compile, but GSC assertions,
native injection, game behavior, co-op scheduling and full 1:1 parity remain
unverified.

Players and Options show the current access label and cleaned player name.
Formatting-only or unavailable names display Unnamed Player. The selected row
follows its player reference across duplicate names, renames, role changes and
roster reordering. A departed selected actor cannot supply an Options title.
These are compiled source contracts; native identity, co-op access and visual
acceptance still require the game's runtime.

Opening appearance

Main and Quick menu options now request Apparition's source opening fade.
The first visible row appears immediately; later rows fade together over
visible-index times 0.1 seconds, up to 0.9 seconds in the default ten-row view.
The main menu retains the source 50 ms opening delay; Quick has no such delay.
Access and the exact guest grant are rechecked after the main delay. Passive
snapshots wait until the longest opening fade ends, while direct input remains
available. Chrome and scroller movement use their existing separate paths.
Native interpolation, rapid page/editor/cursor transitions during a fade and
exact visual fidelity remain untested.

Up/down now requests Large Cursor scale and spotlight-opacity transitions using
Scroll Animation Time. A one-row viewport shift keeps each retained option on
its existing HUD group, moves it one row, and fades the entering/leaving edges.
Visible row groups create a fresh incoming group at each admitted edge shift.
The outgoing group is destroyed after its fade, or immediately at zero duration.
Fresh row count and identity checks reject changed menus; long-page wraps request immediate redraw instead.
Position, scale and opacity target caches prevent passive redraws from reissuing
unchanged native transitions. Cleanup and repositioning traverse current groups;
an older retirement timer cannot destroy a replacement group or a closed HUD.
Full option redraws destroy previous groups and allocate only the current visible
count. Editors release option groups and reposition the remaining owned elements.
Cursor text color and spotlight opacity now share one native fade request.
Opening/entering styles request immediate colors before opacity fades; rainbow
samples update colors without reissuing opacity. Named theme changes retain
separate text and checked-fill durations. Exact interruption behavior and final
visual fidelity remain unverified. Page navigation redraws option groups while
slider/status updates retain matching groups. Boolean selections schedule the
source 180 ms redraw independently of callback completion; a changed or closed
session rejects it. Theme callbacks first retarget colors using the old option
snapshot, then the timer rebuilds current checkbox values. The passive monitor
waits through that interval. A page callback does not trigger a second render.

Design changes and Option Counter now recreate the full main HUD with the
opening animation. Stealth UI also reopens when it clears an active counter.
Selecting the existing design keeps its HUD. Editor exit
recreates the full HUD without option fades, followed by the source 100 ms hold.
One cancellable opening request rechecks the session, page, target, access and
exact grant after the main 50 ms delay. Closing cancels pending allocation.
Delayed refreshes capture the exact HUD; successful Counter and Stealth callbacks
retain their own bool timer through a replacement. Each option now owns only its
present label, value or checkbox elements. Blank spacer rows also own a native
accent line. Movement, styling, cleanup and repositioning use that same handle
map; a changed display shape requires a fresh draw. Spacer opacity preserves the
source's different opening, entering and retained-row targets. Named themes fade
its color, while rainbow samples update it directly. No animation or GSC assertion
ran in-game. Directional input now skips ordinary blank spacers with the source
half-scroll wait, while keeping its long-wrap and viewport-edge redraw exceptions.
Opening and rebuilds keep their saved cursor, including blank rows. Short wraps
use a defined viewport; an all-blank short page cannot recurse indefinitely.
Each wait rechecks the exact menu, HUD, ordered row objects, cursor and authorization before
continuing. Outgoing rows keep their fade timer through an option redraw.
Verified visual parity remains unfinished.

Personal God Mode, Unlimited Ammo, Unlimited Equipment and perk/retention
controls now use the same captured target policy as dispatch. A departed or
unauthorized remote target is unavailable before its settings are read. This
keeps the page from presenting an action that dispatch must reject. Own-player
settings retain the same self-target allowance. Valid dead players can still
configure future ammo, equipment and retention; immediate perk changes keep their
life/callback requirements. Rendering never clears the rejected player's settings.
Immediate personal and lobby perk changes also wait until every selected player
is out of last stand. Ownership checkboxes remain readable, and future retention
can still be configured while down. Native perk callbacks can change health and
self-revive data, so their admission is stricter than the menu's life predicate.

Source bindings

Personal and Co-Host-enabled source lobby God Mode, including the native Host;
personal No Explosive Damage;
personal Demi-God with native directional hit effects;
Continuous/Reload/Disable ammo; absolute Movement Speed override; Invisibility;
personal Modify Score, Disable HUD, Multi-Jump, Shoot While Sprinting and Custom Crosshairs;
native Down requests for a selected player or current non-Host players;
direct source-style teleports, native Official Spawn Points, Mystery Wheel/perk
entity destinations, saved location/view pairs and authorized player destinations;
host-spawned native power-up pickups with personal spawn-location selection;
individual and all ten Spaceland machine perks; DJ-part collection; twelve-stage
UFO progress; native side-portal visits and Pack-a-Punch entry after their unlock;
DJ speaker/tone-generator requests; guarded speaker placement, assigned-attacker
assistance and native post-defense pickup; native generator placement and
center activation; native stage-5 wave clearing; cancellable native tone matching for stage 8; host-controlled
native damage against reserved quest bombers in stage 9; and full-fight/exposed-fuse
assists for the Grey fight in stage 10; native dropped-fuse collection and native
Pack-a-Punch fuse insertion and final power-node inputs in stage 11; and native
Soul Key pickup after quest completion. A speaker request grants the native item;
placement starts the normal defense timer. A current-pass Death request is also available from the source Zombie Options
Kill slider. Unported features, freeze and remaining EE actions display
unavailable descriptions.
Lobby commands use the current roster; they do not apply a policy to later joins.
God Mode checkmarks show configured flags. If its damage callback is replaced,
an existing checked setting can still be disabled, with a message that protection
is not confirmed. Enabling still requires the active callback. A mixed lobby
requests enable-all, so its existing flags must be cleared through individual
Basic Scripts pages while the hook is unavailable. An empty roster is unchecked
and cannot report a successful toggle. Dispatch rechecks current flags, authority,
roster and hook state; a stale displayed checkmark cannot authorize enabling.
The full fresh selection must pass actual-player admission before hook checks
or any flag change. Invalid lobby snapshots stay unchecked and unavailable;
users below Co-Host retain the role-denial explanation when the snapshot is invalid.
Valid guest snapshots can still show the roster's configured checkmark.
Single-perk and All Perks actions share a complete initial roster/callback check.
Every selected player must be alive, out of last stand and outside spectator
mode; both native callback directions must be registered for every selected perk. Disabled rows
show the reason; a missing unrelated callback does not disable a ready single
perk. An empty roster never displays checked ownership. Personal changes use
only the selected target, so another unavailable player does not block them.
Malformed callback registry, selected-ID or entry shapes now fail admission
before indexing/member reads. Personal and lobby rows show the same disabled
reason while preserving known ownership. Native registration extensions remain
supported; no unverified function-pointer type check is claimed.
A defined non-array perk inventory also blocks immediate changes with a visible
reason. Undefined inventory stays valid because the native grant initializes
it. Future Retain Perks settings remain configurable. Lobby inventory rejection
does not block an otherwise valid personal target.
If readiness changes after application starts, native effects have no verified
rollback. Failure reports unavailable or incomplete and rows read actual inventory.
Inventory membership does not prove that every native effect finished.

Immediate perk changes pause while Ghosts N Skulls or a native temporary-perk
marker owns the inventory. The game saves and later restores those perks;
changing them in between can start duplicate native effect workers. Personal
and lobby rows keep the actual inventory checkmarks and show the pause reason.
Retain Perks remains configurable, while its native grant calls share the same
admission check. The source and installed bytecode support this rule; GSC
assertions and game behavior remain unrun.

Immediate perk changes also pause while native keep_perks preservation is pending.
The menu explains that another spawn may be needed. This marker can remain set
after a solo or one-player revive until a later native loadout restores effects;
the restriction can last for the rest of that life or match. The port does not
clear it or assume a one-second timeout. A pending member blocks the lobby batch,
while another ready player can still use personal controls. Ownership checkmarks
and future Retain Perks configuration remain available. This is a conservative
IW7 admission rule; the native timing and gameplay outcome remain untested.

No Explosive Damage is bound at its original Basic Scripts position for the
selected player. It uses IW7's native isexplosivedamagemod predicate and leaves
nonexplosive damage on the native callback path. Its setting is independent of
God Mode. An active Apparition damage callback is required to enable it; a saved
enabled setting can still be cleared after callback ownership is lost. The
checkbox describes configuration, and the footer warns when protection is not
confirmed. Runtime explosive classification and damage behavior remain untested.

Demi-God keeps the second Basic Scripts row for the selected player. It blocks
damage through the same owned callback and requests IW7's native directional
hit effects from the actual damage vector. Enabling clears God Mode only after
the callback, current actor, model tag and loaded effects are admitted. A saved
setting can still be cleared after hook or effect loss; a departed target is
unavailable. A missing direction produces no invented random feedback. The
checkbox records configuration. Native effect presentation and equivalence to
Apparition's BO3 FakeDamageFrom remain untested.

The damage wrapper now preserves all twelve arguments carried by the inspected
IW7 callback, including the two trailing opaque values. Earlier candidates
forwarded only ten. Compilation alone did not detect that mismatch; the current
source and bytecode checks compare the full packet with pinned native source.

Movement Speed keeps its original Basic Scripts position and seven values from
0 to 3 in 0.5 steps, with a preview default of 1. Use applies an absolute scale
to the selected player. Nonneutral values repeat every 0.5 seconds; selecting 1
sets literal 1 once and stops the previous repeating worker. This follows the
original override behavior, including across death, spawn and arcade activity.
It can overwrite speed changes from native weapons, perks and modes until the
override is stopped; it does not compose a multiplier with those native factors.

The row displays configured state separately from the slider preview. Unknown
means the saved value cannot be read as a supported setting; it does not imply
a native scale. No engine movement-scale getter is used. The worker stops on
replacement, disconnect, game end or an unsupported session. It never writes
native speed modifier fields or invents a stored baseline. The IW7 method name
is source-backed; accepted engine input range, timing, movement and co-op state
transitions remain untested in-game. Selecting 0 intentionally requests no movement.

Invisibility keeps its original Basic Scripts position and personal target.
Use flips the saved flag and sends one native playerhide or playershow command.
These player-specific IW7 methods are used in native player transition scripts.
The checkbox and Saved on/off footer describe configuration, not an observed
engine visibility state. Native scripts can change visibility afterward; the
menu does not repeat or restore the command automatically. Its actual effect on
the world model, attachments, first-person view and native modes is untested.
Movement, Invisibility, Disable HUD, Multi-Jump and Shoot While Sprinting share
one selected-player admission snapshot, with a fresh actual-player check again
when an action is selected.

Modify Score keeps all thirteen source slider strings in Basic Scripts and the
living Quick Menu. The preview is a delta: positive adds, negative subtracts,
and 0 clears the balance. Use reads the selected player's native currency and
cap again, bounds the result to 0 through that cap, and requests one native
balance update. The footer shows the captured live balance separately from the
preview. Missing or invalid native data disables the row. Native spawn and mode
code can overwrite an early request; no delayed retry is added. The native
setter updates the balance and its EoG currency statistic, without reward or
purchase helpers. This binding and the GSC contracts remain untested in-game.

Disable HUD keeps its personal Basic Scripts toggle. Use sends one selected-
player ui_hide_hud client omnvar command. Its checkbox shows saved intent;
game scripts can change the native value afterward. No visibility getter or
repeating worker is added. Exact HUD coverage and whether the menu remains
visibly usable after hiding the native HUD require later game testing.

Multi-Jump keeps its personal Basic Scripts toggle. The first airborne jump
release arms it; later airborne press/release cycles add 250 to current vertical
velocity. The original pending-release behavior is retained: a boost begun in
the air can still apply after landing. A disabled setting, dead/spectator target
or unsupported session cannot submit that impulse. Each player has one command
observer shared across toggles, using jump command notifications rather than the
host's physical key bindings. The checkbox shows saved intent. Exact release
event delivery, held-at-load input, movement and co-op behavior need game testing.

Shoot While Sprinting toggles IW7's specialty_sprintfire through the CP perk
helpers at its original personal Basic Scripts position. The checkbox reports
the helper's tracked setting; no general native perk getter was found. Racin'
Stripes shares this effect, so removing sprint fire can leave that machine owned
while its sprint-fire effect is off. No machine inventory is changed. Native
loadout/perk changes can override it; runtime effect and exact checkbox parity
remain untested. Unlimited Sprint and Clone still have no verified IW7 mapping.

Custom Crosshairs keeps its personal Basic Scripts position and source text
choices, including the current target's cleaned name when available. Disable
removes the owned overlay. Another text choice updates the existing element;
if its native handle is missing, the next valid choice can create a replacement.
The footer separates saved text, slider preview and missing-handle status.
The target's static theme or shared Smooth Rainbow color follows the overlay
even while the menu is closed. Closing the menu keeps it; Disable, unsupported
session, disconnect and game-end cleanup release it. This setting is transient.

The crosshair uses centered IW7 native HUD text. The original BO3 HudElementText
component is absent from the reference source, so its font and coordinate mapping
are unresolved. Exact appearance, visibility, pause/Disable HUD interaction,
respawn and co-op behavior need game testing. Adjacent name-format tokens are
removed correctly, and an unavailable empty-name choice is omitted. Dynamic
slider previews now clamp after list shrink without changing the saved index;
display, selection and scrolling use that same resolved index.

Teleport Menu now opens at its original root position for the selected player.
Crosshairs uses the menu owner's current aim endpoint, Sky adds exactly 35000
to the selected player's current Z, and Random Player chooses another eligible
current player once. Save Current Location stores that player's origin and
entity angles together; Load Saved Location restores both. For a remote target,
Teleport To Self moves the target to the owner, while Teleport To Player moves
the owner to the target. These are immediate requests, without an active mode.
Co-Host can reach a current non-Host player through Players Menu -> player ->
Options -> Teleport Menu; native Host keeps its broader existing access. Options
also opens Basic Scripts and preserves the source's fourteen labels; its other
unported controls remain disabled.

Official Spawn Points now lists the complete native player-respawn registry with
numeric choices starting at 0. The selected index keeps its displayed point's
identity; dispatch checks that the same point still exists and applies its live
origin and view angles. The changing active-zone subset does not renumber this
catalog. A known empty catalog hides the row, as in the source; pending map data
keeps a disabled explanation. Point counts and positions depend on the loaded map.

Entity Teleports now opens for the selected player. Mystery Box targets the
native selected Mystery Wheel; Fire Sale can make additional wheels usable.
Perk destinations use the native interaction structs and the existing Spaceland
perk names. A displayed action keeps that exact native point, then rechecks its
current registry membership before movement. A wheel changing areas stays
pending until its selected pointer and area agree. No machine purchase or
activation is performed. BGB and BO3 crafting-table destinations remain unmapped.

Movement retains Apparition's negative-right 70-unit wheel offset, positive-right
70-unit perk offset and view toward the native origin plus 55 units. The view
calculation uses the player's actual eye after moving. These formulas are source
behavior; native authored orientation and landing clearance remain unverified.

Each action checks the current roster, role-aware target authority, native
life and travel permission again. Linked movement, rides, arcade/PAP/portal states,
slides, launches, phase/rewind signals and the Ghosts N Skulls arena block moves.
Native locks and cleanup remain owned by the game. Destinations use the original
raw coordinates; there is no safe-landing, collision or damage protection claim.
All Players -> Teleport keeps the original Self, Crosshairs, Sky slider. Self
requests each recipient to the requester's location; Crosshairs uses the
requester's current trace for each recipient; Sky adds 35000 Z to each recipient's
own origin. Only the current native Host is excluded. A Co-Host requester is
included and moved last for Crosshairs, after everyone else. The original fixed
developer-ID exemptions are omitted. Solo has no targets. Every recipient's
movement state and position are checked before the first move. Self/Crosshairs
also need the requester's travel readiness; a requester-only travel pause leaves
Sky available. Each write checks current roster, authority and travel state again.
A later rejection stops further moves; earlier moves remain applied. No rollback,
arrival-effect or landing-clearance guarantee is made. Native co-op movement
and all game-VM assertions remain unrun.

Save & Load Position now enables the source held shortcuts for the selected
player: Action Slot 3 saves and Action Slot 2 loads. They run only outside that
player's open or opening menu. Save is sampled first; Load is sampled again after
its 50 ms save delay, with another 50 ms after Load and a shared 50 ms poll.
The setting remains configurable while movement is paused; actual saves and loads
use the same current roster, life and native travel checks as the menu actions.
Disabling or losing the requester's grant stops the shortcut worker and keeps the
saved location. It runs independently of Teleport Gun. Held controls may repeat;
this does not convert them to one-shot key presses. Keyboard/controller mapping,
co-op input, timing and actual movement remain untested in-game.
The original BO3 arrival effects remain unavailable.
Movement, view restoration, map hazards,
co-op and all GSC assertions remain untested in-game.

Death keeps the source Down/Kill slider, with Down first. Down requests lethal
damage through IW7's native player path and clears that target's menu God Mode.
Native shields, temporary protection and the game's revival rules still decide
the result. Kill remains visibly unavailable. Co-Host and Host can submit
lobby Down against current eligible players; the actual native Host is excluded
from recipients. No fixed developer IDs are used. A host-only roster has no
eligible non-Host recipient.

Slider availability now follows the selected choice. A blocked Kill, Crosshairs
or Random Player preview dims the label/value and shows its reason; Use checks
that same reason. A ready Sky preview remains usable when aim or peer selection
is unavailable. Numeric sliders keep their existing preview behavior.

Page refresh now preserves the selected control and its target when conditional
rows change. Duplicate player names keep their distinct actor identities, and
equal machine names retain their distinct native point identities.

Teleport Gun keeps its original personal toggle. Each weapon_fired event uses
the selected firing player's own aim, including when the host enabled it for
another player. The checkbox shows saved intent. Native movement restrictions
pause shots while leaving the setting configurable; the footer shows the current
pause reason. The same player entity can resume after ordinary death/spawn.
No arrival effect is added, and ordinary weapon firing is left to the game.

The setting belongs to its requesting player. Co-Host may use it on current
non-Host targets; the native Host retains its broader target access. Loss of the
requester's roster membership, private-session access or current target
permission clears it. An idle supervisor checks every 0.05 seconds, and each shot
checks again before moving. Disable clears the grant and stops its shot listener; cleanup also runs
on unsupported session, disconnect and game end. Native notification timing,
rapid fire, host changes, movement and co-op behavior remain untested.

Power-Up Menu preserves Spawn Location, Reign Drops, the separator and nine
normal Spaceland drops: Double Cash, Nuke, Insta-Kill, Max Ammo, Carpenter,
Infinite Ammo, Fire Sale, Infinite Grenades and Weapon Upgrade. Spawn Location
configures the menu owner's Crosshairs or Self choice; its saved value is shown
separately from the slider preview. Only the current living host can create a
pickup. Rows show current missing-table, effect, callback or location reasons.
Reign Drops remains unavailable because its IW7 equivalent is not established.

Every drop request checks the current roster, loaded loot entries/effects and
navmesh, exclusion and active-area rules again. Crosshairs requires a usable
surface hit. The native helper owns the pickup, effect and expiry. Collect the
pickup normally to apply its effect; creation is not confirmation of collection.
The request skips the consumable-notification argument, so native attribution
falls back to the first current roster player. It leaves global random-drop
quota unchanged and updates the selected item's native drop cooldown. Native
pickup effects, targeting, timing and co-op behavior remain untested.

Unlimited Ammo keeps Continuous, Reload and Disable in the source order. Use
applies the selected preview to the current target or host's current roster;
later joins keep their own mode. The full selected actor set and mode are checked
before stopping workers or changing settings. Empty or invalid rosters are
unavailable, and missing lobby admission data cannot display an active Disable
setting. Guests can inspect a valid lobby mode but cannot change it. Personal
settings can be configured while down; the worker waits for native spawn.
The GSC suite now covers events sent immediately after waiter startup, paired
events without an intervening wait and cancellation after bounded child entry.
These contracts compile; their assertions and the engine's event timing remain unrun.

Revive is bound at the original Basic Scripts, living Quick Menu and All Players
positions. Personal requests use the selected player; the Co-Host or Host lobby
action uses currently eligible non-Host players and shows the eligible count.
It requires an ordinary live playing laststand, the known Spaceland wait
callback and the exact current native revive model. Afterlife, spectator,
Ghosts N Skulls, arcade, coaster, active self-revive and kill-trigger-marked
states are excluded. The solo/one-player Hoff override is also excluded;
ordinary solo auto-revive can
lack this native model and remains unavailable through this action.

The request calls the native instant-revive helper once per current native
model. A custom submitted marker is written before input; it cannot be retried
while that same model remains current and unconfirmed. A later down uses its
own native model and does not inherit an earlier marker. The menu never writes
health, laststand, weapons or native revive progress. Native code owns the exit
and cleanup. Submitted input is not confirmed revival; the native listener and
state transition, concurrent rescues, co-op and GUI behavior remain untested.

Unlimited Equipment now binds the supported grenade portion in Basic Scripts,
living Quick Menu and the host's current-roster lobby controls. Its checkbox is
a configured setting. One worker observes live native charges every 0.1 seconds
and refills the currently owned supported primary grenade through the game's
power-refill helper. The setting survives death and resumes in normal play.
Disabling stops the worker and leaves current native ammo in place.
The row also shows a read-only readiness snapshot: Ready means eligible for the
next refill check; Full means at or above the native cap; Waiting means dead or
spectating without a blocked mode; Paused means a native equipment mode owns
inventory and takes precedence over Waiting; Unavailable means
session or primary selection is not ready; Missing means its native weapon is
absent; Off means the setting is disabled. A lobby snapshot counts every current
player as ready, full, paused or off; paused includes Waiting, Unavailable and
Missing. Unknown means a valid snapshot is unavailable. The checkbox remains the
configured setting, and the worker rechecks live state before each refill.

The supported native IDs are Bio Spike, C4, Cluster, Concussion, Frag, Gas,
Semtex, Splash and Cryobomb. The live primary slot, registry, weapon identity and
ownership must match. Ambiguous slots, active/locked powers, depleted entries
with queued native removal, dead/spectator actors and temporary laststand,
arcade, Afterlife, Ghosts N Skulls or coaster states receive no refill. Existing
above-cap charges are preserved. Missing weapons and removed powers are never
recreated. Secondary power parity remains unfinished; the row states this limit.
Native charge/weapon/HUD updates, polling timing and co-op lifecycle are untested.

Retain Perks is available for a selected player or the host's current roster.
It captures supported owned perks at the next normal down, before native removal, and
restores that saved selection after a native spawn completes loadout. It does
not restore on an ordinary teammate revive that does not spawn the player.
The setting may be configured while dead and applies to future captures. A new
normal down replaces the saved selection; disabling discards it and stops this feature's
listeners and pending restoration. Later joins keep their own setting.
Restoration waits up to five seconds for native keep_perks processing to finish
and skips actors still in laststand, Afterlife, Ghosts N Skulls or native perk
protection. It never writes those native preservation flags. A partial/unavailable
restore prints a message and leaves actual inventory visible; no rollback is
claimed. If callback ownership is lost, existing checked settings can still be
disabled. Mixed lobby settings can be disabled in each player's Perk Menu.
Capture skips only players whose native playing_ghosts_n_skulls marker is active.
The marker brackets native arcade perk removal and restoration, so this temporary
inventory leaves the saved normal selection unchanged. Global GNS activity alone
can include a joining player before arcade entry; dontremoveperks and keep_perks
alone also permit normal capture. Newly owned perks therefore still replace the
snapshot on those normal downs. This applies to personal and lobby settings
without changing the configuration checkbox or the stock last-stand callback.
Retain Perks scheduling, native effects and lifecycle behavior are untested in-game.

Ghosts N Skulls now has a native progress page under Spaceland Scripts. All players
can view its seven unlock stages, arena activity, map-wide started-wave count and
the last native arena result. At the Spell GHOST stage, Face Current Skull lets
the living host face the one native skull at an exact source location, after
checking the native sightline. Keep it in view for the normal 1.5-second check.
The action checks current state again when selected. The dance, floating-skull
and Brute-at-cabinet stages also have the assists described below;
remaining unlock stages and the arena require normal gameplay.

At Pop Spawn Balloons, open Spawn Balloons and select an authored location.
The current living host can request one view-angle change toward that exact
native object. Selection follows the object if query order changes; a removed
object cannot be replaced by another at the same coordinates. The request does
not shoot or pop anything, prove a balloon is still unpopped, or check completion.
Shoot normally and let the native quest advance. Game view changes remain untested.

Ghosts stage reads now reject malformed tables, callback entries and fractional
indices before indexing. Bounded whole-valued numbers are normalized to integer
keys. All Ghosts controls and the arcade observer share this one validation path.

During Arcade Critical Shots, select that stage to open Arcade Results. The
page lists Zombie Zoom, Bowling for Planets, Rings of Saturn, Cryptid Attack and
Black Hole in native order. An observer ready before the stage records distinct
native result events. Observed means a result event was seen; Pending means none
has been seen for that game with complete early coverage. Late or invalid history
shows Unknown, with an explanation that unchecked does not mean unfinished.
When the native quest advances, all five entries show Completed. This is shared
quest progress: it does not name a player or prove a particular success route.
The page sends no throws, shots, scores or completion events. Normal play remains
required. GSC assertions, event scheduling and in-game display remain untested.

The final Activate Cabinet checkmark requires observing the normal quest callback
return while its session and registration remain valid. The final selected stage,
an active arena, a Fate & Fortune card or a win does not create that receipt.
Loading after activation cannot reconstruct it. Native result zero is also the
game's initial value, so Failed requires the native failure-processing marker.
A retry clears that marker; an ambiguous result displays Unconfirmed. A recorded
win may belong to an earlier attempt. Map Waves Started includes retries and is
not a cleared-wave or current-attempt percentage. Stage-two dance hints show the
native next color and remaining kills only while its exact kill callback is active.
Native model discovery, view changes, look timing, callback scheduling and co-op
behavior have not been tested in-game.

At the final Activate Cabinet row, open Cabinet Activation to inspect the current
roster's hold requirements. Each player must leave last stand, stop carrying,
stand within 50 units of the native cabinet corner and hold Use together. The
page shows compact player status labels, each selected player's blocker in the
wrapped footer and a Passing Now count. The game checks the
whole roster twice, 0.25 seconds apart; one passing sample never marks activation.
The existing completion checkbox still requires its native callback receipt.

Both initial and observed retry routes require their known registration and the
normal activation marker before input is sampled. A missing marker or roster
shows unavailable data. The marker can remain after an unresolved debug
termination path, so the page does not confirm that an activation wait is running.
It sends no input and changes no native quest, FX or player state. Input display,
entity deletion visibility and co-op timing remain untested in-game.

At the native 1984 dance-kill stage, the host can Start Dance Kill Assist while
standing on the indicated native floor color. The background worker submits at
most one damage request per 0.25-second pass against a living, tracked ordinary
zombie or clown with the known native death callbacks. Reserved/protected actors
are excluded. The host must move to each newly indicated color; standing elsewhere
pauses requests. Closing the menu leaves the worker active. Cancel stops future
requests and leaves earned native quest progress in place.

The worker rereads the native order, host position and authority before each
request. Teammate kills can change that order. An empty sequence stops requests
but does not report completion until a known later native quest stage is observed.
The assist stops after five minutes with Pending if advancement is unconfirmed.
Owner death, laststand, disconnect, lost host authority or changed native context
also stop requests. Damage acceptance, kill credit, scheduling and cancellation
latency have not been tested in-game. These local bounds do not prove how many
native callbacks a damage request will produce.

At Hit Floating Skull, the host can request one direct sign-laser-type hit against
the native moving skull. The native UFO must already be destroyed, and at least
one current player must wear the real glasses. The action requires exactly one
living zmb_pixel_skull model in its source movement path. It rechecks the current
stage, host, glasses and model before sending a one-point native damage request
with the sign laser's weapon ID. This direct menu assist does not fire a visible
sign beam or charge the five power nodes.

The input observer continues after closing the menu and waits up to five seconds
for a known later native Ghosts stage. A submitted hit or disappearing model
alone does not confirm completion. Submitted history survives timeout or owner
loss, so the menu cannot repeat an unconfirmed request during that map. A failure
before input remains retryable, and normal sign-laser gameplay remains available.
The separate Floating Skull Input row reports observer state. Native damage
delivery to this model, listener readiness and co-op timing remain untested.

At a ready native Brute Laser at Cabinet stage, Hit Cabinet With Brute requires a
living host, exactly one native cabinet damage target and an existing living axis
Brute from the game's live-agent list. It rechecks the target and Brute, then
submits one direct bullet-type hit credited to that Brute. The action does not
spawn an actor or fire a visible beam. The native quest still decides whether the
cabinet hit advances this stage.

The separate Brute Cabinet Input row reports observer state, and Cabinet Route
shows Initial Unlock, Reactivation or Unavailable. This input uses a five-second
observer and retains submitted history through timeout or owner loss. A rejection
before input remains retryable. Both direct-hit actions share one observation
loop and status policy while keeping their own admission and request records.

Cabinet reactivation after arena failure is a separate native quest. The menu
observes the game's actual restart callback before admitting its Brute stage.
A new attempt can accept a fresh hit only if the prior native Brute phase was
known to have advanced. An unresolved overlapping restart, lost callback owner,
changed registry or late-loaded unobserved attempt stays unavailable. The same
captured attempt cannot replay an unconfirmed submitted hit. Normal quest stage
six is never treated as reactivation completion: that attempt's own native step
must advance. Normal Brute laser and cabinet activation gameplay remain available.
Direct trigger delivery, callback/quest scheduling, actor credit and co-op timing
remain untested in-game.

Menu Customization now keeps the source's seven-entry root. Main Design Color
offers all 36 named source colors. Menu Preferences supports Boxes, Text and
Text Color indicators; Left/Right boxes; Spotlight, Colored and Large Cursor;
Option Counter; Stealth UI; Quick Exit; Disable Quick Menu; and scroll animation from 100
to 250 actual milliseconds. Quick Exit closes a submenu after ten held Melee
samples with source 0.01-second waits; a short press goes back. Root pages close
immediately. Disable Quick Menu blocks its opening chord while the normal menu
remains available. A held action requires its original open session, HUD, actor
and navigation state; death invalidates a main-menu hold.
Action Slots 3/4 preview a slider and Use applies it. The description reports
the applied value. Visual settings belong to the menu owner, even when another
player was selected. Applied settings remain in memory through closing, reopening
and respawn. A per-player Dvar save/restore path now attempts reuse when a new
controller starts; native lifetime across maps/reconnects is unverified.
Stealth UI uses five visible options, changes Boxes to Text and disables Option
Counter. Text Color remains selectable. Turning Stealth off keeps the current
text style and leaves the counter off until explicitly changed. Disabled choices
show the same restrictions that callbacks enforce. Saves now use version 3;
version-1 saves restore with Stealth off, and version-1/2 saves restore the new
instruction defaults. This implements the source
visual rules. Native archive visibility, allocation limits and rendering remain
unverified; every port menu HUD element still uses archived=false.
Menu Instructions now contains the six source controls: Disable, Alternate
Style, Disable Background, Adaptive Position, Reposition and Reset Position.
The separate guide remains visible with the menu closed and shows the applied
opening chords. While open it shows navigation controls. A disabled Quick Menu
has no closed-menu quick prompt, including while dead. Dead Jump says Go Back/Exit
to match nested navigation. Alternate Style makes one inline guide and clears
Adaptive Position; Adaptive stays unavailable until Alternate is off. Reposition
uses Action Slots 1/2/3/4 in fixed eight-pixel steps and Melee to exit. It keeps a
20-pixel menu panel with titles and saves only the guide position. Reset restores
255,472 normally or 320,472 for Alternate Style. Reset stays available while the
guide is disabled. The guide's native alignment, font/glyph width, controller
mode and dead visibility still require in-game acceptance.
Main Design Color also supports Smooth Rainbow with the source shared hue cycle.
Selecting a named color turns rainbow off and requests the source 0.5-second
accent/checked-box fades and 1-second text fades. Width Editor supports the
source 200..500-pixel range with a temporary instruction view. Attack/ADS change
width, Action Slots 3/4 change the 1..10-pixel step, and Melee exits. The applied
width survives close/reopen during the connection. Reposition Menu moves the
whole HUD with Action Slots 1/2/3/4. Secondary Offhand/Frag lower/raise its 1..10
pixel step; Melee exits. Editor exit saves the applied width/position through
the same per-player Dvar record.
Design now offers Apparition, Classic, Native, AIO and Basic in source order.
Action Slots 3/4 preview a design and Use applies it. Classic/Native disable
Colored Cursor; AIO/Basic disable Option Counter. Their disabled controls explain
the restriction. Each design uses its source panel/header/scroller geometry,
colors, title scales and counter placement. Width/Reposition use the same design
plan; Reposition retains titles and Width hides them. AIO displays the owner's
the current verification level. The shared HUD pool redraws on design changes.
Open Controls now offers separate Apparition and Quick Menu chords with one to
three buttons from the original thirteen-command catalog. Select the menu and
slot with Action Slots 3/4, apply each selector with Use, then apply a button.
None clears that optional slot and every later slot; slot one remains required.
Duplicates, skipped slots and pairing Frag with Secondary Offhand are rejected.
Instructions show the applied chords. Edits belong to the menu owner and use
the same settings save path. Fixed menu navigation remains ADS/Attack, Use, Action Slots
3/4 and Melee. While dead, Quick Menu instead uses the fixed ADS + Jump chord;
Jump also backs out. Disable Quick Menu blocks both quick opening paths.
Death closes main pages while Quick Menu and its nested history remain open.
Menu life follows the original rule: native life plus a defined session state
other than spectator. The shared perk batch rechecks that rule before applying.
The root contains 12/14 rows for a living guest/host and 1/3 while dead.
Revive now binds the guarded ordinary native laststand path described below.
Respawn, Restart Game and Disconnect remain unavailable. Row rebuilds
preserve a surviving selection, and personal perk rows disable for a dead target
while continuing to show native ownership. Remaining preferences stay unavailable.
Native rendering,
font/safe-area fidelity and source reopen/row animations remain unverified or
unfinished.

Default boxes show ten rows. Text indicators add two rows, and the option
counter reserves two. Disabling instructions adds one row with Boxes or two
with text; Stealth keeps its fixed five-row window, matching the source rules. Fresh option draws allocate
only that visible count. Text Color shows checked labels in green;
Colored Cursor controls selected text without changing checked-box accents.

Accepted customization changes save one namespaced record using the player's
native identity. This includes applied position, width, design, named color or
Rainbow mode, indicators, scroll timing, preference flags, both opening chords,
and the instruction position/style/background/adaptive choices.
Editor selection, navigation history and live HUD/editor state are excluded.
Missing identity or an invalid stored record keeps the default opening controls.
If saving/readback fails, the menu reports that settings apply for this connection.
Dvar creation, identity readiness, map/reconnect reuse and application restart
behavior have not been tested. This is best-effort engine storage, with no disk
or cross-host persistence guarantee.

For later isolated testing

Freeze binding check: in a later private match, the source-audited IW7-Mod console
can inspect a registered Dvar by entering its bare name, with no argument:

    g_ai

Record the exact echoed name, current/default values, type and domain. Console
autocomplete also reads the registered-name pool. A reply must identify the exact
name g_ai; an unrelated lookup result does not establish registration. Do not use
set, toggle or an extra value for this presence check. Registration alone still
does not prove an AI freeze effect or safe restoration. The installed loader
revision and this command path have not been verified in a running session.
No IW7 process was running during the latest read-only check. The existing
console log supplied no g_ai/freezecontrols evidence; absence from that log
does not establish absence from the game.

1. Keep the existing game/mod files backed up. Use one active menu. Move the
   existing Synergy.gsc outside every custom_scripts scan folder before loading
   this candidate. A filename still ending in .gsc can still be loaded.
2. Merge only this package's custom_scripts/ and scripts/ directories into the
   existing loader filesystem root, normally the game's iw7-mod/ directory.
   Preserve the relative folders. Do not copy the whole tests/ tree as normal
   production custom_scripts content.
3. Use the existing IW7-Mod launch setup and a private normal Spaceland match.
   The menu refuses public matchmaking, other maps and Escape.
4. Open with ADS + Melee. A living Quick Menu uses ADS + secondary offhand.
   While dead, ADS + Jump opens Quick Menu and Jump also returns/closes.
   ADS/Attack scrolls, Use selects, Action Slots 3/4 change the slider preview,
   and Melee returns or closes. Open Controls can change either opening chord. Held inputs
   repeat with the source cadence. Use applies
   the selected ammo mode. Main and quick navigation retain separate state.
5. Inspect the loader console for compile/link errors before testing features.
   The installed loader revision is not proven identical to the source audited.

The UFO portal-stage action transports the host through the game's native
Pack-a-Punch route. All four side portals must already have been used, and native
power/unlock/cooldown/travel checks must be ready. The game owns the usual room
timer and exit. The action observes entry for at most five seconds. If entry is
not confirmed by then, it reports pending and leaves native travel running. After use, the footer explains
that quest advancement waits for the next wave. Speaker controls now cover native
placement, assigned-attacker assistance and pickup while preserving the timer.

During stages 2-4, select the current Speaker Defense entry to open its controls.
Request/Retry Speaker talks to the native DJ. Place Speaker uses the one active
native location and the game's own placement trace, grounded state, height and
interaction checks. This is a remote menu action; it does not teleport the host.
Stand on clear ground at the selected location's height. Placement runs on the
level, so closing the menu or losing the actor after commit cannot interrupt its
owned admission-slot release. Its status reports native model confirmation.

Assist Active Speaker must start while the placed speaker is active. It damages
living axis zombie agents currently assigned to this exact native speaker clip,
using the game's attacker flag and preferred target. Brutes are excluded from
that assignment set by native code. Other threats can still damage the device;
this assist does not promise invulnerability. Damage requests use current enemy
health; native armor/scaling can change the result. The normal 60/90/120-second timer
continues. Timer and hit points are read-only native values; unknown is distinct
from zero. After native success, the worker sends at most one trigger to the
captured speaker model and observes deletion. Native code owns item updates and
model cleanup. A level observer captures the actual model/clip/stage while the
defense is active and arms its trigger listener before either job is available.
The listener stays active while the menu is closed and after job cancellation.
An observed physical pickup prevents another menu trigger.

Cancel stops future damage/pickup submissions and leaves native work running.
Closing the HUD leaves the assist active. Owner death, last stand, disconnect or
lost private-host context stops further input. The worker polls every 0.25 seconds,
allows five seconds for submitted pickup confirmation and observes for at most
five minutes. Pending is unconfirmed. Only the native next quest stage reports
Completed: speaker pickup and a real regular-wave event are both required.
Stage 5 also waits for a subsequent real regular wave; no synthetic wave event is emitted.
Collect Defended Speaker can start after timer success even if combat assist
was never running. It uses the recorded original model, requires the native
inactive success state, and shares the assist's status and Cancel Speaker Job
control. No model scan or timer skip is used. A missing early capture or listener
leaves ordinary in-game pickup available. Handshake timeouts retry only while
the same unspent native defense is active; they cannot reopen a blind receipt
window after success. Pickup yields 0.05 seconds, then rechecks native state and
physical receipt before claiming its one input. That claim survives cancellation
and pending results. This delay is a policy, not a proven native waiter-ready
signal. Placement, damage, event ordering and co-op lifecycle need later gameplay
acceptance.

At stage 5, open Wait One Wave -> Native Wave Controls. Clear to Next Regular
Wave assists the current wave and a known intervening native clown round until
the next regular-wave event. It damages only living, tracked axis generic
zombies and clowns with the expected native death callbacks. Reserved,
respawn-marked, script-kill-protected and unknown actor types remain untouched;
Brutes remain outside this action. Native pause flags suspend further damage.
The living host is the damage source, so native kill-credit and loot effects
can apply. Player attribution follows the native clown branch without its
non-player radius blast. Max-health damage requests can require repeated
packets because native armor/scaling still applies.

The page shows native wave/death counters and job status. A full counter stops
submissions; only native quest advancement reports Completed. The worker uses
a 0.25-second cooldown and five-minute observation bound. Counter callbacks can
run after a batch, so it does not promise an exact quota of submitted kills.
Cancel stops future input and releases the reservation after listener cleanup.
A captured regular-wave event remains recorded after cancellation, preventing
restart from clearing another round while native quest advancement is pending.
Closing the menu leaves the level job running. Lost living private-host context
stops further input. Native scheduling, damage, co-op and lifecycle need later
gameplay acceptance; compiling these sources does not establish them.

Spaceland Scripts -> Portal Controls exposes four side visits in stable order.
Each visit uses the powered native portal: charge/open it normally, observe its
trigger before sending one host trigger, then wait for that actor's completion
and the native used_once flag. An already open unused portal skips charging.
The checkboxes also reflect visits completed by teammates. Side Portal 1-4 map
to the native arcade, moon, europa and mars keys; region display names await
asset/UI confirmation. Power is required before starting a charge. A native
charge or open window survives power loss, matching the stock worker/trigger
rules. Cooldown, disabled/alternate-route state, actor readiness and return
assets are checked at their relevant stages. One side-visit worker runs at
a time. Its status remains visible after closing and reopening the menu.

Side opening and travel observations each have a five-second bound. A captured
portal trigger before the menu emits its own stops further menu input. Pending
and other terminal outcomes do not cancel native charging or transport, and no
automatic trigger retry occurs. The one-trigger limit applies to each menu job;
the native open window remains shared by players. A listener cannot detect input
sent before it was armed. The observer releases its own listeners even
if its actor disconnects. Native simultaneous input, same-window races and
death/disconnect recovery still require gameplay verification. These controls
do not turn on local power or force a wave-start event.

Tone matching controls are under Spaceland Scripts -> UFO Quest Steps ->
Match UFO Tones while that native stage is active. Start waits for a fresh listening
window and reads the current note order for every round. Cancel stops future menu
notes without resetting the quest. The status row reports waiting, playing and
terminal outcomes. A fresh-window wait is bounded at 120 seconds; processed-note
responses are bounded at 1.5 seconds. Native quest state alone marks completion.
Other players should avoid speaker inputs during this job. Extra/mismatched input
is detected where observable; native events do not identify the sender, so an
identical simultaneous input cannot be reliably attributed. This is unverified
in the game VM. Freeze remains unavailable: the stock zombie pause stops spawns,
and the stock cryo effect is not a reversible general freeze.

UFO Quest Steps -> Defeat Suicide Bombers opens UFO Bomber Controls during stage 9.
Start runs one host-owned damage job while navigation remains responsive. The
worker refreshes the native alive-axis roster and selects only reserved
generic_zombie agents marked as suicide bombers. Native DoDamage handles deaths;
the menu never deletes agents, assigns health, increments kills or advances the
quest index. The displayed count comes from num_ufo_zombies_killed. The stock
sequence spawns 51 actors and requires 50 tracked deaths. A reported count of
at least 50 pauses further menu damage while the game finishes its own sequence.

Cancel stops future damage and keeps prior native deaths. Closing the HUD leaves
the job running. Owner death, last stand, disconnect, lost host/private context
or changed stage stops further submissions. The worker polls every 0.25 seconds
and observes the native stage for at most 120 seconds. An expired observation
reports Pending rather than claiming success or failure. Only native quest
advancement reports Completed. Damage acceptance, native death tracking, later
spawns, co-op timing and lifecycle behavior remain unverified in-game.

During stage 10, UFO Quest Steps -> Defeat Alien Grey opens Grey Fight Controls.
Defeat Greys submits native body damage and handles fresh exposed-fuse windows.
It requires an unchanged native stage callback observed before stage 10 and the
return of the entire initial native spawn loop. This avoids menu damage while
later co-op Greys are still being spawned. A late-loaded or replaced callback
leaves the full assist unavailable. The normal native completion wait is kept,
and the original callback is restored only while still owned.

Full mode refreshes the native Grey roster, includes clones for ordinary damage,
and skips body hits during regeneration or the native MOD_UNKNOWN rejection gate.
Body batches have at least a 250-millisecond cooldown after processing. Native
damage callbacks own actual health changes, regeneration, clones and deaths.
The menu does not assign boss health, remove actors/models or emit completion.
The spawn watch and roster size are observations, not quest completion evidence.

Exposed Fuse Controls retains Auto Strike Exposed Fuses as a separate fuse-only
mode for fighting the bosses normally. Both modes share one reservation and
Cancel Grey Assist. Only one can run at a time. The fuse path sends a small
native melee hit to a Grey at the currently exposed fuse's position.

Every new job and newly observed Grey must first be seen outside regeneration.
Starting during an existing exposed-fuse window waits for a later window. Each
observed fresh window receives at most one menu submission; Cancel and restart
cannot retry a window that is still active. The worker checks exact map hooks,
tracked native actor membership, life state, nonclone status and the exposed
model's owner, back tag and available-fuse membership. It arms the native stop
event before input, rechecks after arming and spends the window before damage.
An observed teammate stop event suppresses the menu hit. A regeneration-cap
snapshot from idle also rejects a hit accepted before listener registration.
Past notifications cannot be replayed, simultaneous physical input cannot be
fully excluded, and fuse removal cannot prove
which player caused it. Avoid other fuse inputs during the assist job.

The assist requires the same living private-session host throughout. Cancel
stops future submissions; closing the menu leaves the job running. Removal of
the selected fuse must be observed within 1.5 seconds of the hit, or the job
ends Pending without retrying. The whole observer stops after five minutes.
These are policy bounds, not measured game timings. Only native advancement
past stage 10 reports Completed. No remaining fuses or an empty Grey roster
alone can complete a quest checkbox. Native damage delivery, regeneration,
co-op timing and lifecycle cleanup remain unverified in-game.

During stage 11, UFO Quest Steps -> Destroy UFO opens UFO Finale Controls.
Collect Dropped Alien Fuses sends one host trigger to the uniquely identified
first model of the dropped pair. The game owns inventory, interaction changes,
shared item display and deletion of both models. The pair becomes one shared
inventory item. A teammate's collection completed before the worker starts is
observed without another input. The collector requires initialized native fuse
inventory, the registered PAP insertion callbacks and both native interaction
structs before submitting anything.

Confirmation requires pickup deletion plus native inventory and interaction-list
changes, or the inserted flag if another player has already consumed the item.
The observer has a five-second bound. An unconfirmed result is Pending, and
the menu cannot submit a second pickup trigger during that map, even after owner
loss or timeout. The ordinary in-game pickup remains available if the pair is
still present. Closing the menu leaves the level-owned observer running.

Insert Alien Fuses calls the native zero-cost PAP interaction after collecting
the pair. It requires known idle PAP history, both native interaction slots and
the living private-session host to pass normal carrying/grenade/ground/phase
gates. The action is remote and does not require proximity to the machine.
Unknown cycle history disables the remote action; normal insertion at
the machine remains available. Both slots are reserved together until the native
callback finishes its animation, inventory update and delayed list restoration.
The level owns this committed transaction: menu closure, owner death or
disconnect does not interrupt its native cleanup. An unconfirmed submitted call
cannot be repeated from the menu during that map.

Finale checkboxes read native collection and insertion progress rather than job
results. The separate insertion status reaches Inserted only after observing
native consumption, the PAP limit increment and weapon-interaction restoration.
Neither fuse action completes the final stage or claims the Soul Key.
The first-model location is taken from the inspected native drop routine; a
missing or ambiguous match disables the action. Target-build entity discovery,
trigger delivery, co-op timing and lifecycle behavior remain unverified in-game.


Final Power Nodes opens from UFO Finale Controls. Equip a double-upgraded
Spaceland wonder weapon as the living private-session host. Charge one node
normally first to prove that the native damage monitor is ready. Start then
assists the remaining nodes, submitting at
most one native damage hit per uncharged node and observes native activation.
It checks the exact native weapon predicate, first-match point mapping, canonical
node/arc structs, gate lights, FX and damage trigger. The game owns all lights,
activation flags, the WMD projectile and UFO destruction. Cancel stops future
menu hits; prior hits and native projectiles continue. Closing the HUD leaves
the level worker running. Owner loss stops further menu input.

A damage observer must arm before stage 11. Once hits have mapped to all five
distinct nodes, it permanently excludes another remote firing cycle for that
map. This records possible inputs, not successful charges: even ineffective
weapon shots can conservatively exclude the remote action. Normal weapon shots
remain available. A submitted but unconfirmed menu hit cannot be repeated.
The observer never adopts reset node flags as evidence that no projectile is
pending. New workers can continue untouched nodes only after earlier submitted
hits have native activation evidence and no full input cycle was observed.

Each hit has a 1.5-second activation observation bound, and the worker observes
for at most 60 seconds. Pending is unconfirmed. Only native ufo_destroyed reports
Destroyed; the main quest checkbox separately follows ufo_quest_finished. Node
checkboxes show the native flags and reset normally during firing. Trigger damage
payload delivery, observer fanout/order, co-op timing and lifecycle acceptance
remain unverified. Soul Key Controls provides the separate native reward pickup.


After native UFO quest completion, the checked final-stage row still opens
UFO Finale Controls -> Soul Key Controls. Collect Soul Key submits one host
trigger to the unique dropped native model. This uses the game's normal pickup:
it grants Soul Key ownership fields and achievement progress to the lobby roster
selected by the native callback. The menu does not write profile data or call
achievement functions directly. Its action description states those lobby effects.

The observer checks disappearance of that model and both native ownership fields
for its snapshotted recipients. Pre-existing ownership alone cannot confirm this
match's pickup. A recipient who disconnects or cannot be read leaves confirmation
unavailable or pending. Native recipients are chosen at callback processing time;
a join in that interval may differ from the observer snapshot. The separate
ownership checkbox/count always reads the current roster and may reflect earlier
matches. Receipt checks and model scans run only while the reward page is open;
the bounded observer continues independently after closing the menu.

An unconfirmed submitted pickup cannot be repeated by the menu during that map.
A pre-input rejection remains retryable, and the ordinary pickup stays available
if the model remains. The observation bound is five seconds. Native use-listener
readiness, notification delivery, receipt visibility, achievement behavior,
co-op scheduling and profile persistence remain untested in-game. Compile results
do not establish an award or external achievement unlock.

The six available native held-button queries are retained. Action Slots 1-4,
Sprint, Stance and Jump use the stock getKeyBinding(command) then
buttonPressed(physical key) pattern. This removes the four press/release trackers.
Command mapping, keyboard/controller layouts and remote-client binding lookup
are unverified in the installed game.

Input exclusivity is not yet verified. Slot commands can also reach game-bound
handlers, particularly crafted equipment, and ADS/Attack remain native inputs.
The file is a reviewable test candidate, not a production-ready release.

Offline compilation

Published utility names differ between edited dumps and the compiler token table.
Ammo therefore owns its GSC event waiter, and native flag checks use direct GSC
predicates. These parts no longer depend on disputed truth/waiter import names.
Other native bindings still require resolution against the installed runtime.

GSC Tool is a compiler/decompiler, separate from the game loader. The package
uses the source-audited IW7-Mod loader layout; downloading the compiler alone
does not establish that this loader is installed or compatible.

With gsc-tool available, run from the parent of the extracted package:

  gsc-tool -m comp -g iw7 -s pc -y apparition-iw

The -y option checks compilation without writing bytecode. IW7-Mod normally
compiles loose GSC during game loading. Compiling does not link every game asset
or execute a contract check. No external shell/Python menu code is required.

Optional GSC contract run in a later test session

Copy tests/ beneath the same loader filesystem root. Separately copy
 tests/custom_scripts/cp/apparition_tests.gsc
into the loader's active custom_scripts/cp/ folder. The test entry is disabled
unless one of these dvars is explicitly set before the map loads:

  apparition_test_probe 1   Runs one intentional failing check
  apparition_run_tests 1    Runs the contract suites when probe is off

First use the probe in its own session and look for the expected failure and
'Apparition probe observed the expected failure'. Then turn the probe off and
run the suites. A result requires the final PASSED line and no prior script
errors. Most checks operate on isolated structs, including native-style notification
regressions. The cancellation regression observes current quest state but uses no
valid actor and sends no gameplay input. Gameplay integration remains separate.
Actor-list admission tests also read one actual player reference after a bounded
readiness wait; they never modify the native roster or apply gameplay effects.
Remove the test entry point and dvars after the test session.

Original Apparition developer: CF4_99
Original credits: Extinct, CraftyCritter, ItsFebiven, Joel
Reference source version: 1.6.0.9, originally for Black Ops 3 Zombies

DJ request readiness

Speaker requests and the tone-generator request now show the current native
readiness reason when disabled: selected door, DJ state, cooldown or pending
quest callback. Guests see the host requirement. A retained speaker page after
the quest advances explains its stage boundary. The action checks current living
private-host authority and samples native readiness again before the normal DJ
callback. The row keeps its source label and native completion checkbox. Native
quest progression and in-game request behavior still require testing.

Host Field Of View Scale

Host Menu > Field Of View Scale now retains the original65..85 range and one-unit
increment. It uses the exact original global cg_fov setter. Only the current
verified native host in the supported private session may apply it, including
while dead. Native camera rendering and replication to other clients are untested;
this is not described as a per-player camera override. The separate Field Of View
control uses cg_fov_default in Apparition and remains unavailable.

The first valid live reading seeds a source-bounded preview. Its fractional part
is preserved, and later refreshes or page revisits keep the uncommitted preview.
The footer shows the current native setting separately. Left/Right only change
preview; Use validates the source range and current host again before writing.
Readback confirms the numeric setting, not visual acceptance. Native modes can
replace camera effects or the setting. No automatic reset or continuous worker
was added.

Apparition checks fractional endpoint overshoot before direction. At84.5 either
direction first snaps to85; at65.5 either first snaps to65. The next outward
step wraps to the opposite endpoint. This source quirk is retained. Numeric
previews show their value without an invented named-choice index; existing
named sliders keep their original index display. Gameplay, formatting, repeat
input and co-op still require an in-game test.

Optional ammo transition trace

The menu includes a default-off GSC observer for the unresolved ammo last-stand
case. It initializes only its own apparition_trace_ammo diagnostic setting to
zero when absent. It never grants ammo, changes life state, grants perks, emits
weapon/down/revive notifications, or changes quest state. The normal ammo worker
and menu rows are unchanged. No extra CP script or wrapper bypass is needed.

For a later test, update the installed candidate first. Keep the existing
iw7-mod.exe shortcut launch-options line and append, after %command%:

  +set apparition_trace_ammo 1

Start a fresh private normal Spaceland match. The observer allows up to120 seconds
for a supported current host, then records that host only for up to180 seconds
or512 records. It stops on host/session loss, disconnect or game end. This is
script-visible observation, not an external process-memory reader or DLL injector.

Search IW7-Mod's console output for "Apparition ammo trace START". The current
loader's default console log is iw7-mod/logs/console.log relative to the game
folder; a changed g_consoleLog can put it elsewhere. Each trace line has a record
number, elapsed milliseconds, event, native isAlive result, inlaststand marker,
session state, saved ammo mode, current weapon, clip and reserve. Dual wield
also logs left/right clips. Missing markers read unknown and an absent saved
mode reads unset. Valid current-weapon ammo reads are intentionally not gated
on isAlive, so the trace can observe the condition being investigated.

The trace watches weapon_fired, weapon_change, spawned_player, last_stand and
revive. It also samples every0.1 seconds and logs changed readings. Event lines
can precede the ammo worker in the same frame. Stock last_stand and revive
notifications precede parts of their flag/weapon transition; use later sample
lines to inspect settled state. Polling can miss transitions shorter than0.1s.
The trace does not record giveMaxAmmo calls or prove which native writer changed
ammo. A record limit or missing START cannot establish a missing game event.

Use one ammo mode per fresh test match. Establish visible firing/weapon-switch
events while active, then record down/revive behavior and visible ammo counts.
Keep the trace alongside the mode and actions performed. God Mode or Demi-God
must be off for an ordinary damage-driven down. No observer action forces that
transition. Game end/disconnect may terminate the observer without a STOP line.
Remove the added launch option, or set its value to0, before normal play; restart
the game so a previously set diagnostic value is not reused in that process.

The observer, native getters, startup option and log delivery have not run in
the game. Its fixed limits, output cap and event catalog have GSC contracts;
normal/developer compilation and source/bytecode guards do not execute them.

Optional inventory detail in the same trace

Use this value instead of1 when inventory observations are needed:

  +set apparition_trace_ammo 2

Only exact value2 adds inventory details. Other nonzero values retain the
ammo-only trace. The value is captured at startup; change the launch option
and restart for a different trace. It shares the same current-host admission,
five events,100ms samples,180-second duration and512-record cap. No extra worker,
menu control, gameplay setter or diagnostic Dvar is added.

Each detailed state includes inventory8173, inventory8176 and primaries. The
first two labels identify distinct native method IDs that share a decoded
getweaponslistall name; they do not claim complete or disjoint membership.
Each result keeps its original count, order, duplicates and zero-based indices.
Only the first16 entries are displayed, followed by truncated when more exist.
Unknown means no usable array was returned; count=0 means a known empty array.
Non-string and undefined entries are marked rather than treated as weapon names.
The console/logger may impose a further line-length limit; a cut-off line is
incomplete evidence even if no scripted truncation marker is visible.

script_primary, script_secondary and script_special are the player's script
bookkeeping markers for grenades. These fields do not prove current native
offhand-slot assignments. Inventory reads are skipped while sessionstate is
not playing or spectating is set, with an explicit skip reason. They are not
gated on isAlive, so a playing last-stand transition remains observable. The
ordinary life/weapon/ammo part of the trace continues during these skips.

For a later fresh solo test, record the starting weapons and equipment, switch
between held weapons, acquire or replace ordinary equipment, and note each
action beside its trace time. If testing an already supported Take Current
Weapon action, compare the later settled samples as well as the event line.
Do not infer final slot cleanup, list completeness or safe Take All behavior
from a getter name, one snapshot, a truncated line or script bookkeeping alone.
Native execution, getter behavior and output delivery remain untested. This
adds observations for the unresolved mapping; Take All remains unavailable.

Host SV Cheats

Host Menu > SV Cheats now keeps the original fifteenth row and native boolean
checkbox. It toggles the existing server-wide sv_cheats setting between0 and1.
Only a currently admitted private-session native host can apply it; a Co-Host
role or a selected remote player does not substitute for native host identity.
The row is unavailable when the setting is missing or unreadable.

The checkbox and hint describe the captured native reading. Use resolves current
authority and reads the setting again before toggling, so another native writer
can change the next action between drawing and pressing Use. A rejected write
reports incomplete and later draws continue to read the actual setting. No saved
menu flag predicts success. Other native command checks still apply.

The control writes only sv_cheats and adds no worker, previous-value snapshot,
extra cheat-variable reset, or menu-close restore. Current official IW7-Mod source
registers this boolean as replicated and has dedicated setter handling. Actual
GSC setter acceptance, command effects and co-op replication remain untested.
For a later fresh private solo test, observe the checkbox, toggle ON, then OFF,
and confirm it follows the native value without a false success state.
