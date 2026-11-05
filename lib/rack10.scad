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
BOLT_CLEAR   = 6.6;      // clearance hole diameter for the M6 mounting bolts
SLOT_EXTRA   = 10;       // mounting slots are this much wider than BOLT_CLEAR, for rack slack
SLOT_EDGE    = 3;        // minimum panel material between a slot's outer end and the panel edge

function panel_height(rack_u) = rack_u * U_PITCH - PANEL_GAP;

// Z (panel coordinates) of the rail holes used for mounting: bottom hole of the
// first U, top hole of the last U, and the hole just above every internal U
// boundary. That gives 4 + (rack_u - 1) * 2 holes in total.
function hole_zs(rack_u) = [ for (z = concat(
        [HOLE_EDGE],
        [for (i = [1 : 1 : rack_u - 1]) i * U_PITCH + HOLE_EDGE],
        [rack_u * U_PITCH - HOLE_EDGE])) z - PANEL_GAP / 2 ];

// X of the centre of the right-hand mounting slots. They are centred on the rail
// holes unless that would leave less than SLOT_EDGE of material at the panel
// edge; then the slot keeps its width and moves inwards (the bolt then sits off
// centre in the slot, with more room towards the middle of the panel).
function slot_centre_x(slot_w) = min(HOLE_CC / 2, PANEL_W / 2 - SLOT_EDGE - slot_w / 2);
// X of the inner end of the right-hand mounting slots (the left ones mirror it).
function slot_inner_x(bolt_clear = BOLT_CLEAR, slot_extra = SLOT_EXTRA) =
    slot_centre_x(bolt_clear + slot_extra) - (bolt_clear + slot_extra) / 2;

// Z of the bottom of a unit of height unit_h, vertically centred on the panel.
function unit_z0(unit_h, rack_u) = panel_height(rack_u) / 2 - unit_h / 2;
// Z of the bottom of a unit: unit_z if given, otherwise centred.
function unit_bottom(unit_h, rack_u, unit_z = undef) = is_undef(unit_z) ? unit_z0(unit_h, rack_u) : unit_z;

// The panel lip around an aperture is one number for all sides,
// [sides, top/bottom] or [sides, bottom, top].
function lip_x(lip)      = is_list(lip) ? lip[0] : lip;
function lip_bottom(lip) = is_list(lip) ? lip[1] : lip;
function lip_top(lip)    = is_list(lip) ? (len(lip) > 2 ? lip[2] : lip[1]) : lip;

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
module rack_panel(rack_u = 1, panel_t = 5, corner_r = 2, bolt_clear = BOLT_CLEAR, slot_extra = SLOT_EXTRA) {
    panel_h = panel_height(rack_u);
    difference() {
        translate([0, panel_t, 0]) rotate([90, 0, 0])
            linear_extrude(panel_t) rounded_rect(PANEL_W, panel_h, corner_r);
        for (z = hole_zs(rack_u), sx = [-1, 1])
            translate([sx * slot_centre_x(bolt_clear + slot_extra), 0, z]) mounting_slot(panel_t, bolt_clear, slot_extra);
        children();
    }
}

// Aperture for a unit resting on a shelf, `lip` smaller than the unit (one
// number, [sides, top/bottom] or [sides, bottom, top]). unit_x moves the unit
// sideways from the panel centre; unit_z is the bottom of the unit (default:
// vertically centred).
module unit_aperture(unit, rack_u = 1, lip = 1, panel_t = 5, unit_x = 0, unit_z = undef) {
    ap_w = unit[0] - 2 * lip_x(lip);
    ap_h = unit[2] - lip_bottom(lip) - lip_top(lip);
    translate([unit_x - ap_w / 2, -1, unit_bottom(unit[2], rack_u, unit_z) + lip_bottom(lip)])
        cube([ap_w, panel_t + 2, ap_h]);
}

// Translucent ghost of the unit, in its mounted position.
module unit_ghost(unit, rack_u = 1, panel_t = 5, unit_x = 0, unit_z = undef) {
    %translate([unit_x - unit[0] / 2, panel_t, unit_bottom(unit[2], rack_u, unit_z)]) cube(unit);
}

