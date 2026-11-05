# Undalogic miniSMU MS01 + Raspberry Pi 3 B

A 1U bracket holding an Undalogic miniSMU MS01 (two-channel source-measure unit)
with its BNC face to the front, and beside it, hidden behind the panel, a
Raspberry Pi 3 B. The Pi translates Ethernet to USB, so the miniSMU can be
controlled over the network.

Seen from the front:

- **miniSMU on the left.** It sits on a shelf with side fins and a low rear lip,
  like the GS308 bracket. The front aperture has a 1 mm lip all round, and the
  BNCs come through it. The side lip can be 8mm. 
- There miniSMU have heatsinks along the sides, and a blower fan in the middle
  of the unit. Perhaps allow for a 15mm tall and 90mm long window in the side fin
  on each side.
- **Pi on the right**, behind solid panel. It sits on four short (5 mm) standoffs
  with holes for M2.5 heat-set inserts. The holes go on down into the shelf, so
  the standoffs can stay short.
  - It lies with its USB/Ethernet end at the rear edge of the shelf. The Ethernet
    cable plugs in from behind, and a short USB cable runs from the Pi to the
    back of the miniSMU.
  - Turned this way, the Pi's micro-USB power socket faces outwards, towards the
    rail. A straight plug fits, with open space around it: the shelf goes on
    30 mm beyond the socket (`pi_power_gap`), and there is about 50 mm to the
    rail. The cable can then run back along the outer edge.
  - A short wall at the outer front corner of the Pi shelf, with a fillet to the
    panel, ties the shelf to the panel. It ends 20 mm behind the panel, ahead
    of the power socket (about 37 mm behind the panel).

## Heat-set inserts

The insert holes are 3.6 mm wide and 6 mm deep, measured from the standoff top,
for M2.5 x 5.7 mm inserts. Check the hole size on your insert's datasheet and set
`insert_d` and `insert_depth` to match. Press the inserts in with the bracket
lying on its back, then fix the Pi with M2.5 x 6 screws.

## Dimensions

Measured: 107 mm long (between top of screwhead front and back), 82 mm wide and 28 mm tall. 
The BNC face is the front 82 mm wide side, so the unit is 82 mm wide in the rack and
107 mm deep. The shelf is 111 mm deep, and the Pi shelf matches it.
The stopper at the back can be 5mm tall without crashing into connectors or antennas.
