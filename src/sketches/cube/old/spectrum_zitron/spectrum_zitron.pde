/*
 * spectrum_zitron.pde
 *
 *  Created on: 08.11.2009
 *      Author: Kristian
 *
 *  based on code by "zitron"
 *  http://www.arduino.cc/cgi-bin/yabb2/YaBB.pl?num=1254359561
 *  using his desktop program to transmit data;
 */
#include <max7221.h>
#include <cube.h>

#include <stdlib.h> // for malloc and free
void* operator new(size_t size) { return malloc(size); }
void operator delete(void* ptr) { if (ptr) free(ptr); }

max7221* Max7221 = new max7221;
cube Cube( Max7221 );

byte power[32];
byte display_power[4];

void setup()
{
	Max7221->selectPins(10, 11, 12); //clock, data, load
	Max7221->init(); //set default modes
	Cube.allOff();
	Cube.pushData();
	Serial.begin(38400);
}

void loop()
{
	if(receiveLine()){
		transformPower();
		Cube.shiftCube('y', 1);
		//Cube.allOff();
		for( int i = 0; i < 4; i++)
		{
			byte z;
			int p = display_power[i];
			switch( p )
			{
			case 0:
				z = 1;
				break;
			case 1:
				z = 1;
				break;
			case 2:
				z = 2;
				break;
			case 3:
				z = 3;
				break;
			case 4:
				z = 4;
				break;
			default:
				z = 0;
				break;
			}
			if(z != 0)
			{
				for( int j = 1; j <= p; j++ )
				{
					Cube.setState(i+1, 1, j, 1);
				}
			}
		}
		Serial.write(1);
		Cube.pushData();
		delay(30);
		Serial.flush();
	}
}

void transformPower()
{
	for( int i = 0; i < 4; i++ )
	{
		byte tmp_sum = 0;
		for ( int j = 0; j < 8; j++ )
		{
			tmp_sum += power[ i*4 + j ];
		}
		display_power[i] = (tmp_sum / 8) / 2;
		//display_power[i] = power[i * 8] / 2;
	}
}

int receiveLine() {
  byte n = 0;
  char temp = '0';

  if (Serial.available() > 0) {
    while ((temp != 13) && (n <= 32+1)) {
      if (Serial.available() > 0) {
        temp = Serial.read();
        power[n] = temp-48;
        n++;
      }
    }
    return 1;
  }
  else {
    return 0;
  }
}
