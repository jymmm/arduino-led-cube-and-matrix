/*
 * particles.pde
 *
 *  Created on: 12.04.2010
 *      Author: Kristian
 */
#include <LedControl.h>
#include <LedDisplay.h>

LedDisplay Display(11,10,12);

const int particle_count = 3;
const int delay_time = 50;

const int display_min_x = 1;
const int display_min_y = 1;
const int display_max_x = 16;
const int display_max_y = 16;

const int space_max_x = 1600;
const int space_max_y = 1600;

//runtime variables
int position_x[particle_count];
int position_y[particle_count];

int velocity_x[particle_count];
int velocity_y[particle_count];

void setup()
{
	Serial.begin(9600);
	Serial.println("Setup");
	randomSeed(analogRead(0));
	seedAll();
}

void loop()
{
	Serial.println("loop");
	move();
	display();

	delay( delay_time );
}

void seedAll()
{
	Serial.println("seedAll");
	for( int i = 0; i < particle_count; i++ )
	{
		seedSingle( i );
	}
}

void seedSingle( int i )
{
	Serial.println("seedSingle");
	position_x[i] = random(0, space_max_x);
	position_y[i] = random(0, space_max_y);
	velocity_x[i] = random( -space_max_x / 10, space_max_x / 10);
	velocity_y[i] = random( -space_max_y / 10, space_max_y / 10);
}

void move()
{
	Serial.println("move");
	for( int i = 0; i < particle_count; i++ )
	{
		crash(i);
		position_x[i] = position_x[i] + velocity_x[i];
		position_y[i] = position_y[i] + velocity_y[i];
	}
}

void display()
{
	Serial.println("display");
	Display.allOff();

	for( int i = 0; i < particle_count; i++ )
	{
		int x = normalize_x(position_x[i]);
		int y = normalize_y(position_y[i]);
		Display.setState(x, y, 1);
	}

	Display.pushData();
}

int normalize_x( int pos ){
	Serial.println("normalize_x");
	return map( pos, 0, space_max_x, display_min_x, display_max_x );
}
int normalize_y( int pos ){
	Serial.println("normalize_y");
	return map( pos, 0, space_max_y, display_min_y, display_max_y );
}

void crash( int i )
{
	Serial.println("crash");
	if( position_x[i] > space_max_x || position_x[i] < 0 || position_y[i] > space_max_y || position_y[i] < 0 )
	{
		seedSingle(i);
	}
}
