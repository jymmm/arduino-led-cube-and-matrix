/*
 * sine_wave.pde
 *
 * Displays an excerpt from a sine wave on the first layer (front) and
 * pushes the last image one layer back with every iteration.
 *
 *  Created on: 05.09.2009
 *      Author: Kristian
 */

#include <max7221.h>
#include <cube.h>

#include <stdlib.h> // for malloc and free
void* operator new(size_t size) { return malloc(size); }
void operator delete(void* ptr) { if (ptr) free(ptr); }

max7221* Max7221 = new max7221;
cube Cube( Max7221 );

int delay_time = 100;

byte t = 0; //time for sine function
byte t_steps = 20 - 1;
byte column_value;
byte z;

byte lookup_sine[20] = {
		2,
		3,
		3,
		4,
		4,
		4,
		4,
		4,
		3,
		3,
		2,
		1,
		1,
		0,
		0,
		0,
		0,
		0,
		1,
		1,
};

void setup()
{
	Max7221->selectPins(10, 11, 12); //clock, data, load
	Max7221->init(); //set default modes
}

void loop()
{
	//move the old data 1 unit away from the view (y direction)
	Cube.shiftCube( 'y', 1 );
	//set the front most layer (empty after shifting previous data)

	for( byte x = 1; x <=4; x++ ){
		//set a new column, essentially y = sin(t+i).
		column_value = lookup_sine[ t + x - 1 ];
		z = 1;
		while( z <= column_value )
		{
			Cube.setState( x, 1, z, 1 );
			z++;
		}
	}
	t++;
	if( t == t_steps )
	{
		t = 0;
	}
	//display that data!
	Cube.pushData();
	delay( delay_time );
}
