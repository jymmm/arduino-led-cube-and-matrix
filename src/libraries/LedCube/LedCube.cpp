/*
 * LedCube.cpp
 *
 *  Created on: 03.08.2010
 *      Author: Kristian
 */

#include "LedCube.h"
#include "../LedControl/LedControl.h"

LedCube::LedCube( int dataPin, int clkPin, int csPin ) : LedControl( dataPin, clkPin, csPin, 1 ) {
	shutdown(0, false);
	setIntensity(0, 15);
}

LedCube::~LedCube() {

}

void LedCube::mapData ()
{
	/*
	 * parses the data array for pushData() by transposing the structured
	 * array to one that corresponds to the MAX7221 registers and columns.
	 * Every byte here is a register holding the column data in its bits.
	 */
	int reg, col;
	bool state;
	for( int x = 1; x <= 4; x++ )
	{
		for( int y = 1; y <= 4; y++ )
		{
			for( int z = 1; z <= 4; z++ )
			{
				switch ( x ) {
					case 1:
						reg = z - 1; //digits 0(1), 1, 2, 3(4)
						col = 8 - y; //segments DP(1), A, B, C(4)
						break;
					case 2:
						reg = z - 1; //digits 0(1), 1, 2, 3(4)
						col = 4 - y; //segments D(1), E, F, G(4)
						break;
					case 3:
						reg = z + 3; //digits 4(1), 5, 6, 7(4)
						col = 4 - y; //segments D(1), E, F, G(4)
						break;
					case 4:
						reg = z + 3; //digits 4(1), 5, 6, 7(4)
						col = 8 - y; //segments DP(1), A, B, C(4)
						break;
					default:
						break;
				}
				state = getState( x, y, z );
				bitWrite(_mapped_state[ ( reg ) ], col, state);
			}
		}
	}
}
void LedCube::pushData ()
{
	/*
	 * pushes all data out to via the inheritedLedControl functions
	 */
	mapData();
	for ( int reg = 0; reg < 8; reg++ )
	{
		setRow( 0, reg, _mapped_state[ reg ] );
	}
}


bool LedCube::manageState ( bool mode, byte x, byte y, byte z, bool state )
{
	/*
	 * reads or writes the given position's status ( on = 1, off = 0).
	 * mode = 1: write; mode = 2: read;
	 */
	if( x < 0 || y < 0 || z < 0 || x > 4 || y > 4 || z > 4 ){
		return 0;
	}
	switch ( z ) {
		case 1:
			/*
			 * upper left corner (First layer z = 1)
			 * x = 1 will get bit 7; x = 4 moves to bit 3.
			 * y = 1 will get byte 0; y = 4 moves to byte 3.
			 */
			x = 8 - x;
			y = y - 1;
			break;
		case 2:
			/*
			 * upper right corner (Second layer z = 2)
			 * x = 1 will get bit 3; x = 4 moves to bit 0.
			 * y = 1 will get byte 0; y = 4 moves to byte 3.
			 */
			x = 4 - x;
			y = y - 1;
			break;
		case 3:
			/*
			 * lower left corner (Third layer z = 3)
			 * x = 1 will get bit 7; x = 4 moves to bit 4.
			 * y = 1 will get byte 4; y = 4 moves to byte 7.
			 */
			x = 8 - x;
			y = y + 3;
			break;
		case 4:
			/*
			 * lower right corner (Fourth layer z = 4)
			 * x = 1 will get bit 3; x = 4 moves to bit 0.
			 * y = 1 will get byte 4; y = 4 moves to byte 7.
			 */
			x = 4 - x;
			y = y + 3;
			break;
		default:
			break;
	}
	if( mode == 1 )
	{
		/*
		 * set the status
		 */
		bitWrite ( _cube_state[ y ], x, state );
		return 1;
	}
	else if( mode == 0 )
	{
		/*
		 * read and return the status
		 */
		bool bit = bitRead ( _cube_state[ y ], x );
		return bit;
	}
}

void LedCube::setState ( byte x, byte y, byte z, bool state )
{
	/*
	 * changes the state of the given position
	 * calls the private manageState function to do the converting etc.
	 */
	manageState( 1, x, y, z, state);
	return;
}

bool LedCube::getState ( byte x, byte y, byte z )
{
	/*
	 * reads the state of the given position
	 * calls the private manageState function to do the converting etc.
	 */
	return manageState( 0, x, y, z, 0);
}

void LedCube::allOff()
{
	/*
	 * changes the state of every LED to 'off'.
	 */
	for ( int i = 0; i < 8; i++ )
	{
		_cube_state[i] = 0;
	}
}
void LedCube::allOn()
{
	/*
	 * public
	 * changes the state of every LED to 'on'.
	 */
	for ( int i = 0; i < 8; i++ )
	{
		_cube_state[i] = 255;
	}
}

void LedCube::importData ( byte data[8] )
{
	/*
	 * replaces the current cube with a previously saved data set
	 * in the default byte array[8] format.
	 * (default: the one we use for saving data, not for transmitting it.)
	 */
	for(int i = 0; i < 8; i ++)
	{
		_cube_state[i] = data[i];
	}
}

void LedCube::tmpDisplayData ()
{
	/*
	 * displays the current state (determined with getState()) via the Serial connection
	 */
	Serial.println("== Cube State Array ===");
	for(int i=0; i<8; i++)
	{
		Serial.print("Row ");
		Serial.print(i, DEC);
		Serial.print(": 0b");
		Serial.println(_cube_state[i], BIN);
	}
}
void LedCube::tmpDisplayMappedData ()
{
	/*
	 * displays the current mapped array
	 */
	Serial.println("== Mapped State Array ===");
	for(int i=0; i<8; i++)
	{
		Serial.print("Digit 0x0");
		Serial.print(i, DEC);
		Serial.print(": 0b");
		Serial.println(_mapped_state[i], BIN);
	}
}
