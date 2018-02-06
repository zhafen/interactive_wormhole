// Interactive visualization of the Ellis wormhole metric. 

//////////////////////////////////////////////////////////

// Malleable Global Variables

float b = 20.; // Wormhole radius
PVector w_pos = new PVector( 400, 300 ) ; // Wormhole position in units of pixels

float direction_of_motion = -1. ; // -1 for infalling particles, +1 for outgoing particles
//float h_gamma = 100. ; // Changing this should change how large the linear momentum is relative to the angular momentum.

float dt = .01;

///////////////////////////////////////////////

// Fixed Global Variables

SoulFlock soul_flock = new SoulFlock();
int n_souls = 0;

float frame_rate = 60.;
//float dt = 1./frame_rate;

///////////////////////////////////////////////////////

void setup() {
  size(800, 600);
  frameRate(frame_rate);
  colorMode(HSB, 100);
  
  textAlign( CENTER );
  textSize( 22 );

  add_new_particle(true);
}

void draw() {
  
  background(0);
  
  if ( second() < 20. ) {
    stroke( 0 );
    text( "Press 'n' to place a new particle at mouse location with random speed.", width/2., height/4. );
    text( "Click and drag particles to move them.", width/2., 3.*height/4. );
  }

  // Update and display the souls being guided along the path
  soul_flock.update(dt);
  soul_flock.display();

  //Show the wormhole location
  pushMatrix();
  translate(w_pos.x, w_pos.y);
  fill(17.*180/PI, 61, 99);
  ellipse(0, 0, 10, 10);
  fill(100);
  popMatrix();
}

// This, combined with mouseReleased(), allows for dragging of particles
void mousePressed() {

  float l = 20;
  PVector mouse_pos = new PVector(mouseX, mouseY);
  for (int i = 0; i < soul_flock.souls.size(); i++) {
    Soul soul = soul_flock.souls.get(i);
    if (mouse_pos.dist(soul.sf.pos) < l) {
      soul.su.update_type = "mouse";
    }
  }
}

// Return to regular updating
void mouseReleased() {
  for (int i = 0; i < soul_flock.souls.size(); i++) {
    Soul soul = soul_flock.souls.get(i);
    soul.su.update_type = "standard";
  }
}

void keyTyped() {

  // Add another particle
  if (key == 'n') {
    add_new_particle(false);
  }

  // Clear the waypoints and souls
  if (key == 'c') {

    // The Souls moving along a path
    soul_flock.reset();
    n_souls = 0;
  }
}

void add_new_particle(boolean random_pos) {
  // Add a soul to move along the path
  PVector pos = new PVector();
  if (random_pos == true) {
    pos = new PVector(random(width/4), random(height/4));
  } else {
    pos = new PVector(mouseX, mouseY);
  }
  PVector vel = new PVector(random(-300., 300.), random(-300., 300.));
  SoulForm sf = new SoulForm(pos, vel);
  Soul sl = new Soul(sf);
  //sl.su.boundary = "periodic";
  
  // Give the particle random impact parameter
  sl.su.impact_parameter = random(400.);
  // Give it a random angular momentum
  sl.su.l_mag = random(-100000., 100000.);

  //// Get the gravity from other souls and add onto this soul
  ArrayList<Force> forces = new ArrayList<Force>();

  // Add it to the flock
  soul_flock.souls.add(sl);
  soul_flock.all_forces.add(forces);
}