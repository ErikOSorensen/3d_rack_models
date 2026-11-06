// Connector panel R4p2: 1U panel for a 10" benchtop rack with a row of eight
// keystone jacks and no Neutrik connectors.
// Geometry comes from ../lib/rack10.scad; see README.md here for the design rules.
//
// Print with the front panel face down on the bed (print_orientation = true).
// test_coupon prints a small plate with the same cuts instead of the whole panel.

use <../lib/rack10.scad>

/* [Connectors] */
// left to right seen from the front: "neutrik_d_rear", "neutrik_d" or "keystone"
connectors = [for (i = [1 : 8]) "keystone"];
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
