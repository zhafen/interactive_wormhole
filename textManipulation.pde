// Tools for manipulating text.

////////////////////////////////////////////////////

// Break down a sentence

class SentenceGeometry {
  int n_words;
  String[] word_list;
  FloatList x_coords = new FloatList();
  float sentence_width;

  // Constructor
  SentenceGeometry(String sentence) {

    // Space width used for calculating coordinates
    float space_width = textWidth(" ");

    // Break the sentence down
    sentence_width = textWidth(sentence);
    word_list = split(sentence, " ");
    n_words = word_list.length;

    // Save the text coordinates to a json array
    float text_coord = 0.;
    for (int i = 0; i<word_list.length; i++) {
      x_coords.append(text_coord);
      text_coord += space_width + textWidth(word_list[i]);
    }
  }
}

////////////////////////////////////////////////////////////

// Class for breaking down a paragraph

class ParagraphGeometry {
  ArrayList<SentenceGeometry> geo_list = new ArrayList<SentenceGeometry>();
  int n_words = 0;
  float x, y, spacing;

  // Constructor
  ParagraphGeometry(String[] paragraph, float x_coord, float y_coord, float line_spacing) {

    x = x_coord;
    y = y_coord;
    spacing = line_spacing;

    // Get the individual sentence geometries.
    for (int i = 0; i<paragraph.length; i++) {
      SentenceGeometry geometry = new SentenceGeometry(paragraph[i]);
      n_words += geometry.n_words;
      geo_list.add(geometry);
    }
  }


  /////////////////////////////////////////////////////////

  // Return {s_coord, w_coord}, where s_coord is the coordinate for the number of sentences in and w_coord is the coordinate for the number of words into that sentence.
  // This is for a word t_coord+1 words into the paragraph.

  int[] wordSentenceCoords(int t_coord) {
    int[] coords = {0, 0};

    SentenceGeometry geo = geo_list.get(coords[0]);
    for (int i = 0; i < t_coord; i++) {

      // Change the coordinates if end of the sentence is reached
      if (coords[1]==geo.n_words-1) {
        coords[0]++;
        coords[1] = 0;
        geo = geo_list.get(coords[0]);
      } else {
        coords[1]++;
      }
    }

    return coords;
  }

  //////////////////////////////////////////////////////

  // Display a section of a paragraph

  void displayParagraph(int n_words_print) {

    int s_coord = 0;
    int w_coord = 0;

    float y_coord = y - spacing*geo_list.size()/2.;
    SentenceGeometry geo = geo_list.get(s_coord);
    for (int i = 0; i <= n_words_print; i++) {

      // Display the selected word.
      textAlign(LEFT);
      float x_coord = geo.x_coords.get(w_coord) + x - geo.sentence_width/2.;
      text(geo.word_list[w_coord], x_coord, y_coord);

      // Change the coordinates
      if (w_coord==geo.n_words-1) {
        // Don't try to update the coordinates at the end
        if (i != n_words_print) {
          s_coord++;
          y_coord += spacing;
          w_coord = 0;
          geo = geo_list.get(s_coord);
        }
      } else {
        w_coord++;
      }
    }
  }

  //////////////////////////////////////////////////////

  // Get the x and y coordinates of the "t_coord + 1"th word in a paragraph

  float[] xyCoords(int t_coord) {

    // For iterating when going over the loop
    int s_coord = 0;
    int w_coord = 0;
    int n_words_print = t_coord + 1;

    // Loop initialization
    float x_coord = 0;
    float y_coord = y - spacing*geo_list.size()/2.;
    SentenceGeometry geo = geo_list.get(s_coord);

    for (int i = 0; i <= t_coord; i++) {

      // Get the x_coordinate
      x_coord = geo.x_coords.get(w_coord) + x - geo.sentence_width/2.;

      // Change the coordinates
      if (w_coord==geo.n_words-1) {

        // Don't try to update the coordinates at the end
        if (i != n_words_print) {
          s_coord++;
          y_coord += spacing;
          w_coord = 0;
          geo = geo_list.get(s_coord);
        }
      } else {
        w_coord++;
      }
    }

    float[] xy_coords = {x_coord, y_coord};

    return xy_coords;
  }
}