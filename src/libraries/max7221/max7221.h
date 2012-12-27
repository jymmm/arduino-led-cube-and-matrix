/*
 * max7221.h
 *
 *  Created on: 10.09.2009
 *      Author: Kristian
 */
#include "WProgram.h"

#ifndef MAX7221_H_
#define MAX7221_H_

class max7221 {
public:
	max7221();

	void init();

	void selectPins( byte pinCLK, byte pinDATA, byte pinLOAD );
	void selectChipCount( byte chipcount );
	void selectChip(byte chip);


	void setDecodeMode( byte val );
	void setIntensity( byte val );
	void setScanLimit( byte val );
	void setShutdown( byte val );
	void setDisplayTest( byte val );

	void latch( bool state );
	void noOp(byte count);
	void putByte( byte data );
	void put( byte reg, byte data );

private:
	byte _pinCLK;
	byte _pinDATA;
	byte _pinLOAD;

	byte _chipcount;
	bool _chipselect; //0: write to the first chip
};

#endif /* MAX7221_H_ */
