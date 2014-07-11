/*
 * bounce_test.pde
 *
 *  Created on: 06.09.2009
 *      Author: Kristian
 */
#include <max7221.h>
#include <cube.h>
#include <bounce.h>;

#include <stdlib.h> // for malloc and free
void* operator new(size_t size) { return malloc(size); }
void operator delete(void* ptr) { if (ptr) free(ptr); }

max7221* Max7221 = new max7221;
cube Cube( Max7221 );

/*
 * runtime data variables
 */

const int particle_count = 1;
bounce particles[ particle_count ] = bounce(100, 100);

int delay_time = 200;

void setup()
{
	randomSeed( micros() );

	Max7221->selectPins(10, 11, 12); //clock, data, load
	Max7221->init(); //set default modes

	for( int i = 0; i < particle_count; i++ )
	{
		particles[i].randomize();
	}
}

void loop()
{
	Cube.allOff();
	for( int i = 0; i < particle_count; i++ )
	{
		particles[i].update();
		Cube.setState(
				particles[i].getX(),
				particles[i].getY(),
				particles[i].getZ(),
				1 );
	}
	Cube.pushData();
	delay(delay_time);
}