// ------------------------------------------------------------ shelf bracket
// A front panel with an aperture, a shelf behind it, a side wall ("fin") on
// each side of the unit and a low fixed lip across the rear of the shelf. The
// unit is dropped in from above and rests against the back of the panel.
//
//   unit            [width, depth, height] of the equipment
//   unit_x          sideways offset of the unit (and its shelf) from the panel
//                   centre, to make room for something else beside it
//   unit_z          bottom of the unit above the panel bottom (default: the
//                   unit is vertically centred on the panel)
//   lip             panel overlaps the unit by this much on every side, or
//                   [sides, top/bottom] or [sides, bottom, top]
//   side_clear      clearance between unit and each side wall
//   rear_clear      clearance between unit and the rear stop
//   shelf_t         shelf thickness
//   wall_t          side wall thickness
//   wall_above_shelf  side wall height above the shelf top (default: unit height - 2)
//   wall_bottom     side walls extend down to this z (stiffens the shelf);
//                   clamped so they never go below the shelf bottom
//   rear_stop_t/h   rear lip thickness and height above the shelf (h = 0: none)
//   rear_stop_gaps  [[x_from, x_to], ...] openings in the rear lip for cables,
//                   measured from the left edge of the unit seen from the front
//   vents           [[y_from, y_to, z_centre, height], ...] openings in the side
//                   walls, in unit coordinates (from its front face / bottom)
//   vent_margin     vent openings are this much larger than listed, all round
//   tracks          [[x_centre, width], ...] front-to-back tracks in the shelf
//                   top for the unit's feet, x measured from the centre of the
//                   unit; each runs from the back of the panel to the rear stop
//   track_depth     depth of the tracks below the shelf top; equal to the feet
//                   height, the unit's body rests on the shelf with the feet
//                   just reaching the track floor
//   track_floor_t   a track deeper than the shelf allows gets a channel hanging
//   track_wall_t    under the shelf, with this floor and wall thickness
//   fillet_r        radius of the solid fillets joining the outside face of each
//                   side wall to the back of the panel (0: none)
module shelf_bracket(unit, rack_u = 1, lip = 1, unit_x = 0, unit_z = undef,
                     side_clear = 0.75, rear_clear = 1.0,
                     shelf_t = 4, wall_t = 4, wall_above_shelf = undef, wall_bottom = 0.5,
                     rear_stop_t = 3, rear_stop_h = 5, rear_stop_gaps = [],
                     vents = [], vent_margin = 1.5, fillet_r = 8,
                     tracks = [], track_depth = 6, track_floor_t = 3, track_wall_t = 2,
                     panel_t = 5, corner_r = 2, bolt_clear = BOLT_CLEAR, slot_extra = SLOT_EXTRA) {
    unit_w = unit[0]; unit_d = unit[1]; unit_h = unit[2];
    panel_h  = panel_height(rack_u);
    z0       = unit_bottom(unit_h, rack_u, unit_z); // shelf top = bottom of the unit
    shelf_z0 = z0 - shelf_t;
    inner_w  = unit_w + 2 * side_clear;            // between the side walls
    shelf_w  = inner_w + 2 * wall_t;
    shelf_d  = rear_clear + unit_d + rear_stop_t;  // measured from the back of the panel
    wall_h   = is_undef(wall_above_shelf) ? unit_h - 2 : wall_above_shelf;
    wall_z0  = max(wall_bottom, shelf_z0);
    slot_w   = bolt_clear + slot_extra;
    slot_in  = slot_inner_x(bolt_clear, slot_extra); // inner end of the mounting slots
    reach    = abs(unit_x) + shelf_w / 2;          // outermost edge of the shelf
    track_z0 = z0 - track_depth;                   // track floor
    chan_z0  = track_z0 - track_floor_t;           // bottom of a track channel under the shelf

    assert(2 * reach <= RAIL_OPENING - SHELF_MARGIN,
           str("shelf is too wide or too far off centre: reaches x = ", reach,
               " > ", (RAIL_OPENING - SHELF_MARGIN) / 2));
    assert(shelf_z0 >= 0, str("shelf does not fit under the unit (", shelf_z0, "): increase rack_u or reduce shelf_t"));
    assert(z0 + unit_h + lip_top(lip) <= panel_h, "unit too tall for the panel: increase rack_u");
    assert(z0 - lip_bottom(lip) >= 0, "unit sits too low for the panel lip below the aperture");
    assert(slot_in > reach + 1, "mounting slots collide with the shelf");
    assert(slot_in > reach + fillet_r + 1,
           "side wall fillets collide with the mounting slots: reduce fillet_r");
    for (t = tracks) {
        assert(abs(t[0]) + t[1] / 2 + track_wall_t <= inner_w / 2,
               str("track at x=", t[0], " runs into a side wall"));
        assert(chan_z0 >= 0 || track_z0 - shelf_z0 >= track_floor_t,
               str("track at x=", t[0], " goes below the panel bottom: reduce track_depth"));
    }

    echo(str("panel ", PANEL_W, " x ", panel_h, " x ", panel_t,
             " mm, shelf ", shelf_w, " x ", shelf_d, " x ", shelf_t,
             " mm (bottom at z=", shelf_z0, "), aperture ", unit_w - 2 * lip_x(lip), " x ", unit_h - lip_bottom(lip) - lip_top(lip),
             " mm, ", 2 * len(hole_zs(rack_u)), " mounting slots ", slot_w, " x ", bolt_clear, " mm",
             unit_x == 0 ? "" : str(", unit centred at x=", unit_x)));

    union() {
        rack_panel(rack_u, panel_t, corner_r, bolt_clear, slot_extra)
            unit_aperture(unit, rack_u, lip, panel_t, unit_x, unit_z);
        translate([unit_x, 0, 0]) {
            // shelf, with front-to-back tracks for the unit's feet. Where a
            // track would go through the shelf it gets a channel hanging
            // under the shelf instead, which also stiffens the shelf.
            difference() {
                union() {
                    translate([-shelf_w / 2, panel_t, shelf_z0]) cube([shelf_w, shelf_d, shelf_t]);
                    for (t = tracks) if (chan_z0 < shelf_z0)
                        translate([t[0] - t[1] / 2 - track_wall_t, panel_t, chan_z0])
                            cube([t[1] + 2 * track_wall_t, shelf_d, shelf_z0 - chan_z0 + 1]);
                }
                for (t = tracks)
                    translate([t[0] - t[1] / 2, panel_t - 1, track_z0])
                        cube([t[1], 1 + rear_clear + unit_d, track_depth + 1]);
            }

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

            // fillets between the outside of each side wall and the back of the panel
            if (fillet_r > 0)
                for (s = [-1, 1]) mirror([s < 0 ? 1 : 0, 0, 0])
                    translate([shelf_w / 2, panel_t, wall_z0])
                        linear_extrude(z0 + wall_h - wall_z0) fillet_2d(fillet_r);

            // rear stop, with cable gaps; a gap reaching the edge of the unit
            // runs on to the side wall. The stop reaches 1 mm down into the
            // shelf so the two always merge into one solid.
            if (rear_stop_h > 0)
                translate([-inner_w / 2, panel_t + rear_clear + unit_d, z0 - 1]) difference() {
                    cube([inner_w, rear_stop_t, rear_stop_h + 1]);
                    for (g = rear_stop_gaps)
                        let(x1 = g[0] <= 0 ? -1 : side_clear + g[0],
                            x2 = g[1] >= unit_w ? inner_w + 1 : side_clear + g[1])
                            translate([x1, -1, 1]) cube([x2 - x1, rear_stop_t + 2, rear_stop_h + 1]);
                }
        }
    }
}

