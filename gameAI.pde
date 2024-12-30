import java.util.Queue;
import java.util.LinkedList;
World world;
int world_width, world_height;
AgentPool agent_pool;
final int AGENT_COUNT = 1000;
final float UNITS_PER_PIXEL = 5;
void setup() {
  size(1000, 1000);
  noSmooth();
  world_width = int(width/UNITS_PER_PIXEL);
  world_height = int(height/UNITS_PER_PIXEL);
  world = new World(world_width, world_height);
  agent_pool= new AgentPool(AGENT_COUNT);
  frameRate(1000);
}
void draw() {
  background(0);
  agent_pool.update();
  world.update();
  world.display();
  if(keyPressed&&key==' '){
    world.display_extra(); // display tomatoes, yam, roads, ect. CAUSES LAG
  }
  if(mousePressed){
    agent_pool.display_debug();
  }
  agent_pool.display();
  textAlign(LEFT,TOP);
  fill(255);
  textSize(20);
  text(int(frameRate),0,0);
  text(agent_pool.contains_count,0,20);
  text(agent_pool.contains_count2,0,40);
  text(agent_pool.bfs_count,0,60);
  //println(world.farmable_tiles.size());
}
