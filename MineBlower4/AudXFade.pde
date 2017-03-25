/* Simple crossfade class - by Al Biles
 Implements a simple crossfade between tracks stored in an array
 of AudioPlayers.  Actually a simple variant on the HorReSeq class
 that immediately does a crossfade from the currently playing track
 to the new track by fading out the current track while starting
 and fading in the new track.  Each track is looped when it is playing.
 The duck() and restore() methods can be used to fade out entirely
 and fade back in while remaining on the current track.
 
 Methods:
 xFade() - Fades out the currently playing track (if any) while fading in
    the indicated track.  If the current track is ducked, changes the
    current track to the new one, but leaves it ducked.
 duck() - Quickly ducks (fades out the level of) the currently playing track
    without stopping it.
 restore() - Quickly fades the level of the currently ducked track to
    its level in the gains array.
 */
class CrossFade
{
  AudioPlayer [] snds;   // The sounds (tracks) in the sequence
  float [] gains;        // Gain levels for each track (0.0 => play as is)
  float [] leng;         // Length of each track in ms (not used currently)
  int currTrk = -1;      // Offset in array of currently playing sound
  int nextTrk = -1;      // Offset of next track to play (-1 => none)
  int fadeTime = 500;    // Crossfades will take this many milliseconds
  float silent = -70.0;  // Inaudible gain level
  boolean ducked = false;

  // Constructor needs path & number of sound files
  // The dirPath should be a folder name followed by a slash followed
  // by a root file name.  For example if you have Tune0.mp3, Tune1.mp3
  // and Tune2.mp3 in the BackMus folder, you would pass in
  // "BackMus/Tune" as the value of dirPath, and nSnds would be 3.
  // Also expects a Gain file containing gain levels for the sound files,
  // one per line.  These will be used to set the max gain for each file
  // when it is faded in.  The Gain file in this example would be named
  // TuneGain.txt, in the BackMus folder.
  CrossFade(String dirPath, int nSnds)
  {
    snds = new AudioPlayer [nSnds];
    gains = new float [nSnds];
    leng = new float [nSnds];

    // Text file the gain values, one per line in order of sound files
    String [] gainAra = loadStrings(dirPath + "Gains.txt");
    
    for (int i = 0; i < snds.length; i++)
    {
      String filePath = dirPath + i + ".mp3";
      snds[i] = minim.loadFile(filePath, 512);
      gains[i] = float(gainAra[i]);            // Convert to gain level
      leng[i] = snds[i].length();
      //println(filePath, leng[i], gains[i]);
    }
  }
  
  // Crossfade to track trk
  // Ignores trk < 0; treats trk >= number of tracks as end the tune
  void xFade(int trk)
  {
    if (trk < 0)
    {
      return;               // Can't crossfade to a negative track number
    }
    else if (trk < snds.length)
    {
      if (currTrk < 0)
      {
        currTrk = trk;          // First track to play, start the tune
        snds[currTrk].setGain(gains[currTrk]);  // at full volume
        snds[currTrk].rewind();
        snds[currTrk].loop();
        ducked = false;
      }
      else
      {
        if (ducked)
        {
          snds[currTrk].play();          // Change current track to run out          
          currTrk = trk;                 // Set up next track to fade in
          snds[currTrk].setGain(silent); // Make it silent
          snds[currTrk].rewind();        // Cue it up
          snds[currTrk].loop();          // Start it playing silently
        }
        else
        {
          snds[currTrk].play();          // Change current track to run out
          float currLevel = snds[currTrk].getGain();    // Fade it out
          snds[currTrk].shiftGain(currLevel, silent, fadeTime);
          currTrk = trk;                 // Set up next track to fade in
          snds[currTrk].setGain(silent); // Make it silent
          snds[currTrk].rewind();        // Cue it up
          snds[currTrk].loop();          // Start it playing
          snds[trk].shiftGain(silent, gains[trk], fadeTime);  // Fade it in
        }
      }
    }
    else // trk >= number of tracks
    {
      // Large track number means end the tune
      if (snds[currTrk].isLooping() && ! ducked)
        snds[currTrk].play();         // Last track playing; stop when it ends
    }
  }
  
  // Duck currently playing track by setting its gain to inaudible
  void duck()
  {
    if (currTrk >= 0 && ! ducked)
    {
      float currLevel = snds[currTrk].getGain();    // Fade out current track
      snds[currTrk].shiftGain(currLevel, silent, fadeTime);
      ducked = true;
    }
  }
  
  // Restore previously ducked track to its intended level
  void restore()
  {
    if (ducked)
    {
      snds[currTrk].shiftGain(silent, gains[currTrk], fadeTime);  // Fade it back
      ducked = false;
    }
  }
}