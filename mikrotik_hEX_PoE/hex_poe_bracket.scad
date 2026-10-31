// Mounting bracket for a MikroTik hEX PoE (RB960PGS) router in a 10" benchtop rack, 1U.
// Geometry comes from ../lib/rack10.scad; this file only holds the hEX PoE numbers.
//
//   * All connectors (DC jack, SFP, Ether1-5, USB) are on one face of the
//     router, so that face goes to the front, through an aperture 1 mm smaller
//     than the case on every side. The LEDs are on the same face.
//   * Shelf with side fins and a low fixed lip across the rear of the shelf that
//     stops the router sliding back when cables are pushed into the ports. The
//     router is dropped in from above and lifted straight out.
//   * The DC jack is at the left end of the connector face (seen from the
//     front). A round hole in the panel to the left of the aperture lets the
//     power plug be threaded through from the back, so the power cable can run
//     along the outside of the left fin to a supply at the back of the rack.
//     Two cable-tie bridges on the outside of the left fin hold the cable.
//   * The side fins are solid. If the case turns out to have vents in its sides,
//     list them in `vents` (from the front face / bottom of the case) and the
//     fins get matching windows.
//
// Dimensions from the MikroTik brochure: 114 x 137 x 29 mm; the connector face
// is the 137 mm side. Measure the unit to confirm (and remove the rubber feet,
// or add their height to unit_h).
//
// Print with the front panel face down on the bed (print_orientation = true).

include <../lib/rack10.scad>

/* [hEX PoE] */
unit_w = 137;               // connector face
unit_h = 29;
unit_d = 114;
vents = [];                 // [[y_from, y_to, z_centre, height], ...] side vents, if any

/* [Bracket] */
rack_u = 1;
lip = 1;                    // panel overlaps the router by this much on each side
side_clear = 0.75;          // clearance between router and each side wall
rear_clear = 1.0;           // clearance between router and the rear stop
shelf_t = 4;                // shelf thickness
wall_t = 4;                 // side wall thickness
wall_above_shelf = 27;      // side wall height above the shelf top
wall_bottom = 0.5;          // side walls extend down to this z (stiffens the shelf)
vent_margin = 1.5;          // vent window is this much bigger than the vent, all round
fillet_r = 25;              // fillet between the outside of each side wall and the panel
                            // (0: none); max ~38 before it reaches the mounting slots
rear_stop_t = 3;            // rear lip thickness
rear_stop_h = 5;            // rear lip height above the shelf (0 for none)

/* [Power cable] */
power_hole_d = 15;          // hole for threading the power plug through the panel (0: none)
power_hole_x = -93;         // hole centre, left of the aperture (between fin and mounting slot)
power_hole_chamfer = 1;     // edge chamfer on both faces of the hole, for the cable
tie_bridges_y = [42, 110];  // cable-tie bridges on the outside of the left fin,
                            // measured from the back of the panel ([] for none)
tie_w = 4.8;                // cable tie width
tie_t = 1.5;                // cable tie thickness
tie_bridge_h = 8;           // bridge height, centred on the hole

/* [Rendering] */
print_orientation = false;  // true: lay the bracket with the front panel on the bed
show_unit = false;          // ghost of the hEX PoE for checking fit
$fn = 48;

unit     = [unit_w, unit_d, unit_h];
panel_t  = 5;
panel_h  = panel_height(rack_u);
shelf_w  = unit_w + 2 * side_clear + 2 * wall_t;
shelf_d  = rear_clear + unit_d + 3;                  // rear_stop_t = 3
z0       = unit_z0(unit_h, rack_u);
hole_z   = panel_h / 2;
slot_in  = HOLE_CC / 2 - (6.6 + 5) / 2;              // inner edge of the mounting slots
bridge   = tie_bridge_size([tie_w, tie_t], h = tie_bridge_h);

assert(power_hole_d == 0 || abs(power_hole_x) + power_hole_d / 2 + 6 <= slot_in,
       "power hole too close to the mounting slot (leave room for a washer)");
assert(power_hole_d == 0 || abs(power_hole_x) - power_hole_d / 2 >= unit_w / 2 - lip + 3,
       "power hole breaks into the aperture");
assert(power_hole_d == 0 || power_hole_d / 2 <= panel_h / 2 - 3, "power hole too tall for the panel");
for (y = tie_bridges_y) {
    assert(y - bridge[1] / 2 >= fillet_r, str("tie bridge at y=", y, " overlaps the fillet: move it back"));
    assert(y + bridge[1] / 2 <= shelf_d, str("tie bridge at y=", y, " overhangs the back of the shelf"));
    assert(hole_z - tie_bridge_h / 2 >= max(wall_bottom, z0 - shelf_t) &&
           hole_z + tie_bridge_h / 2 <= z0 + wall_above_shelf, "tie bridge taller than the fin");
}

module power_hole() {
    translate([power_hole_x, 0, hole_z]) rotate([-90, 0, 0]) {
        translate([0, 0, -1]) cylinder(d = power_hole_d, h = panel_t + fillet_r + 2);
        c = power_hole_chamfer;
        if (c > 0) {
            translate([0, 0, -0.01]) cylinder(d1 = power_hole_d + 2 * c, d2 = power_hole_d, h = c);
            translate([0, 0, panel_t - c + 0.01]) cylinder(d1 = power_hole_d, d2 = power_hole_d + 2 * c, h = c);
        }
    }
}

print_oriented(print_orientation) {
    difference() {
        union() {
            shelf_bracket(unit, rack_u = rack_u, lip = lip,
                          side_clear = side_clear, rear_clear = rear_clear,
                          shelf_t = shelf_t, wall_t = wall_t,
                          wall_above_shelf = wall_above_shelf, wall_bottom = wall_bottom,
                          rear_stop_t = rear_stop_t, rear_stop_h = rear_stop_h,
                          fillet_r = fillet_r,
                          vents = vents, vent_margin = vent_margin);
            for (y = tie_bridges_y)
                translate([-shelf_w / 2, panel_t + y, hole_z])
                    tie_bridge([tie_w, tie_t], h = tie_bridge_h);
        }
        if (power_hole_d > 0) power_hole();
    }
    if (show_unit) unit_ghost(unit, rack_u);
}
