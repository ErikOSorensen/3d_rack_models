# Undalogic miniSMU MS01 + Raspberry Pi 3 B

A 1U bracket holding an Undalogic miniSMU MS01 (two-channel source-measure unit)
with its BNC face to the front, and beside it, hidden behind the panel, a
Raspberry Pi 3 B. The Pi translates Ethernet to USB, so the miniSMU can be
controlled over the network.

Seen from the front:

- **miniSMU on the left.** It sits on a shelf with side fins and a low rear lip,
  like the GS308 bracket. The front aperture has a 1 mm lip all round, and the
  BNCs come through it.
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
    panel, ties the shelf to the panel. It ends 30 mm behind the panel, well
    ahead of the power socket (about 56 mm behind the panel).

## Heat-set inserts

The insert holes are 3.6 mm wide and 6 mm deep, measured from the standoff top,
for M2.5 x 5.7 mm inserts. Check the hole size on your insert's datasheet and set
`insert_d` and `insert_depth` to match. Press the inserts in with the bracket
lying on its back, then fix the Pi with M2.5 x 6 screws.

## Dimensions

Measured: 126 mm long, 82 mm wide and 30 mm high. The BNC face is assumed to be
the 82 mm side, so the unit is 82 mm wide in the rack and 126 mm deep. The shelf
is 130 mm deep, and the Pi shelf matches it, with the Pi at the rear.

## TODO

- Confirm that the BNCs are on the 82 mm face.
- Check where the miniSMU's rear sockets are (USB-C, 12 V DC, WiFi antenna).
  Lower `rear_stop_h` if the rear lip gets in the way of the plugs.
