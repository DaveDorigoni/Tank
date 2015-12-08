import processing.serial.*;    //  Load serial library

///////////////////////////////////////////////////////////////////////////////////

int tankLevel = 0;

public class Tank{
 private int x;
 private int y;
 private int color_ = 200;
 private float size;
 private int level; //height of the threshold
 private float levelPerc; //level in perc of the threshold
 private int waterLevel; //level in perc of the water
 
 public Tank(int xf, int yf, float _size){
  x = xf;
  y = yf;
  size = _size; //the size equals to a unit
  level = (int)(y + size);
 }
 
///////////////////////////////////////////////////////////////////////////////////
 
 public void generateTank(){
   line(x, y, x, y + size * 6);
   line(x, y + size * 6, x + size * 5, y + size * 6);
   line(x + size * 5, y, x + size * 5, y + size * 6);
   line(x, y, x - size, y);
   line(x + size * 5, y, x + size * 6, y);
   line(x, y + size, x - size, y + size);
   ellipse(x - size / 2, y + size, size / 2, size / 2); //valve
   fill(0);
   textSize(size / 2);
   text("TANK", x, y - size);
 }
 
///////////////////////////////////////////////////////////////////////////////////
 
 public void threshold(){
   //creazione di una linea trateggiata-------------
   stroke(0);
   line(x - size * 0.5, level, x, level);
   line(x + size * 0.5, level, x + size, level);
   line(x + size * 1.5 , level, x + size * 2, level);
   line(x + size * 2.5 , level, x + size * 3, level);
   line(x + size * 3.5 , level, x + size * 4, level);
   line(x + size * 4.5 , level, x + size * 5, level);
   line(x + size * 5.5 , level, x + size * 6, level);
   line(x + size * 6.5 , level, x + size * 7, level);
   //-----------------------------------------------
   textSize(size / 3);
   text("threshold: " + int(levelPerc) + "%", x + size * 7, level);
   
   if(level > y + size * 6) { //limite basso superato
     level = y + (int)(size * 6); 
     mousePressed = false;
   }
   else if(level < y + size) { //limite alto superato
     level = y + int(size); 
     mousePressed = false;
   }
   else if((level >= y + size) && (level <= y + size * 6) && (mousePressed == true)) level = mouseY; //in range
   levelPerc = (y + size * 6 - level) * 100 / (5 * size); 
 }
 
 public void water(int level_){ //draw the water in the tank
   waterLevel = level_;
   noStroke();
   fill(100, 100, color_);
   rect(x + size * 0.1, (y + size * 6) - waterLevel, size * 4.8, (y + size * 6) - ((y + size * 6) - waterLevel));
   stroke(0);
 }
 
 public void valve(){ //when the level of water is lower than the threshold the valve fills the tank
   if(waterLevel < (y + size * 6 - level)){ 
     noStroke();
     fill(50, 230, 50); //valve color: green
     ellipse(x - size / 2, y + size, size * 0.4, size * 0.4); 
     stroke(0);
     port.write('1'); //sends the value 1 to arduino
   }
   else { 
     noStroke();
     fill(230, 50, 50); //valve color: red
     ellipse(x - size / 2, y + size, size * 0.4, size * 0.4); 
     stroke(0);
     port.write('0'); //sends the value 0 to arduino
   }
 }
}

///////////////////////////////////////////////////////////////////////////////////

Tank tank;
Serial port;

///////////////////////////////////////////////////////////////////////////////////

void setup(){
  size(800,500);
  tank = new Tank(100, 100, 50); //(x starting point, y starting point, size)
  port = new Serial(this, "COM4", 9600);
}

///////////////////////////////////////////////////////////////////////////////////

void draw(){
  background(255);
  tank.water(tankLevel); //draws the water
  tank.generateTank(); //draws the tank
  tank.threshold(); //draws the threshold
  tank.valve(); //rappresents the valve
}

///////////////////////////////////////////////////////////////////////////////////

void serialEvent(Serial p){
  String message=p.readStringUntil(13);
  if(message!=null){
    try{
        String[]elements=splitTokens(message);
        tankLevel = int(elements[0]); //value incoming of the height of the water
    }
    catch(Exception e){
    }
  }
}