// Mounting bracket for a TP-Link 7-port USB 3.0 hub in a 10" benchtop rack, 1U.
// Geometry comes from ../lib/rack10.scad; this file only holds the hub numbers.
//
//   * The seven USB outputs are on the front and fit within 155 mm, so the
//     aperture is 155 mm wide (5 mm lip at each side) and 1 mm smaller than the
//     hub at the top and bottom.
//   * Power and USB-in are on the back, at the right end seen from the front.
//     The rear lip has a 45 mm gap there for the plugs.
//   * The power button is on top of the hub, 11 mm from its left side. Rather
//     than a lever, the hub sits as low as the bracket allows (shelf on the
//     panel bottom) and a round hole in the panel above the hub lets a pencil
//     reach in and press the button from the front.
//   * Shelf with side fins; the hub is dropped in from above and lifted
//     straight out.
//
// Print with the front panel face down on the bed (print_orientation = true).

include <../lib/rack10.scad>

/* [USB hub] */
unit_w = 165;
unit_h = 20;
unit_d = 66;
aperture_w = 155;           // the USB outputs fit within this width
rear_gap_w = 45;            // opening in the rear lip for power and USB-in, at the right end
button_x = 11;              // power button, from the left side of the hub (seen from the front)
button_y = 20;              // power button, from the front face of the hub (TODO: measure)

/* [Bracket] */
rack_u = 1;
lip_z = 2;                  // panel overlaps the hub by this much at the top and bottom
side_clear = 0.75;          // clearance between hub and each side wall
rear_clear = 1.0;           // clearance between hub and the rear stop
shelf_t = 4;                // shelf thickness; the shelf sits on the panel bottom
wall_t = 4;                 // side wall thickness
wall_above_shelf = 18;      // side wall height above the shelf top
wall_bottom = 0.5;          // side walls extend down to this z (stiffens the shelf)
fillet_r = 19;              // fillet between the outside of each side wall and the panel
                            // (0: none); max ~19 before it reaches the mounting slots
rear_stop_t = 3;            // rear lip thickness
rear_stop_h = 7;            // rear lip height above the shelf (0 for none)

/* [Power button access] */
button_hole_d = 13;         // hole in the panel above the hub, for a pencil (0: none);
                            // max ~14 between the aperture and the top edge
button_hole_z = 33.5;       // hole centre above the panel bottom
button_hole_chamfer = 1;    // edge chamfer on both faces of the hole

/* [Rendering] */
print_orientation = false;  // true: lay the bracket with the front panel on the bed
show_unit = false;          // ghost of the hub for checking fit
$fn = 48;

unit    = [unit_w, unit_d, unit_h];
panel_t = 5;
panel_h = panel_height(rack_u);
unit_z  = shelf_t;                                // hub bottom; the shelf rests on z = 0
lip     = [(unit_w - aperture_w) / 2, lip_z];
hole_x  = -unit_w / 2 + button_x;                 // the hole is straight above the button

assert(button_hole_d == 0 || button_hole_z - button_hole_d / 2 >= unit_z + unit_h - lip_z + 3,
       "button hole breaks into the aperture: raise button_hole_z or shrink it");
assert(button_hole_d == 0 || button_hole_z + button_hole_d / 2 <= panel_h - 3,
       "button hole too close to the top of the panel");
assert(button_hole_d == 0 || abs(hole_x) + button_hole_d / 2 <= unit_w / 2,
       "button hole is outside the width of the hub");

echo(str("pencil reaches the button at ", atan((button_hole_z - (unit_z + unit_h)) / (panel_t + button_y)),
         " degrees down from the hole (button ", button_y, " mm behind the front)"));

module button_hole() {
    translate([hole_x, 0, button_hole_z]) rotate([-90, 0, 0]) {
        translate([0, 0, -1]) cylinder(d = button_hole_d, h = panel_t + 2);
        c = button_hole_chamfer;
        if (c > 0) {
            translate([0, 0, -0.01]) cylinder(d1 = button_hole_d + 2 * c, d2 = button_hole_d, h = c);
            translate([0, 0, panel_t - c + 0.01]) cylinder(d1 = button_hole_d, d2 = button_hole_d + 2 * c, h = c);
        }
    }
}

print_oriented(print_orientation) {
    difference() {
        shelf_bracket(unit, rack_u = rack_u, lip = lip, unit_z = unit_z,
                      side_clear = side_clear, rear_clear = rear_clear,
                      shelf_t = shelf_t, wall_t = wall_t,
                      wall_above_shelf = wall_above_shelf, wall_bottom = wall_bottom,
                      rear_stop_t = rear_stop_t, rear_stop_h = rear_stop_h,
                      rear_stop_gaps = [[unit_w - rear_gap_w, unit_w]],
                      fillet_r = fillet_r);
        if (button_hole_d > 0) button_hole();
    }
    if (show_unit) {
        unit_ghost(unit, rack_u, unit_z = unit_z);
        // the power button
        %translate([hole_x, panel_t + button_y, unit_z + unit_h]) cylinder(d = 6, h = 1);
    }
}
