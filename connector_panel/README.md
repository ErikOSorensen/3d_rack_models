# Connector panels

A connector panel is a plain front panel for the 10" rack with a row of panel-mount
connectors: Neutrik D-size connectors (XLR, speakON, etherCON, BNC, USB, ... in the
D housing) and keystone jacks (RJ45, HDMI, USB, F, ... modules), in any mix. There is
no shelf behind it.

The geometry lives in `connector_panel()` in `../lib/rack10.scad`;
`connector_panel.scad` here is an example (four rear-mounted Neutrik D connectors and
three keystones on 1U) and the file to copy for a new panel.
`R3p1.scad` is a panel made that way: three rear-mounted Neutrik D connectors on
the left and five keystones to the right, a full 1U row. `R4p1.scad` is a 1U row of seven
rear-mounted Neutrik D connectors, as many as fit.

## Design rules

The panel follows the general rules in `../README.md`:

- The panel is 5 mm thick, a whole number of U tall, and 254 mm (10") wide.
- It has 4 + (U - 1) * 2 slots for M6 bolts. Each slot is 10 mm wider than the bolt
  needs, to allow for the slack in the home-built racks, and stays at least 3 mm from
  the panel edge.

The connector rules:

- **Thin where the Neutriks are.** Neutrik D connectors are made for sheet-metal
  panels about 1-3 mm thick, so a 5 mm panel cannot hold them as it is. Behind each
  one the panel is thinned from the back with a pocket down to `skin`, 2 mm by
  default. The rest of the panel stays 5 mm thick.
- **A box behind each keystone.** A keystone jack locks with a hook and a latch
  that sit 5-8 mm behind its face, and its body widens behind the nose. The jack
  goes in through a 3 mm front plate into a cavity where the hook and latch
  spring out and lock behind the plate, and a thin lip at the back of the cavity
  stops the body so the jack cannot be pushed through. The cavity is 9.5 mm deep
  from the front face, so each keystone gets a 19 x 28.3 mm box on the back of
  the panel with 2 mm walls. The profile is copied from the
  [10-inch Keystone Patchpanel x10 ports](https://www.printables.com/model/1088263)
  by Mauricio Pessoa, which is known to work.
- **Stiffening lips.** The panel is held only at its ends, 236 mm apart, and a
  cable pushed into it bends it front to back. Lips along the top and bottom edge
  on the back turn the panel into a shallow channel, roughly ten times stiffer.
  - Size: 3 mm thick and 12 mm deep, with a 1.5 mm fillet where they meet the
    panel and rounded ends.
  - Length: 212 mm, so they stop short of the rails, like the shelves do.
  - Set with `stiffeners` (`"both"`, `"top"`, `"bottom"` or `"none"`),
    `stiffener_t` and `stiffener_depth`.
  - They stay inside the panel height and must not overlap a connector pocket.
    On 1U that leaves room for a lip up to about 3.3 mm thick with front-mounted
    Neutriks, and about 4.5 mm with rear-mounted ones.
- **Clear of the mounting bolts.** Connectors are kept 8 mm inside the inner end of
  the mounting slots (`edge_margin`), so washers and bolt heads have room. That
  leaves about 199 mm of usable width.
- **Material between connectors.** There is at least 2 mm of material between
  neighbouring pockets (`min_web`).
- **Inside the panel height.** Every pocket must fit inside the panel height with
  1 mm to spare.
- **Checked when it builds.** The model stops with an error that names the
  offending connector if any of these rules is broken, including a connector that
  collides with a lip. It also stops on an unknown connector type or stiffener
  setting, or if `skin` is too thin for a countersink.

## Connector types

| Type | Front opening | Behind the panel | Fixing |
|---|---|---|---|
| `"neutrik_d_rear"` | 24 mm round hole, 4 countersunk M3 holes | 26.6 x 31.6 mm pocket that holds the flange square | Countersunk M3 x 6 from the front into the threaded holes of the **M3 versions** (e.g. NC3FDM3-L-1, NC3MDM3-L-1) |
| `"neutrik_d"` | 24 mm round hole, 4 plain M3 holes | 28 x 34 mm pocket with room for nuts | Flange on the front face, M3 x 8 screws through the connector's holes, nuts behind |
| `"keystone"` | 15 x 16 mm in a 3 mm plate, top edge ramped | 15 x 24.3 mm cavity 3-8 mm deep, a 1.5 mm stop lip with a 15 x 19.8 mm window behind it, all in a 19 x 28.3 mm box 4.5 mm proud of the panel back | Snaps in from the front, hook and latch behind the 3 mm plate |

Notes on each type:

- **`"neutrik_d_rear"`** gives the cleanest front, and the panel takes the load
  when a cable is pulled. Use it when buying new connectors.
- **`"neutrik_d"`** works with the plain (countersunk-hole) connectors you may
  already have.
- **Neutrik screw holes:** all four corners of the 19 x 24 mm screw pattern are
  drilled, so connectors with screws on either diagonal fit. With rear mounting,
  the two unused countersunk holes show on the front.
- **Keystone:** the latch is at the top. Insert the jack hook-first at the bottom,
  then press the top in until the latch snaps behind the plate; the ramp on the
  top edge of the opening gives the latch room to swing in. The stop lip sits
  8 mm behind the front face, which suits the common jacks: they snap in and
  release cleanly.

How many fit in one row on 1U (all of one type):

| Type | Max per 1U row |
|---|---|
| `"neutrik_d_rear"` | 7 (needs `spacing = 2`; even spreading gives 6) |
| `"neutrik_d"` | 6 |
| `"keystone"` | 9 |

Mixed rows: see [densest-panels.md](densest-panels.md) for the densest
combinations of Neutriks and keystones that fit in 1U.

## Making a panel

1. **Copy the example.** Copy `connector_panel.scad` to a new directory, and name
   the file after the panel.
2. **List the connectors.** Set `connectors` to the connectors from left to right,
   as seen from the front:
   ```openscad
   connectors = ["neutrik_d_rear", "neutrik_d_rear", "keystone", "keystone"];
   ```
3. **Choose the spacing.**
   - By default the row is spread evenly across the usable width.
   - Set `spacing` (mm between pockets) to pack them closer, centred on the panel.
   - For full control, such as two rows on a 2U panel, call `connector_panel()`
     with `positions = [[x, z], ...]`: one entry per connector, with x measured from
     the panel centre and z from the panel bottom.
4. **Set the height.** Set `rack_u` if one U is not enough.
5. **Render and check the console.** Render (F6) and read the console:
   - The `ECHO` line lists the x position of each connector.
   - Any broken rule shows up as an `ERROR`.

## Printing

- PETG, like the rest of the repo.
- Print with the front face on the bed (`print_orientation = true`). The pockets
  then open upwards and the lips are plain vertical walls, so no supports are
  needed. The 2 mm front skin at the Neutriks is the first layers, which gives
  the best surface where the flange seats. The stop lip of each keystone box is
  a 15 mm bridge over the cavity and the ramp overhangs at 50 degrees; both
  print fine in PETG without support.

## Connector sizes

The defaults fit the connectors as printed. All sizes are named constants in
the connector section of `../lib/rack10.scad`, shared by every panel in the repo:

- **Neutrik D:**
  - `NEUTRIK_D_HOLE`: the hole size.
  - `NEUTRIK_D_SCREWS`: the screw spacing.
  - `NEUTRIK_D_REAR_CLEAR`: the gap around the flange in the rear-mount pocket.
  - `NEUTRIK_D_CSK_D`: the countersink size.
- **Keystone:**
  - `KEYSTONE_W` and `KEYSTONE_FACE_H`: the opening.
  - `KEYSTONE_PLATE_T`: the front plate the hook and latch lock behind, and
    `KEYSTONE_RAMP_D` the depth the ramp on its top edge reaches.
  - `KEYSTONE_HOOK` and `KEYSTONE_CLIP`: the room in the cavity below and above
    the opening for the hook and the latch.
  - `KEYSTONE_STOP`, `KEYSTONE_STOP_T` and `KEYSTONE_WINDOW`: the depth and
    thickness of the stop lip and how far its window reaches above the opening.
  - `KEYSTONE_WALL`: the walls of the box.
