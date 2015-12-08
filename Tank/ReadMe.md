CONTROLLO RIEMPIMENTO DI UN SERBATOIO
========================================

##SCOPO:

Realizzare un controllo automatico del livello di un fluido presente in un 
serbatoio con interfaccia uomo-macchina iterattiva.

###DESCRIZIONE:

La commessa è suddivisa in due parti: il programma su computer, scritto con *processin* e quello su *arduino*.
Sul PC viene visualizzato il serbatoio con il livello di fluido in real time. Inoltre è possibile muovere il limite tramite uso del mouse.
Arduino, oltre a mandare costantemente il livello al computer, riceve il comado di valvola aperta o chiusa; quando è a aperta fa entrare nuova acqua mentre quando è chiusa ne blocca il flusso.

###COLLEGAMENTI:

![Alt text](https://github.com/DaveDorigoni/Tank/blob/master/Tank/collegamentiSerbatoio.png?raw=ture) 

###FLOWCHART:

![Alt text](https://github.com/DaveDorigoni/Tank/blob/master/Tank/TankFlowChart.png?raw=true)

##CODICE PROCESSING:

Controlla se il livello del fluido è superiore o inferiore alla soglia e invia l'informazione ad arduino tramite seriale.

##Class Tank:
###Metodo Costruttore e variabili

``` java
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

```
x e y indicano le coordinate (in pixels) di dove l'oggetto verrà creato, size è la grandezza del serbatoio che verrà visualizzato, level è la coordinata y della soglia, levelPerc è l'altezza della soglia in percentuale dal fondo del serbatoio e waterLevel è l'altezza dell'acqua del fondo del serbatoio.
Nel metodo costruttore vengono indicate: x,y,size e level che inizialmente è fissato ad un certo livello di default.

###Funzione generate Tank:

``` java
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
```
La funzione disegna il serbatoio in base ai valori specificati nel metodo costruttore.

###Funzione threshold:

```java
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
```
disegna la soglia, rappresentata da una linea tratteggiata con affianco il valore in percentuale. In più permette all'utente di poterla trasportare entro i limiti.

###Funzione water:
``` java
 public void water(int level_){ //draw the water in the tank
   waterLevel = level_;
   noStroke();
   fill(100, 100, color_);
   rect(x + size * 0.1, (y + size * 6) - waterLevel, size * 4.8, (y + size * 6) - ((y + size * 6) - waterLevel));
   stroke(0);
 }
```
disegna il liquido contenuto con altezza che dipende dal valore (level_) inserito nella funzione.

###Funzione valve:

``` java
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
``` 
Apre la valvola se il liquido è inferiore alla soglia, e la chiude in caso contrario. Nel primo caso la valvola cambia colore in verde, nel secondo in rosso. Inoltre viene inviato tramite seriale '1', in caso di apertura e '0' nel caso di chiusura.

##Funzione setup:

```java
import processing.serial.*;    //  Load serial library

Tank tank;
Serial port;

void setup(){
  size(800,500);
  tank = new Tank(100, 100, 50); //(x starting point, y starting point, size)
  port = new Serial(this, "COM4", 9600);
}
``` 

Vengono inizializzati due oggetti, uno di tipo Serial (necessario per la comunicazione seriale) e uno di tipo Tank.

##Funzione draw:

```
void draw(){
  background(255);
  tank.water(tankLevel); //draws the water
  tank.generateTank(); //draws the tank
  tank.threshold(); //draws the threshold
  tank.valve(); //rappresents the valve
}
```
Nella funzione draw vengono usate le funzioni della classe Tank.


###Comunicazione Seriale:
``` java
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
``` 


##CODICE ARDUINO:

```c++
#define V1 5 //flow in valve
#define L1 0 //level of water
#define SERIAL_BAUD 9600

float waterLevel = 0;
int valveState = 0;

void setup() {
  pinMode(V1, OUTPUT);
  pinMode(L1, INPUT);
  Serial.begin(SERIAL_BAUD);
}

void loop() {
  waterLevel = (int)(analogRead(L1) * 100.0 / 1024.0);
  Serial.println(waterLevel); //sends the height of the water in the tank to the PC
  if(Serial.available()) {  
    valveState = Serial.read(); //value from the PC, it could be 0 or 1
  }
  if(valveState == 0){ //turn off the valve
    digitalWrite(V1, LOW);
  }
  else if(valveState == 1){ //turn on the valve
    digitalWrite(V1, HIGH);
  }
}
```

Vengono inizializzati *L1* e *V1*, sensore di livello e valvola. Nella funzione *loop()* vengono ricevuti e mandati i dati dal computer e in base al valore che riceve, accende o spegne la valvola, simulata da un LED.
