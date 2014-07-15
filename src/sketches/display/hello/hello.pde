/*
 * hello.pde
 * tests all LEDs on the 16x16 matrix
 *
 *  Created on: 11.07.2014
 *      Author: Kristian
 */


#include <LedControl.h>
#include <LedDisplay.h>

LedDisplay Display(11,10,12);


#define TICK 100
int count = 0;

void setup() {

}

void loop() {
  Display.pushData();
  delay(TICK);
    
  if (count >= 256) {
    count = 0;
    Display.allOff();
  } else {
    char x = count % 16 + 1;
    char y = count / 16 + 1;
    Display.setState(x, y, true);
    count++;
  }
}
