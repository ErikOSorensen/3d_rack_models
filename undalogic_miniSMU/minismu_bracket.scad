// Mounting bracket for an Undalogic miniSMU MS01 and a Raspberry Pi 3 B in a
// 10" benchtop rack, 1U. Geometry comes from ../lib/rack10.scad; this file holds
// the miniSMU and Pi numbers and the layout of the two side by side.
//
//   * miniSMU on the left (seen from the front), BNC face forward through an
//     aperture 1 mm smaller than the unit on every side. Shelf with side fins
//     and a low rear lip, like the other brackets.
//   * Raspberry Pi on the right, behind solid panel, on short standoffs with
//     holes for M2.5 heat-set inserts that go on down into the shelf. The Pi
//     bridges Ethernet to the miniSMU's USB.
//   * The Pi lies with its USB/Ethernet end at the rear edge of the shelf, so
//     the Ethernet cable plugs in from behind and a short USB cable runs to the
//     back of the miniSMU. Turned this way, the micro-USB power socket faces
//     outwards, towards the rail: a straight plug fits, with open space around
//     it, and pi_power_gap of shelf beyond the socket.
//   * A short wall at the outer front corner of the Pi shelf ties it to the
//     panel; it ends well ahead of the power plug.
//
// miniSMU measured: 126 long x 82 wide x 30 high mm, BNC face across the
// 82 mm width.
//
// Print with the front panel face down on the bed (print_orientation = true).
// Press the inserts in with the bracket lying on its back.

// include, not use: the layout below needs the library's constants (RPI3_*, rack sizes).
include <../lib/rack10.scad>

/* [miniSMU MS01] */
unit_w = 82;                // BNC face, becomes the front
unit_d = 126;
unit_h = 30;

/* [Bracket] */
rack_u = 1;
lip = 1;                    // panel overlaps the unit by this much on each side
side_clear = 0.75;          // clearance between unit and each side wall
rear_clear = 1.0;           // clearance between unit and the rear stop
shelf_t = 4;                // shelf thickness (miniSMU and Pi shelf)
wall_t = 4;                 // side wall thickness
wall_above_shelf = 28;      // side wall height above the shelf top
wall_bottom = 0.5;          // side walls extend down to this z (stiffens the shelf)
fillet_r = 8;               // fillet between the outside of each side wall and the panel
rear_stop_t = 3;            // rear lip thickness
rear_stop_h = 5;            // rear lip height above the shelf (0 for none; lower it
                            // if it gets in the way of the miniSMU's rear sockets)

/* [Raspberry Pi] */
pi_power_gap = 30;          // shelf beyond the Pi's power edge (the plug may also overhang it)
pi_fin_clear = 3;           // between the Pi (GPIO edge) and the miniSMU side fin
pi_front_clear = 10;        // minimum gap between the panel and the front of the Pi
standoff_h = 5;             // standoff height above the shelf
standoff_d = 6.5;           // standoff diameter (the Pi's keep-out pads are 6 mm)
insert_d = 3.6;             // hole for an M2.5 heat-set insert: check the insert's datasheet
insert_depth = 6;           // hole depth from the standoff top (M2.5 x 5.7 inserts)
pi_wall_t = 4;              // short wall at the outer front corner of the Pi shelf
pi_wall_h = 10;             // its height above the shelf
pi_wall_d = 30;             // its length back from the panel (0: none)

/* [Rendering] */
print_orientation = false;  // true: lay the bracket with the front panel on the bed
show_unit = false;          // ghosts of the miniSMU and the Pi for checking fit
$fn = 48;

unit = [unit_w, unit_d, unit_h];