// ------------------------------------------------------------ tie-down shelf
// An open shelf for things that are strapped down rather than dropped in
// through an aperture: power bricks, cable coils. The panel is cut away between
// the side fins above a low front lip, so the shelf is open at the front. The
// fins are full panel height at the panel and taper in a straight line down to
// fin_rear_h at the back, working as gussets for the floor. The floor sits on
// the panel bottom and has a grid of holes for cable ties.
//
//   depth        how far the shelf reaches back from the rail face (front of the panel)
//   shelf_w      shelf width (default: as wide as the rails allow)
//   shelf_t      floor thickness
//   wall_t       fin thickness
//   fin_rear_h   fin height above the floor at the back
//   fin_front_h  fin height above the floor at the panel (default: up to the panel top)
//   front_lip_h  the panel strip across the front stands this much above the floor
//                (0: flush); at least root_fillet, so the fillet has panel behind it
//   tie_hole     [x, y] size of each tie hole, with hole_r corner radius
//   tie_pitch    [x, y] hole spacing; the grid is centred on the floor
//   tie_margin   no hole comes closer than this to a fin, the panel or the rear edge
//   root_fillet  radius of the concave fillet along the inside corner between the
//                floor and the panel, between the fins (0: none)
//   fin_fillet   radius of the concave fillets between the inside face of each fin
//                and the panel, over the full fin height (0: none); a strip of
//                panel this wide stays beside each fin to back the fillet
//   fin_floor_fillet  radius of the concave fillets along the inside corner
//                between each fin and the floor, front to back (0: none)
// The fillets at the panel spread those joints over many layers when the part
// is printed panel face down; the fin/floor fillets do the same floor down and
// stiffen the fins either way.
module tie_down_shelf(rack_u = 1, depth = 120, shelf_w = undef, shelf_t = 4, wall_t = 4,
                      fin_rear_h = 10, fin_front_h = undef, front_lip_h = 4,
                      tie_hole = [6, 6], tie_pitch = [15, 20], tie_margin = 6, hole_r = 1.5,
                      root_fillet = 6, fin_fillet = 8, fin_floor_fillet = 4,
                      panel_t = 5, corner_r = 2, bolt_clear = BOLT_CLEAR, slot_extra = SLOT_EXTRA) {
    panel_h = panel_height(rack_u);
    w       = is_undef(shelf_w) ? RAIL_OPENING - SHELF_MARGIN : shelf_w;
    inner_w = w - 2 * wall_t;
    floor_d = depth - panel_t;                     // floor behind the panel
    ffh     = is_undef(fin_front_h) ? panel_h - shelf_t : fin_front_h;
    slot_in = slot_inner_x(bolt_clear, slot_extra);
    front_m = max(tie_margin, root_fillet + 1);    // hole margin behind the panel, clear of the root fillet
    side_m  = max(tie_margin, fin_floor_fillet + 1); // hole margin from the fins, clear of their fillets
    hole_d  = floor_d - front_m - tie_margin;      // floor depth available for holes
    open_w  = inner_w - 2 * fin_fillet;            // width of the opening in the panel
    nx      = max(0, floor((inner_w - 2 * side_m - tie_hole[0]) / tie_pitch[0]) + 1);
    ny      = max(0, floor((hole_d - tie_hole[1]) / tie_pitch[1]) + 1);
    hole_xs = [for (i = [0 : 1 : nx - 1]) (i - (nx - 1) / 2) * tie_pitch[0]];
    hole_ys = [for (j = [0 : 1 : ny - 1]) panel_t + front_m + hole_d / 2 + (j - (ny - 1) / 2) * tie_pitch[1]];

    assert(w <= RAIL_OPENING - SHELF_MARGIN,
           str("shelf too wide: ", w, " > ", RAIL_OPENING - SHELF_MARGIN));
    assert(slot_in > w / 2 + 1, "mounting slots collide with the side fins: reduce shelf_w");
    assert(hole_d > 0, "shelf too shallow");
    assert(root_fillet >= 0 && fin_fillet >= 0 && fin_floor_fillet >= 0, "fillet radii must not be negative");
    assert(open_w > 0, "fin_fillet too large for the shelf width");
    assert(root_fillet + 1 < floor_d && fin_fillet + 1 < floor_d, "fillets deeper than the floor");
    assert(front_lip_h >= root_fillet,
           str("front_lip_h (", front_lip_h, ") must be at least root_fillet (", root_fillet,
               ") so the fillet has panel behind it"));
    assert(2 * fin_floor_fillet < inner_w && fin_floor_fillet <= fin_rear_h,
           "fin_floor_fillet too large for the shelf width or the fin height at the back");
    assert(fin_rear_h >= 0 && fin_rear_h <= ffh, "fin_rear_h must be between 0 and the fin height at the panel");
    assert(shelf_t + ffh <= panel_h, "fins taller than the panel: increase rack_u");
    assert(shelf_t + front_lip_h <= panel_h, "front lip taller than the panel");
    assert(hole_r * 2 <= min(tie_hole), "hole_r too large for tie_hole");

    echo(str("tie-down shelf ", w, " x ", depth, " mm (", floor_d, " behind the panel) x ", shelf_t,
             " mm, fins ", ffh, " -> ", fin_rear_h, " mm above the floor, ",
             nx * ny, " tie holes ", tie_hole[0], " x ", tie_hole[1], " mm (", nx, " x ", ny, "), opening ",
             open_w, " x ", panel_h - shelf_t - front_lip_h, " mm, fillets ", root_fillet,
             " mm at the floor root, ", fin_fillet, " mm fin/panel, ", fin_floor_fillet, " mm fin/floor"));

    // A fin's side profile (depth along Y, height along Z) as a slab of
    // thickness t growing in +X from the origin; it starts 1 mm inside the panel.
    module fin_slab(t)
        translate([0, panel_t - 1, 0]) rotate([90, 0, 90]) linear_extrude(t)
            polygon([[0, 0], [floor_d + 1, 0], [floor_d + 1, shelf_t + fin_rear_h],
                     [1, shelf_t + ffh], [0, shelf_t + ffh]]);

    union() {
        // panel, open above the front lip between the strips that back the fin fillets
        rack_panel(rack_u, panel_t, corner_r, bolt_clear, slot_extra)
            translate([-open_w / 2, -1, shelf_t + front_lip_h]) cube([open_w, panel_t + 2, panel_h]);
        // floor with tie holes
        difference() {
            translate([-w / 2, panel_t - 0.01, 0]) cube([w, floor_d + 0.01, shelf_t]);
            for (x = hole_xs, y = hole_ys)
                translate([x, y, -1]) linear_extrude(shelf_t + 2)
                    offset(r = hole_r) offset(delta = -hole_r) square(tie_hole, center = true);
        }
        // tapered fins, reaching 1 mm into the panel so the parts merge
        for (s = [-1, 1]) mirror([s < 0 ? 1 : 0, 0, 0])
            translate([inner_w / 2, 0, 0]) fin_slab(wall_t);
        // fillet along the inside corner between the floor and the panel
        if (root_fillet > 0)
            translate([-inner_w / 2, panel_t, shelf_t]) rotate([90, 0, 90])
                linear_extrude(inner_w) fillet_2d(root_fillet);
        // fillets between the inside face of each fin and the panel, cut to the
        // fin's taper so they slope down towards the back like the fin does
        if (fin_fillet > 0)
            for (s = [-1, 1]) mirror([s < 0 ? 1 : 0, 0, 0])
                intersection() {
                    translate([-inner_w / 2, panel_t, shelf_t])
                        linear_extrude(ffh) fillet_2d(fin_fillet);
                    translate([-inner_w / 2, 0, 0]) fin_slab(fin_fillet + 0.1);
                }
        // fillets along the inside corner between each fin and the floor
        if (fin_floor_fillet > 0)
            for (s = [-1, 1]) mirror([s < 0 ? 1 : 0, 0, 0])
                translate([-inner_w / 2, panel_t + floor_d, shelf_t]) rotate([90, 0, 0])
                    linear_extrude(floor_d) fillet_2d(fin_floor_fillet);
    }
}

