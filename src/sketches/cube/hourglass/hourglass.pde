/*
 * hourglass.pde
 *
 *  Created on: 03.12.2009
 *      Author: Kristian
 */

#include <LedControl.h>
#include <LedCube.h>

LedCube Cube(11,10,12);

int delay_time = 100;

void setup()
{
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
