/* Horizontal Resequencing class - by Al Biles
 Implements simple horizontal resequencing, with an array of sounds
 that can be played one at a time, where the transitions are scheduled
 by calling trigTrans(n), where n is a track (file) number in the
 sequence.  This will cause track n to begin playing when the currently
 playing track (if any) ends.  Because of the parameter to trigTrans(),
 the tracks can be played in any order.  If the parameter's value is
 greater than the highest index in the array, the sequence stops with the
 completion of the currently playing track. If the parameter's value
 is negative, the transition is ignored.
 
 There are two ways to set up the sequence:
 looping - Loop each track until a transition is scheduled (good for music)
 not looping - Each track will be played once only (good for dialog)
 
 Methods:
 update() - Must be called once per frame, likely in update section of draw()
 trigTrans() - Trigger (schedule) a transition to another track
 reset() - Resets the object to its initial state to restart the sequence
 setGain() - Sets gain levels for all the sounds to the level passed in (Legacy)
 */

class HorReSeq
{
  AudioPlayer [] snds;   // The sounds (tracks) in the sequence
  float [] gains;        // Gain level of each track in the snds array
  int currTrk = -1;      // Offset in array of currently playing sound
  int nextTrk = -1;      // Offset of next track to play
  boolean looping;       // true => loop tracks, false => just play once
  boolean makeTrans;     // Set true when transition scheduled
                         // Reset to false when transition made

  // Constructor needs path, number of sound files & whether to loop
  // The dirPath should be a folder name followed by a slash followed
  // by a root file name.  For example if you have Snd0.mp3, Snd1.mp3
  // and Snd2.mp3 in the the Dialog folder, you would pass in
  // "Dialog/Snd" as the value of dirPath, and nSnds would be 3.
  HorReSeq(String dirPath, int nSnds, boolean l)
  {
    snds = new AudioPlayer [nSnds];
    gains = new float [nSnds];
    String [] gainAra = loadStrings(dirPath + "Gains.txt");
    looping = l;
    makeTrans = false;   // No transition yet

    for (int i = 0; i < snds.length; i++)
    {
      String filePath = dirPath + i + ".mp3";
      snds[i] = minim.loadFile(filePath, 512);
      gains[i] = float(gainAra[i]);
      snds[i].setGain(gains[i]);
      //println(filePath, leng[i], looping);
    }
  }
  
  // (Re)sets everything to initial values to replay sequence
  void reset()
  {
    currTrk = -1;          // Offset in array of currently playing sound
    nextTrk = -1;          // Offset of next track to play
    makeTrans = false;     // No transition scheduled yet

    for (int i = 0; i < snds.length; i++)
      snds[i].rewind();
  }

  // Set the gain in all the sounds by gainChg - Legacy 
  void setGain(float gain)
  {
    for (int i = 0; i < snds.length; i++)
      snds[i].setGain(gain);
  }

  // Called every frame to handle any scheduled transitions
  void update()
  {
    // If a transition has been scheduled, see if we can make it
    if (makeTrans)
    {
      if (currTrk < 0)
      {
        currTrk = nextTrk;      // Start first track in sequence
        if (looping)
          snds[currTrk].loop();
        else
          snds[currTrk].play();
        makeTrans = false;      // Transition has been made
      }
      else if (! snds[currTrk].isPlaying())
      {
        currTrk = nextTrk;      // Current track done, so start next one
        if (looping)
        {
          snds[currTrk].rewind();
          snds[currTrk].loop();
        }
        else
        {
          snds[currTrk].rewind();
          snds[currTrk].play();
        }
        makeTrans = false;      // Transition has been made
      }
      // else current track still playing
    }
    // else no transition scheduled, so keep doing what we're doing
  }

  // Trigger (schedule) transition to track trk in the array
  void trigTrans(int trk)
  {
    if (trk < 0)
    {
      return;                  // Can't transition to a negative track
    }
    else if (trk < snds.length)
    {
      nextTrk = trk;           // Set up for next track
      makeTrans = true;        // Tell update() a transition is waiting
      if (looping && currTrk >= 0)
        snds[currTrk].play();  // Turn off looping on current track
    }
    else
    {
      if (looping)             // Large track number means end the tune
        snds[currTrk].play();  // Last track playing; stop when it ends
    }
    //println(nextTrk, makeTrans, looping);
  }

  // Called by aud.pauseAll()
  void pauseAll()
  {
    for (int i = 0; i < snds.length; i++)
      snds[i].pause();
  }

  // Called by aud.closeAll()
  void closeAll()
  {
    for (int i = 0; i < snds.length; i++)
      snds[i].close();
  }
}