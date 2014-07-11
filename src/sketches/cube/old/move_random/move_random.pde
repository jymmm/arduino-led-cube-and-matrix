/*
 * move_random.pde
 *
 * Displays a variable number of dots and moves them around randomly one unit per tick.
 *
 * Created on: 03.10.2009
 *      Author: Kristian
 */


#include <max7221.h>
#include <cube.h>

#include <stdlib.h> // for malloc and free
void* operator new(size_t size) { return malloc(size); }
void operator delete(void* ptr) { if (ptr) free(ptr); }

max7221* Max7221 = new max7221;
cube Cube( Max7221 );

//constants
const int delay_time = 150;
const byte dot_count = 1;

//runtime data
byte dot_positions[dot_count][3];
byte dot_prev_positions[dot_count][3];


void setup()
{
	Max7221->selectPins(10, 11, 12); //clock, data, load
	Max7221->init(); //set default modes

	randomSeed(micros()); //init random number genrator

	for( byte i = 0; i < dot_count; i++ )
	{
		for( byte k = 0; k < 3; k++ )
		{
			dot_positions[i][k] = random ( 0, 4 ) + 1;
			dot_prev_positions[i][k] = 0;
		}
	}
}

void loop()
{
	Cube.allOff(); //clear cube

	for( byte i = 0; i < dot_count; i++ )
	{
		//calculate new position

		byte coordinate = random( 0, 3 );
		switch( dot_positions[i][coordinate] )
		{
		case 1:
			dot_positions[i][coordinate] += 1;
			break;
		case 4:
			dot_positions[i][coordinate] -= 1;
			break;
		default:
			int modifier = random(0,2);
			if(modifier == 0)
			{
				modifier = -1;
			}
			dot_positions[i][coordinate] += modifier;

			if( dot_positions[i][coordinate] == dot_prev_positions[i][coordinate] )
			{
				dot_positions[i][coordinate] -= 2 * modifier;
			}
			break;
		}
		dot_prev_positions[i][coordinate] = dot_positions[i][coordinate];
		//display dot
		Cube.setState(
				dot_positions[i][0],
				dot_positions[i][1],
				dot_positions[i][2],
				1 );
	}
	Cube.pushData();
	//delay till next iteration
	delay( delay_time );
	
}
