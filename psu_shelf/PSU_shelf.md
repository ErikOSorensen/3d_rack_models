# Power supply shelf

An open shelf for the power bricks of the equipment in the rack. It mounts to
the rails at the back of the rack, so the supplies and their cables stay out of
the way behind the equipment.

- 1U, bolted to the rails like the brackets, with the same slots.
- Open at the front: the panel is cut away between the side fins, down to a low
  lip 6 mm above the floor, so bricks and cables are reached from the open side.
  An 8 mm strip of panel stays beside each fin to back the fin fillets, so the
  opening is 178 mm wide.
- The floor is 120 mm deep from the rail face and 202 mm wide, 10 mm narrower
  than the rails allow so it fits even if the rack is a little narrow. It is
  4 mm thick and sits on the bottom edge of the panel.
- The fins are full panel height at the panel and taper to 10 mm at the back,
  working as gussets for the floor.
- Concave fillets, 6 mm along the inside corner between floor and panel and
  8 mm up the inside corners between the fins and the panel, spread those
  joints over many layers when the part is printed panel face down. The lip and
  the strips are what those fillets lean on. Further 4 mm fillets run along the
  inside corner between each fin and the floor and stiffen the fins.
- The floor has a grid of 6 x 6 mm holes, 15 mm apart across and 20 mm front
  to back, for cable ties up to 4.8 mm wide. Strap the bricks down through them
  and tie the excess cable length down as a coil.

`tie_down_shelf()` in `../lib/rack10.scad` builds it; `psu_shelf.scad` holds the
numbers above and is the file to copy for a different size.
`psu_shelf_150.scad` is such a copy: the same shelf 150 mm deep, with 12 x 7
tie holes.

Printing: both ways up work without supports. Floor down is the stronger
print, since the floor's layers run along its length, but the footprint is
254 x 120 mm and cannot be turned, so it needs a bed wider than 254 mm. On a
256 mm bed print it panel face down, set diagonally like the other brackets:
254 x 44 mm footprint, 120 mm tall. The fins then carry the floor like the
shelves of the other brackets do.