// Concave fillet filling the corner of the first quadrant, radius r, with a
// small overlap into the walls it joins so the union is solid.
module fillet_2d(r, overlap = 0.01) {
    translate([-overlap, -overlap]) difference() {
        square(r + overlap);
        translate([r + overlap, r + overlap]) circle(r = r);
    }
}

// ------------------------------------------------------------ cable tie bridge
// A bridge on the outside of a wall for a cable tie: a bar parallel to the
// wall, standing a tie's thickness off it on two legs. The tie passes between
// bar and wall (along Z) and around a cable lying against the outside of the
// bar, so the cable is held along the wall without anything getting between
// the wall and the equipment on its other side.
//
// Frame: the wall face is the plane x = 0 with the wall at x > 0; the bridge
// grows towards -x and is centred on y = 0 and z = 0.
//
//   tie        [width, thickness] of the cable tie
//   clear      the slot is this much wider than the tie, in both directions
//   bar_t      bar thickness (how far the bar stands proud of the slot)
//   leg_t      length of each leg along Y
//   h          height along Z
function tie_bridge_size(tie = [4.8, 1.5], clear = 0.6, bar_t = 3, leg_t = 3, h = 8) =
    [tie[1] + clear + bar_t, tie[0] + 2 * clear + 2 * leg_t, h];   // x reach, y length, z height

