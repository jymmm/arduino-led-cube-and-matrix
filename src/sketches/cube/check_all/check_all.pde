/*
 * checkall.pde
 *
 *  Created on: 06.11.2009
 *      Author: Kristian
 */

#include <LedControl.h>
#include <LedCube.h>

LedCube Cube(11,10,12);	//pins: data, clock, load(cs)

const bool single_mode = 0;
int delay_time = 100;

void setup()
{

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
