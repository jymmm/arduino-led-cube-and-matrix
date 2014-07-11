#include <LedControl.h>
#include <LedCube.h>

LedCube Cube(11,10,12);	//pins: data, clock, load(cs)
void setup()
{

}

void loop()
{
	Cube.allOff();
	Cube.pushData();
	delay(100);
	Cube.allOn();
	Cube.pushData();
	delay(100);
}
