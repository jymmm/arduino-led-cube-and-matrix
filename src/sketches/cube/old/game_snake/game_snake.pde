/*
 * game_snake.pde
 *
 *  Created on: 18.11.2009
 *      Author: Kristian
 */

#include <max7221.h>
#include <cube.h>
#include <effects.h>

#include <stdlib.h> // for malloc and free
void* operator new(size_t size) { return malloc(size); }
void operator delete(void* ptr) { if (ptr) free(ptr); }

max7221* Max7221 = new max7221;
effects Cube( Max7221 );

/*
 * "cheats" and game environment settings
 *
 * Presentation: tail length=8, infinite level = 1, auto pilot on for first demo only.
 */
const bool game_infinite_level = 1;	//doesn't level up from level 1. useful for demo
const bool game_autopilot = 1;		//active autopilot disables any user input and ignores level speed.
const bool game_no_tail_crash = 0;	//dies only when you hit a wall
const bool game_no_time_limit = 1;	//disables the time limit for user controlled actions.

const byte game_max_tail_length = 2; //8 - 16 should be OK.

const byte game_speed = 100;	//auto move delay in ms for the highest level;
const short int game_autopilot_speed = 50;	//delay inbetween autopilot moves
const byte game_food_blink_speed = 5;	//on/off delay in ms for goodies
const byte game_head_blink_speed = 20;	//on/off delay in ms for the snake's head
const byte game_max_level = 5;	//remember to adjust the game_level_req array!

/*
 * game state variables (nothing to adjust here)
 */
byte game_tail[game_max_tail_length][3];	//positions of the snake's tail. max length: 16. (x, y, z)
byte game_head[3];							//position of the snake's head. (x, y, z)
byte game_food[3];							//position of the next goodie.
byte game_tail_length = 0;					//current number of blocks in the snake's tail
byte game_level = 0;						//level. starting at zero to level up to 1 instantly (effects, repositioning, etc)
byte game_direction = 0; 					//0: paused. 1,2 forth, back. 3,4 left, right. 5,6 up, down.

bool game_food_blink = 0;
bool game_head_blink = 0;

unsigned long game_score = 0;
unsigned long int timer = 0;	//millisecond counter.

byte game_level_req[ game_max_level ] = {
		0,
		3,
		8,
		15,
		16
};

void setup()
{
	Max7221->selectPins(10, 11, 12); //clock, data, load
	Max7221->init(); //set default modes

	Serial.begin(9600);

	randomSeed( analogRead(0) );

	if( game_infinite_level == 1 )
	{
		game_level_req[1] = 255;
	}

	Cube.allOn();
	Cube.pushData();

	newGame();
}


void loop()
{
	if( checkFrame() )
	{
		Cube.allOff();

		move();
		if( crash() )
		{
			return;
		}

		renderSnake();

		eat();

		if( nextLevel() )
		{
			return;
		}

	}

	//effects
	if( timer % game_food_blink_speed == 0 )
	{
		game_food_blink = !game_food_blink;
		Cube.setState(
				game_food[0],
				game_food[1],
				game_food[2],
				game_food_blink );
	}
	if( timer % game_head_blink_speed == 0 )
	{
		game_head_blink = !game_head_blink;
		Cube.setState(
				game_head[0],
				game_head[1],
				game_head[2],
				game_head_blink );
	}
	//after every loop, increment the timer.
	delayMicroseconds(1000);
	timer++;
	//and finally upload the rendered image.
	Cube.pushData();
}

