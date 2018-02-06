// Class for moving souls on paths

////////////////////////////////////////////////

// Base class. Actual guides have to be constructed independently

class SoulGuide {

  String guide_update_type = "none"; // By default, the guide is not being called
  String at_final_waypoint = "loop"; // What to do when the final waypoint is reached?
  float change_range = 20.; // Range within which to move onto the next waypoint

  SoulFlock waypoints = new SoulFlock();
  int i_path;

  // Constructor
  SoulGuide() {
  }

  //////////////////////////////////////

  // Dummy method. All force subclasses will have a version of this.
  ArrayList<Force> guideForces(SoulForm sf, ArrayList<Force> forces) {
    println("Dummy method in base class called, no force calculated.");

    return new ArrayList<Force>();
  }

  ////////////////////////////////////

  // Increment which part of the path to use.
  void waypointCheck(SoulForm sf, Soul target_wp) {
    
    if (sf.pos.dist(target_wp.sf.pos) <= change_range) {
      i_path++;
    }
    
  }

  ////////////////////////////////////

  // How to handle end of the path?

  void endCheck(SoulForm sf) {

    if (i_path == waypoints.souls.size()) {

      // Keep last waypoint as the final destination
      if (at_final_waypoint == "stop") {
        i_path = waypoints.souls.size() - 1;

        // Loop it
      } else if (at_final_waypoint == "loop") {
        i_path = 0;

        // Turn particle invisible
      } else if (at_final_waypoint == "make_invisible") {
        i_path = waypoints.souls.size() - 1;
        sf.visible = false;
      }
    }
  }
}

////////////////////////////////////////////

// Class for moving along the path by setting some forces at each location. The forces are a inverse square force and a velocity^2 force moving them closer in velocity space.

class ForceGuide extends SoulGuide {

  // Input for VelPoly (b*v**gamma) force
  float b = -0.005;
  float gamma = 2.0;

  // Input for InverseSquare (k*1/(r**2 + h**2))
  float k = -10000.;
  float h = 10.;

  // Constructor
  ForceGuide(SoulFlock input_waypoints) {
    waypoints = input_waypoints;
    guide_update_type = "force";
  }

  ///////////////////////////////////////

  // How the guide should move

  ArrayList<Force> guideForces(SoulForm sf, ArrayList<Force> forces) {

    // Force array to store
    ArrayList<Force> guide_forces = new ArrayList<Force>();

    // Get the waypoint to follow
    if (waypoints.souls.size()>0) {
      Soul target_wp = waypoints.souls.get(i_path);

      // The forces under which it moves: inverse square and vel poly pointing at position in velocity space
      VelPoly f_vp = new VelPoly(b, gamma, target_wp.sf.vel);
      InverseSquare f_is = new InverseSquare(target_wp.sf.pos, k, h);
      guide_forces.add(f_vp);
      guide_forces.add(f_is);


      // What to do when reached the next waypoint?
      waypointCheck(sf, target_wp);

      // What to do if at end of the path?
      endCheck(sf);
    }

    // Add the previous forces
    guide_forces.addAll(forces);

    return guide_forces;
  }
}