/* Mine class - by Al Biles
 Handles all stuff that happens to a Mine.
 A given mine can be reset MAX_RESET times.
 */
class Mine
{
  PVector loc = new PVector(-100, -100);  // Locate it off screen by default
  PVector centerW = new PVector(width/2.0, height/2.0);
  int mineFrmN = 0;
  int expFrmN = 0;
  float radius = 50;
  int mineSt = 0;    // 0 active, 1 exploding, 2 disarmed, 3 dormant, 4 gone
  int inactiveTime;
  final int INACTIVE_MAX = 500;
  int fadeTime;
  final int FADE_MAX = 100;
  int nReset = MAX_RESET;     // MAX_RESET defined global in main

  Mine ()
  {
    randPlace(centerW);       // Avoid placement in center of window
    mineFrmN = int(random(0, gr.nMineFrms));
  }

  // Reset the mine so that it can reappear at a new place
  void reset()
  {
    randPlace(sub.loc);
    mineFrmN = int(random(0, gr.nMineFrms));
    mineSt = 0;
    expFrmN = 0;
    inactiveTime = 0;
    fadeTime = 0;
  }

  // Puts mine at random place not too close to sub or another mine
  void randPlace(PVector avoid)  // Sub is at avoid
  {
    PVector newLoc = new PVector(random (200, width-50), random (100, height-100));
            // Not too close to sub or to any existing mine
    while (newLoc.dist(avoid) < 250 || mineCluster(newLoc))
    {
      newLoc.set(random (200, width-50), random (100, height-100));
    }
    loc = newLoc;
  }

  // Returns true if mine at (x,y) would be too close to another mine
  boolean mineCluster (PVector newLoc)
  {
    for (int i = 0; i < nMines && mines[i] != null; i++)
      if (newLoc.dist(mines[i].mineLoc()) < 100)
        return true;
    return false;
  }

  // Returns true if (x,y) inside the Mine
  boolean touch(float x, float y)
  {
    if (mineSt > 0)                    // Can only touch if mine active
      return false;
    else
      return dist(x, y, loc.x, loc.y) < radius;  // Assume a round mine
  }
  boolean touch(PVector pt)            // Overload for PVector parameter
  {
    if (mineSt > 0)                    // Can only touch if mine active
      return false;
    else
      return pt.dist(loc) < radius;    // Assume a round mine
  }
  
  float dist2Arm(PVector pt)
  {
    if (mineSt > 0)
      return width;
    else
      return pt.dist(loc);
  }

  boolean active()         // Some getters
  {
    return mineSt == 0;
  }

  boolean inactive()
  {
    return mineSt > 1;     // Fading away or truly inactive
  }

  PVector mineLoc()
  {
    return loc;
  }

  // Called when the mine explodes, whatHit 0 => sub, 1 => torpedo
  void explode(int whatHit)
  {
    if (mineSt == 0)       // Can only blow up if Mine still active
    {
      mineSt = 1;          // Mine is now exploding
      aud.triggerWhere(aud.bangSnd, loc.x);
    }
    if (whatHit == 0)      // Only play stinger if sub caused explosion
      aud.safePlay(aud.explodeStinger);
  }

  void disarm()            // Called when the mine has been disarmed
  {
    if (mineSt == 0)       // Can only disarm if Mine still active
    {
      mineSt = 2;                             // Make Mine disarmed
      inactiveTime = INACTIVE_MAX;
      fadeTime = FADE_MAX;                    // Start fading away
      aud.triggerWhere(aud.disarmSnd, loc.x);
      aud.safePlay(aud.disarmStinger);
      sc.disarmed();
    }
  }

  // Primary move method - Different moves for different states
  void move()
  {
    if (mineSt == 0)         // Mine still active, animate intermittently
    {
      if (frameCount % gr.nMineFrms == 0 && random(0, 10) < 5)
        mineFrmN = (mineFrmN + 1) % gr.nMineFrms;
    }
    else if (mineSt == 1)    // Mine is exploding
    {
      if (expFrmN < gr.nExpFrms)
        expFrmN++;
      else
      {
        mineSt = 3;          // Explosion done, make Mine inactive
        inactiveTime = INACTIVE_MAX;
        if (random(10) > 5)
          aud.rF1.trigger(); // Somtimes trigger robotic comment
      }
    }
    else if (mineSt == 2)    // Mine is disarmed, fading away
    {
      inactiveTime--;
      fadeTime--;
      if (fadeTime <= 0)     // Done fading, make it inactive
      {
        fadeTime = 0;
        mineSt = 3;
      }
    }
    else if (mineSt == 3)    // Is inactive, waiting to be reset
    {
      if (nReset > 0)
      {
        inactiveTime--;
        if (inactiveTime <= 0) // Time to reactivate it
        {
          mineSt = 0;
          nReset--;
          reset();
        }
      }
      else
        mineSt = 4;          // No resets left
    }
    // else (mineSt == 4) No more resets, mine ignored
  }

  void display()
  {
    if (mineSt == 0)         // Mine still active
    {
      image(gr.mineFrm[mineFrmN], loc.x, loc.y);
    }
    else if (mineSt == 1)    // Mine is exploding
    {
      if (expFrmN < gr.nExpFrms)
      {
        image (gr.expFrm[expFrmN], loc.x, loc.y, 
                             // Scale up explosion image size by 2
            gr.expFrm[expFrmN].width * 2, gr.expFrm[expFrmN].height * 2);
      }
    }
    else if (mineSt == 2)    // Mine is fading away after being disarmed
    {
      tint(255, fadeTime);
      image(gr.mineFrm[mineFrmN], loc.x, loc.y);
      noTint();
    }
    // else mineSt == 3 or 4, can't see it
  }
}