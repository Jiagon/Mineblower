/* PingTone class - by Al Biles
 Uses Minim UGens to implement a synthesis chain that generates
 sonar pings at a random pan location.  Implements Instrument interface
 by providing noteOn() and noteOff methods, even though the NoteOff is
 never called because when the envelope runs out, it unpatches from out.
 
 maybePing() in Audio creates a PingTone object and calls noteOn()
 to start pinging.  Main tab calls aud.maybePing()
 Note: AudioOutput object set up in Audio class
 */
class PingTone
{
  Oscil myWave;      // Sine wave oscillator for the ping sound
  Damp myDamp;       // Damp envelope for decay after quick attack
  Delay myDelay;     // Use Delay effect for echo
  Pan myPan;         // Pan it somewhere in the stereo field

  PingTone()         // Constructor creates an object for the pings
  {
    myWave = new Oscil( 1000, 0.4, Waves.SINE );  // 1000 Hz, kinda loud
    myDamp = new Damp( 0.01, 0.15, 0.9 );         // Attack, decay time, amp
    myDelay = new Delay( 0.75, 0.5, true, true ); // Delay with feedback
    myPan = new Pan(random(-1.0, 1.0));           // Random pan location
    myWave.patch(myDamp).patch(myDelay).patch(myPan); // Chain together
  }

  void noteOn()      // Called from main to start pinging
  {
    myDamp.activate();          // Turn on the envelope
    myPan.patch(aud.out);       // Patch end of chain to out to hear it
    myDamp.unpatchAfterDamp(aud.out);  // Unpatch after envelope runs out
  }

  void noteOff()     // Not needed with the Delay envelope
  {
    myDamp.unpatchAfterDamp(aud.out);
  }
}