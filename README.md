# Dungeon Quests

An in-game browser for every Classic & TBC 5-man dungeon and the quests tied to it.
For each quest it shows your live status and where to pick it up.

## Usage

- `/dq` (or `/dungeonquests`) — open/close the window.
- `/dq validate` — sanity-check every catalogued quest ID against Questie's database
  (prints any wrong/missing IDs to chat). Run this after editing `Data.lua`.
- `/dq reset` — restore default settings.

Pick a dungeon on the left; its quests appear on the right, each tagged:

| Tag | Meaning |
|-----|---------|
| **Eligible** (blue) | You can pick it up right now |
| **In Progress** (yellow) | Currently in your quest log |
| **Locked** (grey) | Right faction/class, but a prerequisite or level gate isn't met (hover for the reason) |
| **Done** (green) | Already completed |
| **Unavailable** (red) | Wrong faction / class / race for this character |

Each row's second line is the pickup location: quest-giver NPC — zone (x, y). Hover a
row for the full quest-giver list, level, prerequisites and quest ID. **Left-click a quest**
to pop up its Wowhead link (auto-selected — press Ctrl+C to copy). **Right-click a quest**
to mark it as "seen" — it's struck through and faded (right-click again to unmark). Seen
marks are saved account-wide.

**Add your own quests:** with a dungeon selected, click **+ Add quest** (top-right) and enter a
quest ID — or just paste a Wowhead quest link. It's validated against Questie and added to that
dungeon (tagged `(custom)`, saved account-wide). To remove one, click the red **X** on its row (or
Shift-click it). This also lets you fill in the dungeons that don't ship with quests yet.

The **Classic** and **TBC** category headers are collapsible — click one to fold/unfold its
dungeons (remembered between sessions; searching temporarily shows everything). The search box
filters the dungeon list by name.

### Settings

All options live in the standard settings panel — **Esc → Options → AddOns → Dungeon Quests**,
the **Settings** button in the window, or `/dq config`:

- **Show only my faction's quests**, **Hide completed quests**, **Hide unavailable quests**
- **Show breadcrumb quests** — lists the breadcrumb quests leading to a quest (🍞, indented above
  it); breadcrumbs are also always shown in a quest's hover tooltip
- **Show completion counts** — each dungeon's `done/total` in the list, with its name turning
  **green** when complete; **Count breadcrumbs toward completion** includes them in the totals
- **Window opacity** — fades the whole window (100% = fully opaque)

All settings are saved account-wide.

## Requires Questie

Quest names, levels, factions, quest-givers, pickup coordinates and prerequisites are read
live from the **Questie** addon's database at runtime. Questie must be installed and enabled.
If it isn't, the window says so instead of erroring.

All 20 Classic and 16 TBC 5-man dungeons ship pre-populated (~360 quests). You can still add
your own quests in-game with **+ Add quest** (saved locally), or contribute them to everyone via
a pull request — see below.

## Contributing quest data

The quest database is a single hand-maintained file: **`Data.lua`**. Everything else
(names, levels, factions, quest-givers, pickup coordinates, prerequisites) is read live from
Questie at runtime, so a contribution is almost always just **editing `Data.lua`** — no other
file needs to change.

### What a dungeon entry looks like

`ns.dungeons` is an ordered list. Each dungeon is one entry:

```lua
{ key = "uld", name = "Uldaman", expansion = "Classic", minLevel = 35, maxLevel = 45,
  zone = "Badlands", quests = {
    { id = 1144, name = "Reclaimed Treasures" },
    { id = 2278, name = "The Platinum Discs" },
    -- ...
} },
```

- `key` — a unique short id for the dungeon.
- `expansion` — `"Classic"` or `"TBC"` (controls the grouping in the list).
- `minLevel` / `maxLevel` / `zone` — shown in the header; cosmetic.
- `quests` — the curated part: a list of `{ id = <questID>, name = "<expected name>" }`.
  The `name` is only a fallback label and lets `/dq validate` flag a wrong id. Questie's name
  is authoritative at runtime, so faction/level/giver are filled in automatically — you only
  need the correct **quest id**.

### To add or fix quests

1. Find the quest's numeric id (e.g. from its Wowhead URL: `wowhead.com/.../quest=NNNNN`).
2. Add a `{ id = NNNNN, name = "Quest Name" }` line to that dungeon's `quests` list (or add a
   whole new dungeon entry).
3. In-game, `/reload` then run **`/dq validate`** — it checks every id against Questie and prints
   any that are missing or whose name doesn't match, so mistakes are easy to catch.
4. Open a pull request on GitHub with your `Data.lua` change.

That's it — you do **not** need to touch `Core.lua`, `Questie.lua`, `Status.lua`, or `UI.lua` to
add quest data. Those only change for actual addon behaviour/features.
