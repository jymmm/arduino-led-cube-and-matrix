/*
 * game_control.pde
 *
 *  Created on: 23.10.2009
 *      Author: Kristian
 */
#include <max7221.h>
#include <cube.h>

#include <stdlib.h> // for malloc and free
void* operator new(size_t size) { return malloc(size); }
void operator delete(void* ptr) { if (ptr) free(ptr); }

max7221* Max7221 = new max7221;
cube Cube( Max7221 );

unsigned short	game_tick_millis	=	1000; //milliseconds, maximum delay between two frames;
unsigned long	last_tick_millis	=	0;
unsigned long	game_state			=	0;

const byte	button_pins [ 2 ]		=	{2, 3};
bool		button_states [ 2 ]		=	{0, 0};

void setup()
{
	Max7221->selectPins(10, 11, 12); //clock, data, load
	Max7221->init(); //set default modes
	

	pinMode( button_pins[0], INPUT );
	pinMode( button_pins[1], INPUT );
	Serial.begin(9600);
}

void loop()
{
	updateButtonState();
	if( millis() - last_tick_millis >= game_tick_millis )
	{
		gameTick();
		last_tick_millis = millis();
	}
	Serial.print(".");
}

void gameTick()
{
	if( button_states[0] == 1 )
	{
		button_states[0] = 0; //reset and wait for next signal
		Cube.allOn();
	}
	else
	{
		Cube.allOff();
	}
	Cube.pushData();
}

void updateButtonState()
{
	for( int i = 0; i < 2; i++ )
	{
		if( button_states[i] == 0 )
		{
			if( digitalRead( button_pins[i] ) == HIGH )
			{
				button_states[i] = 1;
			}
		}
	}
	return;
}
