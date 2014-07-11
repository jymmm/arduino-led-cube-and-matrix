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

int delay_time = 100;
byte current[2];
byte target[2];

void setup()
{
	Max7221->selectPins(10, 11, 12); //clock, data, load
	Max7221->init(); //set default modes

	Serial.begin(9600);

	randomSeed( analogRead( 0 ) + micros() );

	current[0] = random( 1, 5 );
	current[1] = random( 1, 5 );

	newTarget();

	Cube.allOff();
}

void loop()
{
	Cube.shiftCube('z', 0);

	move();
	if( hit() )
	{
		newTarget();
	}

	Cube.setState( current[0], current[1], 4, 1 );
	Cube.pushData();

	delay( delay_time );
}

void move()
{
	if( current[0] > target[0] )
		current[0]--;
	else if( current[0] < target[0] )
		current[0]++;

	if( current[1] > target[1] )
		current[1]--;
	else if( current[1] < target[1] )
		current[1]++;
}

bool hit()
{
	if( current[0] == target[0] && current[1] == target[1] )
	{
		return true;
	}
	else
	{
		return false;
	}
}

void newTarget()
{
	do
	{
		target[0] = random( 1, 5 );
		target[1] = random( 1, 5 );
	}
	while( hit() );
}
