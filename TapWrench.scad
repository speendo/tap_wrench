/* [Tap Settings] */
// Tap square size in mm
tap_size = 12; // [0:0.01:100]

// Height of the "tap sleeve" in mm
tap_height = 12; // [0:0.1:50]

// Size of the small holes in the corners of the squares in mm
flex_hole_diameter = 1; // [0:0.1:10]

/* [Grip Settings] */

// in mm
grip_length = 50; // [0:1:200]

// in mm
grip_width = 12; // [0:0.1:50]

// in mm
grip_height = 8; // [0:0.1:50]

/* [General Settings] */

// Thickness at the flex holes in mm
material_thickness = 3; // [1:0.1:50]

// in mm, can be deactivated with <debug=true>
roundness = 2; // [0:0.1:10]

/* [Output Settings] */
// Round edges off?
debug = false;

// $fn - don't care too much about it
resolution = 20; // [8:2:100]

/* [Hidden] */

$fn = resolution;

tapWrench(
	tap_size,
	tap_height,
	flex_hole_diameter,
	grip_length,
	grip_width,
	grip_height,
	material_thickness,
	roundness,
	debug
);

module tapWrench(tap_size, tap_hegiht, flex_hole_diameter, grip_length, grip_width, grip_height, material_thickness, roundness, debug) {
	difference() {
		union() {
			solidTapWrenchCenter(tap_size, flex_hole_diameter, material_thickness, tap_height, debug, roundness);
			grip(tap_size, flex_hole_diameter, material_thickness, debug, roundness);
		}
		tapHole(tap_size, flex_hole_diameter, tap_height);
	}
}

module solidTapWrenchCenter(tap_size, flex_hole_diameter, material_thickness, tap_height, debug, roundness) {
	diameter = diameter(tap_size, flex_hole_diameter, material_thickness);

	if(debug) {
		cylinder(d=diameter, h=tap_height);
	} else {
		difference() {
			cylinder(d=diameter, h=tap_height);
			carveRoundCylinder(diameter, roundness);
			translate([0,0,tap_height]) {
				rotate([180,0,0]) {
					carveRoundCylinder(diameter, roundness);
				}
			}
		}
	}
}

module grip(tap_size, flex_hole_diameter, material_thickness) {
	diameter = diameter(tap_size, flex_hole_diameter, material_thickness);
	
	translate([-(diameter / 2 + grip_length),-grip_width/2,0]) {
		rcube([diameter + 2*grip_length, grip_width, grip_height], radius=roundness, debug=debug);
	}
}

module tapHole(tap_size, flex_hole_diameter, tap_height) {
	translate([-tap_size/2, -tap_size/2, -1]) {
		union() {
			cube([tap_size, tap_size, tap_height + 2]);
			cylinder(d=flex_hole_diameter, h=tap_height + 2);
			translate([tap_size,0,0]) {
				cylinder(d=flex_hole_diameter, h=tap_height + 2);
			}
			translate([tap_size,tap_size,0]) {
				cylinder(d=flex_hole_diameter, h=tap_height + 2);
			}
			translate([0,tap_size,0]) {
				cylinder(d=flex_hole_diameter, h=tap_height + 2);
			}
		}
	}
}

module carveRoundCylinder(diameter, roundness) {
	translate([0, 0, roundness]) {
		rotate_extrude() {
			translate([diameter/2-roundness, 0, 0]) {
				difference() {
					translate([(roundness + 1)/2, ((roundness - 1)/2) - roundness, 0]) {
						square([roundness + 1, roundness + 1], center = true);
					}
					circle(r = roundness);
				}
			}
		}
	}
}

function diameter(tap_size, flex_hole_diamter, material_thickness) = sqrt(2)*tap_size + 2*flex_hole_diameter + 2*material_thickness;


