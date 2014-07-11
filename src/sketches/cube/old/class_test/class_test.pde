/*
 * class_test.pde
 * includes the max7221 and cube classes for some quick-and-dirty tests.
 *
 *  Created on: 03.09.2009
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
}

void loop()
{
	Cube.allOff();
	Cube.pushData();
	delay(100);
	Cube.allOn();
	Cube.pushData();
	delay(100);
}
