/* YellowSub class - by Al Biles
 Handles Yellow Submarine, which wanders onto the window
 from the right sometime after the player's health drops to 60%
 of the initial value.  The sub wanders from right to left
 in the background (behind everything else) and doesn't interact
 with anything in the game.  Basically, this is an excuse for
 music that does looped horizontal resequencing.
 The placeholder music is, what else, Yellow Submarine, or at least
 4 loopable 2-bar phrases of Yellow Submarine played on trumpet.
 */
class YellowSub
{
  PVector loc;              // Current location
  PVector d;                // Delta vector per frame
  float offScr = 100;       // Starts and ends this much to right and left of screen
  int curFrm;               // Current frame in animation
  int running = 0;          // 0 => pre-run, 1 => running, 2 => post-run
  int curStem = -1;         // Currently playing stem in horizontal resequencing obj
  int nStems;               // Number of stems in horizontal resequencing obj

  public YellowSub()
  {
    float vertRng = height * 0.3;
    loc = new PVector(width+offScr, height/2.0 + vertRng - random(vertRng*2));
    d = new PVector(-1.5, 0);
    nStems = aud.yelSub.snds.length;
  }

  void startYelSub()
  {
    if (running == 0)
    {
      running = 1;
      aud.bkgdMus.duck();    // Duck the background music
      aud.yelSub.trigTrans(0); // Fire off the first stem in sequence
    }
  }

  void move()                  // Move for each draw() frame
  {
    if (running == 1)
    {
      curFrm = (curFrm+1) % gr.nYelSubFrms;  // Look up next animation frame
      loc.add(d);                            // Move the sub
      if (gameState < 2)                     // If game is still being played
      {
        int newStem = mapX2Stem();           // Get stem based on x location
        //println(curFrm + " " + curStem + " " + newStem);
        if (newStem != curStem)              // If it's a new stem
        {
          aud.yelSub.trigTrans(newStem);     // Trigger transition 
          curStem = newStem;
        }
        if (loc.x < -offScr)                 // If we're off screen to left
        {
          aud.yelSub.trigTrans(nStems);      // Last time on last loop
          aud.bkgdMus.xFade(2);              // Restore background music to next track
          aud.bkgdMus.restore();
          running = 2;
        }
      }
      else  // gameState == 2, 3 or 4 (sinking, sunk or won)
      {
        running = 2;
        aud.yelSub.trigTrans(nStems);
        if (gameState == 4)   // player won!
        {
          aud.bkgdMus.xFade(4);
          aud.bkgdMus.restore();
        }
        else                  // gameState == 3
        {
          aud.bkgdMus.xFade(5);  
          aud.bkgdMus.restore();
        }
      }
    }
  }

  // Map x location of Yellow Submarine to a stem number
  // Stems go up as x location goes down
  int mapX2Stem()
  {
    if (loc.x >= width)    // Off screen to right => first stem
      return 0;
    else if (loc.x <= 0)   // Off screen to left => last stem
      return nStems - 2;
    else {
      return nStems - 2 - (int) (loc.x * (nStems - 1) / width);  // On screen
    }
  }

  void display()
  {
    if (running == 1)
    {
      tint(150, 100);         // Make it look like it's in the distance
      image(gr.yelSubFrm[curFrm], loc.x, loc.y);    // Display next frame
      noTint();
    }
  }
}