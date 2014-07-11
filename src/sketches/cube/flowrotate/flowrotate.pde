/*
 * flowrotate.pde
 *
 *  Created on: 04.08.2010
 *      Author: Kristian
 */

#include <LedControl.h>
#include <LedCube.h>
#include <math.h>

//settings
float	phi_step = 0.0001;
int		precision = 100;
int		x_step = 10;
int		delay_time = 10;

const short	particle_count = 10;
const short space_max = 4;
//declarations
float	alpha_1, alpha_2, phi;
int		a_1, b_1, c_1, x_1, y_1, a_2, b_2, c_2, x_2, y_2, m;
byte	x, y, z;

int		particles[ particle_count ][3];

//init
LedCube Cube(11,10,12);

void setup()
{
	Serial.begin(9600);
	spawn( 1 );
	phi = 0;
	m = space_max * precision / 2;
	randomSeed(analogRead(0));
}

void loop()
{
	spawn( 0 );
	render();
	move();
	
	phi += phi_step;
	delay( delay_time );
}


void spawn( bool initial )
{
	for( int i = 0; i < particle_count; i++ )
	{
		if( particles[i][0] > space_max * precision || initial == 1 )
		{
			Serial.println("spawned.");
			//initialize this particle slot.
			particles[i][0] = -1 * random(0, space_max * precision); //x
			particles[i][1] = random(0, space_max * precision); //y
			particles[i][2] = random(1, 5); //layer (z)
		}
	}
}

void move()
{
	for( int i = 0; i < particle_count; i++ )
	{
			particles[i][0] += x_step;
	}
}

void render()
{
	Cube.allOff();

	for( int i = 0; i < particle_count; i++ )
	{
		x_1 = particles[i][0];
		y_1 = particles[i][1];
		//rotate virtual layer
		/*Serial.print(x_2);
		Serial.print(" | ");
		Serial.println(y_2);*/

		//1
		a_1 = x_1 - m;
		b_1 = y_1 - m;
		c_1 = sqrt( square(a_1) + square(b_1) );

		//2
		alpha_1 = asin( (float)b_1 / (float)c_1 );

		//3
		alpha_2 = alpha_1 - phi;

		//4
		c_2 = c_1;

		a_2 = c_2 * cos( alpha_2 );
		b_2 = c_2 * sin( alpha_2 );

		//5
		if( a_1 < 0 )
		{
			x_2 = m - a_2;
		}
		else
		{
			x_2 = m + a_2;
		}
		y_2 = m + b_2;

		/*Serial.print(x_2);
		Serial.print(" | ");
		Serial.println(y_2);
		Serial.println();*/

		//determine final rendering positions
		x = cubePosition( x_2 );
		y = cubePosition( y_2 );
		z = particles[i][2];

		if( x * y != 0 )
		{
			Cube.setState(x, y, z, 1);
		}
	}

	Cube.pushData();
}

byte cubePosition(int virtualposition)
{
	if( virtualposition < 0 )
	{
		return 0;
	}
	else if( virtualposition < 1 * precision )
	{
		return 1;
	}
	else if( virtualposition < 2 * precision )
	{
		return 2;
	}
	else if( virtualposition < 3 * precision )
	{
		return 3;
	}
	else if( virtualposition < 4 * precision )
	{
		return 4;
	}
	else
	{
		return 0;
	}
}
