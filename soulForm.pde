// Body details for the soul particle class

class SoulForm {
  PVector pos, vel;

  boolean visible = true;

  // Constructor
  SoulForm(PVector position, PVector velocity) {
    pos = position;
    vel = velocity;
  }

  ////////////////////////////////////////////

  // Default display option
  void display() {
    if (visible) {
      pushMatrix();
      translate(pos.x, pos.y);
      ellipse(0, 0, 25, 25);
      popMatrix();
    }
  }
}

//////////////////////////////////////////

// Class for displaying text for the particles

class TextForm extends SoulForm {
  String text;

  int textsize = 16;
  color text_fill = color(0);

  // Constructor
  TextForm(PVector position, PVector velocity, String used_text) {
    super(position, velocity);
    text = used_text;
  }

  /////////////////////////////////////////////////////////////////

  void display() {
    if (visible) {
      pushMatrix();
      translate(pos.x, pos.y);
      stroke(255);
      textAlign(LEFT);
      textSize(textsize);
      text(text, 0, 0);
      popMatrix();
    }
  }
}

///////////////////////////////////////////////////////////

class TrailForm extends SoulForm {

  SoulHistory sh = new SoulHistory();

  // Number of frames between trailing objects
  int n_frames_between = 1;

  // Constructor
  TrailForm(PVector position, PVector velocity) {
    super(position, velocity);
  }

  ////////////////////////////////////////////////////////////

  void display() {

    sh.update(pos, vel);

    if (visible) {

       // DEBUG
       // Change to step, instead of calculating modulus, for speedup
      for (int i = sh.prev_pos.size() - 1; i >= 0; i = i - 1) {

        if (i % n_frames_between == 0) {
          PVector h_pos = sh.prev_pos.get(i);

          // Get the color
          float b = map(i, sh.prev_pos.size() - 1, 0, 0, 100);
          fill(0, 0, b);

          pushMatrix();
          translate(h_pos.x, h_pos.y);
          ellipse(0, 0, 25, 25);
          popMatrix();
        }
      }
    }
  }
}