// Mounting bracket for a QuantAsylum QA403 audio analyzer in a 10" benchtop rack, 2U.
// Geometry comes from ../lib/rack10.scad; this file only holds the QA403 numbers.
//
//   * BNC face to the front, through an aperture 2 mm smaller than the unit on
//     every side. USB at the back.
//   * The unit is 44 mm tall, more than a 1U panel (43.65 mm), hence 2U; the
//     unit is vertically centred on the panel.
//   * Shelf with side fins and a low fixed lip across the rear of the shelf
//     that stops the unit sliding back when BNC cables are pushed on. The unit
//     is dropped in from above and lifted straight out.
//   * The fins have a window where the unit has its side vents (30..70 mm from
//     the back, 25..37 mm above the bottom of the box).
//   * The rubber feet stay on: two front-to-back tracks in the shelf take
//     them, so the body rests on the shelf with the feet in the tracks. The
//     tracks are deeper than the shelf, so each is a channel hanging under
//     the shelf (open towards the unit, closed by the panel at the front and
//     the rear lip at the back).
//
// Dimensions from the QuantAsylum product page: 177 W x 44 H x 97 D mm
// (115 mm deep including the BNC connectors); the 44 mm is the box, the feet
// are below it. Feet measured: 13 mm diameter, 6 mm tall, 151 mm apart
// side-to-side and 77 mm front-to-back, centred on the bottom.
//
// Print with the front panel face down on the bed (print_orientation = true).

use <../lib/rack10.scad>

/* [QA403] */
unit_w = 177;
unit_h = 44;                // body only, without the feet
unit_d = 97;                // body only; the BNCs stick out through the aperture
foot_d = 13;                // rubber feet diameter
foot_h = 6;                 // rubber feet height below the body
feet_dx = 151;              // distance between the feet, side-to-side (centres)
feet_dy = 77;               // distance between the feet, front-to-back (centres)
vent_from_back = 33;        // side vents: nearest edge, measured from the back of the unit
vent_len = 30;              // side vents length (front-to-back)
vent_bottom = 27;           // side vents: bottom edge above the bottom of the box
vent_h = 9;                // side vents height

/* [Bracket] */
rack_u = 2;
lip = 2;                    // panel overlaps the unit by this much on each side
side_clear = 0.75;          // clearance between unit and each side wall
rear_clear = 1.0;           // clearance between unit and the rear stop
shelf_t = 4;                // shelf thickness
wall_t = 4;                 // side wall thickness
wall_above_shelf = 40;      // side wall height above the shelf top
wall_bottom = 0.5;          // side walls extend down to this z (stiffens the shelf)
fillet_r = 13;              // fillet between the outside of each side wall and the panel
                            // (0: none); max ~13 before it reaches the mounting slots
rear_stop_t = 3;            // rear lip thickness
rear_stop_h = 5;            // rear lip height above the shelf (0 for none)
vent_margin = 1.5;          // vent window is this much bigger than the vent, all round
track_clear = 1;            // tracks are this much wider than the feet on each side
                            // (more than side_clear, so the side walls locate the unit)
track_depth = foot_h;       // tracks go this far below the shelf top; = foot_h puts the
                            // body on the shelf with the feet just reaching the track floor
track_floor_t = 3;          // floor thickness of the track channels under the shelf
track_wall_t = 2;           // wall thickness of the track channels

/* [Rendering] */
print_orientation = false;  // true: lay the bracket with the front panel on the bed
show_unit = false;          // ghost of the QA403 (with feet) for checking fit
$fn = 48;

unit = [unit_w, unit_d, unit_h];
track_w = foot_d + 2 * track_clear;

print_oriented(print_orientation) {
    shelf_bracket(unit, rack_u = rack_u, lip = lip,
                  side_clear = side_clear, rear_clear = rear_clear,
                  shelf_t = shelf_t, wall_t = wall_t,
                  wall_above_shelf = wall_above_shelf, wall_bottom = wall_bottom,
                  rear_stop_t = rear_stop_t, rear_stop_h = rear_stop_h,
                  fillet_r = fillet_r,
                  vents = [[unit_d - vent_from_back - vent_len, unit_d - vent_from_back,
                            vent_bottom + vent_h / 2, vent_h]],
                  vent_margin = vent_margin,
                  tracks = [for (sx = [-1, 1]) [sx * feet_dx / 2, track_w]],
                  track_depth = track_depth,
                  track_floor_t = track_floor_t, track_wall_t = track_wall_t);
    if (show_unit) {
        unit_ghost(unit, rack_u);
        // the feet, hanging below the body into the tracks
        %for (sx = [-1, 1], sy = [-1, 1])
            translate([sx * feet_dx / 2, 5 + unit_d / 2 + sy * feet_dy / 2,
                       unit_z0(unit_h, rack_u) - foot_h])
                cylinder(d = foot_d, h = foot_h);
    }
}