bool getInput()
{
	char last_input = 0;
	while( Serial.available() > 0 )
	{
		last_input = Serial.read();
	}

	switch( last_input )
	{
	case 'w':
		game_direction = 1;
		break;
	case 's':
		game_direction = 2;
		break;
	case 'a':
		game_direction = 3;
		break;
	case 'd':
		game_direction = 4;
		break;
	case 'r':
		game_direction = 5;
		break;
	case 'f':
		game_direction = 6;
		break;
	case ' ':
		game_direction = 0;
		return false;
		break;
	default:
		return false;
		break;
	}
	return true;
}
bool checkFrame()
{
	if( game_autopilot == 1 )
	{
		//never check user input
		if( timer >= game_autopilot_speed )
		{
			timer = 0;
			autoPilot();
			return true;
		}
		else
		{
			return false;
		}
	}
	bool input_active = getInput();
	if( input_active )
	{
		timer = 0;
		return true;
	}
	else if( timer >= ( game_speed * ( 1 + game_max_level - game_level ) ) )
	{
		timer = 0;
		if( game_no_time_limit )
		{
			return false;
		}
		else
		{
			return true;
		}
	}
	else
	{
		return false;
	}
}

void move()
{
	/*
	 * moves the snake's head in the given direction and updates its tail positions.
	 */
	if( game_direction != 0 )
	{
		for( int i = game_tail_length - 1; i > 0; i-- )
		{
			for( int j = 0; j < 3; j++ )
			{
				game_tail[ i ][j] = game_tail[ i - 1 ][j];
			}
		}
		for( int j = 0; j < 3; j++ )
		{
			game_tail[ 0 ][j] = game_head[j];
		}
		moveHead(game_head, game_direction);
	}
}
void moveHead(byte buffer[3], byte dir)
{
	short int mx = 0;
	short int my = 0;
	short int mz = 0;
	switch( dir )
	{
	case 1:
		my = 1;
		break;
	case 2:
		my = -1;
		break;
	case 3:
		mx = -1;
		break;
	case 4:
		mx = 1;
		break;
	case 5:
		mz = 1;
		break;
	case 6:
		mz = -1;
		break;
	default:
		break;
	}
	buffer[0] += mx;
	buffer[1] += my;
	buffer[2] += mz;

}
bool crash()
{
	/*
	 * checks for a collision with wall or tail.
	 * if so, gameOver is called.
	 */

	if( crashWall( game_head ) == 1 )
	{
		gameOver();
		return true;
	}
	if(game_no_tail_crash == 0)
	{
		if( crashTail( game_head ) == 1 )
		{
				gameOver();
				return true;
		}
	}
	Serial.print(".");
	return false;
}

bool crashWall( byte buffer[3] )
{
	for( int i = 0; i < 3; i++)
	{
		byte coord = buffer[i];
		if( coord == 0 || coord > 4 )
		{
			return true;
		}
	}
	return false;
}

bool crashTail( byte buffer[3] )
{
	for( int i = 0; i < game_tail_length; i++ )
	{
		byte collisions = 0;
		for( int j = 0; j < 3; j++)
		{
			byte coord = buffer[j];
			if( coord == game_tail[i][j] )
			{
				collisions++;
			}
		}
		//FIXME it seems to return true whether that's true or not.
		if( collisions == 3 )
		{
			//TODO removing this line causes a problem somehow. WTF?
			Serial.print("");
			return true;
		}
	}
	return false;
}

void eat()
{
	/*
	 * checks if the snake's head has collided with a food item.
	 * if so, the score and tail length is updated and a new item is spawned.
	 */
	if(
		game_head[0] == game_food[0] &&
		game_head[1] == game_food[1] &&
		game_head[2] == game_food[2]
	)
	{
		Serial.print("*");
		game_score += game_level * 10 + game_tail_length * 5;
		if( game_tail_length < game_max_tail_length)
		{
			game_tail_length++;
		}
		spawnFood();
	}
}

void renderSnake()
{
	/*
	 * renders the snake's tail. the head is rendered in the effects section of the main loop.
	 */
	for( int i = 0; i < game_tail_length; i++ )
	{
		Cube.setState(
				game_tail[i][0],
				game_tail[i][1],
				game_tail[i][2],
				1);
	}
}

void spawnFood()
{
	game_food[0] = random(1,5);
	game_food[1] = random(1,5);
	game_food[2] = random(1,5);
}

