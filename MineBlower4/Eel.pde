/* Eel class - by Al Biles
 Handles Eel behaviors.
 Uses State machine to control animations.
 */
class Eel
{
  PVector loc;        // Center location
  float xDevL = -28;  // Left edge deviation of bounding box
  float xDevR = 38;   // Right edge deviation of bounding box
  float yDevU = -81;  // Up edge deviation of bounding box
  float yDevD = 63;   // Down edge deviation of bounding box
  PVector centerW = new PVector(width/2.0, height/2.0);  // Center of Window

  int [] [] transTab = {  // Transition table
    {                     // eelSt 0: normal animation
      1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 0, 14, 15, 16, 17, 18, 19, 20, 0, 0
    }
    , {                   // eelSt 1: zapping animation
      13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 14, 15, 16, 17, 18, 19, 20, 0, 0
    }
    , {                   // eelSt 2: grounded animation
      13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 14, 15, 16, 17, 18, 19, 20, 21, 21
    }
  };
  int zapFrm = 13;        // Frame offset where zap animation starts
  int groundFrm = gr.nEelFrms - 1;  // Extra frame used when eel is grounded
  int curFrm = 0;
  int eelSt = 0;          // 0 => normal, 1 => zapping, 2 => grounded
  int sleepFrms = 600;    // Eel stays grounded this many draw() frames
  int wakeFrm = 0;
  int groundCtr = 0;

  Eel ()
  {
    randPlace();
    curFrm = int (random(0, zapFrm));  // Random normal frame
  }

  // Puts eel at random place not too close to sub or another eel
  void randPlace()
  {
    PVector rdpt = new PVector(0, 0);
    do
    {        // Put it at random place
      rdpt.set(random (200, width-50), random (100, height-100));
    }        // Not too close to sub or to any existing eel
    while (rdpt.dist (centerW) < 250 || eelCluster(rdpt));
    loc = rdpt;
  }

  // Returns true if eel at (x,y) would be too close to another eel
  boolean eelCluster (PVector pt)
  {
    for (int i = 0; i < nEels && eels[i] != null; i++)
      if (pt.dist(eels[i].loc) < 160)
        return true;
    return false;
  }

  void move()              // Normal move for each draw() frame
  {
    curFrm = transTab[eelSt][curFrm];         // Look up next animation frame
    if (eelSt == 1 && curFrm == groundFrm-1)  // Do zap cycle only once
      eelSt = 0;                              // then return to normal animation
    else if (eelSt == 2 && frameCount >= wakeFrm) // No longer grounded
      eelSt = 0;
  }

  void zap()
  {
    if (eelSt == 0)        // Can only zap if in normal state
    {
      eelSt = 1;
      aud.triggerWhere(aud.zapSnd, loc.x);
    }
  }

  void ground()            // Start grounded sequence (eel inactive)
  {
    eelSt = 2;
    groundCtr = 32;
    wakeFrm = frameCount + sleepFrms;
    aud.triggerWhere(aud.groundSnd, loc.x);
    sc.grounded();
  }

  boolean grounded()
  {
    return eelSt == 2;
  }

  boolean zapping()
  {
    return eelSt == 1;
  }

  // Returns true if (x,y) is inside eel's bounding box
  boolean touch (float x, float y)
  {
    if (eelSt != 0)       // if grounded or zapping, can't touch
      return false;
    else
      return x > loc.x+xDevL && x < loc.x+xDevR &&
        y > loc.y+yDevU && y < loc.y+yDevD;
  }
  boolean touch (PVector pt)  // Overload for PVector param
  {
    if (eelSt != 0)       // if grounded or zapping, can't touch
      return false;
    else
      return pt.x > loc.x+xDevL && pt.x < loc.x+xDevR &&
        pt.y > loc.y+yDevU && pt.y < loc.y+yDevD;
  }

  void display()
  {
    image (gr.eelFrms[curFrm], loc.x, loc.y);  // Always display eel
    if (eelSt == 2)           // If grounded...
    {
      if (groundCtr > 0)      // ...see if ground symbol still on
      {
        if (groundCtr % 2 == 0)
          flashGround();      // Flashes green ground symbol over eel
        groundCtr--;
      }
    }
  }

  void flashGround()          // Draws a green ground symbol
  {
    float x = loc.x;          // Unpack eel's current location
    float y = loc.y;
    float xDev = 40;          // Width and height of bars
    float yDev = 80;
    strokeWeight (10);
    stroke (75, 255, 150);
    line(x, y-77, x, y);
    line(x-xDev, y, x+xDev, y);
    line(x-xDev*0.6, y+yDev*0.4, x+xDev*0.6, y+yDev*0.4);
    line(x-xDev*0.3, y+yDev*0.8, x+xDev*0.3, y+yDev*0.8);
  }
}