module tie_bridge(tie = [4.8, 1.5], clear = 0.6, bar_t = 3, leg_t = 3, h = 8, overlap = 0.01) {
    gap  = tie[1] + clear;
    slot = tie[0] + 2 * clear;
    size = tie_bridge_size(tie, clear, bar_t, leg_t, h);
    translate([-size[0], -size[1] / 2, -h / 2]) difference() {
        cube([size[0] + overlap, size[1], h]);
        translate([bar_t, leg_t, -1]) cube([gap + overlap + 1, slot, h + 2]);
    }
}

// ------------------------------------------------------------ PCB standoffs
// A plate with short standoffs for a bare circuit board. Each standoff has a
// blind hole for a heat-set insert that goes on down into the plate, so the
// standoffs can stay short. Plate frame: corner at the origin, plate from
// z = 0 to plate_t, standoffs on top.
//
//   size          [x, y] of the plate
//   holes         [[x, y], ...] standoff centres in the plate frame
//   standoff_h    standoff height above the plate (board underside clearance)
//   standoff_d    standoff outside diameter
//   insert_d      hole diameter for the heat-set insert (see the insert's datasheet)
//   insert_depth  hole depth from the standoff top; at least 1 mm of plate stays below it
//   flare         extra diameter of a 45 degree cone at the standoff foot
module standoff_plate(size, holes, plate_t = 4, standoff_h = 5, standoff_d = 6.5,
                      insert_d = 3.6, insert_depth = 6, flare = 2) {
    assert(insert_depth <= plate_t + standoff_h - 1,
           str("insert hole (", insert_depth, " mm) too deep for plate + standoff (",
               plate_t + standoff_h, " mm): leave 1 mm below it"));
    assert(standoff_d - insert_d >= 2, "standoff wall around the insert is thinner than 1 mm");
    difference() {
        union() {
            cube([size[0], size[1], plate_t]);
            for (h = holes) translate([h[0], h[1], plate_t - 0.01]) {
                cylinder(d = standoff_d, h = standoff_h + 0.01);
                if (flare > 0) cylinder(d1 = standoff_d + flare, d2 = standoff_d, h = flare / 2 + 0.01);
            }
        }
        for (h = holes) translate([h[0], h[1], plate_t + standoff_h - insert_depth])
            cylinder(d = insert_d, h = insert_depth + 1);
    }
}

// Raspberry Pi 3 B / 3 B+ (also 2 B, 4 B: same board outline and holes).
// Board frame: origin at the corner nearest the micro-USB power socket's end,
// x along the 85 mm edge towards the USB/Ethernet end, y across, so that the
// power/HDMI edge is y = 0 and the GPIO header runs along y = 56.
RPI3_BOARD   = [85, 56];
RPI3_PCB_T   = 1.4;
RPI3_HOLES   = [[3.5, 3.5], [61.5, 3.5], [3.5, 52.5], [61.5, 52.5]];   // M2.5
RPI3_TOP_H   = 17;     // tallest part above the board (USB stack), rounded up
RPI3_PORTS   = [21, 2]; // USB/Ethernet block: length on the board, overhang past x = 85
RPI3_POWER_X = 10.6;   // micro-USB power socket centre along the y = 0 edge

// Translucent ghost of a Pi in its board frame, board underside at z = 0.
module rpi3_ghost() {
    %union() {
        cube([RPI3_BOARD[0], RPI3_BOARD[1], RPI3_PCB_T]);
        translate([RPI3_BOARD[0] - RPI3_PORTS[0], 1, RPI3_PCB_T])
            cube([RPI3_PORTS[0] + RPI3_PORTS[1], RPI3_BOARD[1] - 2, RPI3_TOP_H]);
    }
}

