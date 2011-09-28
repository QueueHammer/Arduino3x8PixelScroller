#include <TimerOne.h>
#include "LPD6803.h"

int dataPin = 2;       // 'yellow' wire
int clockPin = 3;      // 'green' wire

int cStripLen = 25;
int columns = 8;
int pixPerColumn = 3;
int lightValue = 0x3;

LPD6803 strip = LPD6803(25, dataPin, clockPin);


unsigned long startingValue = 0;
unsigned long lights = startingValue;
unsigned long bitMask = 1;
char textToScroll[] = "0123456789\0";

int stringIndex = 0;
int pixelCharIndex = 0;
int maxPixelCharIndex = 3;

unsigned int pixelChars[40];

void setup() {  
  Serial.begin(9600); 
  strip.setCPUmax(50);  // start with 50% CPU usage. up this if the strand flickers or is slow
  
  // Start up the LED counter
  strip.begin();

  // Update the strip, to start they are all 'off'
  strip.show();
  
  //Setup values for pixel characters
  //Numbers
  pixelChars[0] = 0x1EF;
  pixelChars[1] = 0x7;
  pixelChars[2] = 0x7C;
  pixelChars[3] = 0x1FD;
  pixelChars[4] = 0x1D6;
  pixelChars[5] = 0x139;
  pixelChars[6] = 0x1F;
  pixelChars[7] = 0x3C;
  pixelChars[8] = 0xFE;
  pixelChars[9] = 0x3E;
  //Characters (+10) 
  pixelChars[10] = 0x5B; //a
  pixelChars[11] = 0x1F; //b
  pixelChars[12] = 0x16F; //c
  pixelChars[13] = 0x3B; //d
  pixelChars[14] = 0x17F; //e
  pixelChars[15] = 0x137; //f
  pixelChars[16] = 0x3E; //g
  pixelChars[17] = 0x1D7; //h
  pixelChars[18] = 0x17D; //i
  pixelChars[19] = 0x1A9; //j
  pixelChars[20] = 0x157; //k
  pixelChars[21] = 0x7; //l
  pixelChars[22] = 0x1F7; //m
  pixelChars[23] = 0xD3; //n
  pixelChars[24] = 0x1EF; //o
  pixelChars[25] = 0x37; //p
  pixelChars[26] = 0x7E; //q
  pixelChars[27] = 0x13; //r
  pixelChars[28] = 0x139; //s
  pixelChars[29] = 0x13C; //t
  pixelChars[30] = 0xCB; //u
  pixelChars[31] = 0x8A; //v
  pixelChars[32] = 0x1DF; //w
  pixelChars[33] = 0x155; //x
  pixelChars[34] = 0x1D6; //y
  pixelChars[35] = 0x7C; //z
  
  //Special Chars
  pixelChars[36] = 0x0; //space
  pixelChars[37] = 0xA; //-
  
  
}

void loop(){
  for(int i = 0; i < cStripLen; i++){
    if((lights >> i) & 1  == 1) {
      strip.setPixelColor(i, Color(lightValue,lightValue,lightValue));
    }
    else {
      strip.setPixelColor(i, Color(0,0,0));
    }
  }
  strip.show();
  
  CharacterShifter();
  
  delay(500);
}

unsigned int Color(byte r, byte g, byte b)
{
  //Take the lowest 5 bits of each value and append them end to end
  return( ((unsigned int)r & 0x1F )<<10 | ((unsigned int)g & 0x1F)<<5 | (unsigned int)b & 0x1F);
}

void CharacterShifter() {
  //shift lights 3 pixels lower
  lights = lights >> 3;
  
  //if the pixelCharIndex is at the end (maxPixelCharIndex) then get a new character from the buffer
  if(pixelCharIndex >= maxPixelCharIndex)
  {
    // set the pixelCharIndex to 0 and move to the next char
    pixelCharIndex = 0;
    stringIndex++;
    
    //then pull the next character from the buffer
    if(textToScroll[stringIndex] == '\0')
    {
      //if the value in the buffer is null then set the position of the buffer to zero
      stringIndex = 0;
    }
    
    //Since we are changing characters in the buffer insert a one pixel space
    //Which was already done for use when we shifted our bits down 3 :)
  }
  else {    
    //print the 3 bits of the value indexed in the buffer
    unsigned int pixelChar = CharToPixelChar(pixelChars[stringIndex]);
    lights = (((unsigned long)(pixelChar >> (3 * pixelCharIndex) & 0x7))
                 << (3 * 7))
                | lights;
    
    pixelCharIndex++;
    
    if(pixelCharIndex < maxPixelCharIndex &&
        (((pixelChar >> (pixelCharIndex * 3)) && 0x7) == 0))
    {
      pixelCharIndex = maxPixelCharIndex;
    }
  }
  //print the first 3 bits of the value indexed in the buffer
  //increase the pixelCharIndex
  //if maxPixelCharIndex is less than 3 check next three bits
  //if they are equal to zero set the index to maxPixelCharIndex
}

unsigned int CharToPixelChar(char character){
  if(stringIndex > 37) stringIndex = 0;
  return pixelChars[stringIndex];
}
 
