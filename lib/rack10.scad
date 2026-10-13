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
//   fillet_r        radius of the solid fillets joining the outside face of each
//                   side wall to the back of the panel (0: none)
module shelf_bracket(unit, rack_u = 1, lip = 1,
                     side_clear = 0.75, rear_clear = 1.0,
                     shelf_t = 4, wall_t = 4, wall_above_shelf = undef, wall_bottom = 0.5,
                     rear_stop_t = 3, rear_stop_h = 5,
                     vents = [], vent_margin = 1.5, fillet_r = 8,
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
    assert(HOLE_CC / 2 - slot_w / 2 > shelf_w / 2 + fillet_r + 1,
           "side wall fillets collide with the mounting slots: reduce fillet_r");

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

        // fillets between the outside of each side wall and the back of the panel
        if (fillet_r > 0)
            for (s = [-1, 1]) mirror([s < 0 ? 1 : 0, 0, 0])
                translate([shelf_w / 2, panel_t, wall_z0])
                    linear_extrude(z0 + wall_h - wall_z0) fillet_2d(fillet_r);

        // rear stop
        if (rear_stop_h > 0)
            translate([-inner_w / 2, panel_t + rear_clear + unit_d, z0])
                cube([inner_w, rear_stop_t, rear_stop_h]);
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

// ------------------------------------------------------------ connector panels
// Cut-outs for panel-mount connectors. Each cut is centred on the origin in X/Z
// and runs through the panel along Y (front face at y = 0). The connectors are
// made for thin sheet-metal panels, so behind each opening the panel is thinned
// from the back: to `skin` mm for Neutrik D, to KEYSTONE_LIP_T for keystones.
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
// Keystone jacks (RJ45, HDMI, USB, F, ... modules). Profile measured from the
// cavity of "Keystone Rj45 Jack" v7 by snowboarder (CC BY,
// https://www.printables.com/model/187565): a 1.5 mm front lip with the face
// opening, a 45 degree chamfer behind the top edge so the clip can swing in,
// and a cavity behind the lip that the hook (bottom) and clip (top) lock into.
// The cut is centred on the face opening; the clip is at the top.
KEYSTONE_W          = 14.9;           // opening and cavity width
KEYSTONE_FACE_H     = 15.87;          // face opening height
KEYSTONE_LIP_T      = 1.52;           // front lip the hook and clip catch behind
KEYSTONE_CHAMFER    = 1.43;           // chamfer behind the top (clip) edge
KEYSTONE_HOOK       = 2.6;            // cavity extends this far below the opening
KEYSTONE_CLIP       = 5.49;           // cavity extends this far above the opening
// symmetric envelope used for layout checks
KEYSTONE_FOOTPRINT  = [KEYSTONE_W, KEYSTONE_FACE_H + 2 * max(KEYSTONE_HOOK, KEYSTONE_CLIP)];

// [width, height] of the area a connector occupies on the back of the panel.
function connector_footprint(type) =
    type == "neutrik_d" ? NEUTRIK_D_POCKET :
    type == "neutrik_d_rear" ? NEUTRIK_D_FLANGE + 2 * [NEUTRIK_D_REAR_CLEAR, NEUTRIK_D_REAR_CLEAR] :
    type == "keystone"  ? KEYSTONE_FOOTPRINT : undef;

module connector_cut(type, panel_t = 5, skin = 2) {
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
        h = KEYSTONE_FACE_H / 2;
        // profile in the Y-Z plane, extruded across the width
        rotate([90, 0, 90]) translate([0, 0, -KEYSTONE_W / 2]) linear_extrude(KEYSTONE_W)
            polygon([[-1, -h], [-1, h], [KEYSTONE_LIP_T - KEYSTONE_CHAMFER, h],
                     [KEYSTONE_LIP_T, h + KEYSTONE_CHAMFER], [KEYSTONE_LIP_T, h + KEYSTONE_CLIP],
                     [panel_t + 1, h + KEYSTONE_CLIP], [panel_t + 1, -h - KEYSTONE_HOOK],
                     [KEYSTONE_LIP_T, -h - KEYSTONE_HOOK], [KEYSTONE_LIP_T, -h]]);
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
                       panel_t = 5, corner_r = 2, bolt_clear = 6.6, slot_extra = 5) {
    panel_h = panel_height(rack_u);
    slot_w  = bolt_clear + slot_extra;
    usable  = 2 * (HOLE_CC / 2 - slot_w / 2 - edge_margin);
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
        rack_panel(rack_u, panel_t, corner_r, bolt_clear, slot_extra)
            for (i = [0 : n - 1]) translate([pos[i][0], 0, pos[i][1]])
                connector_cut(connectors[i], panel_t, skin);
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
        translate([0, panel_t, 0]) rotate([90, 0, 0])
            linear_extrude(panel_t) rounded_rect(plate_w, plate_h, corner_r);
        for (i = [0 : n - 1]) translate([xs[i], 0, plate_h / 2])
            connector_cut(types[i], panel_t, skin);
    }
}

// Lay the bracket with the front panel on the print bed.
module print_oriented(enabled = true) {
    if (enabled) rotate([90, 0, 0]) children();
    else children();
}
