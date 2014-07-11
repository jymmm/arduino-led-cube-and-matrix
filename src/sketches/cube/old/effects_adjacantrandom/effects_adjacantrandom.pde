/*
 * effects_adjacantrandom.pde
 *
 *  Created on: 20.11.2009
 *      Author: Kristian
 */
#include <max7221.h>
#include <cube.h>
#include <effects.h>

#include <stdlib.h> // for malloc and free
void* operator new(size_t size) { return malloc(size); }
void operator delete(void* ptr) { if (ptr) free(ptr); }

max7221* Max7221 = new max7221;
effects Cube( Max7221 );

bool state = 0;
int t_speed = 40;
int t_delay = 10;
byte x = 1;
byte y = 1;
byte z = 1;


void setup()
{
	Max7221->selectPins(10, 11, 12); //clock, data, load
	Max7221->init(); //set default modes

	Serial.begin(9600);

	randomSeed(micros());
}

void loop()
{
	state = !state;
	x = changeCoord( x );
	y = changeCoord( y );
	z = changeCoord( z );
	Cube.fillFromPoint( t_speed, state, x, y, z );
	delay( t_delay );
	Serial.println();
	Serial.print(x, DEC);
	Serial.print(y, DEC);
	Serial.print(z, DEC);
	Serial.println();
}


byte changeCoord( byte coord )
{
	byte shit = (coord) + random(0,3) - 1;
	if(shit == 0)
	{
		shit = 1;
	}
	else if( shit > 4 )
	{
		shit = 4;
	}
	return shit;
}
