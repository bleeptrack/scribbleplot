import processing.pdf.*;

//change these parameters as you want :)
//pdf gets saved automatically
//click to safe jpg
//press any key to redraw image

//size of each scribbly block in the finished image
int s = 9;

//number of pixels lines are allowed to expand into the neighour blocks
int addon = 2;

//maximum lines allowed in each block
int maxlines = 30;

// path/name of the file to load
String filename = "../exampleImages/cat.jpg";

PImage img;
float lastX = 0;
float lastY = 0;
float posX = 0;
float posY = 0;

void setup() {
  
  img = loadImage(filename);
  
  size(800, 600);
  surface.setResizable(true);
  surface.setSize(img.width, img.height);
  redraw();
  noLoop();
  
  beginRecord(PDF, "scribble.pdf"); 
}

void mousePressed(){
  saveFrame("scribble.jpg");
}

void keyPressed(){
  redraw();
}


void draw() {
  
  stroke(0);
  background(255);
  //image(img, 0, 0);
  for(int windowX = s/2+1; windowX+s/2< img.width; windowX += s){
    for(int windowY = s/2+1; windowY+s/2 < img.height; windowY += s){
      update(windowX,windowY);
      drawBlock(windowX,windowY,s,addon);
      
      //println(windowX + " "+ windowY);
      
    }
  }
  
  endRecord();
}

int loc(int x, int y){
  return x + y*img.width;
}

float brit(int x, int y){
  int pos = loc(x,y);
  color col = img.pixels[pos];
  return brightness(col);
}

float avgBrit(int x, int y, int s){
  FloatList l = new FloatList();
  for(int xi = x-s/2; xi <= x+s/2; xi++){
    for(int yi = y-s/2; yi <= y+s/2; yi++){
      l.append(brit(xi,yi));
    }
  }
  return 255 - (l.sum()/l.size());
}

void update(float lineX, float lineY){
  lastX = posX;
  lastY = posY;
  posX = lineX;
  posY = lineY;
}

float randBlock(int x, int s, int a){
  return random(x-s/2-a,x+s/2+a);
}

int getLoop(float brit){
  return round(map(brit,0,255,0,maxlines));
}

int getLoop(int x, int y, int s){
  float brit = avgBrit(x,y,s);
  //println("brit " + brit + " " + x + " " + y);
  return round(map(brit,0,255,0,maxlines));
}

void drawBlock(int x, int y, int s, int a){
  int loops = getLoop(x,y,s);
  for(int i = 0; i<loops; i++){
    update(randBlock(x,s,a),randBlock(y,s,a));
    line(lastX,lastY,posX,posY);
  } 
}