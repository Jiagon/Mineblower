/* Sub class - by Al Biles
 * Handles all sub behaviors and interactions with other objects
 * Forces are handled as scalers in x or y direction because each is
 * independent of the others.  Boost forces are in x or y direction
 * because of the arrow keys.  Buoyancy is always in y direction and
 * drag is always in x direction (could be a true vector, but it's not).
 */
class Sub
{
  PVector loc;             // Location of center of sub
  PVector d = new PVector(0,0); // Deviation per frame (velocity)
  float buoyancy = -0.05;  // Sub wants to float
  float drag = -0.025;     // Water exerts drag in x direction only
  float xBoost = 0.15;     // Per frame increment in deviations 
  float yBoost = 0.15;
  float maxD = 4.0;        // Max deviation per frame
  
  float subWidth = 269;    // Total sub dimensions
  float subHeight = 167;
  float hullLeft = -135;   // Hull left/right edge from center
  float hullRight = 134;
  float hullTop = -19;     // Hull top/bottom from center
  float hullBot = 84;
  float conLeft = -12;     // Conning tower left/right from center
  float conRight = 66;
  float conTop = -83;      // Conning tower top/bottom from center
  float conBot = -18;
  SubArm arm;              // Grappling arm to grab mines

  int subState = 0;        // 0 Normal, 1 Zapping, 2 Sinking, 3 Sunk
  int electroN = 0;        // Frame counter for zapping sequence
  int zapMax = 20;         // Zap sequence lasts 20 frames
  int curFrm = 0;          // Current frame in animation
  float bForce = 8000.0;   // Blast Force of an exploding mine
  float careful = 1.5;     // Motion threshold for disarming mine
  float tooFarOff = 200.0; // Distance off screen that triggers Vert Remix
  float sunkTh = 500.0;    // When sub sinks this far below window, game over
  //boolean gameOver;      // true when game over, global defined in main

  Sub()
  {
    loc = new PVector(width/2.0, height/2.0);
    arm = new SubArm(loc);    // Create arm relative to sub center
  }

  boolean eelTouch(Eel e1)    // Returns true if e1 overlaps sub
  {
    if (subState > 0 || e1.grounded() || e1.zapping())  // Don't overdo it
      return false;
    else
    {
      // Have to check enough hull points to be "realistic"
      return e1.touch(loc.x+hullLeft, loc.y+hullTop) ||
        e1.touch(loc.x+hullLeft/2, loc.y+hullTop) ||
        e1.touch(loc.x+hullRight, loc.y+hullTop) ||
        e1.touch(loc.x+hullLeft, loc.y+hullBot) ||
        e1.touch(loc.x+hullLeft/2, loc.y+hullBot) ||
        e1.touch(loc.x, loc.y+hullBot) ||
        e1.touch(loc.x+hullRight/2, loc.y+hullBot) ||
        e1.touch(loc.x+hullRight, loc.y+hullBot) ||
        e1.touch(loc.x+conLeft, loc.y+conTop) ||
        e1.touch(loc.x+conLeft, loc.y+conBot) ||
        e1.touch(loc.x+conRight, loc.y+conTop) ||
        e1.touch(loc.x+conRight, loc.y+conBot);
    }
  }

  // Called when zapped by an eel
  void zap()
  {
    if (subState < 2)      // Only if we're not sinking or sunk
    {
      subState = 1;        // Transition to zapping state
      electroN = zapMax;   // Set up frame timer for zapping sequence
      sc.zapped();
    }
  }

  boolean mineTouch(Mine m1)  // Returns true if m1 overlaps sub
  {
    if (! m1.active())        // Not if mine is inactive
        return false;
    else
    {
      // Have to check enough hull points to be "realistic"
      return m1.touch(loc.x+hullLeft, loc.y+hullTop) ||
        m1.touch(loc.x+hullLeft, loc.y) ||
        m1.touch(loc.x+hullLeft, loc.y+hullBot) ||
        m1.touch(loc.x+hullLeft/2, loc.y+hullTop) ||
        m1.touch(loc.x+hullLeft/2, loc.y+hullBot) ||
        m1.touch(loc.x+hullRight, loc.y+hullTop) ||
        m1.touch(loc.x+hullRight, loc.y) ||
        m1.touch(loc.x+hullRight, loc.y+hullBot) ||
        m1.touch(loc.x+hullRight/2, loc.y+hullBot) ||
        m1.touch(loc.x, loc.y+hullBot) ||
        m1.touch(loc.x+conLeft, loc.y+conTop) ||
        m1.touch(loc.x+conLeft, loc.y+conBot) ||
        m1.touch(loc.x+conRight, loc.y+conTop) ||
        m1.touch(loc.x+conRight, loc.y+conBot);
    }
  }

  boolean careful()  // Returns true if current speed slow enough
  {
    return d.mag() < careful;
  }

