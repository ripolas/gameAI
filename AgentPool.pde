class AgentPool {
  ArrayList<Agent> agents = new ArrayList();
  int contains_count = 0;
  int contains_count2 = 0;
  int bfs_count = 0;
  int no_goal_bfs = 0;
  boolean [][] goal_claimed;
  AgentPool(int count) {
    for (int i = 0; i<count; i++) {
      boolean cant_spawn = true;
      int rndx;
      int rndy;
      goal_claimed = new boolean [world.w][world.h];
      reset_goal_claimed();
      do {
        rndx = (int)random(0, world.w);
        rndy = (int)random(0, world.h);
        boolean can_spawn = true;
        for (int j = 0; j<agents.size(); j++) {
          if (agents.get(j).position.x==rndx&&agents.get(j).position.y==rndy) {
            can_spawn = false;
            break;
          }
        }
        cant_spawn = !can_spawn;
        if (world.tiles[rndx][rndy].tile_type==Tile_type.WATER) {
          cant_spawn = true;
        }
      } while (cant_spawn);
      agents.add(new Agent(rndx, rndy));
    }
  }
  void update() {
    contains_count = 0;
    contains_count2 = 0;
    no_goal_bfs = 0;
    bfs_count = 0;
    for (int i = 0; i<agents.size(); i++) {
      agents.get(i).update();
    }
  }
  void display() {
    for (int i = 0; i<agents.size(); i++) {
      agents.get(i).display();
    }
  }
  void display_debug() {
    for (int i = 0; i<agents.size(); i++) {
      agents.get(i).display_debug();
    }
  }
  void reset_goal_claimed() {
    for (int i = 0; i<world.w; i++) {
      for (int j = 0; j<world.h; j++) {
        goal_claimed[i][j] = false;
      }
    }
  }
}
