/*
 * 3dplot.pde
 *
 *  Created on: 10.11.2009
 *      Author: Kristian
 */

/*
 * Displaying a three dimensional lissajous-curve on a 4x4x4 LED-Cube powered by the max7221 display driver and an Arduino board. To get a better view, we are not only displaying the LEDs for t, but also for t+1, t+2, ... t+10. All calculations are done by the microprocessor on the Arduino board.
Parameters used in this video:
x(t) = sin ( t )
y(t) = sin ( 1.1 * t )
z(t) = sin ( t + 0.5 * PI )
 */

#include <max7221.h>
#include <cube.h>

#include <stdlib.h> // for malloc and free
void* operator new(size_t size) { return malloc(size); }
void operator delete(void* ptr) { if (ptr) free(ptr); }

max7221* Max7221 = new max7221;
cube Cube( Max7221 );

byte c_x, c_y, c_z;

unsigned long int time = 0;

void setup()
{
	Max7221->selectPins(10, 11, 12); //clock, data, load
	Max7221->init(); //set default modes

	Serial.begin(9600);
}

void loop()
{
	Cube.allOff();
	for( int i = 0; i < 10; i++ )
	{
		float t = t1( time + i );
		c_x = normalize ( x1( t ) );
		c_y = normalize ( y1( t ) );
		c_z = normalize ( z1( t ) );
		if(c_x * c_y * c_z != 0)
			Cube.setState( c_x, c_y, c_z, 1 );
	}
	Cube.pushData();
	time++;
	delay(1);
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
	float t = time / (2*PI);
	return t;
}

double x1( float t )
{
	float value = sin( t );
	return value;
}
double y1( float t )
{
	float value = sin( 1.1*t );
	return value;
}
double z1( float t )
{
	float value = sin( t + PI * 0.5 );
	return value;
}
