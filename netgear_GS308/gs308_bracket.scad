// Mounting bracket for a Netgear GS308 in a 10" benchtop rack, 1U.
// Geometry comes from ../lib/rack10.scad; this file only holds the GS308 numbers.
//
//   * 5 mm front panel, one U tall, M6 slots 5 mm wider than needed.
//   * Aperture 1 mm smaller than the switch on every side.
//   * Shelf with side fins; the fins have a window where the GS308 has its
//     ventilation holes (45..90 mm from the front, vertically centred, 12 mm tall).
//   * A low fixed lip across the rear of the shelf stops the switch sliding back
//     when cables are pushed into the front ports. The switch is dropped in from
//     above and lifted straight out. Remove the rubber feet.
//
// Print with the front panel face down on the bed (print_orientation = true).

use <../lib/rack10.scad>

/* [GS308] */
unit_w = 153;
unit_h = 26;
unit_d = 101;
vent_front = 45;            // ventilation holes start, measured from the front
vent_back = 90;             // ventilation holes end, measured from the front
vent_h = 12;                // ventilation holes height, vertically centred

/* [Bracket] */
rack_u = 1;
lip = 1;                    // panel overlaps the switch by this much on each side
side_clear = 0.75;          // clearance between switch and each side wall
rear_clear = 1.0;           // clearance between switch and the rear stop
shelf_t = 4;                // shelf thickness
wall_t = 4;                 // side wall thickness
wall_above_shelf = 24;      // side wall height above the shelf top
wall_bottom = 0.5;          // side walls extend down to this z (stiffens the shelf)
vent_margin = 1.5;          // vent window is this much bigger than the vent, all round
fillet_r = 25;               // fillet between the outside of each side wall and the panel (0: none)
rear_stop_t = 3;            // rear lip thickness
rear_stop_h = 5;            // rear lip height above the shelf (0 for none)

/* [Rendering] */
print_orientation = false;  // true: lay the bracket with the front panel on the bed
show_unit = false;          // ghost of the GS308 for checking fit
$fn = 48;

unit = [unit_w, unit_d, unit_h];

print_oriented(print_orientation) {
    shelf_bracket(unit, rack_u = rack_u, lip = lip,
                  side_clear = side_clear, rear_clear = rear_clear,
                  shelf_t = shelf_t, wall_t = wall_t,
                  wall_above_shelf = wall_above_shelf, wall_bottom = wall_bottom,
                  rear_stop_t = rear_stop_t, rear_stop_h = rear_stop_h,
                  fillet_r = fillet_r,
                  vents = [[vent_front, vent_back, unit_h / 2, vent_h]],
                  vent_margin = vent_margin);
    if (show_unit) unit_ghost(unit, rack_u);
}
