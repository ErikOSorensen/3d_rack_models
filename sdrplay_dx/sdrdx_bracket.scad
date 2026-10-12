// Mounting bracket for an SDRplay RSPdx in a 10" benchtop rack, 1U.
// Geometry comes from ../lib/rack10.scad; this file only holds the RSPdx numbers.
//
//   * Centred on a 1U front panel, antenna connectors (SMA A, SMA B, BNC C)
//     facing forward through the aperture, USB-B at the back.
//   * Aperture 2 mm smaller than the unit on every side.
//   * Shelf with side fins (the RSPdx has no side vents) and a low fixed lip
//     across the rear of the shelf as the stopper. The unit is dropped in from
//     above and lifted straight out; the lip is low enough to clear the USB socket.
//
// Dimensions: the RSPdx datasheet (RSPdxDatasheetV1.0.pdf) says 113 x 94 x 35 mm,
// 315 g. SDRdx (the spec in this directory) says 133 x 94 x 35 mm. The 94 mm
// connector face is the front, so width = 94. The depth below follows the
// datasheet; measure the unit and change unit_d if it really is 133 mm.
//
// The unit is 35 mm tall, which leaves only 4.3 mm under it in a 1U panel, so the
// shelf is 3 mm thick and the side fins do not extend below the shelf.
//
// Print with the front panel face down on the bed (print_orientation = true).

use <../lib/rack10.scad>

/* [RSPdx] */
unit_w = 94;                // connector face, becomes the front
unit_d = 113;               // datasheet; SDRdx spec says 133 - measure!
unit_h = 35;

/* [Bracket] */
rack_u = 1;
lip = 2;                    // panel overlaps the unit by this much on each side
side_clear = 0.75;          // clearance between unit and each side wall
rear_clear = 1.0;           // clearance between unit and the rear stop
shelf_t = 3;                // shelf thickness (only 4.3 mm available under the unit)
wall_t = 4;                 // side wall thickness
wall_above_shelf = 33;      // side wall height above the shelf top
wall_bottom = 0;            // clamped to the shelf bottom by the library
rear_stop_t = 3;            // rear lip thickness
rear_stop_h = 5;            // rear lip height above the shelf (0 for none)

/* [Rendering] */
print_orientation = false;  // true: lay the bracket with the front panel on the bed
show_unit = false;          // ghost of the RSPdx for checking fit
$fn = 48;

unit = [unit_w, unit_d, unit_h];

print_oriented(print_orientation) {
    shelf_bracket(unit, rack_u = rack_u, lip = lip,
                  side_clear = side_clear, rear_clear = rear_clear,
                  shelf_t = shelf_t, wall_t = wall_t,
                  wall_above_shelf = wall_above_shelf, wall_bottom = wall_bottom,
                  rear_stop_t = rear_stop_t, rear_stop_h = rear_stop_h);
    if (show_unit) unit_ghost(unit, rack_u);
}
