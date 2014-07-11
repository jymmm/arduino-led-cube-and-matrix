/*
 * humantetris.pde
 *
 * "Human" Tetris game. A wall moves towards the player, who has to move (left/right)
 * to find one of the holes in the wall and jump in time.
 *
 *  Created on: 24.10.2009
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

bool	button_left, button_right, button_jump;		//button states

const unsigned short	game_tick_millis	=	5;	//milliseconds, maximum delay between two frames;
unsigned long			last_tick_millis	=	0;

const unsigned short	game_start_lives	=	5;
const unsigned int		game_base_speed		= 	10; //this * 10 is the frame duration at max level.
const unsigned short	game_max_level		=	10;
const short				game_level_tresholds[11] = { 0,
													400,
													1000,
													1200,
													3000,
													5000,
													7500,
													11000,
													16000,
													22000,
													30000 };
unsigned short	game_lives			=	game_start_lives;
unsigned long	game_counter		=	0;			//a global counter
byte			game_player[3]		=	{2, 1, 1};	//player position (x, y, z; y is fixed)
bool			game_player_jumping	=	0;
byte			game_goodie[3]		=	{0, 0, 0};	//goodie position(there is at max 1 of those)
unsigned long	game_score			=	0;
unsigned short	game_level			=	1;
bool			game_obstacle_shape[4][4];
byte			game_obstacle		=	0;			//obstacle position (1 = front, 4 = back);

void setup()
{
	Max7221->selectPins(10, 11, 12); //clock, data, load
	Max7221->init(); //set default modes
	
	Serial.begin(9600);

	newGame();
}

void loop()
{
	updateButtonState();
	if( millis() - last_tick_millis >= game_tick_millis )
	{
		gameTick();
		last_tick_millis = millis();
	}
}

void gameTick()
{
	/*
	 * button 0: switch left/right;
	 * button 1: jump;
	 */
	if( button_left == 1 )
	{
		button_left = 0;
		if(game_player[0] > 1 && game_player[2] == 1)
		{
			game_player[0]--;
		}
	}
	if( button_right == 1 )
	{
		button_right = 0;
		if(game_player[0] < 4 && game_player[2] == 1)
		{
			game_player[0]++;
		}
	}
	if( button_jump == 1 )
	{
		button_jump = 0;
		if( game_player_jumping != 1)
		{
			game_player_jumping = 1;
			game_player[ 2 ] = 4; //will be set to 3 in the frame calculation.
		}
	}

	/*
	 * new frame calculation
	 */
	if( game_counter == (11 - game_level) * game_base_speed )
	{
		game_counter = 0;
		/*
		 * let the player fall down if he's up in the air
		 */
		if( game_player[ 2 ] > 1 )
		{
			game_player_jumping = 0;
			game_player[ 2 ]--;
		}
		/*
		 * move obstacle
		 */
		if( game_obstacle > 0 )
		{
			game_obstacle--;
		}
		/*
		 * move / spawn goodie
		 */
		if(game_goodie[1] > 0)
		{
			game_goodie[1]--;
		}
		else if(game_obstacle == 4)
		{
			//goodie has been collected or is outside of the image now.
			//Maybe it's time for a new one?
			if(random(0, 5) == 1)
			{
				newGoodie();
				//push back the obstacle to make obtaining the bonus item easier.
				game_obstacle = round(random(60+game_level, 100)/10);
			}
		}
		/*
		 * events and score calculation
		 */
		if( hitObstacle() )
		{
			game_lives --;
			Serial.println("<<< ** FATALITY **  >>>");
			Cube.blinkAll( 300, 1, 1 );
			if( game_lives < 1 )
			{
				delay( 500 );
				gameOver();
				return;
			}
			else{
				Serial.print(game_lives, DEC);
				Serial.println(" lives left.");
			}
			game_player_jumping = 0;
			game_player[2] = 1;
			newObstacle();
		}
		else if( game_obstacle < 1 )
		{
			//it moved past the player without hitting him
			game_score += 50 + 21 * game_level;
			newObstacle();
		}
		if( hitGoodie() )
		{
			//either grant an extra life or bonus points.
			if( random(0, 5) == 0 || (game_lives == 1 && random(0, 2) == 1) ) //1 of 5 goodies will be an extra life!
			{
				Serial.println("=== LIFE BONUS <3 ==");
				game_lives++;
			}
			else
			{
				unsigned short tmp_bonus = 200 + 10 * game_level;
				Serial.print("=== SCORE BONUS +");
				Serial.print( tmp_bonus, DEC );
				Serial.println("! ===");
				game_score += tmp_bonus;
			}
		}
		/*
		 * Score board
		 */
		if( game_score >= game_level_tresholds[ game_level ] && game_level < game_max_level)
		{
			game_level ++;
			Serial.print("LEVEL UP! You are now on level ");
			Serial.print(game_level, DEC);
			Serial.println(".");
		}
	}
	/*
	 * generate base image (player, obstacle);
	 */
	Cube.allOff();

	//render player
	Cube.setState( game_player[0], game_player[1], game_player[2], 1 );

	//render obstacle
	if( game_obstacle > 0 && game_obstacle != 5 )
	{
		byte y = game_obstacle;
		for( byte x = 0; x < 4; x++ )
		{
			for( byte z = 0; z < 4; z++ )
			{
				if( game_obstacle_shape[x][z] == 1 )
				{
					Cube.setState( x+1, y, z+1, 1 );
				}
			}
		}
	}
	/*
	 * special effects
	 */
	if( game_counter % 10 == 0)
	{
		if( game_goodie[1] != 0)
		{
			//if a goodie is in the field, make it blink!
			bool state = !Cube.getState( game_goodie[0], game_goodie[1], game_goodie[2] );
			Cube.setState( game_goodie[0], game_goodie[1], game_goodie[2], state );
		}
	}
	/*
	 * output/display
	 */
	game_counter++;
	Cube.pushData();
}

