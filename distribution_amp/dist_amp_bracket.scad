// Mounting bracket for a BNC distribution amplifier in a 10" benchtop rack, 1U.
// Geometry comes from ../lib/rack10.scad; this file only holds the amplifier's numbers.
//
//   * The BNC outputs are on the front, so that face goes to the front through
//     an aperture 3 mm smaller than the case on every side. The single input
//     is on the back.
//   * Shelf with solid side fins and a low fixed lip across the rear of the
//     shelf that stops the unit sliding back when cables are pushed onto the
//     front BNCs. The lip is 5 mm high, well below the input BNC on the back.
//     The unit is dropped in from above and lifted straight out.
//
// Case measured: 165 wide x 105 deep x 31 mm tall.
//
// Print with the front panel face down on the bed (print_orientation = true).

use <../lib/rack10.scad>

/* [Distribution amplifier] */
unit_w = 165;               // BNC face, becomes the front
unit_d = 105;
unit_h = 31;

/* [Bracket] */
rack_u = 1;
lip = 3;                    // panel overlaps the unit by this much on each side
side_clear = 0.75;          // clearance between unit and each side wall
rear_clear = 1.0;           // clearance between unit and the rear stop
shelf_t = 4;                // shelf thickness (6.3 mm available under the unit)
wall_t = 4;                 // side wall thickness
wall_above_shelf = 29;      // side wall height above the shelf top
wall_bottom = 0.5;          // side walls extend down to this z (stiffens the shelf)
fillet_r = 19;              // fillet between the outside of each side wall and the panel
                            // (0: none); max ~19 before it reaches the mounting slots
rear_stop_t = 3;            // rear lip thickness
rear_stop_h = 5;            // rear lip height above the shelf (0 for none)

/* [Rendering] */
print_orientation = false;  // true: lay the bracket with the front panel on the bed
show_unit = false;          // ghost of the amplifier for checking fit
$fn = 48;

unit = [unit_w, unit_d, unit_h];

print_oriented(print_orientation) {
    shelf_bracket(unit, rack_u = rack_u, lip = lip,
                  side_clear = side_clear, rear_clear = rear_clear,
                  shelf_t = shelf_t, wall_t = wall_t,
                  wall_above_shelf = wall_above_shelf, wall_bottom = wall_bottom,
                  rear_stop_t = rear_stop_t, rear_stop_h = rear_stop_h,
                  fillet_r = fillet_r);
    if (show_unit) unit_ghost(unit, rack_u);
}
