/*
 * tetris1.pde
 *
 *  Created on: 06.05.2010
 *      Author: Kristian
 */
#include <LedControl.h>
#include <LedDisplay.h>

//constants and initialization
#define UP		65
#define DOWN	66
#define RIGHT	67
#define LEFT	68

const unsigned short brick_count = 7;
const unsigned int bricks[ brick_count ][4] = {
		{
			0b0100010001000100,			//1x4
			0b0000000011110000,
			0b0100010001000100,
			0b0000000011110000
		},
		{
			0b0000010011100000,			//T
			0b0000010001100100,
			0b0000000011100100,
			0b0000010011000100
		},
		{
			0b0000011001100000,			//2x2
			0b0000011001100000,
			0b0000011001100000,
			0b0000011001100000
		},
		{
			0b0000000011100010,			//L
			0b0000010001001100,
			0b0000100011100000,
			0b0000011001000100
		},
		{
			0b0000000011101000,			//inverse L
			0b0000110001000100,
			0b0000001011100000,
			0b0000010001000110
		},
		{
			0b0000100011000100,			//S
			0b0000011011000000,
			0b0000100011000100,
			0b0000011011000000
		},
		{
			0b0000010011001000,			//Z
			0b0000110001100000,
			0b0000010011001000,
			0b0000110001100000
		}
	};

//Display initialization (pins)
LedDisplay Display(11,10,12);

//Display Settings
const short		field_width			= 10;
const short		field_height		= 16;
const short		field_start_x		= 1;
const short		field_start_y		= 1;

const short 	preview_start_x		= 13;
const short		preview_start_y		= 1;

const short		delimeter_x			= 11;

//gameplay Settings
const bool		display_preview		= 1;
const int		tick_microseconds	= 0; //adjustable after speed-optimization



const unsigned short	max_level						= 9;
const unsigned long	level_tresholds[ 10 ]	= {
	0,
	100,
	500,
	1500,
	4000,
	6000,
	8000,
	10000,
	14000,
	20000
};
const unsigned int level_ticks_timeout[ max_level ]	= {
	32,
	28,
	24,
	20,
	17,
	13,
	10,
	8,
	5
};
const unsigned int score_per_level					= 10; //per brick in lv 1+
const unsigned int score_per_line					= 300;

//runtime variables
bool 			field[field_width][field_height];
bool			wall[field_width][field_height];

unsigned int	ticks				= 0;
unsigned short	last_key			= 0;

unsigned short	current_brick_type;
unsigned short	next_brick_type;
bool			current_brick[4][4];
int				position_x, position_y;
unsigned short	rotation;

unsigned short	level				= 0;
unsigned long	score				= 0;
unsigned long	score_lines			= 0;


void setup()
{
	Serial.begin(9600);
	randomSeed(micros());

	Display.allOff();

	if(delimeter_x != 0)
	{
		for( int i = 1; i <= field_height; i++ )
		{
			Display.setState(delimeter_x, i, 1);
		}
	}

	Display.pushData();

	newGame();
}

void loop()
{
	getLastKey();

	if( last_key == UP )
	{
		if( checkRotate( 1 ) == true )
		{
			rotate( 1 );
		}
	}
	else if( last_key == LEFT )
	{
		if( checkShift( -1, 0 ) == true )
		{
			shift( -1, 0 );
		}
	}
	else if( last_key == RIGHT )
	{
		if( checkShift( 1, 0 ) == true )
		{
			shift( 1, 0 );
		}
	}

	if( ticks >= level_ticks_timeout[level] || last_key == DOWN )
	{
		if( checkGround() )
		{
			addToWall();
			if( checkCeiling() )
			{
				gameOver();
			}
			else
			{
				while( clearLine() )
				{
					scoreOneUpLine();
				}
				nextBrick();
				scoreOneUpBrick();
			}
		}
		else
		{
			//grounding not imminent
			shift( 0, 1 );
		}
		scoreAdjustLevel();
		ticks = 0;
	}
	{
		ticks++;
	}
	render();
	display();
	delayMicroseconds( tick_microseconds );
}
//get functions. set global variables.
void getLastKey(){
	/*
	 * saves the most recently received key code to last_key.
	 */
	last_key = 0;
	while( Serial.available() > 0 )
	{
		last_key = Serial.read();
	}
}

