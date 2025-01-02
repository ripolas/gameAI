class Agent {
  PVector position;
  PVector goal;
  boolean moving = false;
  ArrayList<PVector> path = new ArrayList();
  int agent_group_index;
  int index;
  int path_element;
  int frames_not_moving = 0;
  boolean had_bfs = false;
  final int inactivity_index = 1; //frames spent not moving
  Agent(int x, int y, int agent_group_index, int index) {
    position = new PVector(x, y);
    this.agent_group_index = agent_group_index;
    this.index = index;
  }
  void update() {
    if (!moving) {
      frames_not_moving++;
      agent_pool.agent_groups.get(agent_group_index).agent_coords[(int)position.x][(int)position.y] = index;
      if (frames_not_moving>inactivity_index&&!agent_pool.agent_groups.get(agent_group_index).bfs_requests.contains(index)) {
        agent_pool.agent_groups.get(agent_group_index).requestBFS(index);
      }
    }
    if (moving) {
      had_bfs = true;
      frames_not_moving = 0;
      position = path.get(path_element);
      path_element--;
      if (path_element<0) {
        moving = false;
        goal = null;
        interact();
      }
    }
  }
  void interact() {
    if (is_goal(world.tiles[(int)position.x][(int)position.y].tile_type)) {
      if (world.tiles[(int)position.x][(int)position.y].tile_type==Tile_type.GRASS) {
        Plant_type here = Plant_type.NONE;
        final int CHECK_RADIUS = 10; // what radius around the agent to check for matching crops
        for (int dx = -CHECK_RADIUS; dx<=CHECK_RADIUS; dx++) {
          for (int dy = -CHECK_RADIUS; dy<=CHECK_RADIUS; dy++) {
            if (valid_coordinates(position.x+dx, position.y+dy)) {
              if (world.tiles[(int)position.x+dx][(int)position.y+dy].plant_type!=Plant_type.NONE) {
                here = world.tiles[(int)position.x+dx][(int)position.y+dy].plant_type;
                dx = MAX_INT-1;
                break;
              }
            }
          }
        }
        if (here == Plant_type.TOMATO) {
          world.tiles[(int)position.x][(int)position.y].tile_type=Tile_type.TOMATO_PLANTED;
          world.tiles[(int)position.x][(int)position.y].plant_type=Plant_type.TOMATO;
          agent_pool.tomatoes_planted++;
        } else if (here == Plant_type.YAM) {
          world.tiles[(int)position.x][(int)position.y].tile_type=Tile_type.YAM_PLANTED;
          world.tiles[(int)position.x][(int)position.y].plant_type=Plant_type.YAM;
          agent_pool.yams_planted++;
        } else if (here == Plant_type.NONE) {
          if (agent_pool.tomatoes_planted>agent_pool.yams_planted) {
            world.tiles[(int)position.x][(int)position.y].tile_type=Tile_type.YAM_PLANTED;
            world.tiles[(int)position.x][(int)position.y].plant_type=Plant_type.YAM ;
            agent_pool.yams_planted++;
          } else {
            world.tiles[(int)position.x][(int)position.y].tile_type=Tile_type.TOMATO_PLANTED;
            world.tiles[(int)position.x][(int)position.y].plant_type=Plant_type.TOMATO;
            agent_pool.tomatoes_planted++;
          }
        }
        world.tiles[(int)position.x][(int)position.y].update_needed = true;
      }
      if (world.tiles[(int)position.x][(int)position.y].tile_type==Tile_type.TOMATO_RIPE) {
        world.tiles[(int)position.x][(int)position.y].tile_type=Tile_type.TOMATO_STALK;
        world.tiles[(int)position.x][(int)position.y].update_needed = true;
      }
      if (world.tiles[(int)position.x][(int)position.y].tile_type==Tile_type.YAM_GROWN) {
        world.tiles[(int)position.x][(int)position.y].tile_type=Tile_type.YAM_ROOTS;
        world.tiles[(int)position.x][(int)position.y].update_needed = true;
      }
    }
  }
  void setup_for_walk() {
    path_element = int(path.size()-1);
    moving = true;
    goal = path.get(0).copy();
  }
  void display() {
    colorMode(RGB);
    if (had_bfs) {
      fill(0, 255, 0, 100);
    } else {
      fill(255, 0, 0, 100);
    }
    rectMode(CENTER);
    noStroke();
    circle(position.x*(width/world_width), position.y*(height/world_height), agent_pool.agent_groups.get(agent_group_index).MAX_AGENT_TRAVEL_DISTANCE*(float(width)/world.w));
  }
  void display_debug() {
    colorMode(RGB);
    if (goal!=null) {
      stroke(0);
      line(position.x*(width/world_width), position.y*(height/world_height), goal.x*(width/world_width), goal.y*(height/world_height));
    }
  }
}
