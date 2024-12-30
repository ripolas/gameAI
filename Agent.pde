class Agent {
  PVector position;
  int[][] distances;
  boolean[][] reachable;
  PVector goal;
  boolean has_goal = false;
  ArrayList<PVector> path = new ArrayList();
  PVector possible_goal;
  PVector last_pos;
  int current_path_element = 0;
  Agent(float x, float y) {
    position = new PVector(x, y);
    last_pos = position.copy();
    distances = new int [world.w][world.h];
    reachable = new boolean [world.w][world.h];
    reset_distances();
    calculate_reachable();
  }
  void update() {
    last_pos = position.copy();
    if (goal!=null) {
      move_to_goal();
      if (world.tiles[(int)position.x][(int)position.y].tile_type == Tile_type.GRASS) {
        world.tiles[(int)position.x][(int)position.y].tile_type = Tile_type.TOMATO_PLANTED;
      } else if (world.tiles[(int)position.x][(int)position.y].tile_type == Tile_type.TOMATO_RIPE) {
        world.tiles[(int)position.x][(int)position.y].tile_type = Tile_type.TOMATO_UNRIPE;
      }
    } else {
      if (!is_goal(world.tiles[(int)position.x][(int)position.y].tile_type)) {
        has_goal = false;
        possible_goal=null;
        if(!(keyPressed&&key=='w')){
          for (int k = 0; k<world.farmable_tiles.size(); k++) {
            int i = (int)world.farmable_tiles.get(k).x;
            int j = (int)world.farmable_tiles.get(k).y;
            if (reachable[i][j]) {
              if (is_goal(world.tiles[i][j].tile_type)) {
                agent_pool.contains_count++;
                if (!agent_pool.goal_claimed[i][j]) {
                  possible_goal = new PVector(i, j);
                  has_goal = true;
                  break;
                }
              }
            }
          }
        }
        if (has_goal) {
          bfs((int)position.x, (int)position.y);
          if (goal!=null) {
            build_path((int)goal.x, (int)goal.y);
          } else {
            agent_pool.no_goal_bfs++;
          }
        }
      } else if (world.tiles[(int)position.x][(int)position.y].tile_type==Tile_type.GRASS) {
        world.tiles[(int)position.x][(int)position.y].tile_type = Tile_type.TOMATO_PLANTED;
      } else if (world.tiles[(int)position.x][(int)position.y].tile_type==Tile_type.TOMATO_RIPE) {
        world.tiles[(int)position.x][(int)position.y].tile_type = Tile_type.TOMATO_UNRIPE;
      }
    }
  }
  void display() {
    colorMode(RGB);
    fill(255, 0, 0);
    noStroke();
    rect(position.x*(width/world_width), position.y*(height/world_height), width/world_width, height/world_height);
  }
  void display_debug() {
    colorMode(RGB);
    //if (possible_goal!=null) {
    //  stroke(0, 255, 0);
    //  line(position.x*(width/world_width), position.y*(height/world_height), possible_goal.x*(width/world_width), possible_goal.y*(height/world_height));
    //}
    if (goal!=null) {
      stroke(0);
      line(position.x*(width/world_width), position.y*(height/world_height), goal.x*(width/world_width), goal.y*(height/world_height));
    }
  }
  void move_to_goal() {
    //if (!is_goal(world.tiles[(int)goal.x][(int)goal.y].tile_type)) {
    //  remove_goal();
    //  return;
    //}
    position = path.get(current_path_element).copy();
    current_path_element--;
    if (position.x==goal.x&&position.y==goal.y) {
      remove_goal();
    }
  }
  void build_path(int x, int y) {
    if (distances[x][y]!=-1) {
      path = new ArrayList<PVector>();
      path.add(new PVector(x, y));
      for (int i = distances[x][y]-1; i>=0; i--) {
        int px = (int)path.get(path.size()-1).x;
        int py = (int)path.get(path.size()-1).y;
        for (int dx = -1; dx<=1; dx++) {
          for (int dy = -1; dy<=1; dy++) {
            //if (abs(dx)+abs(dy)==1) {
            if (valid_coordinates(px+dx, py+dy)) {
              if(distances[px+dx][py+dy]!=-1){
                if (distances[px][py] > distances[px+dx][py+dy]) {
                  path.add(new PVector(px+dx, py+dy));
                  dy = 2;
                  dx = 2;
                }
              }
            }
          }
        }
      }
      current_path_element = path.size()-2; // last element is current position
    }
  }
  void bfs(int x, int y) {
    agent_pool.bfs_count++;
    reset_distances();
    Queue<PVector> queue = new LinkedList();
    queue.add(new PVector(x, y));
    distances[x][y] = 0;
    while (!queue.isEmpty()) {
      PVector current = queue.poll();
      for (int dx = -1; dx<=1; dx++) {
        for (int dy = -1; dy<=1; dy++) {
          //if (abs(dx)+abs(dy)==1) {
          if (valid_coordinates(current.x+dx, current.y+dy)) {
            if (distances[(int)current.x+dx][(int)current.y+dy]==-1) {
              if (walkable(world.tiles[(int)current.x+dx][(int)current.y+dy].tile_type)) {
                distances[(int)current.x+dx][(int)current.y+dy] = distances[(int)current.x][(int)current.y]+1;
                queue.add(new PVector(current.x+dx, current.y+dy));
                if (is_goal(world.tiles[(int)current.x+dx][(int)current.y+dy].tile_type)) {
                  agent_pool.contains_count2++;
                  if (!agent_pool.goal_claimed[(int)current.x+dx][(int)current.y+dy]) {
                    goal = new PVector(current.x+dx, current.y+dy);
                    agent_pool.goal_claimed[(int)goal.x][(int)goal.y] = true;
                    return;
                  }
                }
              }
            }
          }
        }
      }
    }
  }
  void calculate_reachable() {
    int x = (int)position.x;
    int y = (int)position.y;
    reset_reachable();
    Queue<PVector> queue = new LinkedList();
    queue.add(new PVector(x, y));
    reachable[x][y] = true;
    while (!queue.isEmpty()) {
      PVector current = queue.poll();
      for (int dx = -1; dx<=1; dx++) {
        for (int dy = -1; dy<=1; dy++) {
          //if (abs(dx)+abs(dy)==1){
          if (valid_coordinates(current.x+dx, current.y+dy)) {
            if (!reachable[(int)current.x+dx][(int)current.y+dy]) {
              if (walkable(world.tiles[(int)current.x+dx][(int)current.y+dy].tile_type)) {
                reachable[(int)current.x+dx][(int)current.y+dy] = true;
                queue.add(new PVector((int)current.x+dx, (int)current.y+dy));
              }
            }
          }
        }
      }
    }
  }
  void reset_reachable() {
    for (int i = 0; i<world.w; i++) {
      for (int j = 0; j<world.h; j++) {
        reachable[i][j] = false;
      }
    }
  }
  void reset_distances() {
    for (int i = 0; i<world.w; i++) {
      for (int j = 0; j<world.h; j++) {
        distances[i][j] = -1;
      }
    }
  }
  void remove_goal() {
    agent_pool.goal_claimed[(int)goal.x][(int)goal.y] = false;
    goal = null;
  }
}