bool hitGoodie()
{
	/*
	 * returns true if the player collected the goodie
	 */
	if( game_player[0] == game_goodie[0]
		&& game_player[1] == game_goodie[1]
		&& game_player[2] == game_goodie[2] )
	{
		//remove the goodie from the field
		game_goodie[0] = 0;
		game_goodie[1] = 0;
		game_goodie[2] = 0;
		return true;
	}
	else
	{
		return false;
	}
}

bool hitObstacle()
{
	/*
	 * returns true if the player's position is within the obstacle.
	 */
	byte check_x, check_z;
	if( game_obstacle == 1 )
	{
		// "-1" to accommodate the zero-based array indexes!
		check_x = game_player[0]-1;
		check_z = game_player[2]-1;
	}
	if( game_obstacle_shape[check_x][check_z] == 1 && game_obstacle == 1 )
	{
		return true;
	}
	else
	{
		return false;
	}
}

void newGoodie()
{
	/*
	 * generates a new goodie
	 */
	game_goodie[0] = random(1,5);//x = 2 or 3
	game_goodie[1] = 5;//start behind the cube and get moved in next frame.
	game_goodie[2] = random(1,4);//z = 1, 2 or 3
}
void newObstacle()
{
	game_obstacle = 5;
	byte holes = 0;
	bool state;
	for( int x = 0; x < 4; x++ )
	{
		for( int z = 0; z < 4; z++ )
		{
			if( z == 3)
			{
				state = 1;
			}
			else
			{
				state = random( 0, 2 );
				if( state == 0 )
				{
					holes ++;
				}
			}
			game_obstacle_shape[x][z] = state;
		}
	}
	if(holes == 0)
	{
		//assure that the player can actually beat this obstacle
		byte x = random(1,5);
		byte z = random(1,4);
		game_obstacle_shape[x][z] = 0;
	}
}

void newGame()
{
	//reset variables
	button_left = 0;
	button_right = 0;
	button_jump = 0;
	game_score = 0;
	game_level = 1;
	game_lives = game_start_lives;
	game_player[0] = 2;
	game_player[1] = 1;
	game_player[2] = 1;
	game_player_jumping = 0;
	newObstacle();
	game_obstacle = 10;
	game_counter = 0;
	game_goodie[0] = 0;
	game_goodie[1] = 0;
	game_goodie[2] = 0;
	game_counter = 0;
	//effect:
	for( int i = 0; i < 3; i++)
	{
		Cube.allOff();
		Cube.pushData();
		delay(200);
		Cube.allOn();
		Cube.pushData();
		delay(100);
	}
	Serial.println("Insert coin to start a new game! (Press Anykey)");
	Serial.flush();
	while(Serial.available() == 0)
	{
		delay(1);
	}
	Serial.flush();
	Cube.fillRandom(1000, 0);
	newGoodie();
	delay(200);
}

void gameOver()
{
	unsigned long level_bonus = round( game_score * game_level / 100 ); //add a 1% score bonus per level

	Serial.println( "XX --- GAME OVER --- XX" );
	Serial.print( "Score: " );
	Serial.print( game_score, DEC );
	Serial.print( ", Level Bonus: +" );
	Serial.println( level_bonus, DEC );
	Serial.print( "Final Score: ");
	Serial.println( ( game_score + level_bonus ), DEC );

	Serial.println("Try Again!");
	Serial.println("XX --- --------- --- XX");
	Cube.fillRandom(1000, 1);
	newGame();
}



void updateButtonState()
{
	while(Serial.available() > 0){
		byte read = Serial.read();
		if(read == 'a')
		{
			button_left = 1;
			button_right = 0;
		}
		if(read == 'd')
		{
			button_right = 1;
			button_left = 0;
		}
		if(read == 'w')
		{
			button_jump = 1;
		}
	}
	return;
}
