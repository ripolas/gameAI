class AgentPool {
  ArrayList<AgentGroup> agent_groups = new ArrayList();
  boolean reachable [][];
  int tomatoes_planted = 0;
  int yams_planted = 0;
  AgentPool(int count) {
    ArrayList<PVector> agent_positions = new ArrayList();
    for (int k = 0; k<count; k++) {
      int rndx=-1;
      int rndy=-1;
      while (true) {
        int rnd_id = (int)random(0,world.walkable_tiles.size());
        rndx = (int)world.walkable_tiles.get(rnd_id).x;
        rndy = (int)world.walkable_tiles.get(rnd_id).y;
        if (walkable(world.tiles[rndx][rndy].tile_type)) {
          boolean agent_there = false;
          for (PVector a : agent_positions) {
            if (a.x==rndx&&a.y==rndy) {
              agent_there = true;
              break;
            }
          }
          if (!agent_there) {
            break;
          }
        }
      }
      agent_positions.add(new PVector(rndx, rndy));
      reachable = new boolean [world.w][world.h];
      for (int i = 0; i<world.w; i++) {
        for (int j = 0; j<world.h; j++) {
          reachable[i][j] = false;
        }
      }
      bfs(rndx, rndy);
      boolean added = false;
      for (int i = 0; i<agent_groups.size(); i++) {
        if (agent_groups.get(i).same(reachable)) {
          agent_groups.get(i).agents.add(new Agent(rndx, rndy, i,agent_groups.get(i).agents.size()));
          agent_positions.add(new PVector(rndx, rndy));
          added = true;
          break;
        }
      }
      if (!added) {
        agent_groups.add(new AgentGroup(reachable));
        agent_groups.get(agent_groups.size()-1).agents.add(new Agent(rndx, rndy, agent_groups.size()-1,0));
      }
      println("Agent "+(k+1)+" added.");
    }
    println("Created "+agent_groups.size()+" groups.");
    println("Added "+count+" agents.");
    for (int i = 0; i<agent_groups.size(); i++) {
      agent_groups.get(i).init();
    }
  }
  void update() {
    for (int i = 0; i<agent_groups.size(); i++) {
      agent_groups.get(i).update();
    }
  }
  void display() {
    for (int i = 0; i<agent_groups.size(); i++) {
      agent_groups.get(i).display();
    }
  }
  void display_debug() {
    for (int i = 0; i<agent_groups.size(); i++) {
      agent_groups.get(i).display_debug();
    }
  }
  void bfs(int x, int y) {
    Queue<PVector> queue = new LinkedList();
    queue.add(new PVector(x, y));
    reachable[x][y] = true;
    while (!queue.isEmpty()) {
      PVector current = queue.poll();
      for (int dx = -1; dx<=1; dx++) {
        for (int dy = -1; dy<=1; dy++) {
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
}
