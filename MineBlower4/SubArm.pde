/* Arm class - by Al Biles
 This class implements the arm sticking out of the top right of the sub,
 which is used to disarm mines.
 */
class SubArm
{
  PVector loc;              // Arm location is where main boom connects to sub
  PVector dev = new PVector(67,-15); // Arm location deviation from sub center
  PVector grab = new PVector(109,-37); // Grab point relative to arm loc
  PVector d = new PVector(0,0);        // At rest by default
  PVector ejectVel = new PVector(3.0, -1.0);
  float drag = 0.01;                   // Water exerts drag

  SubArm(PVector subLoc)               // Start arm connected to Sub
  {
    loc = PVector.add(subLoc, dev);
  }

  PVector grab()
  {
    return PVector.add(loc, grab);
  }

  void sinking(PVector subLoc, PVector dSub)
  {
    loc = PVector.add(subLoc, dev);
    d = PVector.add(dSub, ejectVel); // Arm ejects at (3,-1) relative to sub vel
  }

  void move (PVector subLoc)         // Move the arm with the Sub
  {
    loc = PVector.add(subLoc, dev);
  }

  void sinkingMove ()           // Move the arm on its own
  {
    d.y += 0.05;                // Sinks in y direction
    loc.y += d.y;
                                // Drag applied only in X direction
    d.x += (d.x > 0 ? -drag : (d.x < 0 ? drag : 0));
    loc.x += d.x;
  }

  void display(int electroN)    // electroN: Number of frames left to zap
  {    
    if (electroN > 0)           // Arm flashes if sub zapping
      stroke(random(0, 255), 255, 255);  // Random Hue
    else
      stroke(100);              // Not zapping => gray
    strokeWeight(5);
    line (loc.x, loc.y, loc.x+70, loc.y-30);        // Main boom
    line (loc.x+70, loc.y-30, loc.x+100, loc.y-55); // Upper claw segment
    line (loc.x+70, loc.y-30, loc.x+100, loc.y-20); // Lower claw segment
    //displayGrabPt();            // Visible grab point for disarming
  }
  
  void displayGrabPt()  // Displays grab point for disarming mines
  {
    PVector grabPt = this.grab();
    point (grabPt.x, grabPt.y); // Grab point for disarming
  }

}