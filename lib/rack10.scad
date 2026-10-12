// Shared geometry for brackets that mount lab equipment in a 10" (254 mm) rack.
// See ../README.md for the design rules this implements.
//
// Coordinates: X across the rack (0 = centre), Y = depth (front face of the
// panel at y = 0, equipment behind it at y > 0), Z = up (panel bottom at z = 0).
//
// Usage from a device file:
//     use <../lib/rack10.scad>
//     shelf_bracket(unit = [w, d, h], rack_u = 1, lip = 1, ...);

// ------------------------------------------------------------ rack constants
U_PITCH      = 44.45;    // 1U
PANEL_GAP    = 0.794;    // a panel is this much shorter than rack_u * U_PITCH
PANEL_W      = 254;      // 10"
HOLE_CC      = 236.525;  // horizontal distance between rail hole centres (9.3125")
HOLE_EDGE    = 6.35;     // rail hole centre measured from the U boundary
RAIL_OPENING = 222.25;   // clear width between the rails (8.75")
SHELF_MARGIN = 10;       // a shelf must be at least this much narrower than RAIL_OPENING

function panel_height(rack_u) = rack_u * U_PITCH - PANEL_GAP;

// Z (panel coordinates) of the rail holes used for mounting: bottom hole of the
// first U, top hole of the last U, and the hole just above every internal U
// boundary. That gives 4 + (rack_u - 1) * 2 holes in total.
function hole_zs(rack_u) = [ for (z = concat(
        [HOLE_EDGE],
        [for (i = [1 : 1 : rack_u - 1]) i * U_PITCH + HOLE_EDGE],
        [rack_u * U_PITCH - HOLE_EDGE])) z - PANEL_GAP / 2 ];

// Z of the bottom of a unit of height unit_h, vertically centred on the panel.
function unit_z0(unit_h, rack_u) = panel_height(rack_u) / 2 - unit_h / 2;

// ------------------------------------------------------------ front panel
module rounded_rect(w, h, r) {
    translate([-w / 2, 0]) offset(r = r) offset(delta = -r) square([w, h]);
}

// A horizontal slot for one bolt, through the panel along Y, centred at the origin.
module mounting_slot(panel_t, bolt_clear, slot_extra) {
    translate([0, -1, 0]) rotate([-90, 0, 0])
        hull() for (dx = [-slot_extra / 2, slot_extra / 2])
            translate([dx, 0, 0]) cylinder(d = bolt_clear, h = panel_t + 2);
}

// Full-width front panel with mounting slots. Children are subtracted
// (use them for apertures).
module rack_panel(rack_u = 1, panel_t = 5, corner_r = 2, bolt_clear = 6.6, slot_extra = 5) {
    panel_h = panel_height(rack_u);
    difference() {
        translate([0, panel_t, 0]) rotate([90, 0, 0])
            linear_extrude(panel_t) rounded_rect(PANEL_W, panel_h, corner_r);
        for (z = hole_zs(rack_u), sx = [-1, 1])
            translate([sx * HOLE_CC / 2, 0, z]) mounting_slot(panel_t, bolt_clear, slot_extra);
        children();
    }
}

// Aperture for a unit resting on a shelf, `lip` smaller than the unit all round.
module unit_aperture(unit, rack_u = 1, lip = 1, panel_t = 5) {
    ap_w = unit[0] - 2 * lip;
    ap_h = unit[2] - 2 * lip;
    translate([-ap_w / 2, -1, unit_z0(unit[2], rack_u) + lip]) cube([ap_w, panel_t + 2, ap_h]);
}

// Translucent ghost of the unit, in its mounted position.
module unit_ghost(unit, rack_u = 1, panel_t = 5) {
    %translate([-unit[0] / 2, panel_t, unit_z0(unit[2], rack_u)]) cube(unit);
}

