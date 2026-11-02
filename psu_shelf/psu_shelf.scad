// Open tie-down shelf for power supplies at the back of a 10" benchtop rack, 1U.
// Geometry comes from ../lib/rack10.scad; this file only holds the numbers.
//
//   * Bolts to the rear rails. The panel is open between the side fins above a
//     low lip, so the shelf is reached from the open side. A strip of panel
//     stays beside each fin to back the fin fillets.
//   * The floor reaches 120 mm back from the rail face and is 10 mm narrower
//     than the rails allow, so it always fits between them even if the rack is
//     a little narrow. It has a grid of holes for cable ties: the power bricks are
//     strapped down through them, and so is excess cable, coiled up.
//   * The side fins are full height at the panel and taper down towards the
//     back, so they act as gussets for the floor.
//   * Concave fillets along the floor/panel corner and up the fin/panel corners
//     spread those joints over many layers when printed panel face down; more
//     fillets along the fin/floor corners stiffen the fins.
//
// Printing: either way up works without supports. Floor down (as modelled,
// print_orientation = false) is the stronger print, the floor's layers running
// along its length, but the footprint is 254 x 120 mm and cannot be turned, so
// it needs a bed wider than 254 mm. On a 256 mm bed print it panel face down
// (print_orientation = true), set diagonally like the other brackets: the
// footprint is then 254 x 44 mm, 120 mm tall.

use <../lib/rack10.scad>

/* [Shelf] */
rack_u = 1;
depth = 120;                // from the rail face (front of the panel) to the back edge
shelf_w = 202;              // 10 mm narrower than the rails allow, 5 mm spare at each side
shelf_t = 4;                // floor thickness
wall_t = 4;                 // fin thickness
fin_rear_h = 10;            // fin height above the floor at the back
root_fillet = 6;            // fillet along the inside corner between floor and panel (0: none)
fin_fillet = 8;             // fillets between the inside of each fin and the panel (0: none);
                            // a strip of panel this wide stays beside each fin
fin_floor_fillet = 4;       // fillets along the inside corner between each fin and the floor (0: none)
front_lip_h = 6;            // front lip above the floor, at least root_fillet (0: flush with the floor)

/* [Tie holes] */
tie_hole = [6, 6];          // hole size [across, front to back]; takes ties up to 4.8 mm wide
tie_pitch = [15, 20];       // hole spacing [across, front to back]
tie_margin = 6;             // no hole closer than this to a fin, the panel or the rear edge

/* [Rendering] */
print_orientation = true;   // true: panel face on the bed (fits a 256 mm bed diagonally); false: floor on the bed
$fn = 48;

print_oriented(print_orientation)
    tie_down_shelf(rack_u = rack_u, depth = depth, shelf_w = shelf_w, shelf_t = shelf_t, wall_t = wall_t,
                   fin_rear_h = fin_rear_h, front_lip_h = front_lip_h,
                   root_fillet = root_fillet, fin_fillet = fin_fillet, fin_floor_fillet = fin_floor_fillet,
                   tie_hole = tie_hole, tie_pitch = tie_pitch, tie_margin = tie_margin);
