# Dungeon Quests

**An in-game browser for every Classic & TBC 5-man dungeon and the quests tied to it.**

[![License: MIT](https://img.shields.io/badge/license-MIT-blue)](LICENSE)
![Version](https://img.shields.io/badge/version-0.2-brightgreen)
![WoW](https://img.shields.io/badge/WoW-TBC%20Classic%20%2F%20Anniversary-f8b700)
![Interface](https://img.shields.io/badge/interface-20505-555)

Pick a dungeon and see every quest tied to it, each tagged with your character's **live
status** (eligible, in progress, done, locked, unavailable) and **where to pick it up** —
quest-giver, zone and coordinates. All 20 Classic and 16 TBC 5-man dungeons ship
pre-populated (~360 quests), and you can add your own in-game or contribute them upstream.

> **Requires [Questie](https://www.curseforge.com/wow/addons/questie).** Quest names,
> levels, factions, quest-givers, pickup coordinates and prerequisites are read live from
> Questie's database at runtime. If Questie isn't enabled, the window says so instead of
> erroring.

<!--
Screenshots: drop images into docs/ and reference them here, e.g.
![Dungeon list](docs/window.png)
-->

## Features

- 🗺️ **Every 5-man, every quest** — all 20 Classic and 16 TBC dungeons pre-populated
  (~360 quests). Pick a dungeon on the left; its quests appear on the right.
- 🎯 **Live per-character status** — each quest is tagged from your own quest log and
  history:

  | Tag | Meaning |
  |-----|---------|
  | **Eligible** (blue) | You can pick it up right now |
  | **In Progress** (yellow) | Currently in your quest log |
  | **Locked** (grey) | Right faction/class, but a prerequisite or level gate isn't met (hover for the reason) |
  | **Done** (green) | Already completed |
  | **Unavailable** (red) | Wrong faction / class / race for this character |

- 📍 **Pickup location** — each row's second line shows quest-giver — zone (x, y); hover for
  the full giver list, level, prerequisites and quest ID.
- 🔗 **Wowhead links** — left-click a quest to pop up its Wowhead link, auto-selected for a
  quick Ctrl+C.
- ✅ **"Seen" marks** — right-click a quest to strike it through (saved account-wide);
  right-click again to clear.
- ➕ **Add your own** — paste a Wowhead quest link or enter an ID; it's validated against
  Questie and saved locally (tagged `(custom)`). Fills the gaps in dungeons that don't ship
  with quests yet.
- 🍞 **Breadcrumbs, counts & more** — optional breadcrumb-quest listing, per-dungeon
  `done/total` completion counts, collapsible Classic/TBC headers, name search, and a
  window-opacity slider.

## Usage

| Command | What it does |
|---|---|
| `/dq` (or `/dungeonquests`) | Open / close the window. |
| `/dq config` | Open settings & options. |
| `/dq validate` | Sanity-check every catalogued quest ID against Questie (prints wrong/missing IDs). |
| `/dq reset` | Restore default settings. |

Settings also live under **Esc → Options → AddOns → Dungeon Quests** (or the **Settings**
button in the window): show only your faction's quests, hide completed/unavailable quests,
show breadcrumb quests, completion counts, and window opacity. All settings are saved
account-wide.

## Contributing quest data

The quest database is a single hand-maintained file: **`Data.lua`**. Everything else
(names, levels, factions, quest-givers, coordinates, prerequisites) is read live from
Questie at runtime, so a contribution is almost always just **editing `Data.lua`**.

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

To add or fix quests:

1. Find the quest's numeric id (e.g. from its Wowhead URL: `wowhead.com/.../quest=NNNNN`).
2. Add a `{ id = NNNNN, name = "Quest Name" }` line to that dungeon's `quests` list (or add a
   whole new dungeon entry).
3. In-game, `/reload` then run **`/dq validate`** — it checks every id against Questie and
   prints any that are missing or whose name doesn't match.
4. Open a [pull request](https://github.com/SokratisV/DungeonQuests/pulls) with your
   `Data.lua` change.

You do **not** need to touch `Core.lua`, `Questie.lua`, `Status.lua`, or `UI.lua` to add quest
data — those only change for actual addon behaviour. Bug reports and ideas are welcome via the
[issue tracker](https://github.com/SokratisV/DungeonQuests/issues).

## License

[MIT](LICENSE).
