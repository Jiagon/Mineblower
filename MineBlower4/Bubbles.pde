/* Bubbles class - by Al Biles
 Does bubbles animation at random places
 */

class Bubbles
{
  PVector loc;
  int bubFrmN = 0;

  Bubbles()
  {
    loc = new PVector (random (200, width-200), random (200, height-100));
  }

  // Resets the bubbles to happen at a randomish location away
  // from where it was last time
  void reset()
  {
    PVector newLoc = new PVector (random (200, width-200), random (200, height-100));
    while (loc.dist(newLoc) < width / 3.0)
    {
      newLoc.set(random (200, width-200), random (200, height-100));
    }
    loc = newLoc;
    aud.safePlay(aud.bubbleSnd, loc.x);
  }

  void move()
  {
    if (frameCount % 6 == 0)  // Advance animation every 6th draw() frame
    {
      bubFrmN = (bubFrmN + 1);
      if (bubFrmN >= gr.nBubFrms)
      {
        bubFrmN = 0;          // If it's over, start it elsewhere
        reset();
      }
    }
  }

  void display()
  {
    image (gr.bubFrm[bubFrmN], loc.x, loc.y);
  }
}