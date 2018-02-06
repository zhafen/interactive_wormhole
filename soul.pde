// Basically a particle class
class Soul {
  SoulForm sf;        // Physical details of the soul
  SoulGuide sg = new SoulGuide();    // If the soul is guided on a set path.
  SoulUpdater su = new SoulUpdater();    // How the Soul changes from moment to moment

  /////////////////////////////////////////////////////////

  // Constructor
  Soul(SoulForm soul_form) {
    sf = soul_form;
  }

  //////////////////////////////////////////////

  // Update the particle's position

  void update(float dt, ArrayList<Force> forces) {
    su.update(dt, sf, sg, forces);
  }

  ///////////////////////////////////////////////////

  // Display the particle

  void display() {
    sf.display();
  }
}