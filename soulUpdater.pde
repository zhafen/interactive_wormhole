// Updating details for the soul particle class

class SoulUpdater {

  String integrator = "wormhole";
  String update_type = "standard";
  String boundary = "periodic";
  String lost_action = "return_to_edges";
  float radial_direction = -1.;
  float l_mag = 10.;
  float impact_parameter = 1.;

  // Constructor
  SoulUpdater() {
  }

  // Updating function
  void update(float dt, SoulForm sf, SoulGuide sg, ArrayList<Force> forces) {

    //////////////////////////////////////////////////////////////////

    // Standard updating based on forces and boundary conditions

    if (update_type == "standard") {

      // Account for how the guide interacts
      if (sg.guide_update_type == "force") {

        // Get the forces from the guide
        ArrayList<Force> guide_forces = sg.guideForces(sf, forces);

        timestepIntegration(dt, sf, guide_forces);

        boundaryConditions(sf);

        lostRoutine(sf);

        // If no guide
      } else {

        timestepIntegration(dt, sf, forces);

        boundaryConditions(sf);

        lostRoutine(sf);
      }

      ///////////////////////////////////////////////

      // Updating based on mouse position
    } else if (update_type == "mouse") {

      sf.pos = new PVector(mouseX, mouseY);
      sf.vel = new PVector((mouseX - pmouseX)/dt, (mouseY - pmouseY)/dt);
    }
  }


  //////////////////////////////////////////////////////////////////////////

  // The integrator to use for the timestep

  void timestepIntegration(float dt, SoulForm sf, ArrayList<Force> forces) {

    PVector acc, acc_new;

    // Choose the integrator to use
    if (integrator == "leapfrog") {
      // Leapfrog integrator

      // Update position
      acc = totalForce(sf, forces);
      PVector vel_term = sf.vel.copy();
      vel_term.mult(dt);
      sf.pos.add(vel_term);
      PVector acc_term = acc.copy();
      acc_term.mult(0.5*pow(dt, 2));
      sf.pos.add(acc_term);

      // Update velocity
      acc_new = totalForce(sf, forces);
      PVector acc_average = PVector.add(acc, acc_new);
      acc_average.mult(0.5*dt);
      sf.vel.add(acc_average);
    } else if (integrator == "wormhole") {
      //Straight lines in an Ellis Wormhole metric
      
      //Change coords to wormhole metric coords
      PVector r_w = PVector.sub( sf.pos, w_pos );
      float r = r_w.mag();
      float phi = r_w.heading();

      //Get momentum and gamma from velocity
      //PVector momentum = w_pos.cross( sf.vel );
      //float l_mag = momentum.mag();
      float gamma = pow( 1. + pow( l_mag, 2.)/( pow( impact_parameter, 2. ) + pow( b, 2. ) ), 0.5 ); // Choose linear momentum to be comparable to angular momentum

      //Solved equations, though not very well. I just use the geodesic eqs as delta x^alpha / delta t.
      float dphi = l_mag / ( pow( r, 2 ) + pow( b, 2 ) );
      float drds_squared =  pow( gamma, 2. ) - 1. - pow( l_mag, 2 ) / ( pow( r, 2 ) + pow( b, 2 ) );
      float dr = radial_direction * pow( drds_squared, 0.5 );

      // In the case that we're close enough to the wormhole that dr ~ 0, change direction
      if ( abs(impact_parameter - r) < 1.0 ) {
        radial_direction *= -1.;
      }

      //Convert differences back to x and y...
      float dx = dr * cos( phi ) - dphi * r * sin( phi );
      float dy = dr * sin( phi ) + dphi * r * cos( phi );

      PVector pos_change = new PVector( dx * dt, dy * dt );
      sf.pos.add( pos_change );
    }
  }

  ////////////////////////////////////////////////////////////////

  // For souls that cross the boundary, apply the boundary conditions
  // Doesn't account for third dimension.

  void boundaryConditions(SoulForm sf) {

    float[] bmin_arr = {0., 0., -10, 000};
    float[] bmax_arr = {width, height, 10, 000.};

    float[] pos_arr = sf.pos.array();
    float[] vel_arr = sf.vel.array();

    for (int i=0; i<pos_arr.length; i++) {

      // Reflective boundary conditions
      if (boundary == "reflective") {
        if (pos_arr[i] >= bmax_arr[i]) {
          vel_arr[i] = -vel_arr[i];
          pos_arr[i] = 2.*bmax_arr[i] - pos_arr[i];  // To avoid getting stuck on the edges
        } else if (pos_arr[i] <= bmin_arr[i]) {
          vel_arr[i] = -vel_arr[i];
          pos_arr[i] = 2.*bmin_arr[i] - pos_arr[i];
        }

        // Periodic boundary conditions
      } else if (boundary == "periodic") {
        if (pos_arr[i] >= bmax_arr[i]) {
          pos_arr[i] = bmin_arr[i] + pos_arr[i] - bmax_arr[i];
        } else if (pos_arr[i] <= bmin_arr[i]) {
          pos_arr[i] = bmax_arr[i] - pos_arr[i] + bmin_arr[i];
        }
      }
    }

    sf.pos = new PVector(pos_arr[0], pos_arr[1]);
    sf.vel = new PVector(vel_arr[0], vel_arr[1]);
  }

  ////////////////////////////////////////////////////////////////

  // How to deal with souls way outside the boundary

  void lostRoutine(SoulForm sf) {

    float[] bmin_arr = {-width/4, -height/4, -10, 000.};
    float[] bmax_arr = {width + width/4, height + height/4, 10, 000.};

    float[] pos_arr = sf.pos.array();
    float[] vel_arr = sf.vel.array();

    for (int i=0; i<pos_arr.length; i++) {

      // Return lost particles to just inside the border, and moving inwards
      if (lost_action == "return_to_edges") {
        if (pos_arr[i] >= bmax_arr[i]) {
          pos_arr[i] = bmax_arr[i] - 10.;
          vel_arr[i] = -10.;
        } else if (pos_arr[i] <= bmin_arr[i]) {
          pos_arr[i] = bmax_arr[i] + 10.;
          vel_arr[i] = +10.;
        }
      }
    }

    sf.pos = new PVector(pos_arr[0], pos_arr[1]);
    sf.vel = new PVector(vel_arr[0], vel_arr[1]);
  }
}