// ------------------------------------------------------------ connector panels
// Cut-outs for panel-mount connectors. Each cut is centred on the origin in X/Z
// and runs through the panel along Y (front face at y = 0). Neutrik D
// connectors are made for thin sheet-metal panels, so behind each opening the
// panel is thinned from the back to `skin` mm. Keystones need more depth than
// the panel has, so they get a box on the back instead (connector_boss()).
//
// Neutrik D-size (XLR, speakON, etherCON, BNC, USB, ... in the D housing):
// 24 mm round hole, M3 screws on a 19 x 24 mm pattern (drilled on all four
// corners so connectors with either diagonal fit), 26 x 31 mm flange, made for
// 1-3 mm panels. Two ways to mount:
//   "neutrik_d"       flange on the front face, M3 screws through the
//                     connector's countersunk holes, nuts in the rear pocket.
//   "neutrik_d_rear"  flange in a snug rear pocket that locates it, nose through
//                     the hole; countersunk M3 screws from the front into the
//                     threaded holes of the M3 versions (e.g. NC3FDM3-L-1).
NEUTRIK_D_HOLE      = 24;
NEUTRIK_D_SCREWS    = [19, 24];       // horizontal, vertical screw spacing
NEUTRIK_D_SCREW_D   = 3.2;
NEUTRIK_D_FLANGE    = [26, 31];
NEUTRIK_D_POCKET    = [28, 34];       // front mount: flange + 1 mm, room for M3 nuts
NEUTRIK_D_REAR_CLEAR = 0.3;           // rear mount: pocket = flange + this, each side
NEUTRIK_D_CSK_D     = 6.5;            // rear mount: 90 degree countersink for M3 flat heads
// Keystone jacks (RJ45, HDMI, USB, F, ... modules). The nose of a jack
// (14.5 x 16 mm) is about 8.2 mm long; the fixed hook (bottom) and the sprung
// latch (top) sit at its rear, 5.4-8.4 mm behind the face, and behind the nose
// the body widens to about 17.5 x 19.4 mm. Profile measured from the
// "10-inch Keystone Patchpanel x10 ports" by Mauricio Pessoa
// (https://www.printables.com/model/1088263): the jack goes in through a 3 mm
// front plate, whose top edge is ramped so the latch can swing in, into a
// cavity where the hook and latch spring out and lock behind the plate. A thin
// lip at the back of the cavity, with a window for the nose, stops the wider
// body so the jack cannot be pushed through; the latch spring holds the jack
// against it. The cavity reaches KEYSTONE_DEPTH behind the front face, so the
// panel gets a box on its back around each keystone (connector_boss()).
// The cut is centred on the face opening; the latch is at the top.
KEYSTONE_W          = 15.0;           // face opening, cavity and window width
KEYSTONE_FACE_H     = 16.0;           // face opening height
KEYSTONE_PLATE_T    = 3.0;            // front plate the hook and latch lock behind
KEYSTONE_RAMP_D     = 4.9;            // ramp from the top edge of the opening reaches the cavity top this deep
KEYSTONE_HOOK       = 2.5;            // cavity extends this far below the opening
KEYSTONE_CLIP       = 5.8;            // cavity extends this far above the opening
KEYSTONE_STOP       = 8.0;            // depth of the stop lip at the back of the cavity
KEYSTONE_STOP_T     = 1.5;            // thickness of the stop lip
KEYSTONE_WINDOW     = 3.8;            // window in the stop lip extends this far above the opening (none below)
KEYSTONE_WALL       = 2.0;            // walls of the box on the back of the panel
KEYSTONE_DEPTH      = KEYSTONE_STOP + KEYSTONE_STOP_T;   // front face to the back of the box
// outside of the box; symmetric envelope used for layout checks
KEYSTONE_FOOTPRINT  = [KEYSTONE_W + 2 * KEYSTONE_WALL,
                       KEYSTONE_FACE_H + 2 * (max(KEYSTONE_HOOK, KEYSTONE_CLIP) + KEYSTONE_WALL)];

// [width, height] of the area a connector occupies on the back of the panel.
function connector_footprint(type) =
    type == "neutrik_d" ? NEUTRIK_D_POCKET :
    type == "neutrik_d_rear" ? NEUTRIK_D_FLANGE + 2 * [NEUTRIK_D_REAR_CLEAR, NEUTRIK_D_REAR_CLEAR] :
    type == "keystone"  ? KEYSTONE_FOOTPRINT : undef;

// `keystone_stop` overrides KEYSTONE_STOP (see keystone_test_coupon()).
module connector_cut(type, panel_t = 5, skin = 2, keystone_stop = KEYSTONE_STOP) {
    fp = connector_footprint(type);
    assert(!is_undef(fp), str("unknown connector type \"", type, "\" (use \"neutrik_d\", \"neutrik_d_rear\" or \"keystone\")"));
    // through opening
    if (type == "neutrik_d" || type == "neutrik_d_rear") {
        csk = type == "neutrik_d_rear";
        translate([0, -1, 0]) rotate([-90, 0, 0]) cylinder(d = NEUTRIK_D_HOLE, h = panel_t + 2);
        for (sx = [-1, 1], sz = [-1, 1])
            translate([sx * NEUTRIK_D_SCREWS[0] / 2, 0, sz * NEUTRIK_D_SCREWS[1] / 2]) {
                translate([0, -1, 0]) rotate([-90, 0, 0]) cylinder(d = NEUTRIK_D_SCREW_D, h = panel_t + 2);
                if (csk)
                    translate([0, -0.01, 0]) rotate([-90, 0, 0])
                        cylinder(d1 = NEUTRIK_D_CSK_D, d2 = 0, h = NEUTRIK_D_CSK_D / 2);
            }
        // rear pocket down to the front skin
        if (skin < panel_t)
            translate([-fp[0] / 2, skin, -fp[1] / 2]) cube([fp[0], panel_t - skin + 1, fp[1]]);
    } else if (type == "keystone") {
        h    = KEYSTONE_FACE_H / 2;
        stop = keystone_stop;
        back = max(stop + KEYSTONE_STOP_T, panel_t) + 1;   // beyond the back of the box
        // profile in the Y-Z plane (depth, height), extruded across the width:
        // face opening, ramp, cavity, stop lip with its window
        rotate([90, 0, 90]) translate([0, 0, -KEYSTONE_W / 2]) linear_extrude(KEYSTONE_W)
            polygon([[-1, -h], [-1, h], [0, h],
                     [KEYSTONE_RAMP_D, h + KEYSTONE_CLIP], [stop, h + KEYSTONE_CLIP],
                     [stop, h + KEYSTONE_WINDOW], [back, h + KEYSTONE_WINDOW],
                     [back, -h], [stop, -h], [stop, -h - KEYSTONE_HOOK],
                     [KEYSTONE_PLATE_T, -h - KEYSTONE_HOOK], [KEYSTONE_PLATE_T, -h]]);
    }
}

