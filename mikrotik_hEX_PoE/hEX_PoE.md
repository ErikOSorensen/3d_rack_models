# MikroTik hEX PoE (RB960PGS) router

A 1U bracket holding a MikroTik hEX PoE on a single shelf with side fins and a
low rear lip, like the GS308 bracket. The front aperture has a 1 mm lip all
round so the router cannot fall out on the front.

All the connectors are on one face of the router: the DC power jack, the SFP
cage, Ethernet ports 1-5 (PoE in on Ether1, PoE out on Ether2-5) and the USB
port. The port LEDs are on the same face. That face goes to the front, so every
cable comes in through the aperture and nothing needs to reach the back of the
unit. The rear lip stops the router sliding back when plugs are pushed in.

## Power cable

The DC jack is at the left end of the connector face, seen from the front. To
keep the power cable out of the way, a 15 mm hole in the panel to the left of
the aperture, vertically centred, lets the plug be threaded through from the
back. The cable then runs back along the outside of the left fin to the supply
at the back of the rack. The hole has a 1 mm chamfer on both faces, and it also
cuts through the foot of the fillet behind the panel, which is only a few
millimetres thick there.

Two cable-tie bridges on the outside of the left fin hold the cable: a bar
standing a tie's thickness off the fin on two short legs. The tie goes between
bar and fin and around the cable on the outside, so nothing gets between the
fin and the router. The slot takes ties up to 4.8 x 1.5 mm. The bridges sit
42 mm and 110 mm behind the panel (`tie_bridges_y`), the first just behind the
fillet; the bridges are 5 mm proud of the fin.

The hEX PoE is cooled passively (up to 59 W with PoE loads, 6 W on its own).
The fins are solid; if the case has ventilation holes in its sides, list them
in `vents` in the .scad file and the fins get matching windows.

## Dimensions

From the MikroTik brochure (missing from the product page, confirmed on the
MikroTik forum): 114 x 137 x 29 mm. The connector face is the long, 137 mm
side, so the unit is 137 mm wide in the rack, 114 mm deep and 29 mm tall.

## TODO

- Verify the dimensions with calipers, and check whether the rubber feet are
  included in the 29 mm (remove them, or raise `unit_h`).
- Check the sides of the case for vents and add them to `vents` if present.
