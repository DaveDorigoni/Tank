#define V1 13 //flow in valve
#define L1 0 //level of water
#define SERIAL_BAUD 9600

float waterLevel = 0;
int valveState = 0;

///////////////////////////////////////////////////////////////////

void setup() {
	pinMode(V1, OUTPUT);
	pinMode(L1, INPUT);
	Serial.begin(SERIAL_BAUD);
}

///////////////////////////////////////////////////////////////////

void loop() {
	waterLevel = (int)(analogRead(L1) * 100.0 / 1024.0);
	Serial.println(waterLevel); //sends the height of the water in the tank to the PC
	if(Serial.available()) {  
		valveState = Serial.read() - '0'; //value from the PC, it could be 0 or 1
	}
	if(valveState == 0){ //turn off the valve
		digitalWrite(V1, LOW);
	}
	else if(valveState == 1){ //turn on the valve
		digitalWrite(V1, HIGH);
	}
}

///////////////////////////////////////////////////////////////////
