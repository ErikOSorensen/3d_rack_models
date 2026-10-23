# Undalogic miniSMU MS01 + Raspberry Pi 3 B

A 1U bracket holding an Undalogic miniSMU MS01 (two-channel source-measure unit)
with its BNC face to the front, and beside it, hidden behind the panel, a
Raspberry Pi 3 B. The Pi translates Ethernet to USB, so the miniSMU can be
controlled over the network.

Seen from the front:

- **miniSMU on the right.** It sits on a shelf with side fins and a low rear lip,
  like the GS308 bracket. The front aperture has a 1 mm lip all round, and the
  BNCs come through it.
- **Pi on the left**, behind solid panel. It sits on four short (5 mm) standoffs
  with holes for M2.5 heat-set inserts. The holes go on down into the shelf, so
  the standoffs can stay short.
  - It lies with its USB/Ethernet end at the rear edge of the shelf. The Ethernet
    cable plugs in from behind, and a short USB cable runs from the Pi to the
    back of the miniSMU.
  - Turned this way, the Pi's micro-USB power socket faces the miniSMU.
    `pi_power_gap` (25 mm) leaves room for the plug between the Pi and the
    miniSMU's side fin. A right-angle plug, or 5 V on the GPIO header, would let
    the gap shrink.
  - A low wall along the outer edge stiffens the Pi shelf.

## Heat-set inserts

The insert holes are 3.6 mm wide and 6 mm deep, measured from the standoff top,
for M2.5 x 5.7 mm inserts. Check the hole size on your insert's datasheet and set
`insert_d` and `insert_depth` to match. Press the inserts in with the bracket
lying on its back, then fix the Pi with M2.5 x 6 screws.

## TODO

- **Measure the miniSMU.** The dimensions in `minismu_bracket.scad`
  (110 W x 90 D x 30 H mm) are placeholders: width across the BNC face, depth
  without the BNCs, and height without rubber feet. With 1U and the Pi beside
  it, the miniSMU can be at most 110 mm wide (with `pi_power_gap = 25` and
  `fillet_r = 8`; about 115 mm with `fillet_r = 3`) and 35 mm tall. The model
  stops with an error if it does not fit.
- Check where the miniSMU's rear sockets are (USB-C, 12 V DC, WiFi antenna).
  Lower `rear_stop_h` if the rear lip gets in the way of the plugs.
