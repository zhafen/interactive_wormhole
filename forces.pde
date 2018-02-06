// Classes for forces acting on a soul

/////////////////////////////////

// Get the total force acting on a soul

PVector totalForce(SoulForm sf, ArrayList<Force> forces) {

  PVector f_net = new PVector(0., 0.);
  for (int i=0; i<forces.size(); i++) {
    Force f = forces.get(i);

    // Calculate the contribution from the force
    f.calcForce(sf);

    // Add the force
    f_net.add(f.force);
  }

  return f_net;
}

///////////////////////////////////////

class Force {
  PVector force;

  Force() {
  }

  // Dummy method. All subclasses will have a version of this.
  void calcForce(SoulForm sf) {
    println("Dummy method in base class called, no force calculated.");
  }
}

///////////////////////////////////////

// Inverse Square force (k*1/(r**2 + h**2));

class InverseSquare extends Force {
  PVector ps;
  float k;
  float h;

  ///////////////////////////////////////////
  // Constructor
  InverseSquare(PVector pos_source, float force_strength, float softening_length) {
    ps = pos_source;
    k = force_strength;
    h = softening_length;
  }

  /////////////////////////////////////
  // Calculate the force on something given its position

  void calcForce(SoulForm sf) {
    PVector pos = sf.pos;

    // Find the distance
    PVector diff = PVector.sub(pos, ps);
    float r_squared = diff.magSq() + pow(h, 2); // Add softening to avoid blowing up.

    // Find the force vector
    PVector f = PVector.sub(pos, ps);
    f.mult(k/abs(pow(r_squared, .75)));

    force = f;
  }
}

///////////////////////////////////////////////////

// A force of the form b*v**gamma*e_v, where v is the vector pointing from the current velocity position to v_f, and e_v is a unit vector pointing in the direction of v_f.

class VelPoly extends Force {
  float b, gamma, v_power; // v2_power is what the magnitude of the velocity squared should be raised to when calculated carefully
  PVector v_f;

  VelPoly(float linear_coeff, float power_coeff, PVector force_velocity_position) {
    b = linear_coeff;
    gamma = power_coeff;
    v_power = gamma - 1.;
    v_f = force_velocity_position;
  }

  //////////////////////////////////////////

  void calcForce(SoulForm sf) {

    // Find the force vector
    PVector f = PVector.sub(sf.vel, v_f);
    f.mult(b*pow(f.mag(), v_power));

    force = f;
  }
}