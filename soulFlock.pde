// Contains a flock of souls

class SoulFlock {

  ArrayList<Soul> souls  = new ArrayList<Soul>();
  ArrayList<ArrayList<Force>> all_forces = new ArrayList<ArrayList<Force>>();

  // Self gravity parameters
  boolean self_gravity = false;
  ArrayList<ArrayList<Force>> all_sg_forces = new ArrayList<ArrayList<Force>>();
  float k = -10000.; // Strength of gravity
  float h = 10.; // Softening length

  // Constructor

  SoulFlock() {
  }

  ///////////////////////////////////////////

  void update(float dt) {

    for (int i=0; i < souls.size(); i++) {
      Soul soul = souls.get(i);

      ArrayList<Force> used_forces = new ArrayList<Force>();
      if (self_gravity == true) {
        // Get the force types
        ArrayList<Force> forces = all_forces.get(i);    
        
        // Get self-gravity forces
        ArrayList<Force> sg_forces = new ArrayList<Force>();
        for (int j=0; j < souls.size(); j++) {
          // Don't calculate gravity w/ itself
          if (i != j) {
            Soul other_soul = souls.get(j);
            InverseSquare sg_force = new InverseSquare(other_soul.sf.pos, k, h);
            sg_forces.add(sg_force);
          }
        }

        // Combined force list
        used_forces.addAll(forces);
        used_forces.addAll(sg_forces);
        
      } else if (self_gravity == false) {
        used_forces = all_forces.get(i);
      }

      soul.update(dt, used_forces);
    }
  }

  ////////////////////////////////////////////////

  void display() {
    for (Soul soul : souls) {
      soul.display();
    }
  }

  ////////////////////////////////////////

  void reset() {
    souls = new ArrayList<Soul>();
    all_forces = new ArrayList<ArrayList<Force>>();
  }

  ///////////////////////////////////////////////

  // Calculate the gravitational forces within the flock
  // Currently broken

  void get_self_grav_forces() {
    all_sg_forces = new ArrayList<ArrayList<Force>>();
    for (int i=0; i < souls.size(); i++) {

      ArrayList<Force> sg_forces =new ArrayList<Force>();

      for (int j=0; j < souls.size(); j++) {

        // Don't calculate gravity w/ itself
        if (i != j) {
          Soul soul = souls.get(j);
          InverseSquare sg_force = new InverseSquare(soul.sf.pos, k, h);
          sg_forces.add(sg_force);
        }
      }
      all_sg_forces.add(sg_forces);
    }
  }
}