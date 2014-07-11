/*
 * communication_images.pde
 *
 *  Created on: 12.10.2009
 *      Author: Kristian
 */
#include <max7221.h>
#include <cube.h>

#include <stdlib.h> // for malloc and free
void* operator new(size_t size) { return malloc(size); }
void operator delete(void* ptr) { if (ptr) free(ptr); }

max7221* Max7221 = new max7221;
cube Cube( Max7221 );


byte image_counter = 0; //the currently displayed image
byte image_count = 1; //the total number of active images we are using.
unsigned long time_last=0; //the last time an image was displayed.

//TODO try to figure out a size for the number of images that fits into RAM...
const byte max_images = 100;

byte current_images[max_images][8]; //the currently looped images.
byte framerate = 1; //animation speed in images per second.

bool indicator_state = 0; //state of an indicator LED to see if the animation is still running, even if multiple images are the same
const byte indicator_pin = 13; //default onboard LED pin

void setup()
{
	Serial.begin( 115200 );//9600
	Max7221->selectPins(10, 11, 12); //clock, data, load
	Max7221->init(); //set default modes
}

void loop()
{
	if( getSerialImages() )
	{
		/*
		 * reset everything and start anew
		 */
		image_counter = 0;
		time_last = 0;
		indicator_state = 0;
	}
	if( millis() - time_last > 1000 / framerate )
	{
		/*
		 * Display the current image
		 */
		Cube.importData( current_images[image_counter] );
		Cube.pushData();
		/*
		 * calculate upcoming image id
		 */
		image_counter++;
		if(image_counter >= image_count)
		{
			image_counter = 0;
		}
		time_last = millis();

		indicator_state = !indicator_state;
		digitalWrite(indicator_pin, indicator_state);
	}
}

bool getSerialImages()
{
	if( Serial.available() == 0 )
	{
		/*
		 * Nothing to see here. Continue with the main loop displaying the current images.
		 */
		return false;
	}
	else
	{
		/*
		 * data is waiting in the serial cache.
		 */
		byte mode = 0;
		/*
		 * modes:
		 * 0 - waiting to start transmission
		 * 1 - receiving the number of images
		 * 2 - receiving image data
		 * 3+ - various metadata, like repetitions or framerate.
		 */
		int byte_counter = 0;
		int line_counter = 0;
		int image_counter = 0;
		/*
		 * these global counters are used in the loop for various purposes.
		 */
		byte expected_images;
		/*
		 * expected_images is the number transmitted to the arduino.
		 * It has almost no practical use, actually.
		 */
		while( 1 )
		{
			if( Serial.available() > 0 )
			{
				byte b = Serial.read();
				//Serial.print("0x");
				//Serial.println(b, HEX);
				if( b == 0xFA )
				{
					/*
					 * Started transmission.
					 */
					Serial.flush();
					Serial.write( 0x01 );
					mode = 1;
				}
				else if( b == 0xFB )
				{
					/*
					 * incoming next image.
					 */
					Serial.flush();
					Serial.write( 0x01 );
					mode = 2;
				}
				else if( b == 0xFC )
				{
					/*
					 * incoming meta data
					 */
					Serial.flush();
					Serial.write( 0x01 );
					mode = 3;
				}
				else if( b == 0xFF )
				{
					/*
					 * done. Save data to eeprom(?) and exit.
					 */
					image_count = expected_images;
					Serial.flush();
					Serial.write( 0x01 );
					break;
				}
				else
				{
					/*
					 * b is a byte that has no control function. So, go parse it!
					 */
					if( mode == 1 )
					{
						/*
						 * This byte is the number of images to be expected.
						 * we need to save [expected_images] images.
						 * Each contains 8 byte or 64 bit
						 * to store the 64 bit for every image we will receive.
						 */
						expected_images = b;
						if(expected_images > max_images)
						{
							/*
							 * ERROR: We can not handle more images.
							 * The host program should exit.
							 */
							Serial.write( (byte) 0x00 );
							Serial.flush();
							break;
						}
						else
						{
							Serial.write( 0x01 );
						}
					}
					else if( mode == 2 )
					{
						/*
						 * This byte belongs to an image and should be 0x00 or 0x01
						 */
						byte_counter++; //1-based. we want to count to 64!
						/*
						 * bit shift "appends" the binary 0 or 1 to the whole thing.
						 */

						current_images[image_counter][line_counter] <<= 1;
						current_images[image_counter][line_counter] += b;
						/*
						 * counter calculations
						 */
						if( ( byte_counter ) % 8 == 0 && byte_counter != 0 )
						{
							/*
							 * byte counter is 8, 16, ..., 64. Switch to the next line.
							 */
							line_counter++;
						}
						if( byte_counter == 64 )
						{
							/*
							 * all 64 byte for this image are here.
							 */
							byte_counter = 0;
							line_counter = 0;
							image_counter++;
							digitalWrite( indicator_pin, HIGH );
							delay(10);
							digitalWrite( indicator_pin, LOW );
							Serial.write( 0x01 );
							if( image_counter == expected_images )
							{
								image_counter = 0;
							}
						}
					}
					else if( mode == 3 )
					{
						byte_counter++;
						switch( byte_counter )
						{
						case 1:
							/*
							 * frame rate
							 */
							framerate = b;
							break;
						default:
							break;
						}
						Serial.write( 0x01 );
					}
				}
			}
			else
			{
				/*
				 * continue waiting for data, until the "done" byte is received.
				 */
				continue;
			}
		}
		return true;
	}
}
