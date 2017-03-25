/* Score class - by Al Biles
 Maintains score and health for the sub
 Also displays the splash, instruction, and game over screens
 */

class Score
{
  int score = 0;               // Player score
  int nMinesDeact = 0;         // Count number of mines deactivated
  int allDeactBonus = 300;     // Bonus for deativating all the mines
  int disarmPoints = 100;      // 100 points to disarm a mine
  int detonatePoints = 50;     // 50 points to blow one up with torpedo
  int blastPoints = 25;        // 25 points to run into one
  int eelGroundPoints = 10;    // 10 points to ground an eel
  int health = 100;            // Start with 100 health
  int zapHurt = 2;             // Eel zaps are -2 health
  int blastHurt = 30000;       // Blast damage expressed as a "force"
  PFont scFont;
  PFont instFont;

  String instruct1 = "You are captain of the sub, " +
    "and your goal is to deactivate as many mines as you can.\n" +
    "There are three ways to deactivate a mine:\n" +
    "1) You can disarm a mine by touching it gently " +
    "with the claw on the sub's arm for 100 points.\n" +
    "2) You can detonate a mine by hitting it with " +
    "a torpedo for 50 points, but you might get a little blast damage, " +
    "depending on how far you are from the mine.\n" +
    "3) If you aren't careful when trying to disarm a mine, " +
    "or you run into a mine, it will explode, which gets you 25 points " +
    "but damages the sub.\n" +
    "If you touch an eel it will zap you, which causes a " +
    "little damage and disables your controls until you float away from it.\n" +
    "If you hit an eel with a torpedo, it becomes grounded for a while, " +
    "so it can't zap you, and you get 10 points.\n" +
    "If you deactivate all the mines you win.\n" +
    "If your health falls below 0, you begin to sink.\n" +
    "If you sink well below the window, you lose.\n\n" +
    "To control the sub, use the down, left and right arrow keys.\n" +
    "The sub is naturally buoyant (it wants to float), so the only way " +
    "to move up is to let the sub float on its own.\n" +
    "To start the game, hit the \'s\' key.        " +
    "To load a torpedo, hit the \'l\' key.\n" +
    "To quit the game, hit the \'q\' key.         " +
    "To fire a torpedo, hit the \'f\' key.\n\n" +
    "Ready to rig for not-so-silent running?\n" +
    "Then hit 's' to start!";

  Score ()
  {
    scFont = createFont("Helvetica-Bold", 32); // This works for standard fonts
    instFont = createFont("Helvetica", 24);    // This works for standard fonts
  }  

  void disarmed()
  {
    score += disarmPoints;
    nMinesDeact++;
    if (sc.nMinesDeact >= nMines * (MAX_RESET+1))
    {
      sc.youWon();
    }
  }

  void detonatePoints()
  {
    score += detonatePoints;
    nMinesDeact++;
    if (sc.nMinesDeact >= nMines * (MAX_RESET+1))
    {
      sc.youWon();
    }
  }

  void blastPoints()
  {
    score += blastPoints;
    nMinesDeact++;
    if (sc.nMinesDeact >= nMines * (MAX_RESET+1))
    {
      sc.youWon();
    }
  }
  
  // Blast damage mitigates the blastHurt "force" by distance from
  // the blast ^ 1.5 power instead of distance squared (real physics)
  // to make it more playable
  void blastDamage(float blastDist)
  {
    health -= int (blastHurt / (blastDist * sqrt(blastDist)));
    if (health < 0)
      sub.sinking();
  }

  void grounded()
  {
    score += eelGroundPoints;
  }

  void zapped()
  {
    if (gameState < 2)
    {
      health -= zapHurt;
    }
    if (health < 0)
      sub.sinking();
  }

  void youSank()
  {
    gameState = 3;
    score += health;
    aud.safePlay(aud.sunkSnd);
  }

  void youWon()
  {
    gameState = 4;
    score += allDeactBonus;
    score += health;
  }

  void display()
  {
    textFont(scFont);
    fill(0, 200, 100);
    textAlign(LEFT);
    text("Score: " + score, 12, height-82);
    text("Health: " + health, 12, height-48);
    text("Deactivated: " + nMinesDeact + "/" +
      (nMines * (MAX_RESET+1)), 12, height-14);
  }

  void splashScreen()
  {
    background(129, 60, 220);
    fill(0, 120, 100);
    rect (width/2-350, height/2-300, 700, 580);
    textFont(scFont, 48);
    fill(128, 200, 255);
    textAlign(CENTER);
    text("MineBlower!", width/2, height/2-220);
    textFont(scFont, 32);
    text("The game that will blow your mine!!", width/2, height/2-150);
    text("And your mind!!!", width/2, height/2-100);
    textFont(instFont, 32);
    text("Detailed Instructions: Hold down \'?\' key", width/2, height/2-15);
    text("Move: Down, Left, Right arrow keys", width/2, height/2+35);
    text("Load torpedo: \'l\' key", width/2, height/2+85);
    text("Fire torpedo: \'f\' key", width/2, height/2+135);
    text("Quit: \'q\' key", width/2, height/2+185);
    text("Start the game: \'s\' key", width/2, height/2+235);
  }

  void instructions()
  {
    fill(0, 120, 100);
    rect (width/2-550, height/2-450, 1100, 850);
    fill(128, 200, 255);
    textFont(instFont, 48);
    textAlign(CENTER);
    text("Detailed Instructions", width/2, height/2-380);
    textFont(instFont, 24);
    textAlign(LEFT);
    text(instruct1, width/2-500, height/2-350, 1000, 730);
  }

  void youSankScreen()
  {
    fill(0, 200, 100);
    rect (width/2-300, height/2-250, 600, 400);
    textFont(scFont);
    fill(128, 200, 255);
    textAlign(CENTER);
    text("You're Sunk!", width/2, height/2-100);
    text("Total Score: " + score, width/2, height/2-50);
    text("Mines Deactivated: " + nMinesDeact + " / " +
      (nMines * (MAX_RESET+1)), width/2, height/2);
  }

  void youWonScreen()
  {
    fill(0, 200, 100);
    rect (width/2-300, height/2-250, 600, 400);
    textFont(scFont);
    fill(128, 200, 255);
    textAlign(CENTER);
    text("All Mines Cleared!", width/2, height/2-100);
    text("Total Score: " + (score+health), width/2, height/2-50);
    text("Mines Deactivated: " + nMinesDeact + " / " +
      (nMines * (MAX_RESET+1)), width/2, height/2);
  }
}