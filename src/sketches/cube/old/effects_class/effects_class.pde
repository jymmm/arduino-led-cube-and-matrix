/*
 * effects_class.pde
 *
 * Testing class inheritance (cube and effects)
 *
 *  Created on: 07.11.2009
 *      Author: Kristian
 */

#include <max7221.h>
#include <cube.h>
#include <effects.h>

#include <stdlib.h> // for malloc and free
void* operator new(size_t size) { return malloc(size); }
void operator delete(void* ptr) { if (ptr) free(ptr); }

max7221* Max7221 = new max7221;
effects Cube( Max7221 );

const int delay_time = 200;

void setup()
{
	Max7221->selectPins(10, 11, 12); //clock, data, load
	Max7221->init(); //set default modes
	Serial.begin(9600);
}

void loop()
{
	Cube.fillFade(2000, 1);
	delay( delay_time );
	Cube.fillFade(2000, 0);
	delay( delay_time * 3 );
	Cube.fillFromPoint(100, 1, 1, 1, 1);
	delay( delay_time );
	Cube.fillFromPoint(100, 0, 1, 1, 1);
	delay( delay_time );
	Cube.fillFromPoint(100, 1, 1, 4, 1);
	delay( delay_time );
	Cube.fillFromPoint(100, 0, 4, 1, 4);
	delay( delay_time * 3 );
	Cube.scanLayers( 500, 0, 'x', 1);
	delay( delay_time );
	Cube.scanLayers( 500, 0, 'y', 1);
	delay( delay_time );
	Cube.scanLayers( 500, 0, 'z', 1);
	delay( delay_time );
	Cube.scanLayers( 500, 0, 'x', 0);
	delay( delay_time );
	Cube.scanLayers( 500, 0, 'y', 0);
	delay( delay_time );
	Cube.scanLayers( 500, 0, 'z', 0);
	delay( delay_time * 3 );
	Cube.fillRandom( 1000, 1 );
	delay( delay_time );
	Cube.fillRandom( 1000, 0 );
	delay( delay_time * 3 );
	Cube.fillFlood(200, 1, 'x', 1);
	delay( delay_time );
	Cube.fillFlood(200, 0, 'x', 1);
	delay( delay_time );
	Cube.fillFlood(200, 1, 'y', 1);
	delay( delay_time );
	Cube.fillFlood(200, 0, 'y', 1);
	delay( delay_time );
	Cube.fillFlood(200, 1, 'z', 1);
	delay( delay_time );
	Cube.fillFlood(200, 0, 'z', 1);
	delay( delay_time );
}
