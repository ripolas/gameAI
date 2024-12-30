class World {
  Tile[][] tiles;
  int w, h;
  PImage world;
  ArrayList<PVector> farmable_tiles = new ArrayList();
  World(int w, int h) {
    this.w=w;
    this.h=h;
    world = createImage(w, h, RGB);
    tiles = new Tile[w][h];
    noiseDetail(8);
    for (int i = 0; i<w; i++) {
      for (int j = 0; j<h; j++) {
        float val = noise(i/(200f/UNITS_PER_PIXEL), j/(200f/UNITS_PER_PIXEL));
        if (val>0.45) {
          tiles[i][j] = new Tile(Tile_type.SAND, i*(width/float(w)), j*(height/h), width/w, height/h, val);
        } else if (val>0.4) {
          tiles[i][j] = new Tile(Tile_type.GRASS, i*(width/float(w)), j*(height/h), width/w, height/h, val);
          farmable_tiles.add(new PVector(i,j));
        } else {
          tiles[i][j] = new Tile(Tile_type.WATER, i*(width/float(w)), j*(height/h), width/w, height/h, val);
        }
      }
    }
    precompute();
  }
  void precompute() {
    world.loadPixels();
    for (int i = 0; i<w; i++) {
      for (int j = 0; j<h; j++) {
        world.pixels[i+j*w] = tiles[i][j].colorValue();
      }
    }
    world.updatePixels();
  }
  void update() {
    for (int i = 0; i<tiles.length; i++) {
      for (int j = 0; j<tiles[0].length; j++) {
        tiles[i][j].update();
      }
    }
  }
  void display() {
    image(world, 0, 0, width, height);
  }
  void display_extra(){
    colorMode(HSB);
    noStroke();
     for (int i = 0; i<tiles.length; i++) {
      for (int j = 0; j<tiles[0].length; j++) {
        tiles[i][j].display();
      }
    }
  }
}
boolean valid_coordinates(float x, float y) {
  return x>=0&&x<world.w&&y>=0&&y<world.h;
}
