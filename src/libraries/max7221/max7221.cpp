/*
 * max7221.cpp
 *
 *  Created on: 10.09.2009
 *      Author: Kristian
 *
 */
#include "WProgram.h"
#include "max7221.h"

max7221::max7221()
{
	selectChipCount(0);
}

void max7221::init()
{
	/*
	 * set the pin configuration and default values to initially turn on the chip.
	 * this function has to be called EXACTLY one time before any data is pushed to the chip.
	 * it is NOT a class constructor, because we will use multiple instances of this class
	 */
	pinMode( _pinCLK, OUTPUT );
	pinMode( _pinDATA, OUTPUT );
	pinMode( _pinLOAD, OUTPUT );

	for( int i = 0; i < _chipcount; i++ )
	{
		selectChip(i);

		setDecodeMode( 0x00 ); //use a custom matrix on all registers
		setIntensity( 0x0f ); //use maximum intensity
		setScanLimit( 0x07 ); //use all 8 available registers
		setShutdown( 0x01 ); //wake up
		setDisplayTest( 0x00 ); //no display test
	}
	selectChip(0);//reset to default first chip for backwards compatibility
}

void max7221::selectPins(byte pinCLK, byte pinDATA, byte pinLOAD)
{
	/*
	 * sets the private _pinXXX variables for use in the other functions.
	 * Call this function BEFORE init.
	 */
	_pinCLK  = pinCLK;
	_pinDATA = pinDATA;
	_pinLOAD = pinLOAD;
}

void max7221::selectChipCount( byte chipcount )
{
	/*
	 * sets the number of chips that will be used in init();
	 */
	_chipcount = chipcount;
}
void max7221::selectChip(byte chipselect)
{
	/*
	 * selects a chip in order to send the correct number of noOp codes in put().
	 */
	_chipselect = chipselect;
}

void max7221::put( byte reg, byte data )
{
	/*
	 * Updates one register of our chip by first selecting the register byte reg
	 * and then putting the data byte data and switching the LOAD pin once.
	 */
	latch(0);
	putByte( reg );
	putByte( data );
	noOp(_chipselect);
	latch(1);
}

void max7221::latch( bool state )
{
	/*
	 * turns on or off the load pin. used with putByte in manual mode or on its own
	 */
	digitalWrite( _pinLOAD, state );
}

void max7221::putByte( byte data )
{
	/*
	 * sends a single byte (8bit) of data to the chip and handles the clock "rhythm".
	 */
	byte mask = 128; //0b10000000;
	for( int i = 0; i < 8; i++ )
	{
		digitalWrite( _pinCLK, LOW );

		if( data & mask ) //if the bit is set, this should give a value > 0
		{
			digitalWrite( _pinDATA, HIGH );
		}
		else
		{
			digitalWrite( _pinDATA, LOW );
		}
		digitalWrite( _pinCLK, HIGH );
		mask = mask >> 1;
	}
}

void max7221::noOp( byte count )
{
	/*
	 * sends count no-op codes to select a chip in daisy-chain mode. 0: first, 1: second, ...
	 * These codes must be sent after the 2 data bytes and before load goes high again.
	 */
	for( int i = 0; i < count; i++ )
	{
		putByte(0x00);
	}
}

void max7221::setDecodeMode( byte val )
{
	/*
	 * DecodeMode sets whether we use the internal font to display on 7-Segments on each
	 * digit. If we only want to drive a custom 8x8 matrix, we shall set it to 0.
	 * Otherwise, the value selects which of the 8 digits use the font and which don't.
	 */
	put( 0x09, val );
}

void max7221::setIntensity( byte val )
{
	/*
	 * Global intensity can be set to values reaching from 0x00 to 0x0F ( 0 - 15 ).
	 * 0x00 is the minimal intensity, but enough to turn the display on.
	 */
	put( 0x0A, val );
}

void max7221::setScanLimit( byte val )
{
	/*
	 * Scan Limit sets how many of the 8 digits/registers are actually used.
	 * Values reach from 0x00 (0, using only one) to 0x07 (7, using all eight)
	 */
	put( 0x0B, val );
}

void max7221::setShutdown( byte val )
{
	/*
	 * Shutdown Mode is used to save power. When it is active (0x00 or 0), the display
	 * is blanked, but the chip can still be programmed. Turn it on by setting shutdown
	 * mode to off (0x01 or 1).
	 * On startup, the MAX7221 is automatically in shutdown mode. Wake up: 0x01 or 1.
	 */
	put( 0x0C, val );
}

void max7221::setDisplayTest( byte val )
{
	/*
	 * Display test mode turns on all segments of the display at maximum intensity and
	 * also overrides shutdown mode.
	 * DisplayTest on: 0x01 / 1; DisplayTest Off: 0x00 / 0.
	 */
	put( 0x0F, val );
}
