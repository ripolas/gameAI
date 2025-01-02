final float SAND_BOUND = 0.45;
final float GRASS_BOUND = 0.4;
class World {
  Tile[][] tiles;
  int w, h;
  PImage world;
  ArrayList<PVector> walkable_tiles = new ArrayList();
  World(int w, int h) {
    this.w=w;
    this.h=h;
    world = createImage(w, h, RGB);
    tiles = new Tile[w][h];
    noiseDetail(20);
    for (int i = 0; i<w; i++) {
      for (int j = 0; j<h; j++) {
        float val = noise(i/(100f), j/(100f));
        if (val>SAND_BOUND) {
          tiles[i][j] = new Tile(Tile_type.SAND, i*(width/float(w)), j*(height/h), width/w, height/h, val,i,j);
        } else if (val>GRASS_BOUND) {
          tiles[i][j] = new Tile(Tile_type.GRASS, i*(width/float(w)), j*(height/h), width/w, height/h, val,i,j);
        } else {
          tiles[i][j] = new Tile(Tile_type.WATER, i*(width/float(w)), j*(height/h), width/w, height/h, val,i,j);
        }
        if (walkable(tiles[i][j].tile_type)) {
          walkable_tiles.add(new PVector(i, j));
        }
      }
    }
    println("CREATED WORLD, STARTING TO PRECOMPUTE THE IMAGE");
    precompute();
    println("IMAGE COMPUTED");
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
    world.loadPixels();
    for (int i = 0; i<tiles.length; i++) {
      for (int j = 0; j<tiles[0].length; j++) {
        tiles[i][j].update();
      }
    }
    world.updatePixels();
  }
  void display() {
    image(world, 0, 0, width, height);
  }
}
boolean valid_coordinates(float x, float y) {
  return x>=0&&x<world.w&&y>=0&&y<world.h;
}
