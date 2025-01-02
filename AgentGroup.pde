class AgentGroup {
  boolean reachable [][];
  int agent_coords [][];
  ArrayList<Agent> agents = new ArrayList();
  int distances [][];
  ArrayList<PVector> goals = new ArrayList();
  ArrayList<Integer> bfs_requests = new ArrayList();
  final int FRAMES_PER_BFS = 1;
  boolean goal_reached = false;
  int MAX_AGENT_TRAVEL_DISTANCE = 40;
  AgentGroup(boolean reachable [][]) {
    this.reachable = reachable;
  }
  void init() {
    println("MAX AGENT TRAVEL DISTANCE: "+MAX_AGENT_TRAVEL_DISTANCE);
    agent_coords = new int [world.w][world.h];
    for (int i = 0; i<world.w; i++) {
      for (int j = 0; j<world.h; j++) {
        agent_coords[i][j] = -1;
      }
    }
    for (int i = 0; i<agents.size(); i++) {
      agent_coords[(int)agents.get(i).position.x][(int)agents.get(i).position.y] = i;
    }
    distances = new int [world.w][world.h];
  }
  void update() {
    goal_reached = false;
    bfs();
    for (int i = 0; i<goals.size(); i++) {
      ArrayList<PVector> tpath = get_path((int)goals.get(i).x, (int)goals.get(i).y);
      int id = agent_coords[(int)tpath.get(tpath.size()-1).x][(int)tpath.get(tpath.size()-1).y];
      if (id!=-1&&!agents.get(id).moving) {
        agents.get(id).path = tpath;
        agents.get(id).setup_for_walk();
        agent_coords[(int)tpath.get(tpath.size()-1).x][(int)tpath.get(tpath.size()-1).y] = -1;
      }
    }
    if (goal_reached) {
      if (frameCount%FRAMES_PER_BFS==0&&bfs_requests.size()>0) {
        int id = bfs_requests.get(0);
        bfs_requests.remove(0);
        PVector goal = single_bfs((int)agents.get(id).position.x, (int)agents.get(id).position.y,!agents.get(id).had_bfs);
        if (goal!=null) {
          ArrayList<PVector> tpath = get_path((int)goal.x, (int)goal.y);
          agents.get(id).path = tpath;
          agents.get(id).setup_for_walk();
          agent_coords[(int)tpath.get(tpath.size()-1).x][(int)tpath.get(tpath.size()-1).y] = -1;
        }
      }
    }
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
  void bfs() {
    reset_distances();
    goals = new ArrayList();
    Queue<PVector> queue = new LinkedList();
    for (int i = 0; i<agents.size(); i++) {
      if (!agents.get(i).moving) {
        queue.add(agents.get(i).position.copy());
        distances[(int)agents.get(i).position.x][(int)agents.get(i).position.y] = 0;
      }
    }
    while (!queue.isEmpty()) {
      PVector current = queue.poll();
      if(distances[(int)current.x][(int)current.y]>MAX_AGENT_TRAVEL_DISTANCE){
        return;
      }
      for (int dx = -1; dx<=1; dx++) {
        for (int dy = -1; dy<=1; dy++) {
          if (valid_coordinates(current.x+dx, current.y+dy)) {
            if (walkable(world.tiles[(int)current.x+dx][(int)current.y+dy].tile_type)) {
              if (distances[(int)current.x+dx][(int)current.y+dy]==-1) {
                if (is_goal(world.tiles[(int)current.x+dx][(int)current.y+dy].tile_type)) {
                  goals.add(new PVector((int)current.x+dx, (int)current.y+dy));
                }
                distances[(int)current.x+dx][(int)current.y+dy] = distances[(int)current.x][(int)current.y]+1;
                queue.add(new PVector((int)current.x+dx, (int)current.y+dy));
                if (goals.size()>=agents.size()*10) { // bigger constant bigger lag, but more agents moving at a given time
                  goal_reached = true;
                  return;
                }
              }
            }
          }
        }
      }
    }
  }
  PVector single_bfs(int x, int y, boolean first) { //if first, bfs has no limit
    reset_distances();
    Queue<PVector> queue = new LinkedList();
    queue.add(new PVector(x, y));
    distances[x][y] = 0;
    while (!queue.isEmpty()) {
      PVector current = queue.poll();
      if(!first && distances[(int)current.x][(int)current.y]>MAX_AGENT_TRAVEL_DISTANCE){
        return null;
      }
      for (int dx = -1; dx<=1; dx++) {
        for (int dy = -1; dy<=1; dy++) {
          if (valid_coordinates(current.x+dx, current.y+dy)) {
            if (walkable(world.tiles[(int)current.x+dx][(int)current.y+dy].tile_type)) {
              if (distances[(int)current.x+dx][(int)current.y+dy]==-1) {
                distances[(int)current.x+dx][(int)current.y+dy] = distances[(int)current.x][(int)current.y]+1;
                queue.add(new PVector((int)current.x+dx, (int)current.y+dy));
                if (is_goal(world.tiles[(int)current.x+dx][(int)current.y+dy].tile_type)) {
                  return new PVector(current.x+dx, current.y+dy);
                }
              }
            }
          }
        }
      }
    }
    return null;
  }
  void requestBFS(int id) {
    bfs_requests.add(id);
  }
  void reset_distances() {
    for (int i = 0; i<world.w; i++) {
      for (int j = 0; j<world.h; j++) {
        distances[i][j] = -1;
      }
    }
  }
  ArrayList<PVector> get_path(int x, int y) {
    ArrayList<PVector> path = new ArrayList();
    path.add(new PVector(x, y));
    while (distances[(int)path.get(path.size()-1).x][(int)path.get(path.size()-1).y]!=0) {
      PVector current = path.get(path.size()-1).copy();
      PVector best = null;
      int smallest = MAX_INT;
      for (int dx = -1; dx<=1; dx++) {
        for (int dy = -1; dy<=1; dy++) {
          if (valid_coordinates(current.x+dx, current.y+dy)) {
            if (distances[(int)current.x+dx][(int)current.y+dy]!=-1) {
              if (distances[(int)current.x+dx][(int)current.y+dy]<smallest) {
                smallest = distances[(int)current.x+dx][(int)current.y+dy];
                best = new PVector(current.x+dx, current.y+dy);
              }
            }
          }
        }
      }
      path.add(best);
    }
    return path;
  }
  boolean same(boolean reachable_ [][]) {
    for (int i = 0; i<world.w; i++) {
      for (int j = 0; j<world.h; j++) {
        if (reachable[i][j]!=reachable_[i][j]) {
          return false;
        }
      }
    }
    return true;
  }
}
