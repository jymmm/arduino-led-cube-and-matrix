/*
 * hello_matrix.c
 * toggles all LEDs in the cube once per second.
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
	Max7221->selectPins(10, 11, 12); //clock, data, load
	Max7221->init(); //set default modes

	Serial.begin(9600);
	Serial.println("hello world");
}
void loop()
{
	delay(1000);
	Serial.println("Another loop has just begun.");
	int starttime=millis();
	for(int x = 1; x <= 4; x++)
	{
		for(int y = 1; y <= 4; y++)
		{
			for(int z = 1; z <= 4; z++)
			{
				if ( Cube.getState( x, y, z ) == 1)
				{
					digitalWrite(13,LOW);
					Cube.setState( x, y, z, 0);
				}
				else
				{
					digitalWrite(13,HIGH);
					Cube.setState( x, y, z, 1);
				}
			}
		}
	}
	Cube.pushData();
	//Cube.tmpDisplayData();
	int tooktime=millis()-starttime;
	Serial.print("Task completed (toggled all LEDs and pushed out the data to the controller). Operation time: ");
	Serial.print(tooktime);
	Serial.println("ms.");
	delay(delayTime);
}
