/*
 * raindrops.pde
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

const short int delay_time = 100;
const short int max_drops = 1;
const short int min_drops = 5;

short int drops = min_drops;
bool dir = 1;

void setup()
{
	Max7221->selectPins(10, 11, 12); //clock, data, load
	Max7221->init(); //set default modes
	randomSeed( micros() );
}

void loop()
{
	if( min_drops < max_drops )
	{
		if( drops >= max_drops )
		{
			dir = 0;
		}
		else if( drops <= min_drops)
		{
			dir = 1;
		}
		if(random(0,2) == 1)
		{
			if(dir == 1)
			{
					drops++;
			}
			else
			{
				drops--;
			}
		}
	}
	Cube.shiftCube( 'z', 0 );

	for(int i = 0; i < drops; i++){
		byte a = random( 1, 5 ); //random values 1, 2, 3, 4!
		byte b = random( 1, 5 );
		byte c = 4;
		Cube.setState( a, b, c, 1 );
	}

	Cube.pushData();
	delay( delay_time );
}
