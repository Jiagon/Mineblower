/* Vertical Remixing class - by Al Biles
 Implements simple vertical remixing, with an array of sounds (tracks)
 where each track can be potted up or down independently.
 Could be used to implement a music piece, where different tracks
 are potted up or down based on game events.  Could also be used to
 implement layers of ambient sounds.
 
 Note: If the tracks need to remain synchronized (as for a tune),
 the files must all be exactly the same length and should be synched
 at the beginning, since they will all be looping in parallel.
 
 Methods:
 startAll() should be called once, likely in setup(). It starts looping
 all the tracks at once at an inaudible level.
 potUp() will pot up level of indicated track to its level set in gains
 potDn() will pot down the indicated track to an inaudible level
 duck() will pot down all tracks to an inaudible level
 allUp() will pot up all tracks to their levels set by the gains array
 */

class VertReMix
{
  AudioPlayer [] snds;    // The sounds (tracks) in to be mixed
  float [] gains;         // Gain level of each track in the snds array
  float inaudLev = -70.0; // Inaudible level
  int fadeTime = 100;     // Pot up/down in 100 ms
  //boolean ducked = true;  // Don't need a flag for being ducked

  // Constructor needs path & number of sound files
  // The dirPath should be a folder name followed by a slash followed
  // by a root file name.  For example if you have Snd0.mp3, Snd1.mp3
  // and Snd2.mp3 in the the Layers folder, you would pass in
  // "Layers/Snd" as the value of dirPath, "mp3" as the value of ext,
  // and nSnds would be 3.  In addition, you would supply a file
  // SndGains.txt with 3 lines, each containing a single number for
  // the gain level for the corresponding sound file.
  VertReMix(String dirPath, String ext, int nSnds)
  {
    snds = new AudioPlayer [nSnds];
    gains = new float [nSnds];
    String [] gainAra = loadStrings(dirPath + "Gains.txt");

    for (int i = 0; i < snds.length; i++)
    {
      String filePath = dirPath + i + "." + ext;
      snds[i] = minim.loadFile(filePath, 512);
      gains[i] = float(gainAra[i]);
      //println(filePath, leng[i]);
    }
  }
  
  // Start them all looping together at an inaudible level
  void startAll()
  {
    for (int i = 0; i < snds.length; i++)
    {
      snds[i].setGain(inaudLev);
      snds[i].loop();
    }
    //ducked = true;
  }

  // Quickly pot up the volume of indicated track to gains level
  void potUp(int trk)
  {
    float currLevel = snds[trk].getGain();
    snds[trk].shiftGain(currLevel, gains[trk], fadeTime);
    //ducked = false;
  }

  // Pot down the volume on the indicated track to inaudible level
  void potDn(int trk)
  {
    //if (! ducked)
    //{
      float currLevel = snds[trk].getGain();
      snds[trk].shiftGain(currLevel, inaudLev, fadeTime);
    //}
  }
  
  void duck()
  {
    for (int i = 0; i < snds.length; i++)
    {
      potDn(i);
    }
    //ducked = true;
  }
  
  void allUp()
  {
    for (int i = 0; i < snds.length; i++)
    {
      potUp(i);
    }
    //ducked = false;    
  }
  
  void reset()
  {
    for (int i = 0; i < snds.length; i++)
    {
      snds[i].pause();
      snds[i].rewind();
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