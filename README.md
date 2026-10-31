# 3d_rack_models
3D models for mounting lab equipment in a 10" benchtop rack

The models in this repo are intended to be 3D printed in PETG. The models
are brackets that will help mount lab equipment (analyzers, radios, switches, ..)
in benchtop 10" racks. The racks are about 30cm deep, and have Adam Hall 61545B10
rack strips steel rails on the sade, with standard 3 holes per U,
9.5 mm Hole size (according to IEC 60297). I mount to the rail with M6 cage nuts. 
Unfortunately, since the racks are home built
wooden frames, they are not as precises in their width as I would have liked. 

The Rack units are documented at https://en.wikipedia.org/wiki/Rack_unit and
https://en.wikipedia.org/wiki/19-inch_rack See also this Figure for dimensions: 
https://en.wikipedia.org/wiki/19-inch_rack#/media/File:19_inch_vs_10_inch_correct_rack_dimensions.svg


The brackets for mounting will be whole U-units tall. Their mounting holes (to the rack)
will need to accommodate a bit of slack for the horizontal spacing being a bit off
in my homemade racks:

- The front of the brackets will be 5 mm thick. 
- If the module is X U tall, then there will be 4 + (X-1)*2 M6 mounting holes.
- The mounting holes will be slots that are 5 mm horizontally wider than necessary for M6 bolts.
- Ideally, width of the shelf holding equipment on the back of the front will be 10mm narrower than the standard allows (because of the woodwork lacking precision).


`shelf_bracket()` in `lib/rack10.scad` builds these. Beyond the basics it can
move the unit sideways (`unit_x`) or set how high it sits (`unit_z`, default
centred), use a different lip at the sides and the top/bottom of the aperture
(`lip = [sides, top/bottom]`), cut windows in the fins for vents (`vents`) and
gaps in the rear lip for cables (`rear_stop_gaps`). The USB hub bracket in
[tplink_usb_hub](tplink_usb_hub/USB_hub.md) uses most of these.

# Connector panels

`connector_panel()` in `lib/rack10.scad` makes a plain rack panel with a row of
Neutrik D-size (front or rear mounted) and/or keystone connectors. See
[connector_panel/README.md](connector_panel/README.md) for the design rules, how to
make a panel, and printing and fit notes.

# PCB standoffs

`standoff_plate()` in `lib/rack10.scad` makes a shelf plate with short standoffs for
a bare circuit board. Each standoff has a hole for a heat-set insert that goes on
down into the plate. The library also has the Raspberry Pi 3 B board outline and
hole positions (`RPI3_*`). The miniSMU bracket in
[undalogic_miniSMU](undalogic_miniSMU/miniSMU.md) uses them. A device file that
needs the library's constants must `include` it, not `use` it.

# Cable tie bridges

`tie_bridge()` in `lib/rack10.scad` makes a small bridge on the outside of a
wall for a cable tie: the tie passes between the bridge's bar and the wall and
around a cable on the outside, so the cable runs along the wall without anything
getting between the wall and the equipment. The hEX PoE bracket in
[mikrotik_hEX_PoE](mikrotik_hEX_PoE/hEX_PoE.md) uses them for the power cable.
