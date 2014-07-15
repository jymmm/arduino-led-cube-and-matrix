/*
 * Kristian Hentschel, 15/07/2014
 *
 * Font based on '6px' by Jos Tan, http://www.dafont.com/6px.font
 */
#include <LedControl.h>
#include <LedDisplay.h>

#define FONT_SIZE 6
#define NUM_SYMBOLS 94
#define DELAY 150

typedef struct fontchar {
    char c;
    char w;
    char pixels[FONT_SIZE];
} Fontchar;

const Fontchar font[NUM_SYMBOLS] = {
    {' ', 1, {0b00000000,0b00000000,0b00000000,0b00000000,0b00000000,0b00000000}}, 
    {'A', 3, {0b01000000,0b10100000,0b10100000,0b11100000,0b10100000,0b00000000}}, 
    {'B', 3, {0b11000000,0b10100000,0b11000000,0b10100000,0b11000000,0b00000000}}, 
    {'C', 3, {0b01000000,0b10100000,0b10000000,0b10000000,0b01100000,0b00000000}}, 
    {'D', 3, {0b11000000,0b10100000,0b10100000,0b10100000,0b11000000,0b00000000}}, 
    {'E', 3, {0b01100000,0b10000000,0b11000000,0b10000000,0b01100000,0b00000000}}, 
    {'F', 3, {0b01100000,0b10000000,0b11000000,0b10000000,0b10000000,0b00000000}}, 
    {'G', 3, {0b01100000,0b10000000,0b10100000,0b10100000,0b01100000,0b00000000}}, 
    {'H', 3, {0b10100000,0b10100000,0b11100000,0b10100000,0b10100000,0b00000000}}, 
    {'I', 1, {0b10000000,0b10000000,0b10000000,0b10000000,0b10000000,0b00000000}}, 
    {'J', 3, {0b00100000,0b00100000,0b00100000,0b10100000,0b01000000,0b00000000}}, 
    {'K', 3, {0b10100000,0b10100000,0b11000000,0b10100000,0b10100000,0b00000000}}, 
    {'L', 2, {0b10000000,0b10000000,0b10000000,0b10000000,0b11000000,0b00000000}}, 
    {'M', 5, {0b01010000,0b10101000,0b10101000,0b10101000,0b10101000,0b00000000}}, 
    {'N', 4, {0b10010000,0b11010000,0b10110000,0b10010000,0b10010000,0b00000000}}, 
    {'O', 3, {0b01000000,0b10100000,0b10100000,0b10100000,0b01000000,0b00000000}}, 
    {'P', 3, {0b11000000,0b10100000,0b10100000,0b11000000,0b10000000,0b00000000}}, 
    {'Q', 3, {0b01000000,0b10100000,0b10100000,0b10100000,0b01100000,0b00000000}}, 
    {'R', 3, {0b11000000,0b10100000,0b10100000,0b11000000,0b10100000,0b00000000}}, 
    {'S', 3, {0b01100000,0b10000000,0b01000000,0b00100000,0b11000000,0b00000000}}, 
    {'T', 3, {0b11100000,0b01000000,0b01000000,0b01000000,0b01000000,0b00000000}}, 
    {'U', 3, {0b10100000,0b10100000,0b10100000,0b10100000,0b01100000,0b00000000}}, 
    {'V', 3, {0b10100000,0b10100000,0b10100000,0b10100000,0b01000000,0b00000000}}, 
    {'W', 5, {0b10101000,0b10101000,0b10101000,0b10101000,0b01010000,0b00000000}}, 
    {'X', 3, {0b10100000,0b10100000,0b01000000,0b10100000,0b10100000,0b00000000}}, 
    {'Y', 3, {0b10100000,0b10100000,0b10100000,0b01000000,0b01000000,0b00000000}}, 
    {'Z', 3, {0b11100000,0b00100000,0b01000000,0b10000000,0b11100000,0b00000000}}, 
    {'a', 3, {0b00000000,0b01000000,0b10100000,0b10100000,0b01100000,0b00000000}}, 
    {'b', 3, {0b10000000,0b11000000,0b10100000,0b10100000,0b11000000,0b00000000}}, 
    {'c', 3, {0b00000000,0b01000000,0b10100000,0b10000000,0b01100000,0b00000000}}, 
    {'d', 3, {0b00100000,0b01100000,0b10100000,0b10100000,0b01100000,0b00000000}}, 
    {'e', 3, {0b00000000,0b01000000,0b10100000,0b11000000,0b01100000,0b00000000}}, 
    {'f', 3, {0b00100000,0b01000000,0b11100000,0b01000000,0b01000000,0b00000000}}, 
    {'g', 3, {0b00000000,0b01100000,0b10100000,0b10100000,0b00100000,0b11000000}}, 
    {'h', 3, {0b10000000,0b11000000,0b10100000,0b10100000,0b10100000,0b00000000}}, 
    {'i', 1, {0b10000000,0b00000000,0b10000000,0b10000000,0b10000000,0b00000000}}, 
    {'j', 2, {0b01000000,0b00000000,0b01000000,0b01000000,0b01000000,0b10000000}}, 
    {'k', 3, {0b10000000,0b10100000,0b11000000,0b10100000,0b10100000,0b00000000}}, 
    {'l', 2, {0b10000000,0b10000000,0b10000000,0b10000000,0b01000000,0b00000000}}, 
    {'m', 5, {0b00000000,0b11010000,0b10101000,0b10101000,0b10101000,0b00000000}}, 
    {'n', 3, {0b00000000,0b11000000,0b10100000,0b10100000,0b10100000,0b00000000}}, 
    {'o', 3, {0b00000000,0b01000000,0b10100000,0b10100000,0b01000000,0b00000000}}, 
    {'p', 3, {0b00000000,0b01000000,0b10100000,0b10100000,0b11000000,0b10000000}}, 
    {'q', 3, {0b00000000,0b01000000,0b10100000,0b10100000,0b01100000,0b00100000}}, 
    {'r', 3, {0b00000000,0b01000000,0b10100000,0b10000000,0b10000000,0b00000000}}, 
    {'s', 3, {0b00000000,0b01100000,0b10000000,0b00100000,0b11000000,0b00000000}}, 
    {'t', 2, {0b10000000,0b11000000,0b10000000,0b10000000,0b01000000,0b00000000}}, 
    {'u', 3, {0b00000000,0b10100000,0b10100000,0b10100000,0b01100000,0b00000000}}, 
    {'v', 3, {0b00000000,0b10100000,0b10100000,0b10100000,0b01000000,0b00000000}}, 
    {'w', 5, {0b00000000,0b10101000,0b10101000,0b10101000,0b01010000,0b00000000}}, 
    {'x', 3, {0b00000000,0b10100000,0b01000000,0b01000000,0b10100000,0b00000000}}, 
    {'y', 3, {0b00000000,0b10100000,0b10100000,0b10100000,0b00100000,0b11000000}}, 
    {'z', 3, {0b00000000,0b11100000,0b00100000,0b10000000,0b11100000,0b00000000}}, 
    {'0', 3, {0b01000000,0b10100000,0b11100000,0b10100000,0b01000000,0b00000000}}, 
    {'1', 3, {0b01000000,0b11000000,0b01000000,0b01000000,0b11100000,0b00000000}}, 
    {'2', 3, {0b01000000,0b10100000,0b00100000,0b10000000,0b11100000,0b00000000}}, 
    {'3', 3, {0b11000000,0b00100000,0b01000000,0b00100000,0b11100000,0b00000000}}, 
    {'4', 3, {0b00100000,0b10100000,0b10100000,0b11100000,0b00100000,0b00000000}}, 
    {'5', 3, {0b11100000,0b10000000,0b11000000,0b00100000,0b11000000,0b00000000}}, 
    {'6', 3, {0b01100000,0b10000000,0b11000000,0b10100000,0b01000000,0b00000000}}, 
    {'7', 3, {0b11100000,0b00100000,0b01000000,0b01000000,0b01000000,0b00000000}}, 
    {'8', 3, {0b01000000,0b10100000,0b01000000,0b10100000,0b01000000,0b00000000}}, 
    {'9', 3, {0b01000000,0b10100000,0b01100000,0b00100000,0b11000000,0b00000000}}, 
    {'$', 3, {0b01000000,0b01100000,0b10000000,0b00100000,0b11000000,0b01000000}}, 
    {'+', 3, {0b00000000,0b01000000,0b11100000,0b01000000,0b00000000,0b00000000}}, 
    {'-', 2, {0b00000000,0b00000000,0b11000000,0b00000000,0b00000000,0b00000000}}, 
    {'*', 3, {0b00000000,0b10100000,0b01000000,0b10100000,0b00000000,0b00000000}}, 
    {'=', 3, {0b00100000,0b00100000,0b01000000,0b10000000,0b10000000,0b00000000}}, 
    {'%', 4, {0b00000000,0b10010000,0b00100000,0b01000000,0b10010000,0b00000000}}, 
    {'"', 3, {0b00000000,0b10100000,0b10100000,0b00000000,0b00000000,0b00000000}}, 
    {'\'',1, {0b00000000,0b10000000,0b10000000,0b00000000,0b00000000,0b00000000}}, 
    {'#', 5, {0b01010000,0b11111000,0b01010000,0b11111000,0b01010000,0b00000000}}, 
    {'@', 4, {0b01100000,0b10010000,0b10110000,0b10000000,0b01110000,0b00000000}}, 
    {'&', 4, {0b01000000,0b10100000,0b01000000,0b10100000,0b11010000,0b00000000}}, 
    {'_', 2, {0b00000000,0b00000000,0b00000000,0b00000000,0b11000000,0b00000000}}, 
    {'(', 2, {0b01000000,0b10000000,0b10000000,0b10000000,0b01000000,0b00000000}}, 
    {')', 2, {0b10000000,0b01000000,0b01000000,0b01000000,0b10000000,0b00000000}}, 
    {',', 1, {0b00000000,0b00000000,0b00000000,0b00000000,0b10000000,0b10000000}}, 
    {'.', 1, {0b00000000,0b00000000,0b00000000,0b00000000,0b10000000,0b00000000}}, 
    {';', 1, {0b00000000,0b00000000,0b10000000,0b00000000,0b10000000,0b10000000}}, 
    {':', 1, {0b00000000,0b00000000,0b10000000,0b00000000,0b10000000,0b00000000}}, 
    {'?', 3, {0b11000000,0b00100000,0b01000000,0b00000000,0b01000000,0b00000000}}, 
    {'!', 1, {0b10000000,0b10000000,0b10000000,0b00000000,0b10000000,0b00000000}}, 
    {'\\',3, {0b10000000,0b10000000,0b01000000,0b00100000,0b00100000,0b00000000}}, 
    {'|', 1, {0b10000000,0b10000000,0b10000000,0b10000000,0b10000000,0b10000000}}, 
    {'{', 3, {0b01100000,0b01000000,0b10000000,0b01000000,0b01100000,0b00000000}}, 
    {'}', 3, {0b11000000,0b01000000,0b00100000,0b01000000,0b11000000,0b00000000}}, 
    {'<', 3, {0b00100000,0b01000000,0b10000000,0b01000000,0b00100000,0b00000000}}, 
    {'>', 3, {0b10000000,0b01000000,0b00100000,0b01000000,0b10000000,0b00000000}}, 
    {'[', 2, {0b11000000,0b10000000,0b10000000,0b10000000,0b11000000,0b00000000}}, 
    {']', 2, {0b11000000,0b01000000,0b01000000,0b01000000,0b11000000,0b00000000}}, 
    {'`', 1, {0b10000000,0b10000000,0b00000000,0b00000000,0b00000000,0b00000000}}, 
    {'^', 3, {0b01000000,0b10100000,0b00000000,0b00000000,0b00000000,0b00000000}}, 
    {'~', 4, {0b01010000,0b10100000,0b00000000,0b00000000,0b00000000,0b00000000}}, 
};

