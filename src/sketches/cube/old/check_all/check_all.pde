/*
 * checkall.pde
 *
 *  Created on: 06.11.2009
 *      Author: Kristian
 */

#include <max7221.h>
#include <cube.h>

#include <stdlib.h> // for malloc and free
void* operator new(size_t size) { return malloc(size); }
void operator delete(void* ptr) { if (ptr) free(ptr); }

max7221* Max7221 = new max7221;
cube Cube( Max7221 );

const bool single_mode = 1;
int delay_time = 100;

void setup()
{
	Max7221->selectPins(10, 11, 12); //clock, data, load
	Max7221->init(); //set default modes
}

void loop()
{
	Cube.allOff();
	for( int x = 1; x <= 4; x++ )
	{
		for( int y = 1; y <= 4; y++ )
		{
			for( int z = 1; z <= 4; z++ )
			{
				if(single_mode)
				{
					Cube.allOff();
				}
				Cube.setState( x, y, z, 1 );
				Cube.pushData();
				delay( delay_time );
			}
		}
	}
	Cube.allOn();
	Cube.pushData();
	delay( 10 * delay_time );
	Cube.allOff();
	Cube.pushData();
	delay( 10 * delay_time );
}
