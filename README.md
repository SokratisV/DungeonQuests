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

Filters (top of the window): **My faction only**, **Hide completed**, **Hide unavailable**,
and **Breadcrumbs** — when on, breadcrumb quests that lead to a quest are shown (marked with a
🍞 bread icon and indented above the quest they point to). Breadcrumbs are also always listed in
a quest's hover tooltip. The search box filters the dungeon list by name.

## Requires Questie

Quest names, levels, factions, quest-givers, pickup coordinates and prerequisites are read
live from the **Questie** addon's database at runtime. Questie must be installed and enabled.
If it isn't, the window says so instead of erroring.

## Adding dungeons

`Data.lua` is the only hand-maintained file. Each dungeon is an entry in `ns.dungeons` with
a `quests` list of `{ id = <questID>, name = "<expected name>" }`. There is no API to enumerate
"all quests for a dungeon", so this mapping is curated; everything else comes from Questie.
After adding IDs, run `/dq validate` in-game to confirm they're correct.

Currently populated: **Uldaman**, **Scarlet Monastery**, **Zul'Farrak**, **Temple of Atal'Hakkar
(Sunken Temple)**, and **Blackrock Depths**. All other Classic + TBC dungeons are listed with empty
quest sets, ready to be filled in the same way.
