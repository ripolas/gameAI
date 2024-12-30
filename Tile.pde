class Tile {
  Tile_type tile_type;
  PVector position;
  float w, h;
  float depth; // perlin noise value
  int counter = 0;
  int tomato_ripe_time = (int)random(20, 70);
  ArrayList<Tile_type> not_natural = new ArrayList();
  Tile(Tile_type tile_type, float x, float y, float w, float h, float depth) {
    this.tile_type = tile_type;
    this.position = new PVector(x, y);
    this.w=w;
    this.h=h;
    this.depth = depth;
    not_natural.add(Tile_type.TOMATO_PLANTED);
    not_natural.add(Tile_type.TOMATO_STALK);
    not_natural.add(Tile_type.TOMATO_UNRIPE);
    not_natural.add(Tile_type.TOMATO_RIPE);
  }
  void update() {
    if (frameCount%1==0) {
      if (tile_type==Tile_type.TOMATO_PLANTED) {
        counter++;
        if (counter>=45) {
          counter = 0;
          tile_type = Tile_type.TOMATO_STALK;
        }
      }
      if (tile_type==Tile_type.TOMATO_STALK) {
        counter++;
        if (counter>=25) {
          counter = 0;
          tile_type = Tile_type.TOMATO_UNRIPE;
        }
      }
      if (tile_type==Tile_type.TOMATO_UNRIPE) {
        counter++;
        if (counter>=tomato_ripe_time) {
          counter = 0;
          tile_type = Tile_type.TOMATO_RIPE;
          tomato_ripe_time = (int)random(20, 70);
        }
      }
    }
  }
  void display() {
    if(not_natural.contains(tile_type)){
      fill(colorValue());
      rect(position.x, position.y, w, h);
    }
  }
  color colorValue(){
    colorMode(HSB);
    if (tile_type == Tile_type.WATER) {
      return color(map(230, 0, 360, 0, 255), 255, map(depth, 0, 0.4, 0, 255));
    } else if (tile_type == Tile_type.GRASS) {
      return color(map(130, 0, 360, 0, 255), 255, map(depth, 0.4, 0.45, 255, 100));
    } else if (tile_type == Tile_type.SAND) {
      return color(map(60, 0, 360, 0, 255), 255, map(depth, 0.45, 1, 255, 0));
    } else if (tile_type == Tile_type.TOMATO_PLANTED) {
      return color(#581412);
    } else if (tile_type == Tile_type.TOMATO_STALK) {
      return color(#AD5333);
    } else if (tile_type == Tile_type.TOMATO_UNRIPE) {
      return color(#E07976);
    } else if (tile_type == Tile_type.TOMATO_RIPE) {
      return color(#830101);
    }
    return color(0);
  }
}
enum Tile_type {
  WATER,
  GRASS,
  SAND,
  TOMATO_PLANTED,
  TOMATO_STALK,
  TOMATO_UNRIPE,
  TOMATO_RIPE,
}
boolean walkable(Tile_type tt){
  return tt!=Tile_type.WATER;
}
boolean is_goal(Tile_type tt){
  return tt==Tile_type.GRASS||tt==Tile_type.TOMATO_RIPE;                     
}
