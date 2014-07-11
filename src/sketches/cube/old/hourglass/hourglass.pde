/*
 * hourglass.pde
 *
 *  Created on: 03.12.2009
 *      Author: Kristian
 */

#include <max7221.h>
#include <cube.h>

#include <stdlib.h> // for malloc and free
void* operator new(size_t size) { return malloc(size); }
void operator delete(void* ptr) { if (ptr) free(ptr); }

max7221* Max7221 = new max7221;
cube Cube( Max7221 );

int delay_time = 800;

void setup()
{
	Max7221->selectPins(10, 11, 12); //clock, data, load
	Max7221->init(); //set default modes


	Cube.allOff();
	for( byte x = 1; x <= 4; x++ )
	{
		for( byte y = 1; y <= 4; y++ )
		{
			Cube.setState( x, y, 1, 1 );
		}
	}
	Cube.pushData();
}

void loop()
{
	changeState( random( 1, 5 ), random(1, 5) );
	delay( delay_time );
}

void changeState( byte x, byte y )
{
	short int direction;
	byte z;
	
	if( Cube.getState( x, y, 1 ) )
	{
		direction = 1;
		z = 1;
	}
	else
	{
		z = 4;
		direction = -1;
	}

	for( int i = 1; i < 4; i++ )
	{
		z += direction;

		Cube.setState( x, y, z, 1);
		Cube.setState( x, y, z - direction, 0);
		Cube.pushData();

		delay( delay_time / (10 + i) );
	}
}
