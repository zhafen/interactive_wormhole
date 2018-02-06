// Keep the history of a soul

class SoulHistory {

  // Position and velocity histories.
  ArrayList<PVector> prev_pos = new ArrayList<PVector>();
  ArrayList<PVector> prev_vel = new ArrayList<PVector>();

  // Number of positions and velocities tracked.
  int n_tracked = 10;

  // Constructor
  SoulHistory() {
  }

  /////////////////////////////////////////////////////

  void update(PVector latest_pos, PVector latest_vel) {

    // Adds the previous position and velocity, with more recent having a lower index
    prev_pos.add(0, latest_pos);
    prev_vel.add(0, latest_vel);

    // Shortens the list if longer than the number tracked.
    if (prev_pos.size() > n_tracked) {
      prev_pos.remove(prev_pos.size() - 1);
      prev_vel.remove(prev_vel.size() - 1);
    }
  }
}