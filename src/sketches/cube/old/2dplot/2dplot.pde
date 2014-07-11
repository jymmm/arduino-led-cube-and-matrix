/*
 * 2dplot.pde
 *
 *  Created on: 12.11.2009
 *      Author: Kristian
 */

#include <max7221.h>
#include <cube.h>

#include <stdlib.h> // for malloc and free
void* operator new(size_t size) { return malloc(size); }
void operator delete(void* ptr) { if (ptr) free(ptr); }

max7221* Max7221 = new max7221;
cube Cube( Max7221 );

byte c_x, c_y, c_z[4];

unsigned int delay_time = 5;
unsigned long int time = 0;

void setup()
{
	Max7221->selectPins(10, 11, 12); //clock, data, load
	Max7221->init(); //set default modes
}

void loop()
{
	Cube.allOff();
	for( int i = 0; i < 4; i++ )
	{
		float t = t1( time + i );
		c_x = (time + i) % 4 + 1;

		c_z[0] = normalize ( z1( t ) );
		c_z[1] = normalize ( z2( t ) );
		c_z[2] = normalize ( z3( t ) );
		c_z[3] = normalize ( z4( t ) );
		if(c_x != 0)
		{
			for( int j = 0; j < 4; j++ )
			{
				c_y = j + 1;
				if(c_z[j] != 0)
					Cube.setState( c_x, c_y, c_z[j], 1 );
			}
		}
	}
	Cube.pushData();
	time++;
	delay( delay_time );
}

byte normalize ( double val )
{
	/*
	 * Wertebereich von val: float -1 bis +1
	 * Wertebereich von retval: byte 1 bis 4
	 */
	byte retval = round( 1.5 * ( val + 1 ) )+1 ;
	return retval;
}

float t1( unsigned long int time )
{
	float t = 50 * time / (2*PI);
	return t;
}

double z1( float t )
{
	float value = sin( t );
	return value;
}
double z2( float t )
{
	float value = sin( t + PI / 4 );
	return value;
}
double z3( float t )
{
	float value = sin( t + PI / 2 );
	return value;
}
double z4( float t )
{
	float value = sin( t + 3 * PI / 4 );
	return value;
}

