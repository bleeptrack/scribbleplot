
//click to safe jpg
//change this path to your image
String filename = "../exampleImages/kleinerfindus.jpg";



PImage img;
boolean resz = false;

float[][] a;
float[][] b;

float minB = -1;
float maxB = 256;

float fmin = 0.025;
float fmax = 0.037;
float kMap[][];

float kmin = 0.056;
float kmax = 0.0632;
float fMap[][];

float[][] filter = { {0.05, 0.2, 0.05}, {0.2, -1, 0.2}, {0.05, 0.2, 0.05}};

//default
float f = 0.037;
float k = 0.061;

float[][] tmpA;
float[][] tmpB;

float da = 1;
float db = 0.5;

int w;
int h;

int count = 0;
int speed = 5;

PImage dimg;


int loc(int x, int y){
  return x + y*img.width;
}

int pointX(int l){
  return l % img.width;
}

int pointY(int l){
  return l / img.width;
}

int brit(int x, int y){
  int pos = loc(x,y);
  color col = img.pixels[pos];
  // inverting here helps for easier weighting later
  return round(255-brightness(col));
}

void init(){
  for(int i = 0; i< w; i++){
    for(int j = 0; j< h; j++){
      a[i][j] = 1.0;
    }
  }               
  
  kMap = new float[w][h];
  fMap = new float[w][h];

  int[] histogram = new int[256];
  
  for(int i = 0; i< w; i++){
    for(int j = 0; j< h; j++){
      histogram[brit(i,j)] += 1;
      
    }
  }
  for(int i = 0; i<256; i++){
    if(minB==-1 && histogram[i]>1000){
      minB = i;
    }
    if(maxB==256 && histogram[255-i]>1000){
      maxB = 255-i;
    }
  }
  
  
  float kStep = (kmax-kmin)/255;
  float cStep = 180.0/width;
  float fStep = (fmax-fmin)/255;
  
  for(int i = 0; i< w; i++){
    for(int j = 0; j< h; j++){
      kMap[i][j] = kmax - kStep*map(brit(i,j),minB,maxB,0,255);
      
      fMap[i][j] = fmin + fStep*map(brit(i,j),minB,maxB,0,255);
    }
  }
}


int getcolorBW(float value){
  return 255-(int)constrain(map(value,0,0.4,0,255),0,255);
}


void setup(){
  img = loadImage(filename);
  size(800, 600, P2D);
  surface.setResizable(true);
  //
  image(img, 0, 0);
  colorMode(HSB,360,100,100);
  
  redraw();
  
  w = img.width;
  h= img.height;
  dimg = new PImage(w,h);
  a = new float[w][h];
  b = new float[w][h];
  tmpA = new float[w][h];
  tmpB = new float[w][h];
  init();
  randFeed();
  noStroke();
  
}

void randFeed(){
  for(int i = 0; i< w; i++){
    for(int j = 0; j< h; j++){
      float r = random(0,1);
      if(r>0.995){
        b[i][j]=1;
      }
    }
  }
}

void mouseClicked(){
  saveFrame("one-"+ceil(random(0,1009))+".png");
}


void draw(){  
  if(!resz){
    surface.setSize(img.width, img.height);
    resz = true;
  }

  if(count>speed){
    count = 0;
    background(255);
    
    for(int x = 0; x<w; x++){
      for( int y = 0; y<h; y++){
        dimg.pixels[loc(x,y)]=color(217,0,map(getcolorBW(b[x][y]),0,255,0,100));
      }
    }
    dimg.updatePixels();
    image(dimg, 0, 0);
  }
 
  step();
  
  
}




void step(){
  count++;
  
  for(int x = 0; x<w; x++){
    for( int y = 0; y<h; y++){
      tmpA[x][y] = constrain(stepA(x,y),0,1);
      tmpB[x][y] = constrain(stepB(x,y),0,1);
    }
  }
  a = tmpA;
  b = tmpB;
}

float stepA(int x, int y){
  return a[x][y] + (da * laplace(a,x,y) - a[x][y] * b[x][y]*b[x][y] + fMap[x][y]*(1-a[x][y])); 
}

float stepB(int x, int y){
  float l = laplace(b,x,y);
  return b[x][y] + (db * l + a[x][y] * b[x][y]*b[x][y] - (kMap[x][y]+fMap[x][y]) * b[x][y]);
}

float laplace(float[][] field, int x, int y){
  float res = 0;
  for(int i = 0; i<3; i++){
    for(int j = 0; j<3; j++){
      res += field[(x-1+i+w)%w][(y-1+j+h)%h] * filter[i][j];
    }
  }
  return res;
}