// ------------------------------------------------------------ shelf bracket
// A front panel with an aperture, a shelf behind it, a side wall ("fin") on
// each side of the unit and a low fixed lip across the rear of the shelf. The
// unit is dropped in from above and rests against the back of the panel.
//
//   unit            [width, depth, height] of the equipment
//   lip             panel overlaps the unit by this much on every side
//   side_clear      clearance between unit and each side wall
//   rear_clear      clearance between unit and the rear stop
//   shelf_t         shelf thickness
//   wall_t          side wall thickness
//   wall_above_shelf  side wall height above the shelf top (default: unit height - 2)
//   wall_bottom     side walls extend down to this z (stiffens the shelf);
//                   clamped so they never go below the shelf bottom
//   rear_stop_t/h   rear lip thickness and height above the shelf (h = 0: none)
//   vents           [[y_from, y_to, z_centre, height], ...] openings in the side
//                   walls, in unit coordinates (from its front face / bottom)
//   vent_margin     vent openings are this much larger than listed, all round
module shelf_bracket(unit, rack_u = 1, lip = 1,
                     side_clear = 0.75, rear_clear = 1.0,
                     shelf_t = 4, wall_t = 4, wall_above_shelf = undef, wall_bottom = 0.5,
                     rear_stop_t = 3, rear_stop_h = 5,
                     vents = [], vent_margin = 1.5,
                     panel_t = 5, corner_r = 2, bolt_clear = 6.6, slot_extra = 5) {
    unit_w = unit[0]; unit_d = unit[1]; unit_h = unit[2];
    panel_h  = panel_height(rack_u);
    z0       = unit_z0(unit_h, rack_u);            // shelf top = bottom of the unit
    shelf_z0 = z0 - shelf_t;
    inner_w  = unit_w + 2 * side_clear;            // between the side walls
    shelf_w  = inner_w + 2 * wall_t;
    shelf_d  = rear_clear + unit_d + rear_stop_t;  // measured from the back of the panel
    wall_h   = is_undef(wall_above_shelf) ? unit_h - 2 : wall_above_shelf;
    wall_z0  = max(wall_bottom, shelf_z0);
    slot_w   = bolt_clear + slot_extra;

    assert(shelf_w <= RAIL_OPENING - SHELF_MARGIN,
           str("shelf is too wide: ", shelf_w, " > ", RAIL_OPENING - SHELF_MARGIN));
    assert(shelf_z0 >= 0, str("shelf does not fit under the unit (", shelf_z0, "): increase rack_u or reduce shelf_t"));
    assert(z0 + unit_h + lip <= panel_h, "unit too tall for the panel: increase rack_u");
    assert(HOLE_CC / 2 - slot_w / 2 > shelf_w / 2 + 1, "mounting slots collide with the shelf");

    echo(str("panel ", PANEL_W, " x ", panel_h, " x ", panel_t,
             " mm, shelf ", shelf_w, " x ", shelf_d, " x ", shelf_t,
             " mm (bottom at z=", shelf_z0, "), aperture ", unit_w - 2 * lip, " x ", unit_h - 2 * lip,
             " mm, ", 2 * len(hole_zs(rack_u)), " mounting slots ", slot_w, " x ", bolt_clear, " mm"));

    union() {
        rack_panel(rack_u, panel_t, corner_r, bolt_clear, slot_extra)
            unit_aperture(unit, rack_u, lip, panel_t);

        // shelf
        translate([-shelf_w / 2, panel_t, shelf_z0]) cube([shelf_w, shelf_d, shelf_t]);

        // side walls with vent windows
        for (s = [-1, 1]) mirror([s < 0 ? 1 : 0, 0, 0])
            difference() {
                translate([inner_w / 2, panel_t, wall_z0])
                    cube([wall_t, shelf_d, z0 + wall_h - wall_z0]);
                for (v = vents)
                    translate([inner_w / 2 - 1,
                               panel_t + v[0] - vent_margin,
                               z0 + v[2] - v[3] / 2 - vent_margin])
                        cube([wall_t + 2, v[1] - v[0] + 2 * vent_margin, v[3] + 2 * vent_margin]);
            }

        // rear stop
        if (rear_stop_h > 0)
            translate([-inner_w / 2, panel_t + rear_clear + unit_d, z0])
                cube([inner_w, rear_stop_t, rear_stop_h]);
    }
}

// Lay the bracket with the front panel on the print bed.
module print_oriented(enabled = true) {
    if (enabled) rotate([90, 0, 0]) children();
    else children();
}