void gameOver()
{
	/*
	 * ends the game. displays the final score and initiates a new game.
	 */
	Serial.println("Ouch!");

	Cube.fillRandom(1000, 1);
	Serial.println("+--- Game Over.");
	Serial.print("|>> Level ");
	Serial.println( game_level, DEC );
	Serial.print("|>> Growth: ");
	Serial.print( game_tail_length, DEC );
	Serial.print(" / ");
	Serial.println( game_max_tail_length, DEC );
	Serial.print("|>>>> Total Score: ");
	Serial.println( game_score, DEC );
	Serial.println("+--- Try Again!");
	Serial.println();
	newGame();
}

bool nextLevel()
{
	if(game_level < game_max_level && game_tail_length >= game_level_req[game_level] )
	{
		game_level++;
		game_tail_length = 0;

		game_head[0] = 1;
		game_head[1] = 2;
		game_head[2] = 2;

		game_direction = 4;

		Cube.fillFlood(200, 1, 'x', 1);
		Cube.fillFlood(200, 0, 'x', 1);
		delay(500);
		Serial.println();
		Serial.print("Level ");
		Serial.println( game_level, DEC );
		return true;
	}
	else
	{
		return false;
	}
}

void newGame()
{
	Cube.allOn();
	Cube.pushData();
	Serial.println("Welcome to L64 Snake!");
	if(!game_autopilot)
	{
		Serial.println("Insert coin to continue!");
		waitForInput();
	}

	game_score = 0;
	game_tail_length = 0;
	timer = 0;
	game_level = 0;

	Cube.fillRandom(500,0);
	delay(100);

	spawnFood();
	nextLevel();
}


void waitForInput()
{
	/*
	 * halts the program until any serial input is received.
	 */
	while( Serial.available() == 0 )
	{
		delay(10);
	}
	Serial.flush();
}

void autoPilot()
{
	/*
	 * sets a direction.
	 * this is not a real path-finding algorithm.
	 * it just compares possible directions and takes one of the most direct route then.
	 */
	byte pc1 = 0;
	byte p1[6];
	byte pc2 = 0;
	byte p2[6];

	byte buffer[3];

	/*
	 * first run: eliminate all directions leading to a tail bite or a wall street crash.
	 */
	for( int i = 1; i <= 6; i ++ )
	{
		byte dir = i;
		for( int j = 0; j < 3; j++ )
		{
			//reset for every possible direction.
			buffer[j] = game_head[j];
		}
		moveHead( buffer, dir );
		if( crashTail( buffer ) == false && crashWall( buffer ) == false )
		{
			//this direction does not crash into the tail or a wall!
			p1[ pc1 ] = dir;
			pc1++;
		}
	}
	if( pc1 == 0 )
	{
		//there's no way out.
		game_direction = -1 * game_direction;
		Serial.println();
		Serial.println("There's no way out of this mess!");
		return;//and die for honor!
	}
	else
	{
		//wow, there is light, but is there a path?
		int original_length = abs(game_food[0] - game_head[0]) +
				abs(game_food[1] - game_head[1]) +
				abs(game_food[2] - game_head[2]);

		for( int i = 0; i < pc1; i++ )
		{
			byte dir = p1[i];
			for( int j = 0; j < 3; j++ )
			{
				//reset for every possible direction.
				buffer[j] = game_head[j];
			}
			moveHead( buffer, dir );
			int new_length = abs(game_food[0] - buffer[0]) +
					abs(game_food[1] - buffer[1]) +
					abs(game_food[2] - buffer[2]);
			if( new_length < original_length )
			{
				p2[ pc2 ] = dir;
				pc2++;
			}
		}
		if( pc2 == 0 )
		{
			//fall back to p1 (possible directions calculated in the first run)
			byte rand = random( 0, pc1 );
			game_direction = p1[ rand ];
			return;//it may not be the correct way, but at least we won't die immediately.
		}
		else
		{
			byte rand = random( 0, pc2 );
			game_direction = p2[ rand ];
			return;//to the battle and fight for glory!
		}
	}
}
