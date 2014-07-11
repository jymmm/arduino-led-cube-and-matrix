/*
 * plotter.pde
 *
 *  Created on: 18.04.2010
 *      Author: Kristian
 */

#include <LedControl.h>
#include <LedDisplay.h>

LedDisplay Display(11,10,12);

const unsigned int resolution = 100;
const unsigned short resolution_display = 16;
const int trace = 10;

unsigned int t = 0;
unsigned int time;
int x, y;


float freq1 = 3; // x
float freq2 = 5.1; // y

void setup()
{
	//Serial.begin(9600);
}

void loop()
{
	Display.allOff();
	for( int i = 0; i < min(trace, t); i++ )
	{
		time = t-i;

		x = sine( time, freq1, 0 ); // ( ( 100 * (t-i) ) % (2*resolution) ) - resolution );
		y = sine( time, freq2, PI/2 ); //resolution * sin( ( 1.5 * omega_t ) / resolution );

		display(x, y);
	}
	Display.pushData();

	t++;
}

int normalize( int val )
{
	/*
	 * takes an integer value between -1 and +1 resolution,
	 * returns a positive, one-based display value for display use
	 */
	val = round ( resolution_display * (val+resolution)/(2*resolution) )+1;
	val = max(1, min( resolution_display, val ));
	return val;
	//return round( (val+resolution)/(2*resolution) * resolution_display );
}

void display( int x, int y )
{
	int n_x = normalize(x);
	int n_y = normalize(y);

	Display.setState( n_x, n_y, 1 );
}

//math functions
int saw( unsigned int time, float frequency )
{
	int phase = frequency * time;
	int val = ( phase % resolution )*2 - resolution;


	return val;
}

int sine( unsigned int time, float frequency, float shift )
{
	unsigned int phase = frequency * time;
	int val = resolution * sin( phase * (2*PI) / resolution + shift);

	return val;
}
