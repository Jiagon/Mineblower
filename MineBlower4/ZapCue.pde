/* ZapCue class - by Al Biles
   Controls the zapLayers music cue, which uses vertical remixing for an
   interactive cue to accompany the sub being zapped by an eel.
 */

class ZapCue
{
  int zapCueSt = 0;               // State controlling the zapLayers music cue
                                  // 0 not zapping, 1 zapping, 2 running out
  int zapCtr = 0;                 // Counter for cummulative zaps used for music cue
  int zapPeriod = 60;             // Number of frames per increment to zapState
  int zapRunOut = 30;             // Number of frames past last zap to stay zapping

  // Update method to control the music cue used when the sub is zapped by eels.
  // This is a bit complex because it is called each frame and has to
  // handle layer manipulations in the vertical remixing object, which
  // are partially controlled by a frame timer that stays on as long
  // the sub stays zapped.  Also ducks the background music if the sub
  // is being zapped.  This has nothing really to do with the the zapping
  // itself, other that 
  void zapCue(boolean zapNow)
  {
    //println(zapCueSt, zapCtr);
    if (gameState > 1)         // Game timing out or over
    {
      aud.zapLayers.duck();    // Shut down zap cue
      if (zapCueSt > 0)
      {
        // Handle non-bkgdMus tracks (kludge!)
        if (yS.running != 1 && dC.dropping != 1)
          aud.bkgdMus.restore();
        zapCtr = 0;
        zapCueSt = 0;         // Back to not zapping
      }
    }
    else if (zapNow)            // Currently zapping
    {
      if (zapCueSt == 0)        // Just zapped
      {
        zapCtr = 0;
        aud.zapLayers.reset();
        aud.zapLayers.startAll();
        aud.zapLayers.allUp();
        aud.bkgdMus.duck();
        zapCueSt = 1;
      } else if (zapCueSt == 1)   // Still zapping
      {
        updateZapCue();
      } else                      // State 2 & re-zapped
      {
        zapCueSt = 1;
        updateZapCue();
      }
    } else                        // Not currently zapping
    {
      if (zapCueSt == 1)
      {
        zapCueSt = 2;             // Start Cue Run Out
        zapRunOut = zapPeriod / 2;
        updateZapCue();
      } else if (zapCueSt == 2)   // Run out still proceeding
      {
        updateZapCue();
        zapRunOut--;
        if (zapRunOut <= 0)     // Just ran out
        {
          aud.zapLayers.duck();
          // Handle non-bkgdMus tracks (kludge!)
          if (yS.running != 1 && dC.dropping != 1)
            aud.bkgdMus.restore();
          zapCtr = 0;
          zapCueSt = 0;         // Back to not zapping
        }
      }
    }
  }
  
  // Triggers a fadeout on next track to do so, based on zapCtr frame counter
  // Keeps the last track playing, regardless of how long sub as been zapped
  void updateZapCue()
  {
    zapCtr++;                            // Count this frame
    if (zapCtr % zapPeriod == 0)         // Trigger next layer fadeout?
    {
      int trk = zapCtr / zapPeriod - 1;  // Which track to fade out
      //println(trk);
      if (trk < aud.zapLayers.snds.length - 1)  // Not the last track
        aud.zapLayers.potDn(trk);
    }
  }
}