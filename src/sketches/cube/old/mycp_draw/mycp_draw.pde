/*
 * mycp_draw.pde
 *
 *  Created on: 15.11.2009
 *      Author: Kristian
 */
#include <max7221.h>
#include <cube.h>
#include <mycp.h>

#include <stdlib.h> // for malloc and free
void* operator new(size_t size) { return malloc(size); }
void operator delete(void* ptr) { if (ptr) free(ptr); }

max7221* Max7221_cube = new max7221;
max7221* Max7221_cp = new max7221;
cube Cube_edit( Max7221_cube );
cube Cube_display( Max7221_cube);
mycp Mycp( Max7221_cp );

const unsigned short int btn_switch_time = 2000;//hold 2 seconds to switch modes
const unsigned short int blink_time = 80;//milliseconds

unsigned long int last_blink_time = 0;
bool operation = 1; //1 = edit, 0 = display
bool btn_pressed;
byte x, y, z;
bool blink = 0;
unsigned short int on_count = 0;
unsigned long int btn_timer;

void setup()
{
	Max7221_cube->selectPins(10, 11, 12); //clock, data, load
	Max7221_cube->init(); //set default modes
	
	Max7221_cp->selectPins(5, 6, 7); //clock, data, load
	Max7221_cp->init(); //set default modes

	Mycp.setupPot( 0, 0 ); //analog input pins
	Mycp.setupPot( 1, 1 );
	Mycp.setupPot( 2, 2 );
	Mycp.setupBtn( 4 ); //digital pin

	Mycp.setPotState( 0, 1 );
}

void loop()
{
	if( Mycp.getBtn() == 1 )
	{
		btn_timer = millis();
		while( Mycp.getBtn() == 1 )
		{
			//wait for button to be released
			delay(1);
			if( millis() - btn_timer >= btn_switch_time )
			{
				Mycp.setBargraph( 2, 0b00011000 ); //yellow LEDs
			}
		}
		Mycp.setBargraph( 0, 0 );
		if( millis() - btn_timer >= btn_switch_time )
		{
			btn_pressed = 0;
			last_blink_time = 0;
			operation = !operation;
		}
		else
		{
			btn_pressed = 1;
		}
	}
	else
	{
		btn_pressed = 0;
	}
	if( operation == 0 )
	{
		//display only.
		Mycp.setPotState(0, 0);
		Mycp.setPotState(1, 0);
		Mycp.setPotState(2, 0);
		Mycp.setStatus( 0, 0 );
		Mycp.blankDisplay();
		Mycp.setBargraph( 2, 0b00000100 ); //red LEDs
		Cube_display.pushData();
	}
	else if( operation == 1 )
	{
		//edit
		Mycp.setPotState(0, 1);
		Mycp.setPotState(1, 1);
		Mycp.setPotState(2, 1);

		x = map( Mycp.getPot( 0 ), 1, 1024, 1, 5);
		y = map( Mycp.getPot( 1 ), 1, 1024, 1, 5);
		z = map( Mycp.getPot( 2 ), 1, 1024, 1, 5);

		Cube_edit.importData(Cube_display._cube_state);
		Cube_edit.setState(x, y, z, blink);

		if( millis() - last_blink_time >= blink_time )
		{
			last_blink_time = millis();
			blink = !blink;
		}

		bool current_state = Cube_display.getState( x, y, z );

		if( current_state == 1 )
		{
			Mycp.setStatus(0, 5);
		}
		else
		{
			Mycp.setStatus(0, 0);
		}

		if(btn_pressed)
		{
			Cube_display.setState( x, y, z, !current_state);
			Cube_display.pushData();
			delay(100);
			on_count += 2 * !current_state - 1;
		}
		Mycp.setNumber( on_count, 0 );

		Mycp.setBargraph( 2, 0b00100000 ); //green LEDs
		Cube_edit.pushData();
	}
}
