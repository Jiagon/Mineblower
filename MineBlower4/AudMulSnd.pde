/* MultiSound class - by Al Biles
 Handles multiple versions of the same sound by maintaining an array
 of AudioPlayer objects, each of which was read from a different sound file.
 The sound files all must be in a folder that is placed in the Audio folder,
 and the file names need to have a common root followed by a digit from 0 to
 whatever (Snd0.mp3, Snd2.mp3, etc.).  See the Constructor below.
 
 Methods:
 trigSeq() - Trigger the sounds in the order they appear in the files
 trigRand() - Triggers them in white-noise random order.
 setGain() - Sets gain levels for all the sounds to the level passed in
 
 When a sound is triggered, it will play to completion before another sound
 from the set can be triggered.
 
 This class is useful for multiple variants of ambient or Foley sounds
 and could be used for a dialog sequence as well. The HorReSeq class
 is basically an elaboration on this class that supports looping and more
 sophisticated triggering control.
 */
 
class MultiSound
{
  AudioPlayer [] snds;   // Tracks read from the files
  float [] gains;        // Gain level of each track
  AudioPlayer activeSnd; // Currently playing (or last played) sound
  int curr = 0;          // Offset in array of currently playing sound

  // Constructor - Must pass in the folder name in the Audio folder
  // that contains the sound files, and how many files there are.
  // The dirPath should be a folder name followed by a slash followed
  // by a root file name.  For example if you have Snd0.mp3, Snd1.mp3
  // and Snd2.mp3 in the the Multi1 folder, you would pass in
  // "Multi1/Snd" as the value of dirPath, and nSnds would be 3.
  MultiSound(String dirPath, int nSnds)
  {
    snds = new AudioPlayer [nSnds];
    gains = new float [nSnds];
    String [] gainAra = loadStrings(dirPath + "Gains.txt");

    for (int i = 0; i < snds.length; i++)
    {
      String filePath = dirPath + i + ".mp3";
      //println(filePath);
      snds[i] = minim.loadFile(filePath, 512);
      gains[i] = float(gainAra[i]);
      snds[i].setGain(gains[i]);
    }
  }

  // Change the gain for all the sounds by gainChg - Legacy
  void setGain(float gain)
  {
    for (int i = 0; i < snds.length; i++)
      snds[i].setGain(gain);
  }

  // Trigger sounds in the sequence they were read, with wraparound
  // Parameter x is x coordinate where sound should localize
  // (width * 0.5 for center)
  void trigSeq(float x)
  {
    // Make sure there's not a sound from the set playing already
    if (activeSnd == null || ! activeSnd.isPlaying())
    {
      activeSnd = snds[curr];
      activeSnd.rewind();
      activeSnd.setPan(map(x, 0, width, -1.0, 1.0));
      activeSnd.play();
      curr = (curr + 1) % snds.length;  // Bump/wrap curr for next time
    }
  }

  // Trigger the sounds in a random sequence
  // Parameter x is x coordinate where sound should localize
  // (width * 0.5 for center)
  void trigRand(float x)
  {
    // Make sure there's not a sound from the set playing already
    if (activeSnd == null || ! activeSnd.isPlaying())
    {
      int which = (int) random(snds.length);
      activeSnd = snds[which];
      activeSnd.rewind();
      float pan = constrain(map(x, 0, width, -1.0, 1.0), -1.0, 1.0);
      activeSnd.setPan(pan);
      activeSnd.play();
      //println("Multi", which, x, pan);
    }
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