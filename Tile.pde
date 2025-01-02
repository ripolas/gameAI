class Tile {
  Tile_type tile_type;
  PVector position;
  float w, h;
  float depth; // perlin noise value
  int counter = 0;
  int ripe_time;
  ArrayList<Tile_type> not_natural = new ArrayList();
  boolean update_needed = false; // do you need to update the pixel the tile coresponds to
  PVector normal_position;
  Plant_type plant_type = Plant_type.NONE;
  Tile(Tile_type tile_type, float x, float y, float w, float h, float depth, int nx, int  ny) {
    this.normal_position = new PVector(nx,ny);
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
    if (frameCount%120==0) {
      if (tile_type==Tile_type.TOMATO_PLANTED) {
        counter++;
        if (counter>=45) {
          counter = 0;
          tile_type = Tile_type.TOMATO_STALK;
          update_needed = true;
        }
      }
      if (tile_type==Tile_type.TOMATO_STALK) {
        counter++;
        if (counter>=25) {
          counter = 0;
          tile_type = Tile_type.TOMATO_UNRIPE;
          ripe_time = (int)random(20, 70);
          update_needed = true;
        }
      }
      if (tile_type==Tile_type.TOMATO_UNRIPE) {
        counter++;
        if (counter>=ripe_time) {
          counter = 0;
          tile_type = Tile_type.TOMATO_RIPE;
          update_needed = true;
        }
      }

      if (tile_type==Tile_type.YAM_PLANTED) {
        counter++;
        if (counter>=40) {
          counter = 0;
          tile_type = Tile_type.YAM_ROOTS;
          update_needed = true;
        }
      }
      if (tile_type==Tile_type.YAM_ROOTS) {
        counter++;
        if (counter>=30) {
          counter = 0;
          tile_type = Tile_type.YAM_FLOWERS;
          ripe_time = (int)random(40, 50);
          update_needed = true;
        }
      }
      if (tile_type==Tile_type.YAM_FLOWERS) {
        counter++;
        if (counter>=ripe_time) {
          counter = 0;
          tile_type = Tile_type.YAM_GROWN;
          update_needed = true;
        }
      }
    }
    if (update_needed) {
      world.world.pixels[int(normal_position.x+normal_position.y*world.w)] = colorValue();
      update_needed = false;
    }
  }
  color colorValue() {
    colorMode(HSB);
    if (tile_type == Tile_type.WATER) {
      return color(map(230, 0, 360, 0, 255), 255, map(depth, 0, GRASS_BOUND, 0, 255));
    } else if (tile_type == Tile_type.GRASS) {
      return color(map(130, 0, 360, 0, 255), 255, map(depth, GRASS_BOUND, SAND_BOUND, 255, 100));
    } else if (tile_type == Tile_type.SAND) {
      return color(map(60, 0, 360, 0, 255), 255, map(depth, SAND_BOUND, 1, 255, 0));
    } else if (tile_type == Tile_type.TOMATO_PLANTED) {
      return color(#430001);
    } else if (tile_type == Tile_type.TOMATO_STALK) {
      return color(#710103);
    } else if (tile_type == Tile_type.TOMATO_UNRIPE) {
      return color(#A20003);
    } else if (tile_type == Tile_type.TOMATO_RIPE) {
      return color(#A20003);
    } else if (tile_type == Tile_type.YAM_PLANTED) {
      return color(#454600);
    } else if (tile_type == Tile_type.YAM_ROOTS) {
      return color(#676700);
    } else if (tile_type == Tile_type.YAM_FLOWERS) {
      return color(#8D8E00);
    } else if (tile_type == Tile_type.YAM_GROWN) {
      return color(#BCBC00);
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
    YAM_PLANTED,
    YAM_ROOTS,
    YAM_FLOWERS,
    YAM_GROWN,
}
enum Plant_type {
  TOMATO,
    YAM,
    NONE //safety first
}
boolean walkable(Tile_type tt) {
  return tt!=Tile_type.WATER;
}
boolean is_goal(Tile_type tt) {
  return tt==Tile_type.GRASS||tt==Tile_type.TOMATO_RIPE||tt==Tile_type.YAM_GROWN;
}