// Material a connector adds on the back of the panel before its cut is made:
// keystones get a box around the cavity when the panel is thinner than
// KEYSTONE_DEPTH. Same origin as connector_cut().
module connector_boss(type, panel_t = 5, keystone_stop = KEYSTONE_STOP) {
    if (type == "keystone") {
        depth = keystone_stop + KEYSTONE_STOP_T;
        w     = KEYSTONE_W + 2 * KEYSTONE_WALL;
        if (depth > panel_t)
            translate([-w / 2, panel_t - 1, -KEYSTONE_FACE_H / 2 - KEYSTONE_HOOK - KEYSTONE_WALL])
                cube([w, depth - panel_t + 1,
                      KEYSTONE_FACE_H + KEYSTONE_HOOK + KEYSTONE_CLIP + 2 * KEYSTONE_WALL]);
    }
}

function _psum(v, n) = n <= 0 ? 0 : v[n - 1] + _psum(v, n - 1);

// X centres for a row of connectors inside `usable` mm of width. With
// spacing = undef the gaps (also at both ends) are equal; otherwise the
// connectors are `spacing` mm apart (pocket to pocket) and the row is centred.
function connector_xs(types, usable, spacing = undef) =
    let(w = [for (t = types) connector_footprint(t)[0]],
        n = len(types),
        gap = is_undef(spacing) ? (usable - _psum(w, n)) / (n + 1) : spacing,
        total = _psum(w, n) + (n - 1) * gap)
    [for (i = [0 : n - 1]) -total / 2 + _psum(w, i) + i * gap + w[i] / 2];

// Full-width rack panel with one row of connectors.
//
//   connectors   list of types, left to right seen from the front:
//                "neutrik_d", "neutrik_d_rear" or "keystone"
//   spacing      pocket-to-pocket gap; undef spreads the row evenly
//   positions    optional [[x, z], ...] overriding the automatic layout
//   z            height of the row centre (default: middle of the panel)
//   skin         panel thickness left at Neutrik D connectors
//   edge_margin  keep connectors this far inside the mounting slots (washers)
//   min_web      minimum material between neighbouring pockets
//   stiffeners   "both", "top", "bottom" or "none": lips along the top and/or
//                bottom edge on the back, turning the panel into a stiff channel
//   stiffener_t / stiffener_depth  lip thickness (along Z) and depth behind the panel
//   stiffener_fillet  radius of the fillet between lip and panel
// The lips are as long as a shelf may be wide (clear of the rails) and must not
// overlap any connector pocket.
module connector_panel(connectors, rack_u = 1, spacing = undef, positions = undef, z = undef,
                       skin = 2, edge_margin = 8, min_web = 2,
                       stiffeners = "both", stiffener_t = 3, stiffener_depth = 12, stiffener_fillet = 1.5,
                       panel_t = 5, corner_r = 2, bolt_clear = BOLT_CLEAR, slot_extra = SLOT_EXTRA) {
    panel_h = panel_height(rack_u);
    slot_w  = bolt_clear + slot_extra;
    usable  = 2 * (slot_inner_x(bolt_clear, slot_extra) - edge_margin);
    row_z   = is_undef(z) ? panel_h / 2 : z;
    xs      = connector_xs(connectors, usable, spacing);
    pos     = is_undef(positions) ? [for (x = xs) [x, row_z]] : positions;
    n       = len(connectors);

    assert(len(pos) == n, "positions must have one [x, z] per connector");
    assert(skin > 0 && skin <= panel_t, "skin must be in (0, panel_t]");
    assert(skin >= NEUTRIK_D_CSK_D / 2 - NEUTRIK_D_SCREW_D / 2 + 0.3 || len([for (t = connectors) if (t == "neutrik_d_rear") t]) == 0,
           "skin is too thin for the countersunk screws of neutrik_d_rear");
    for (i = [0 : n - 1]) let(fp = connector_footprint(connectors[i])) {
        assert(!is_undef(fp), str("unknown connector type \"", connectors[i], "\""));
        assert(abs(pos[i][0]) + fp[0] / 2 <= usable / 2 + 1e-6,
               str("connector ", i, " (", connectors[i], ") is too close to the mounting slots"));
        assert(pos[i][1] - fp[1] / 2 >= 1 && pos[i][1] + fp[1] / 2 <= panel_h - 1,
               str("connector ", i, " (", connectors[i], ") does not fit the panel height: increase rack_u"));
    }
    for (i = [0 : n - 1]) for (j = [i + 1 : 1 : n - 1])
        let(a = connector_footprint(connectors[i]), b = connector_footprint(connectors[j]))
            assert(abs(pos[i][0] - pos[j][0]) >= (a[0] + b[0]) / 2 + min_web - 1e-6 ||
                   abs(pos[i][1] - pos[j][1]) >= (a[1] + b[1]) / 2 + min_web - 1e-6,
                   str("connectors ", i, " and ", j, " are too close: reduce the count or increase rack_u"));

    lip_bottom = stiffeners == "both" || stiffeners == "bottom";
    lip_top    = stiffeners == "both" || stiffeners == "top";
    lip_len    = RAIL_OPENING - SHELF_MARGIN;
    lip_reach  = stiffener_t + stiffener_fillet;   // how far a lip reaches in from the edge
    assert(lip_bottom || lip_top || stiffeners == "none",
           str("unknown stiffeners \"", stiffeners, "\" (use \"both\", \"top\", \"bottom\" or \"none\")"));
    for (i = [0 : n - 1]) let(fp = connector_footprint(connectors[i])) {
        assert(!lip_bottom || pos[i][1] - fp[1] / 2 >= lip_reach - 1e-6,
               str("connector ", i, " (", connectors[i], ") overlaps the bottom stiffener: reduce stiffener_t or move it up"));
        assert(!lip_top || pos[i][1] + fp[1] / 2 <= panel_h - lip_reach + 1e-6,
               str("connector ", i, " (", connectors[i], ") overlaps the top stiffener: reduce stiffener_t or move it down"));
    }

    echo(str("connector panel ", PANEL_W, " x ", panel_h, " x ", panel_t, " mm, ", n,
             " connectors at x = ", [for (p = pos) round(p[0] * 10) / 10],
             ", stiffeners: ", stiffeners, (stiffeners == "none" ? "" :
                 str(" (", lip_len, " x ", stiffener_depth, " x ", stiffener_t, " mm)"))));

    union() {
        difference() {
            union() {
                rack_panel(rack_u, panel_t, corner_r, bolt_clear, slot_extra);
                for (i = [0 : n - 1]) translate([pos[i][0], 0, pos[i][1]])
                    connector_boss(connectors[i], panel_t);
            }
            for (i = [0 : n - 1]) translate([pos[i][0], 0, pos[i][1]])
                connector_cut(connectors[i], panel_t, skin);
        }
        if (lip_bottom)
            stiffener_lip(lip_len, stiffener_depth, stiffener_t, stiffener_fillet, panel_t);
        if (lip_top)
            translate([0, 0, panel_h]) mirror([0, 0, 1])
                stiffener_lip(lip_len, stiffener_depth, stiffener_t, stiffener_fillet, panel_t);
    }
}