// Helper Modules
module rcube(size=[1,1,1], center=false, radius=1, debug=false,
		bo, ce, to,
		fr, ri, ba, le,
		bf, br, bb, bl,
		cfl, cfr, cbr, cbl,
		tf, tr, tb, tl) {
		
	// define all values
	bo = bo == undef ? true : bo;
	ce = ce == undef ? true : ce;
	to = to == undef ? true : to;
	
	fr = fr == undef ? true : fr;
	ri = ri == undef ? true : ri;
	ba = ba == undef ? true : ba;
	le = le == undef ? true : le;
	
	bf = bf == undef ? (bo && fr) : bf;
	br = br == undef ? (bo && ri) : br;
	bb = bb == undef ? (bo && ba) : bb;
	bl = bl == undef ? (bo && le) : bl;
	cfl = cfl == undef ? (ce && fr && le) : cfl;
	cfr = cfr == undef ? (ce && fr && ri) : cfr;
	cbr = cbr == undef ? (ce && ba && ri) : cbr;
	cbl = cbl == undef ? (ce && ba && le) : cbl;
	tf = tf == undef ? (to && fr) : tf;
	tr = tr == undef ? (to && ri) : tr;
	tb = tb == undef ? (to && ba) : tb;
	tl = tl == undef ? (to && le) : tl;
	
	module roundEdge(length, translation=[0,0,0], rotation=[0,0,0]) {
		translate(translation) {
			rotate(rotation) {
				difference() {
					translate([(radius)/2 + 1/4,(radius)/2 + 1/4,0]) {
						cube([radius/2 + 1, radius/2 + 1, length + 4], center=true);
					}
					cylinder(h=length + 2, r=radius, center=true);
				}
			}
		}
	}
	module roundFullCorner(translation=[0,0,0], rotation=[0,0,0]) {
		translate(translation) {
			rotate(rotation) {
				difference() {
					cube([radius/2 + 1, radius/2 + 1, radius/2 + 1]);
					sphere(r=radius);
				}
			}
		}			
	}
	
	if(debug) {
		cube(size=size, center=center);
	} else {
	
		translation = center ? [0,0,0] : size / 2;
	
		translate(translation) {
	
			difference() {
				cube(size=size, center=true);
		
				union() {
					x = size[0];
					y = size[1];
					z = size[2];
			
					// edges
					if(bf) {
						roundEdge(x,[0,-y/2 + radius,-z/2 + radius],[180,90,0]);
					}
					if(br) {
						roundEdge(y,[x/2 - radius,0,-z/2 + radius],[90,90,0]);
					}
					if(bb) {
						roundEdge(x,[0,y/2 - radius,-z/2 + radius],[0,90,0]);
					}
					if(bl) {
						roundEdge(y,[-x/2 + radius,0,-z/2 + radius],[90,180,0]);
					}
					if(cfl) {
						roundEdge(z,[-x/2 + radius,-y/2 + radius,0],[0,0,180]);
					}
					if(cfr) {
						roundEdge(z,[x/2 - radius,-y/2 + radius,0],[0,0,270]);
					}
					if(cbl) {
						roundEdge(z,[-x/2 + radius,y/2 - radius,0],[0,0,90]);
					}
					if(cbr) {
						roundEdge(z,[x/2 - radius,y/2 - radius,0],[0,0,0]);
					}
					if(bf) {
						roundEdge(x,[0,-y/2 + radius,-z/2 + radius],[180,90,0]);
					}
					if(tf) {
						roundEdge(x,[0,-y/2 + radius,z/2 - radius],[180,270,0]);
					}
					if(tr) {
						roundEdge(y,[x/2 - radius,0,z/2 - radius],[270,270,0]);
					}
					if(tb) {
						roundEdge(x,[0,y/2 - radius,z/2 - radius],[0,270,0]);
					}
					if(tl) {
						roundEdge(y,[-x/2 + radius,0,z/2 - radius],[270,180,0]);
					}

					// corners
					if(bf && bl && cfl) {
						roundFullCorner([-x/2 + radius,-y/2 + radius,-z/2 + radius], [180,90,0]);
					}
					if(bf && br && cfr) {
						roundFullCorner([x/2 - radius,-y/2 + radius,-z/2 + radius], [180,0,0]);
					}
					if(bb && br && cbr) {
						roundFullCorner([x/2 - radius,y/2 - radius,-z/2 + radius], [0,90,0]);
					}
					if(bb && bl && cbl) {
						roundFullCorner([-x/2 + radius,y/2 - radius,-z/2 + radius], [0,180,0]);
					}
					if(tf && tl && cfl) {
						roundFullCorner([-x/2 + radius,-y/2 + radius,z/2 - radius], [0,0,180]);
					}
					if(tf && tr && cfr) {
						roundFullCorner([x/2 - radius,-y/2 + radius,z/2 - radius], [0,0,270]);
					}
					if(tb && tr && cbr) {
						roundFullCorner([x/2 - radius,y/2 - radius,z/2 - radius], [0,0,0]);
					}
					if(tb && tl && cbl) {
						roundFullCorner([-x/2 + radius,y/2 - radius,z/2 - radius], [0,0,90]);
					}
				}
			}
		}
	}
}