LedDisplay Display = LedDisplay(11, 10, 12);

/* Draws the specified character with the top left position at x, y.
 * returns the x coordinate for the next character.
 */
int drawChar(char c, int x, int y) {
    char i, j;
    bool p;
    const Fontchar *f = &font[0];

    // Find the symbol in the font
    for(i = 0; i < NUM_SYMBOLS; i++) {
        if(font[i].c == c) {
            f = &font[i];
            break;
        }
    }

    // Draw the symbol pixels
    for(i = 0; i < f->w; i++) {
        for(j = 0; j < FONT_SIZE; j++) {
            p = bitRead(f->pixels[j], 7-i);
            if(x + i >= 1 && x + i <= 16) {
                Display.setState(x + i, y + j, p);
            }
        }
    }

    // return next x coordinate
    return x + f->w + 1;
}

void setup() {
    
}

void loop() {
    static int x0 = 0;
    static int y0 = 5;
    int x;
    int msg_width;
    char *msg = "The quick brown fox jumps over the lazy dog. ABCDEFGHIJKLMNOPQRSTUVXYZ abcdefghijklmnopqrstuvxyz 0123456789 $ +-*/= % \" ' # @ & _ () , . ; : ? ! \\ | {} <> [] ` ^ ~";

    Display.allOff();
    x = x0;
    for(const char *c = msg; *c != '\0'; c++) {
        x = drawChar(*c, x, y0);
    }
    Display.pushData();

    msg_width = x - x0;
    x0 -= 1;

    if (x0 < -msg_width) {
        x0 = 16;
    }

    delay(DELAY);
}