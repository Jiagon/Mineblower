/* Torpedo class - by Al Biles
 Handles Torpedo stuff
 Uses the torpDialog HorReSeq object to manage an 8-line "dialog" whose lines
 are triggered by transitions among the torpedo's 5 states (see transition
 table in the project document).
 */
class Torpedo
{
  PVector loc = new PVector(0, 0);  // Location of torpedo center, set in fire()
  PVector t1 = new PVector(50, -7); // 3 points for detonator triangle at front
  PVector t2 = new PVector(50, 5);  // All three are relative to loc
  PVector t3 = new PVector(60, -1); // 3rd point is tip of detonator (nose cone)
  PVector locInSub = new PVector(60, 30);

  PVector d = new PVector(0, 0);    // delta per frame (d.x, d.y), set in fire()

  // acceleration a has drag in x direction, buoyancy in y direction (always < 0)
  PVector a = new PVector(-0.020, -0.03); // Water exerts drag, wants to float

  float launchV = 13;  // Launch speed in x direction, always to right
  int tState = 0;      // 0 idle, 1 launched, 2 spent, 3 all gone, 4 loaded
  int nTorps;          // Number of torpedos remaining (set in constructor)
  int waitSome = 0;    // Frame timer for explosion sequence
  int waitMax = 30;    // Wait this long for the explosion to complete

  Torpedo(int n)       // Pass in number of torpedos
  {
    nTorps = n;
  }

  void reset()
  {
    d.set(0, 0);       // Start it over not moving
  }
  
  void loadTorp()
  {
    switch(tState)
    {
    case 0:
      tState = 4;
      aud.safePlay(aud.torpLoadSnd);
      aud.torpDialog.trigTrans(0);
      break;
    case 1:
      aud.torpDialog.trigTrans(4);
      break;
    case 2:
      aud.torpDialog.trigTrans(5);
      break;
    case 3:
      aud.torpDialog.trigTrans(6);
      break;
    case 4:
      aud.torpDialog.trigTrans(3);
      break;
    default:
      println("Panic!  Can't happen in loadTorp()");
      break;
    }
  }

  void fire(PVector subLoc) // Called when 'f' hit by user
  {
    switch (tState)
    {
    case 4:   // Can only fire from state 4 (loaded state)
      loc.set(PVector.add(subLoc, locInSub));
      d.set(launchV, sub.d.y*0.5); // launch speed, half of Sub's vertical speed
      tState = 1;
      aud.panPlay(aud.torpRunSnd, subLoc.x, launchV);
      aud.torpDialog.trigTrans(1);
      break;
    case 0:
      aud.torpDialog.trigTrans(7);      
      break;
    case 1:
      aud.torpDialog.trigTrans(4);      
      break;
    case 2:
      aud.torpDialog.trigTrans(5);      
      break;
    case 3:   // No more torpedos, state is a sink
      aud.torpDialog.trigTrans(6);
      break;
    default:
      println("Panic!  Can't happen in fire()");
      break;
    }
  }

  boolean running()
  {
    return tState == 1;
  }

  void explode()            // Called when torpedo hits a mine
  {
    if (tState == 1)        // Can only explode if currently running
    {
      tState = 2;           // Torpedo is gone
      waitSome = waitMax;   // Give animations a chance to finish
      aud.torpRunSnd.pause(); // Torpedo is no longer running
      aud.torpDialog.trigTrans(2);
    }
  }

  // Primary move method
  void move()
  {
    switch (tState)
    {
    case 0:        // Prelaunch state (Idle)
      if (nTorps <= 0)      // Out of torpedos
        tState = 3;         // Go to no more torpedos state
      break;
    case 4:   // Loaded, ready to launch
      break;
    case 1:   // Launched and running
      if (loc.x > width + 100) // Torpedo beyond window, so give up...
      {
        tState = 2;         // ...and retire the torpedo
        waitSome = waitMax; // Give animations a chance to finish
        aud.fadeOut(aud.torpRunSnd);
      }
      else                  // Torpedo still running, so stay in this state
      {
        d.add(a);           // Apply drag and buoyancy to delta
        loc.add(d);         // Move the torpedo
      }
      break;
    case 2:   // Torpedo's run is over, waiting to reset
      waitSome--;
      if (waitSome <= 0)    // Animations should have finished
      {
        nTorps--;           // Count the torpedo
        reset();            // Reinitialize torpedo's attributes
        tState = 0;         // and reset to initial state
        aud.torpDialog.reset();        
      }
      break;
    case 3:   // => No more torpedos, state is a sink
      break;
    default:
      println("Panic!  Can't happen in Torpedo move()");
      break;
    }
  }

  PVector nose()            // Return the tip of the nose cone
  {
    return PVector.add(loc, t3);
  }
  
  void display()
  {
    if (tState == 1)   // Only display if torpedo is launched and running
    {
      image(gr.tImage, loc.x, loc.y); // Torpedo body
      
      strokeWeight(2);                // Detonator in nose
      stroke(0);
      fill(75, 255, 255);
      triangle (loc.x+t1.x, loc.y+t1.y, loc.x+t2.x, loc.y+t2.y,
                loc.x+t3.x, loc.y+t3.y);
    }
  }
}