/*
 * fill_random.pde
 *
 *  Created on: 04.09.2009
 *      Author: Kristian
 */
#include <max7221.h>
#include <cube.h>

#include <stdlib.h> // for malloc and free
void* operator new(size_t size) { return malloc(size); }
void operator delete(void* ptr) { if (ptr) free(ptr); }

max7221* Max7221 = new max7221;
cube Cube( Max7221 );

/*
 * END header template.
 * Place code below, but don't forget to call the following functions in setup().
 */

void setup()
{
	Max7221->selectPins(10, 11, 12); //clock, data, load
	Max7221->init(); //set default modes

	randomSeed( micros() );
}
void loop()
{
	Cube.allOff();
	Cube.pushData();
	fillRandom( 1, 100 );
	delay( 1000 );
	fillRandom( 0, 100 );
}

short getPositionsByState( bool state, byte list[64][3] )
{
	short count = 0;
	for(short x = 1; x <= 4; x++ )
	{
		for(short y = 1; y <= 4; y++ )
		{
			for(short z = 1; z <= 4; z++ )
			{
				if( Cube.getState(x, y, z) == state )
				{
					list[ count ][0] = x;
					list[ count ][1] = y;
					list[ count ][2] = z;
					count++;
				}
			}
		}
	}
	return count;
}
void fillRandom(bool target_state, int delay_time)
{
	/*
	 *
	 */
	bool current_state = abs( target_state - 1 );
	short count;
	short i;
	byte todo_list[64][3];
	do
	{
		count = getPositionsByState( current_state, todo_list );
		i = random( 0, count );
		Cube.setState( todo_list[ i ][0], todo_list[ i ][1], todo_list[ i ][2], target_state);
		Cube.pushData();
		delay( delay_time );
	}
	while( count != 0);
}
