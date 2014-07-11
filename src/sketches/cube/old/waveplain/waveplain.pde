/*
 * waveplain.pde
 *
 *	Every point in the plain moves according to its neighbours. only one point can change its height
 *	by one unit per frame.
 *
 *  Created on: 14.12.2009
 *      Author: Kristian
 */

#include <max7221.h>
#include <cube.h>

#include <stdlib.h> // for malloc and free
void* operator new(size_t size) { return malloc(size); }
void operator delete(void* ptr) { if (ptr) free(ptr); }

max7221* Max7221 = new max7221;
cube Cube( Max7221 );

const short max_state = 4;
const short required_difference = 1; //at least two adjacant points have to be different for one to move.
const int delay_time = 50;

short states[4][4];

void setup()
{
	Max7221->selectPins(10, 11, 12); //clock, data, load
	Max7221->init(); //set default modes

	randomSeed(micros());

	clear();
}

void loop()
{
	move();
	render();
	delay( delay_time );
}

void move()
{
	short tmp_positions[16][3];
	short direction = 0;
	short counter = 0;
	short x, y;

	/*
	 * determine possible moves and directions
	 */
	for( x = 0; x < 4; x++ )
	{
		for( y = 0; y < 4; y++ )
		{
			direction = getDirection(x, y);
			if( direction != 0 )
			{
				tmp_positions[ counter ][0] = x;
				tmp_positions[ counter ][1] = y;
				tmp_positions[ counter ][2] = direction;
				counter++;
			}
		}
	}
	/*
	 * select one of the possible moves at random
	 * or do something random if there is no possible move.
	 */
	if( counter == 0 )
	{
		x = random( 1, 5 );
		y = random( 1, 5 );
		if( states[x][y] == 0 )
		{
			direction = 1;
		}
		else if( states[x][y] == 4 )
		{
			direction = -1;
		}
		else
		{
			direction = random(0, 3) - 1;
		}
	}
	else
	{
		short r = random(0, counter);
		x = tmp_positions[r][0];
		y = tmp_positions[r][1];
		direction = tmp_positions[r][2];
	}
	/*
	 * do the move
	 */
	states[x][y] += direction;
}

short getRelativeState( short x, short y, short x0, short y0 )
{
	short ret = 0;
	if( x <= 0 || x >= 4 || y <= 0 || y >= 4 )
	{
		ret = 0;
	}
	else
	{
		ret = states[x][y] - states[x0][y0];
	}
	return ret;
}

short getDirection( short x, short y )
{
	/*
	 * add up the relative height of the given position's neighbours.
	 * Q: are points in the corners less likely to move?
	 */
	int sum = 0;
	short my_state = states[x][y];

	sum = getRelativeState( x + 1,	y,		x, y )
		+ getRelativeState( x + 1,	y + 1,	x, y )
		+ getRelativeState( x,		y + 1,	x, y )
		+ getRelativeState( x - 1,	y + 1,	x, y )
		+ getRelativeState( x - 1,	y,		x, y )
		+ getRelativeState( x - 1,	y - 1,	x, y )
		+ getRelativeState( x,		y - 1,	x, y )
		+ getRelativeState( x + 1,	y - 1,	x, y );
	if( sum >= 0 + required_difference )
	{
		return 1;
	}
	else if( sum <= 0 - required_difference )
	{
		return -1;
	}
	else
	{
		return 0;
	}
}

void render()
{
	Cube.allOff();

	for( short x = 0; x < 4; x++ )
	{
		for( short y = 0; y < 4; y++ )
		{
			short z = states[x][y];
			if( z != 0 && z <= max_state )
			{
				Cube.setState( x + 1, y + 1, z, 1 );
			}
		}
	}

	Cube.pushData();
}

void clear()
{
	for( short x = 0; x < 4; x++ )
	{
		for( short y = 0; y < 4; y++ )
		{
			states[x][y] = 3;
		}
	}
}
