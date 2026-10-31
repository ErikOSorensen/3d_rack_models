# TP-Link 7-port USB 3.0 hub

A 1U bracket holding the hub on a single shelf with side fins and a low rear
lip, like the GS308 bracket, with three things special to the hub.

## Front aperture

The seven USB outputs are on the front and fit within 155 mm, so the aperture
is 155 mm wide, leaving a 5 mm lip of panel at each side. At the top and bottom
the aperture is 1 mm smaller than the hub, as usual.

## Rear lip

Power and USB-in are on the back, at the right end seen from the front. The
rear lip has a 45 mm gap there (`rear_gap_w`), from the right side wall
inwards, so the plugs can come in low from behind.

## Power button

The button is on top of the hub, 11 mm from its left side. Instead of a lever,
a 13 mm hole in the panel above the hub lets a pencil (or similar) reach in and
press it from the front. To make room for the hole, the hub sits as low as the
bracket allows: the shelf rests on the bottom edge of the panel, so the hub top
is 24 mm up and the hole, centred 33.5 mm up, has 4 mm of panel below it to the
aperture and about 3.5 mm above it to the top edge. That is about as big as a
round hole can get here; for more room it would have to become a slot.

How steep the pencil has to go depends on how far back the button is. With the
button 20 mm behind the front face (`button_y`, a guess), the pencil goes down
at about 22 degrees from the hole; the .scad file echoes the angle. Set
`button_y` to the measured value and, if the angle gets steep, raise
`button_hole_z` or enlarge `button_hole_d`. The rendering option `show_unit`
draws the button as a small disc on top of the ghost of the hub.

## Dimensions

As given: 165 mm wide, 66 mm deep and 20 mm tall. The shelf is 70 mm deep.

## TODO

- Measure how far behind the front face the power button is and set `button_y`.
- Check that the 45 mm gap lines up with the power and USB-in sockets.