  // Called when a mine blows up, sub is blasted away from explosion
  // with "force" bForce, mitigated by Distance ^ 1.5 power instead of
  // distance squared (real physics) to make the effect more playable.
  // bDSq is distance ^ 2.5 power to include converting the distance
  // from blast in each direction to get a unit vector component
  // before doing the actual blast effect.
  void blast(PVector blastLoc)
  {
    if (subState < 3)  // Only if we're not sunk
    {
      float bDist = loc.dist(blastLoc);           // Distance from blast
      float bDSq = bDist * bDist * sqrt(bDist);   // Distance ^ 2.5 power

      PVector blastV = PVector.sub(loc,blastLoc); // Linear blast vector
      d = PVector.mult(blastV, bForce);           // times force
      d.div(bDSq);                                // divided by distance^2.5
      d.limit(maxD);                              // Upper limit

      sc.blastDamage(bDist);                      // Figure damage to sub
    }
  }

  // Called when sub health goes negative (sinking)
  void sinking()
  {
    if (subState < 2)
    {
      subState = 2;
      electroN = 0;
      buoyancy = abs(buoyancy);        // Sub now wants to sink
      arm.sinking(loc, d);
      aud.silenceBkgd();
      aud.bkgdMus.xFade(5);            // Sinking/sunk music cue
      aud.safePlay(aud.sinkingSnd);
      gameState = 2;
    }
  }

  boolean sunk()
  {
    return subState > 2;
  }

  void fireTorp(Torpedo t1)
  {
    t1.fire(loc);
  }

  // Primary move method depends on sub state
  void move()
  {
    if (subState == 0)       // Normal running
      normalMove();
    else if (subState == 1)  // Sub being zapped
      zapMove();
    else if (subState == 2)  // Sub sinking
      sinkingMove();
    else
    {
      sc.youSank();
      gameState = 3;         // subState 3 - sub sunk, game over
    }
  }

  void zapMove()
  {
    if (electroN > 0)
      electroN--;            // Still zapping
    else
    {
      subState = 0;          // Done zapping, go back to Normal state
    }

    baseMove();
    arm.move(loc);           // Move arm with the sub
  }
  
  void sinkingMove()
  {
    baseMove();
    arm.sinkingMove();

    // Once sub and arm sink well below bottom window border, game over
    if (loc.y > height + sunkTh && arm.loc.y > height + sunkTh)
      subState = 3;          // Sunk => Game over
  }

  void normalMove() 
  {
    if (downPressed)         // Handle DOWN arrow
    {
      d.y += yBoost;         // Boost down to overcome buoyancy
      aud.safePlay(aud.diveSnd, loc.x);
    }
    if (leftPressed)         // Handle LEFT arrow
    {
      if (! rightPressed)    // Can only go one way
      {
        d.x -= xBoost;       // Animate propeller backwards
        curFrm = (curFrm == 0 ? gr.nSubFrms-1 : ((curFrm - 1) % gr.nSubFrms));
        aud.safePlay(aud.reverseSnd, loc.x);
      }
    }
    else if (rightPressed)   // Handle RIGHT arrow only if LEFT not pressed
    {
      d.x += xBoost;
      curFrm = (curFrm + 1) % gr.nSubFrms;  // Animate propeller forwards
      aud.safePlay(aud.forwardSnd, loc.x);
    }

    baseMove();              // Move the sub
    arm.move(loc);           // Move the arm with the sub
  }

  // Does sub base move with no (or after) user control
  void baseMove()
  {
    d.y += buoyancy;        // Always bouyant
    d.x += (d.x > 0 ? drag : (d.x < 0 ? -drag : 0)); // Always a drag
    d.limit(maxD);          // Not too fast
    loc.add(d);             // Apply deviation (velocity)
  }

  void display()
  {
    if (subState == 0)                         // Normal state
    {
      image (gr.subFrm[curFrm], loc.x, loc.y); // Normal display
      arm.display(0);                          // Display arm
      //arm.displayGrabPt();

      // Give audio clues to location if sub is too far off the window
      if (loc.x < -tooFarOff)
        aud.tooFarLeft();
      else if (loc.x > width + tooFarOff)
        aud.tooFarRight();
      if (loc.y < -tooFarOff)
        aud.tooFarUp();
      else if (loc.y > height + tooFarOff)
        aud.tooFarDown();
    }
    else if (subState == 1)               // Sub Being zapped
    {
      if (electroN % 2 == 0)              // Make it flash by alternating
      {
        image (gr.zapSubFrm[curFrm], loc.x, loc.y); // Zap display
        arm.display(electroN);            // Display arm
        //arm.displayGrabPt();
      }
      else
      {
        image (gr.subFrm[curFrm], loc.x, loc.y); // Normal display
        arm.display(electroN);                   // Display arm
        //arm.displayGrabPt();
      }
    }
    else if (subState == 2)                 // Sub sinking
    {
      if (arm.loc.y > height+sunkTh && sub.loc.y > height+sunkTh)
        subState = 3;                       // Sub is sunk
      else
      {
        image (gr.sinkImage, loc.x, loc.y); // Sunk image is grayscale
        arm.display(0);                     // Display arm
        //arm.displayGrabPt();
      }
    }
    // else subState == 3, sunk state, show nothing
  }
}