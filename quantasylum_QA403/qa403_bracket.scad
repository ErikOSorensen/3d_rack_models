// Mounting bracket for a QuantAsylum QA403 audio analyzer in a 10" benchtop rack, 2U.
// Geometry comes from ../lib/rack10.scad; this file only holds the QA403 numbers.
//
//   * BNC face to the front, through an aperture 1 mm smaller than the unit on
//     every side. USB at the back.
//   * The unit is 44 mm tall, more than a 1U panel (43.65 mm), hence 2U; the
//     unit is vertically centred on the panel.
//   * Shelf with side fins and a low fixed lip across the rear of the shelf
//     that stops the unit sliding back when BNC cables are pushed on. The unit
//     is dropped in from above and lifted straight out.
//
// Dimensions from the QuantAsylum product page: 177 W x 44 H x 97 D mm
// (115 mm deep including the BNC connectors). Measure the unit to confirm.
//
// Print with the front panel face down on the bed (print_orientation = true).

use <../lib/rack10.scad>

/* [QA403] */
unit_w = 177;
unit_h = 44;
unit_d = 97;                // body only; the BNCs stick out through the aperture

/* [Bracket] */
rack_u = 2;
lip = 1;                    // panel overlaps the unit by this much on each side
side_clear = 0.75;          // clearance between unit and each side wall
rear_clear = 1.0;           // clearance between unit and the rear stop
shelf_t = 4;                // shelf thickness
wall_t = 4;                 // side wall thickness
wall_above_shelf = 40;      // side wall height above the shelf top
wall_bottom = 0.5;          // side walls extend down to this z (stiffens the shelf)
fillet_r = 15;              // fillet between the outside of each side wall and the panel
                            // (0: none); max ~18 before it reaches the mounting slots
rear_stop_t = 3;            // rear lip thickness
rear_stop_h = 5;            // rear lip height above the shelf (0 for none)

/* [Rendering] */
print_orientation = false;  // true: lay the bracket with the front panel on the bed
show_unit = false;          // ghost of the QA403 for checking fit
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