// Lip along the bottom edge on the back of a panel (z = 0 up to t), with the
// back corners rounded and a fillet where it meets the panel.
module stiffener_lip(len, depth, t, fillet, panel_t = 5) {
    end_r = min(4, depth / 2);
    translate([0, panel_t, 0]) {
        linear_extrude(t) hull() {
            translate([-len / 2, -0.01]) square([len, 0.01 + depth - end_r]);
            for (sx = [-1, 1]) translate([sx * (len / 2 - end_r), depth - end_r]) circle(r = end_r);
        }
        if (fillet > 0)
            translate([-len / 2, 0, t]) rotate([90, 0, 90]) linear_extrude(len) fillet_2d(fillet);
    }
}

// Small plate with one cut of each listed type, to check the fit before
// printing a whole panel.
module connector_test_coupon(types = ["neutrik_d", "keystone"], gap = 6,
                             panel_t = 5, skin = 2, corner_r = 2) {
    w  = [for (t = types) connector_footprint(t)[0]];
    hs = [for (t = types) connector_footprint(t)[1]];
    n  = len(types);
    plate_w = _psum(w, n) + (n + 1) * gap;
    plate_h = max(hs) + 2 * gap;
    xs = connector_xs(types, plate_w);
    difference() {
        union() {
            translate([0, panel_t, 0]) rotate([90, 0, 0])
                linear_extrude(panel_t) rounded_rect(plate_w, plate_h, corner_r);
            for (i = [0 : n - 1]) translate([xs[i], 0, plate_h / 2])
                connector_boss(types[i], panel_t);
        }
        for (i = [0 : n - 1]) translate([xs[i], 0, plate_h / 2])
            connector_cut(types[i], panel_t, skin);
    }
}

// Row of keystone cuts whose stop lips sit at different depths (left to
// right, each marked on the front), to find the depth that suits a maker's
// jacks: the jack should click in, sit flush and not rattle.
module keystone_test_coupon(stops = [7.5, 8, 8.5], gap = 4, panel_t = 5, corner_r = 2,
                            text_depth = 0.6) {
    n = len(stops);
    w = KEYSTONE_FOOTPRINT[0];
    plate_w = n * w + (n + 1) * gap;
    plate_h = KEYSTONE_FOOTPRINT[1] + 2 * gap;
    xs = [for (i = [0 : n - 1]) -plate_w / 2 + gap + w / 2 + i * (w + gap)];
    difference() {
        union() {
            translate([0, panel_t, 0]) rotate([90, 0, 0])
                linear_extrude(panel_t) rounded_rect(plate_w, plate_h, corner_r);
            for (i = [0 : n - 1]) translate([xs[i], 0, plate_h / 2])
                connector_boss("keystone", panel_t, stops[i]);
        }
        for (i = [0 : n - 1]) translate([xs[i], 0, plate_h / 2]) {
            connector_cut("keystone", panel_t, keystone_stop = stops[i]);
            // label below the box, cut into the front face
            translate([0, text_depth, -KEYSTONE_FACE_H / 2 - KEYSTONE_HOOK - KEYSTONE_WALL - 1])
                rotate([90, 0, 0]) linear_extrude(text_depth + 1)
                    text(str(stops[i]), size = 3.5, halign = "center", valign = "top");
        }
    }
}

// Lay the bracket with the front panel on the print bed.
module print_oriented(enabled = true) {
    if (enabled) rotate([90, 0, 0]) children();
    else children();
}
