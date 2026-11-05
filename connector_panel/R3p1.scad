// Connector panel R3p1: 1U panel for a 10" benchtop rack with two Neutrik D-size
// connectors (rear mounted) on the left and four keystone jacks to the right.
// Geometry comes from ../lib/rack10.scad; see README.md here for the design rules.
//
// Print with the front panel face down on the bed (print_orientation = true).
// Set test_coupon = true and print that first to check the fit of both types.

use <../lib/rack10.scad>

/* [Connectors] */
// left to right seen from the front: "neutrik_d_rear", "neutrik_d" or "keystone"
connectors = ["neutrik_d_rear", "neutrik_d_rear",
              "keystone", "keystone", "keystone", "keystone"];
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
test_coupon = false;        // true: only a small plate with one of each type
$fn = 64;

print_oriented(print_orientation) {
    if (test_coupon)
        connector_test_coupon(["neutrik_d_rear", "keystone"], skin = skin);
    else
        connector_panel(connectors, rack_u = rack_u,
                        spacing = spacing < 0 ? undef : spacing, skin = skin,
                        stiffeners = stiffeners, stiffener_t = stiffener_t,
                        stiffener_depth = stiffener_depth);
}
