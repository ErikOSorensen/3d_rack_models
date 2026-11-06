# Densest 1U connector panels

The most connectors that fit in one row on a 1U panel, checked by building each
combination with `connector_panel()` (the model stops with an error when a row
does not fit). Numbers as of the keystone box profile of November 2026.

## The rule

A row fits when the pockets, with at least 2 mm of material between them, fit
inside the usable width between the mounting-bolt washers:

| | mm |
|---|---|
| Usable width (`edge_margin = 8` inside the slots) | 198.8 |
| Rear-mounted Neutrik D pocket (`"neutrik_d_rear"`) | 26.6 |
| Front-mounted Neutrik D pocket (`"neutrik_d"`) | 28 |
| Keystone box (`"keystone"`) | 19 |
| Minimum web between pockets (`min_web`) | 2 |

So a row of widths `w` fits when `sum(w) + 2 * (n - 1) <= 198.8`. It can be
spread evenly (`spacing = -1`) only when the even gap, `(198.8 - sum(w)) / (n + 1)`,
is at least 2 mm; otherwise set `spacing = 2` and the row is packed and centred.

## Rear-mounted Neutrik D and keystones

Each row is a maximum: one more of either type does not fit. Anything with fewer
of either type fits too.

| Neutrik D (rear) | Keystones | Row width | Spacing | Example |
|---|---|---|---|---|
| 7 | 0 | 198.2 | `spacing = 2` | `R4p1.scad` |
| 6 | 1 | 190.6 | even or `2` | |
| 5 | 2 | 183.0 | even or `2` | |
| 4 | 4 | 196.4 | `spacing = 2` | |
| 3 | 5 | 182.8 | even or `2` | `R3p1.scad` |
| 2 | 6 | 179.2 | even or `2` | |
| 1 | 8 | 192.6 | even or `2` | |
| 0 | 9 | 187.0 | even or `2` | |

Row width is the packed width, pockets plus 2 mm webs.

## Front-mounted Neutrik D and keystones

| Neutrik D (front) | Keystones | Row width | Spacing |
|---|---|---|---|
| 6 | 0 | 178.0 | even or `2` |
| 5 | 2 | 186.0 | even or `2` |
| 4 | 3 | 175.0 | even or `2` |
| 3 | 5 | 189.0 | even or `2` |
| 2 | 6 | 180.0 | even or `2` |
| 1 | 8 | 196.0 | `spacing = 2` |
| 0 | 9 | 187.0 | even or `2` |

Seven front-mounted Neutriks need 208 mm and do not fit; six is the limit.

## Beyond this

- **2U** gives two rows. Call `connector_panel()` with `positions = [[x, z], ...]`
  (x from the panel centre, z from the panel bottom); each row then holds what the
  tables above allow.
- **Squeezing a row** by lowering `edge_margin` from 8 mm costs washer room at the
  mounting bolts; 4 mm gains 8 mm of row width. Letting neighbouring keystone
  boxes share a wall would gain 4 mm per pair but is not implemented. Neither
  gets six Neutriks and two keystones (211.6 mm) into 1U.
