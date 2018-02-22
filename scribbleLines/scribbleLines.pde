import processing.pdf.*;
import java.util.*;

//click to safe jpg and pdf

//number of connected strokes
int nrStrokes = 50;

//area to search for next line end
int range = 25;

//stroke weight
int strokesize = 2;


// path/name of the file to load
String filename = "../exampleImages/cat.jpg";

PImage img;
int lastX = 0;
int lastY = 0;
int posX = 0;
int posY = 0;
boolean[][] visited;

void setup() {
  
  img = loadImage(filename);
  
  size(800, 600);
  
  surface.setResizable(true);
  surface.setSize(img.width, img.height);
  visited = new boolean[img.width+1][img.height+1];
  redraw();
  //noLoop();
  int l = weightedPos(0,0,img.width,img.height);
  posX = pointX(l);
  posY = pointY(l);
  
  stroke(0);
  strokeWeight(strokesize);
  background(255);
  image(img, 0, 0);
  

  
  beginRecord(PDF, "scribble.pdf"); 
}

void draw() {
  
    stroke(0);
    lastX = 0;
    lastY = 0;
    int l = weightedPos(0,0,img.width,img.height);
    posX = pointX(l);
    posY = pointY(l);

    for(int i = 0; i<nrStrokes; i++){
      l = weightedPos(posX-(range/2),posY-(range/2),range,range);
      update(pointX(l),pointY(l));
      line(lastX, lastY, posX, posY);
    }

}




void mousePressed(){
  saveFrame("scribble.jpg");
  endRecord();
  noLoop();
}

int weightFunc(ArrayList<Integer> val, ArrayList<Integer> weight){
  int sum = 0;
  ArrayList<Integer> integSum = new ArrayList<Integer>();
  for( int i = 0; i<val.size(); i++ ){
    sum += val.get(i)*weight.get(i);
    integSum.add(sum);
  }
 
  float rnd = random(0,sum);
  for(int i = 0; i<integSum.size(); i++){
    if(rnd<=integSum.get(i)){
      return val.get(i);
    }
  }
  return -1;
}


int weightedPos(int x, int y, int w, int h){
  int allPixels = w*h;
  HashMap<Integer,ArrayList<Integer>> map = new HashMap<Integer,ArrayList<Integer>>();
  for(int i = 0; i<w; i++){
    for(int j = 0; j<h; j++){
      
      if(x+i>0 && x+i<img.width && y+j>0 && y+j<img.height){
        ArrayList<Integer> lst = map.get(round(brit(x+i,y+j)));   
        if(lst == null){
          lst = new ArrayList<Integer>();
       
        }

        if(!visited[x+i][y+j]){
          lst.add(loc(x+i,y+j));
        }
        
        map.put(round(brit(x+i,y+j)),lst);

      }
      
    }
  }
  
  //available brightness values
  Set<Integer> s = map.keySet();
  ArrayList<Integer> ks = new ArrayList<Integer>();
  ks.addAll(s);
  Collections.sort(ks);
  
  ArrayList<Integer> weights = new ArrayList<Integer>();
  for( int i = 0; i<ks.size(); i++ ){
    int nrPxls = (int)((float)map.get(ks.get(i)).size()*1000/allPixels);
    weights.add((i+1)*2  *   nrPxls);
   
  }
  
  
  int k =  weightFunc(ks,weights);
  ArrayList<Integer> l = map.get(k);
  int r = round(random(0,l.size()-1));
        
  visited[pointX(r)][pointY(r)] = true;      
        
  return l.get(r);
  
}

void update(int lineX, int lineY){
  lastX = posX;
  lastY = posY;
  posX = lineX;
  posY = lineY;
}

int loc(int x, int y){
  return x + y*img.width;
}

int pointX(int l){
  return l % img.width;
}

int pointY(int l){
  return l / img.width;
}

float brit(int x, int y){
  int pos = loc(x,y);
  color col = img.pixels[pos];
  // inverting here helps for easier weighting later
  return 255-brightness(col)/2;
}