//check functions. do nothing and return true or false.
bool checkRotate( bool direction )
{
	/*
	 * checks if the next rotation is possible or not.
	 */
	rotate( direction );
	bool result = !checkCollision();
	rotate( !direction );

	return result;
}
bool checkShift(short right, short down)
{
	/*
	 * checks if the current block can be moved to the left by comparing it with the wall
	 */
	shift( right, down );
	bool result = !checkCollision();
	shift( -right, -down );

	return result;
}
bool checkGround()
{
	/*
	 * checks if the block would crash if it were to move down another step
	 * i.e. returns true if the eagle has landed.
	 */
	shift( 0, 1 );
	bool result = checkCollision();
	shift( 0, -1 );
	return result;
}
bool checkCeiling()
{
	/*
	 * checks if the block's highest point has hit the ceiling (true)
	 * this is only useful if we have determined that the block has been
	 * dropped onto the wall before!
	 */
	for( int i = 0; i < 4; i++ )
	{
		for( int k = 0; k < 4; k++ )
		{
			if(current_brick[i][k] == 1)
			{
				if( ( position_y + k ) < 0 )
				{
					return true;
				}
			}
		}
	}
	return false;
}
bool checkCollision()
{
	/*
	 * checks if the proposed movement puts the current block into the wall.
	 */
	for( int i = 0; i < 4; i++ )
	{
		for( int k = 0; k < 4; k++ )
		{
			if( current_brick[i][k] == 1 )
			{
				int x = position_x + i;
				int y = position_y + k;

				if(x >= 0 && y >= 0 && wall[x][y] == 1)
				{
					//this is another brick IN the wall!
					return true;
				}
				else if( x < 0 || x >= field_width )
				{
					//out to the left or right
					return true;
				}
				else if( y >= field_height )
				{
					//below sea level
					return true;
				}
			}
		}
	}
	return false; //since we didn't return true yet, no collision was found
}

//do functions - actually execute the command being the function's name
void shift(short right, short down)
{
	/*
	 * updates the position variable according to the parameters
	 */
	position_x += right;
	position_y += down;
}

void rotate( bool direction )
{
	/*
	 * updates the rotation variable and calls updateBrickArray().
	 * direction: 1 for clockwise (default), 0 to revert.
	 */
	if( direction == 1 )
	{
		if(rotation == 0)
		{
			rotation = 3;
		}
		else
		{
			rotation--;
		}
	}
	else
	{
		if(rotation == 3)
		{
			rotation = 0;
		}
		else
		{
			rotation++;
		}
	}
	updateBrickArray();
}

void addToWall()
{
	/*
	 * put the brick in the wall after the eagle has landed.
	 */
	for( int i = 0; i < 4; i++ )
	{
		for( int k = 0; k < 4; k++ )
		{
			wall[position_x + i][position_y + k] |= current_brick[i][k];
		}
	}
}

void updateBrickArray()
{
	/*
	 * uses the current_brick_type and rotation variables to render a 4x4 pixel array of the current block.
	 */
	unsigned int data = bricks[ current_brick_type ][ rotation ];
	for( int i = 0; i < 4; i++ )
	{
		for( int k = 0; k < 4; k++ )
		{
			current_brick[k][i] = bitRead(data, 4*i+3-k);//probability of this being thought through <= 0
		}
	}
}

bool clearLine()
{
	/*
	 * find the lowest completed line, do the removal animation, add to score.
	 * returns true if a line was removed and false if there are none.
	 */
	int line_check;
	for( int i = 0; i < field_height; i++ )
	{
		line_check = 0;

		for( int k = 0; k < field_width; k++ )
		{
			line_check += wall[k][i];
		}

		if( line_check == field_width )
		{
			flashLine( i );
			for( int k = i; k >= 0; k-- )
			{
				for( int m = 0; m < field_width; m++ )
				{
					if( k > 0)
					{
						wall[m][k] = wall[m][k-1];
					}
					else
					{
						wall[m][k] = 0;
					}
				}
			}

			return true; //line removed.
		}
	}
	return false; //no complete line found
}

