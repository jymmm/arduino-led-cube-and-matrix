/*
 * class_cube.h
 * August 2009 by Kristian
 *
 * This class handles the data storage for a fictional cube. It does not need a
 * physical cube to function, so it can also be used for storing cubic images or
 * different states of a single cube.
 *
 * Data is handled in a byte array[8], each element representing a register
 * of the MAX7221. Data is layouted like this: a 4x4 block in the two-dimensional
 * table is one layer in the cube.
 * +----+----+
 * | Z1 | Z2 |   z
 * +----+----+   | y
 * | Z3 | Z4 |   |/
 * +----+----+   0----x
 * However, the wiring of the physical cube is completely different. This layout shall
 * be used for data storage and interaction only.
 */

#ifndef CUBE_H_
#define CUBE_H_

#include <stdlib.h>
#include <WProgram.h>;
#include <../max7221/max7221.h>;

class cube
{
public:
	cube( max7221 *given_output );
	cube();
	~cube();

	byte _cube_state[8];

	bool getState ( byte x, byte y, byte z );
	void setState ( byte x, byte y, byte z, bool state );

	void shiftCube ( char direction, bool orientation );

	void allOff();
	void allOn();

	void pushData ();
	void importData ( byte data[8] );
	void tmpDisplayData ();
	void tmpDisplayMappedData ();
	max7221 *_output;
private:
	bool manageState( bool mode, byte x, byte y, byte z, bool state );
	byte _mapped_state[8];

	void mapData ();
};

#endif /* CUBE_H_ */
