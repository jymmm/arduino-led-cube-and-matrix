/*
 * LedCube.h
 *
 *  Created on: 03.08.2010
 *      Author: Kristian
 */

#ifndef LEDCUBE_H_
#define LEDCUBE_H_

#include <WProgram.h>;
#include <../LedControl/LedControl.h>;

class LedCube : public LedControl {
public:
	LedCube();
	LedCube( int dataPin, int clkPin, int csPin );
	~LedCube();

	byte _cube_state[8];

	bool getState ( byte x, byte y, byte z );
	void setState ( byte x, byte y, byte z, bool state );

	void allOff();
	void allOn();

	void pushData ();
	void importData ( byte data[8] );
	void tmpDisplayData ();
	void tmpDisplayMappedData ();
private:
	bool manageState( bool mode, byte x, byte y, byte z, bool state );
	byte _mapped_state[8];

	void mapData ();
};

#endif /* LEDCUBE_H_ */
