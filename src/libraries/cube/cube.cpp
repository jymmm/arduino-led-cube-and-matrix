/*
 * class_cube.cpp
 * August 2009 by Kristian
 */
#include <stdlib.h> // for malloc and free
#include <WProgram.h>

#include <../max7221/max7221.h>
#include <cube.h>


cube::cube ( max7221 *given_output )
{
	/*
	 * constructor. Expects a pointer to the output object (hardware access layer)
	 */
	_output = given_output;
}
cube::cube ()
{
	/*
	 * empty constructor for use without the hardware connection.
	 */
}
cube::~cube()
{
	/*
	 * destructor. deletes pointer variable _output
	 */
	if(_output)
	{
		free(_output);
	}
}
void cube::mapData ()
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
void cube::pushData ()
{
	/*
	 * pushes all data out to the specified output. (Max7221 chip in this case)
	 */
	mapData();
	for ( int reg = 0; reg < 8; reg++ )
	{
		_output->put( reg + 1, _mapped_state[ reg ] );
	}
}


bool cube::manageState ( bool mode, byte x, byte y, byte z, bool state )
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

void cube::setState ( byte x, byte y, byte z, bool state )
{
	/*
	 * changes the state of the given position
	 * calls the private manageState function to do the converting etc.
	 */
	manageState( 1, x, y, z, state);
	return;
}

bool cube::getState ( byte x, byte y, byte z )
{
	/*
	 * reads the state of the given position
	 * calls the private manageState function to do the converting etc.
	 */
	return manageState( 0, x, y, z, 0);
}

void cube::shiftCube( char direction, bool orientation )
{
	/*
	 * shifts the contents of the cube in the given direction. out-of-bound locations
	 * will be ignored and set to 'off'
	 */
	cube *tmpCube = new cube;
	tmpCube->allOff();
	signed short int modifier;
	if(orientation == 1)
	{
		modifier = 1;
	}
	else
	{
		 modifier = -1;
	}
	byte t_x, t_y, t_z;
	for(byte i_x = 1; i_x <= 4; i_x++ )
	{
		for(byte i_y = 1; i_y <= 4; i_y++ )
		{
			for(byte i_z = 1; i_z <= 4; i_z++ )
			{
				if( getState( i_x, i_y, i_z ) == 1 )
				{
					switch(direction)
					{
					case 'x':
						t_x = i_x + modifier;
						if( t_x <= 0 || t_x > 4 ){
							continue;
						}
						t_y = i_y;
						t_z = i_z;
						break;
					case 'y':
						t_x = i_x;
						t_y = i_y + modifier;
						if( t_y <= 0 || t_y > 4 ){
							continue;
						}
						t_z = i_z;
						break;
					case 'z':
						t_x = i_x;
						t_y = i_y;
						t_z = i_z + modifier;
						if( t_z <= 0 || t_z > 4 ){
							continue;
						}
						break;
					default:
						continue;
						break;
					}
					tmpCube->setState( t_x, t_y, t_z, 1 );
				}
			}
		}
	}
	importData( tmpCube->_cube_state );
	delete tmpCube;
}

void cube::allOff()
{
	/*
	 * changes the state of every LED to 'off'.
	 */
	for ( int i = 0; i < 8; i++ )
	{
		_cube_state[i] = 0;
	}
}
void cube::allOn()
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

void cube::importData ( byte data[8] )
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

void cube::tmpDisplayData ()
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
void cube::tmpDisplayMappedData ()
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
