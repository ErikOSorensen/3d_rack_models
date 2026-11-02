// Mounting bracket for an SDRplay RSPdx in a 10" benchtop rack, 1U.
// Geometry comes from ../lib/rack10.scad; this file only holds the RSPdx numbers.
//
//   * Centred on a 1U front panel, antenna connectors (SMA A, SMA B, BNC C)
//     facing forward through the aperture, USB-B at the back.
//   * The panel overlaps the unit by 4 mm at the sides and bottom, holding it,
//     and only 1 mm at the top so it lifts straight out.
//   * Shelf with side fins (the RSPdx has no side vents) and a low fixed lip
//     across the rear of the shelf as the stopper. For the cables at the back
//     the stopper is only 20 mm long from the left fin and 30 mm from the right
//     fin (seen from the front); the middle is open.
//
// Dimensions: measured case 98 x 93 x 33 mm (see SDRdx in this directory), the
// 93 mm connector face to the front, so width = 93 and depth = 98. The datasheet
// (RSPdxDatasheetV1.0.pdf) gives 113 x 94 x 35 mm, which includes the connectors.
//
// Print with the front panel face down on the bed (print_orientation = true).

use <../lib/rack10.scad>

/* [RSPdx] */
unit_w = 93;                // connector face, becomes the front
unit_d = 98;
unit_h = 33;

/* [Bracket] */
rack_u = 1;
lip_side = 4;               // panel overlaps the unit by this much at each side
lip_bottom = 4;             // ... and at the bottom
lip_top = 1;                // ... and at the top
side_clear = 0.75;          // clearance between unit and each side wall
rear_clear = 1.0;           // clearance between unit and the rear stop
shelf_t = 4;                // shelf thickness (5.3 mm available under the unit)
wall_t = 4;                 // side wall thickness
wall_above_shelf = 31;      // side wall height above the shelf top
wall_bottom = 0.5;          // side walls extend down to this z (stiffens the shelf)
fillet_r = 25;              // fillet between the outside of each side wall and the panel
                            // (0: none); max ~55 before it reaches the mounting slots
rear_stop_t = 3;            // rear lip thickness
rear_stop_h = 5;            // rear lip height above the shelf (0 for none)
rear_stop_left = 20;        // rear lip length from the left fin (seen from the front)
rear_stop_right = 30;       // rear lip length from the right fin (seen from the front)

/* [Rendering] */
print_orientation = false;  // true: lay the bracket with the front panel on the bed
show_unit = false;          // ghost of the RSPdx for checking fit
$fn = 48;

unit = [unit_w, unit_d, unit_h];
lip  = [lip_side, lip_bottom, lip_top];

assert(rear_stop_left + rear_stop_right < unit_w, "rear stop pieces overlap: no cable gap left");

print_oriented(print_orientation) {
    shelf_bracket(unit, rack_u = rack_u, lip = lip,
                  side_clear = side_clear, rear_clear = rear_clear,
                  shelf_t = shelf_t, wall_t = wall_t,
                  wall_above_shelf = wall_above_shelf, wall_bottom = wall_bottom,
                  rear_stop_t = rear_stop_t, rear_stop_h = rear_stop_h,
                  rear_stop_gaps = [[rear_stop_left, unit_w - rear_stop_right]],
                  fillet_r = fillet_r);
    if (show_unit) unit_ghost(unit, rack_u);
}
