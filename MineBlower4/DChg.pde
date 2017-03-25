/* DepthCharge class - by Al Biles
   Handles a depth charge that falls from the top of the screen
   and tumbles slowly to the bottom.  There is no interaction
   with anything in the game, so it's just an excuse for a
   non-trivial linear cue that will play once without interruption.
 */
class DepthCharge
{
  PVector loc;          // Current location of depth charge
  PVector d;            // Current velocity
  float theta = 0.0;    // Current rotation
  float dTheta = 0.03;  // Angular velocity of rotation
  int dropping = 0;     // State: 0 => pre-drop, 1 => dropping, 2 => post-drop
  float offScr = 75;    // How far off screen it starts and ends

  DepthCharge()
  {
    float x = random(width*0.25, width*0.75); 
    loc = new PVector(x, -offScr);   // Locate it off screen to start
    d = new PVector(0, 1.77);        // Drops 1.75 pixels per frame
  }
  
  // Called to start it dropping
  void drop()
  {
    if (dropping == 0)
    {
      dropping = 1;
      aud.bkgdMus.duck();           // Duck the background music
      aud.safePlay(aud.depChgCue);  // Play the depth charge sound
    }
  }
  
  // Called every frame, only does anything if it's dropping
  void move()
  {
    if (dropping == 1)
    {
      loc.add(d);                  // Move it
      theta += dTheta;             // Rotate it
      if (loc.y > height + offScr) 
      {
        dropping = 2;              // Finished dropping
        if (gameState < 2)         // If game still being played
          aud.bkgdMus.xFade(3);    // Restore background music to next track
        else if (gameState < 4)
          aud.bkgdMus.xFade(5);    // Sinking or sunk
        else // gameState == 5
          aud.bkgdMus.xFade(4);    // Game won
        aud.bkgdMus.restore();
      }
    }
  }
  
  // Displays it only if it's actually dropping
  void display()
  {
    if (dropping == 1)
    {
      pushMatrix();            // Standard Matrix trick for rotation
      translate(loc.x, loc.y);
      rotate(theta);
      image(gr.dCImage, 0, 0);
      popMatrix();
    }
  }
}