void nextBrick()
{
	/*
	 * randomly selects a new brick and resets rotation / position.
	 */
	rotation = 0;
	position_x = round(field_width / 2) - 2;
	position_y = -3;

	current_brick_type = next_brick_type;
	next_brick_type = random( 0, brick_count );
	updateBrickArray();
	displayPreview();
}

void clearWall()
{
	/*
	 * clears the wall for a new game
	 */
	for( int i = 0; i < field_width; i++ )
	{
		for( int k = 0; k < field_height; k++ )
		{
			wall[i][k] = 0;
		}
	}
}

void render()
{
	/*
	 * joins wall and floating brick into one array which can be displayed
	 */

	//copy the wall to the output array
	for( int i = 0; i < field_width; i++ )
	{
		for( int k = 0; k < field_height; k++ )
		{
			field[i][k] = wall[i][k];
		}
	}

	//superimpose the brick array on top of that at the correct position
	for( int i = 0; i < 4; i++ )
	{
		for( int k = 0; k < 4; k++ )
		{
			if(current_brick[i][k] == 1)
			{
				if( position_y + k >= 0 )
				{
					field[ position_x + i ][ position_y + k ] = 1;
				}
			}
		}
	}
}

void flashLine( int line ){
	/*
	 * effect, flashes the line at the given y position (line) a few times.
	 */
	bool state = 0;
	for( int i = 0; i < 6; i++ )
	{
		for( int k = 0; k < field_width; k++ )
		{
			field[k][line] = state;
		}
		state = !state;
		display();
		delay(5);
	}
}

void display()
{
	/*
	 * Display the current rendered game field
	 */
	for( int i = 0; i < field_width; i++ )
	{
		for( int k = 0; k < field_height; k++ )
		{
			int x = i + field_start_x;
			int y = k + field_start_y;
			Display.setState( x, y, field[i][k] );
		}
	}
	Display.pushData();
}

void scoreAdjustLevel()
{
	unsigned short next_level = level + 1;
	if( level < max_level )
	{
		if( score >= level_tresholds[ next_level ] )
		{
/*			Serial.println("LEVELUP!");
			Serial.println(score);
			Serial.println(level_tresholds[ level + 1 ]);
			Serial.print(level);
			Serial.print(" + 1 = ");*/
			level = next_level;
//			Serial.println(level);
			displayLevel();
		}
	}
}
void scoreOneUpLine()
{
	/*
	 * adds score points... called once per line.
	 */
	score += score_per_line;
	score_lines++;
}
void scoreOneUpBrick()
{
	/*
	 * adds score points... called once per dropped brick.
	 */
	score += score_per_level * level;
}

void gameOver()
{
	/*
	 * pretty self-explanatory. Also displays final score (maybe)
	 */
	Serial.println( "Game Over." );

	Serial.print( "Level:\t");
	Serial.println( level );

	Serial.print( "Lines:\t" );
	Serial.println( score_lines );

	Serial.print( "Score:\t");
	Serial.println( score );
	Serial.println();

	Serial.println("Insert coin to continue");
	waitForInput();
	newGame();
}

void newGame()
{
	/*
	 * clean up, reset timers, scores, etc. and start a new round.
	 */
	level = 0;
	ticks = 0;
	score = 0;
	score_lines = 0;
	last_key = 0;
	clearWall();

	nextBrick();
}

void waitForInput()
{
	/*
	 * delay until a serial input is received. ("press any key to continue")
	 */
	Serial.flush();
	while(Serial.available() == 0){
		delay(1);
	}
	Serial.flush();
}

//effect functions - display score, next brick, etc.
//TODO: Direct use of display class
void displayPreview()
{
	if( display_preview )
	{
		//prepare array
		short int prev_type = current_brick_type;
		short int prev_rotation = rotation;
		rotation = 0;
		current_brick_type = next_brick_type;
		updateBrickArray();

		//display
		for( int i = 0; i < 4; i++ )
		{
			for( int k = 0; k < 4; k++ )
			{
				int x = i + preview_start_x;
				int y = k + preview_start_y;
				Display.setState(x, y, current_brick[i][k]);
			}
		}
		Display.pushData();

		//reset to real values
		current_brick_type = prev_type;
		rotation = prev_rotation;
		updateBrickArray();
	}
}

void displayLevel()
{
	/*
	 * todo
	 */
	Serial.print("level ");
	Serial.println(level);
}