// ------------------------------------------------------------ layout
// Same values as shelf_bracket() computes, needed to place the Pi beside it.
panel_t   = 5;
z0        = unit_z0(unit_h, rack_u);                  // shelf top
shelf_z0  = z0 - shelf_t;
smu_w     = unit_w + 2 * side_clear + 2 * wall_t;     // miniSMU shelf width
smu_d     = rear_clear + unit_d + rear_stop_t;        // miniSMU shelf depth
pi_area_w = pi_fin_clear + RPI3_BOARD[1] + pi_power_gap;
total_w   = smu_w + pi_area_w;
unit_x    = -total_w / 2 + smu_w / 2;                 // miniSMU centre
pi_x0     = -total_w / 2 + smu_w;                     // Pi shelf, miniSMU side
pi_x1     = total_w / 2;                              // Pi shelf, outer edge
pi_d      = max(smu_d, pi_front_clear + RPI3_BOARD[0]);
pi_wall_z0 = max(wall_bottom, shelf_z0);
slot_inner = slot_inner_x();                           // inner end of the default mounting slots

// The board is turned 90 degrees, USB/Ethernet end to the rear. In the Pi
// shelf's own frame (corner at the front, miniSMU side), board x runs along the
// depth and board y = 0 (the power edge) is the outer side.
board_x = pi_fin_clear + RPI3_BOARD[1];               // power edge, shelf frame
board_y = pi_d - RPI3_BOARD[0];                       // front of the board, shelf frame
pi_holes = [for (h = RPI3_HOLES) [board_x - h[1], board_y + h[0]]];
pi_top = z0 + standoff_h + RPI3_PCB_T + RPI3_TOP_H;
power_y = board_y + RPI3_POWER_X;                     // power socket, from the panel back

assert(total_w <= RAIL_OPENING - SHELF_MARGIN,
       str("miniSMU and Pi too wide together: ", total_w, " > ", RAIL_OPENING - SHELF_MARGIN,
           " mm - reduce pi_power_gap or put the Pi elsewhere"));
assert(pi_x1 + fillet_r + 1 < slot_inner, "Pi wall fillet collides with the mounting slots");
assert(pi_wall_d <= power_y - 10, str("Pi corner wall (", pi_wall_d,
       " mm) reaches the power plug (socket ", power_y, " mm behind the panel)"));
assert(pi_top <= panel_height(rack_u), str("Pi too tall for the panel (top at z=", pi_top, ")"));

echo(str("miniSMU at x=", unit_x, ", Pi shelf ", pi_area_w, " x ", pi_d,
         " mm, Pi standoffs ", standoff_h, " mm, Pi top at z=", pi_top,
         ", power socket ", power_y, " mm behind the panel and ",
         RAIL_OPENING / 2 - (pi_x0 + board_x), " mm from the rail"));

// ------------------------------------------------------------ model
print_oriented(print_orientation) {
    shelf_bracket(unit, rack_u = rack_u, lip = lip, unit_x = unit_x,
                  side_clear = side_clear, rear_clear = rear_clear,
                  shelf_t = shelf_t, wall_t = wall_t,
                  wall_above_shelf = wall_above_shelf, wall_bottom = wall_bottom,
                  rear_stop_t = rear_stop_t, rear_stop_h = rear_stop_h,
                  fillet_r = fillet_r, panel_t = panel_t);

    // Pi shelf with standoffs, overlapping the miniSMU shelf slightly
    translate([pi_x0 - 0.01, panel_t, shelf_z0])
        standoff_plate([pi_area_w + 0.01, pi_d], [for (h = pi_holes) h + [0.01, 0]], plate_t = shelf_t,
                       standoff_h = standoff_h, standoff_d = standoff_d,
                       insert_d = insert_d, insert_depth = insert_depth);

    // short wall at the outer front corner, with a fillet to the back of the panel
    if (pi_wall_d > 0) {
        translate([pi_x1 - pi_wall_t, panel_t, pi_wall_z0])
            cube([pi_wall_t, pi_wall_d, z0 + pi_wall_h - pi_wall_z0]);
        if (fillet_r > 0)
            translate([pi_x1, panel_t, pi_wall_z0])
                linear_extrude(z0 + pi_wall_h - pi_wall_z0) fillet_2d(fillet_r);
    }

    if (show_unit) {
        unit_ghost(unit, rack_u, panel_t, unit_x);
        translate([pi_x0 + board_x, panel_t + board_y, z0 + standoff_h])
            rotate([0, 0, 90]) rpi3_ghost();
    }
}
