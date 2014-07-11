/*
 * toggle_coordinates.c
 * Listens to input from the serial port to toggle an LED at any given coordinate
 * Aug 2009 by Kristian
 */
#include <max7221.h>
#include <cube.h>

#include <stdlib.h> // for malloc and free
void* operator new(size_t size) { return malloc(size); }
void operator delete(void* ptr) { if (ptr) free(ptr); }

max7221* Max7221 = new max7221;
cube Cube( Max7221 );

int delayTime=1000;

void setup()
{
	Serial.begin(9600);
	Max7221->selectPins(10, 11, 12); //clock, data, load
	Max7221->init(); //set default modes
	Cube.allOff();
	Cube.pushData();
}
void loop()
{
	Serial.println("=== Please enter the coordinates to toggle ===");
	Serial.print("X: ");
	while(Serial.available()==0){
		delay(1);
	}
	int x=Serial.read()-48;
	Serial.println(x);
	Serial.print("Y: ");
	while(Serial.available()==0){
		delay(1);
	}
	int y=Serial.read()-48;
	Serial.println(y);
	Serial.print("Z: ");
	while(Serial.available()==0){
		delay(1);
	}
	int z=Serial.read()-48;
	Serial.println(z);

	Serial.print("The selected LED is currently in the state ");
	bool current_state=Cube.getState(x,y,z);
	Serial.println(current_state);
	if(current_state==1)
	{
		Serial.println("Turning this one OFF now.");
		Cube.setState(x,y,z,0);
	}
	else
	{
		Serial.println("Turning this one ON now.");
		Cube.setState(x,y,z,1);
	}
	Cube.pushData();
	Cube.tmpDisplayData();
	Cube.tmpDisplayMappedData();
	Serial.println("Done.");
}
