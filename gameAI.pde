import java.util.Queue;
import java.util.LinkedList;
World world;
int world_width, world_height;
AgentPool agent_pool;
final int AGENT_COUNT = 50;
final float UNITS_PER_PIXEL = 3;
void setup() {
  size(1000,1000,P2D);
  ((PGraphicsOpenGL)g).textureSampling(2);
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
  agent_pool.display();
  agent_pool.display_debug();
  textAlign(LEFT,TOP);
  fill(255);
  textSize(20);
  text(int(frameRate),0,0);
}
void keyPressed(){
  draw();
}
