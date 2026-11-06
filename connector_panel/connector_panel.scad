// 1U connector panel for a 10" benchtop rack: four Neutrik D-size connectors
// and three keystone jacks in one row. Geometry comes from ../lib/rack10.scad.
//
//   * 5 mm front panel, one U tall, M6 slots 10 mm wider than needed.
//   * The Neutrik connectors are made for thin panels, so the panel is
//     pocketed from the back down to `skin` behind them.
//   * Neutrik D: 24 mm hole, M3 holes on all four corners of the 19 x 24 mm
//     pattern. "neutrik_d_rear": the flange sits in a snug pocket behind the
//     panel and countersunk M3 x 6 screws from the front go into the threaded
//     holes of the M3 versions (NC3FDM3-L-1, NC3MDM3-L-1, ...). "neutrik_d":
//     flange on the front, M3 x 8 screws and nuts.
//   * Lips (3 x 12 mm) along the top and bottom edge on the back turn the panel
//     into a stiff channel; they stop short of the rails.
//   * Keystone: 15 x 16 mm opening in a 3 mm plate, a cavity behind it where
//     the hook and latch lock, and a box on the back of the panel (19 x 28.3 mm,
//     9.5 mm from the front face) with a stop lip that the jack's body rests
//     against (profile from printables.com/model/1088263). Insert the jack
//     from the front, hook at the bottom first, then press the latch side in.
//
// test_coupon prints a small plate with the same cuts instead of the whole
// panel; the connector sizes are constants in ../lib/rack10.scad.
//
// Print with the front panel face down on the bed (print_orientation = true).

use <../lib/rack10.scad>

/* [Connectors] */
// left to right seen from the front: "neutrik_d_rear", "neutrik_d" or "keystone"
connectors = ["neutrik_d_rear", "neutrik_d_rear", "neutrik_d_rear", "neutrik_d_rear",
              "keystone", "keystone", "keystone"];
spacing = -1;               // gap between pockets in mm; -1 spreads the row evenly
skin = 2;                   // panel thickness left at Neutrik D connectors

/* [Stiffeners] */
stiffeners = "both";        // [both, top, bottom, none] lips on the back along the edges
stiffener_t = 3;            // lip thickness
stiffener_depth = 12;       // how far the lips reach back from the panel

/* [Panel] */
rack_u = 1;

/* [Rendering] */
print_orientation = false;  // true: lay the panel with the front on the bed
test_coupon = "none";       // [none, connectors, keystone_depths] print a small plate instead: one of each connector type, or keystones with stop lips at 7.5, 8 and 8.5 mm
$fn = 64;

print_oriented(print_orientation) {
    if (test_coupon == "connectors")
        connector_test_coupon(["neutrik_d_rear", "keystone"], skin = skin);
    else if (test_coupon == "keystone_depths")
        keystone_test_coupon();
    else
        connector_panel(connectors, rack_u = rack_u,
                        spacing = spacing < 0 ? undef : spacing, skin = skin,
                        stiffeners = stiffeners, stiffener_t = stiffener_t,
                        stiffener_depth = stiffener_depth);
}
