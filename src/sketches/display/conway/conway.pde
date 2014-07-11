/*
 * conway.pde
 *
 *  Created on: 07.03.2010
 *      Author: Kristian
 */


#include <LedControl.h>
#include <LedDisplay.h>

LedDisplay Display(11,10,12);

const unsigned short int max_x = 15;//width = max_x + 1
const unsigned short int max_y = 15;

const unsigned short int start_x = 0;
const unsigned short int start_y = 0;
const unsigned short int display_max_x = 15;
const unsigned short int display_max_y = 15;

int tick = 200;

const unsigned int max_ticks = 100;
unsigned int ticks;

int density = 20; //density/100: probability that a cell will initially live.


bool ancestor[max_x][max_y];
bool successor[max_x][max_y];


void setup()
{
	Serial.begin(9600);

	randomSeed(analogRead(0));

	seed();
}

void loop()
{
	display();

	nextGen();

	for( int i = 0; i <= max_x; i++ )
	{
		for( int j = 0; j <= max_y; j++ )
		{
			succeed(i, j);
		}
	}

	if(ticks > max_ticks)
	{
		fadeOut();
		ticks = 0;
		seed();
	}
	else
	{
		ticks++;
	}
	delay(tick);
}

void seed()
{
	//fills the successor array with random values for initial display
	for( int i = 0; i <= max_x; i++ )
	{
		for( int j = 0; j <= max_y; j++ )
		{
			bool state;
			if( random(0, 100) <= density )
			{
				state = 1;
			}
			else
			{
				state = 0;
			}
			successor[i][j] = state;
		}
	}
}


void nextGen()
{
	//copies the old successor array to the new ancestor before calculating a new generation
	for( int i = 0; i < max_x; i++ )
	{
		for( int j = 0; j < max_y; j++ )
		{
			ancestor[i][j] = successor[i][j];
		}
	}
}

void succeed( short x, short y)
{
	//reads the ancestor array and writes to the successor

	//calculate number of neighbours
	int neighbours = 0;

	int possible_neighbours[8][2] = {
			{ x-1,	y },
			{ x-1,	y-1 },
			{ x,	y-1 },
			{ x+1,	y-1 },
			{ x+1,	y },
			{ x+1,	y+1 },
			{ x,	y+1 },
			{ x-1,	y+1 }
	};

	for( int i = 0; i < 8; i++ )
	{
		int n_x = possible_neighbours[i][0];
		int n_y = possible_neighbours[i][1];
		if( n_x < 0 || n_x > max_x || n_y < 0 || n_y > max_y)
		{
			//cells outside of the observable universe are, by definition, dead.
			neighbours += 0;
		}
		else
		{
			neighbours += ancestor[n_x][n_y];
		}
	}

	//calculate future state
	bool state;
	if( ancestor[x][y] == 0 )
	{
		//the cell was dead
		if( neighbours == 3 )
		{
			state = 1; //evil reborn
		}
		else
		{
			state = 0; //don't disturb the dead
		}
	}
	else
	{
		//the cell was alive
		if( neighbours == 2 || neighbours == 3 )
		{
			state = 1; //live on
		}
		else
		{
			state = 0; //go die
		}
	}
	successor[x][y] = state;
}

void display()
{
	//displays the successor array.
	Display.allOff();
	for( int x = 0; x <= display_max_x; x++ )
	{
		for( int y = 0; y <= display_max_y; y++ )
		{
			Display.setState( x + 1, y + 1, successor[x + start_x][y + start_y]);
		}
	}
	Display.pushData();
}

void fadeOut()
{
	Display.allOff();
	Display.pushData();
	delay(tick);
}
