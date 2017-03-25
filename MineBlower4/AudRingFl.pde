/* RingFile class - by Al Biles
 Applies Ring Modulation to a sound file as an effect.  Synthesis effect
 using unit generators without implementing the Instrument interface.
 
 Methods:
 trigger() - Triggers sound from the file to play once through Ring Modulator
 setModF() - sets the modulating frequency
 setModAmp() - sets the modulating amplitude (depth)
 */

class RingFile
{
  Sampler snd;    // The sound file acts as the Carrier
  Oscil mod;      // Modulator
  float modF;     // Modulating amplitude in Hz
  float modAmp;   // Modulating amplitude (depth): range 0.0 to 4.0

  // Constructor takes path to the data file and initial values for
  // the modulation frequency and amplitude.  Sets up the ring
  // modulator to apply the modulator to the amplitude input of the
  // sound file, which acts as the carrier.
  RingFile(String path, float mF, float mA)
  {
    // Use a recorded sound as the "carrier" for ring modulation
    snd = new Sampler (path, 1, minim);  // Just need 1 stream

    // Create a sine wave Oscil for modulating the amplitude of sound file.
    // Because it's a bi-polar sine wave, the result is ring modulation
    modF = mF;                           // Assign modulation frequency
    modAmp = mA;                         // & modulation amplitude
    mod = new Oscil(modF, modAmp, Waves.SINE); // SINE minimizes distortion

    // Connect the modulator to the amplitude input of the recorded sound
    mod.patch( snd.amplitude );

    // Patch the "carrier" to the output to hear something
    snd.patch( aud.out );
  }
  
  // Sets the frequency of the modulator
  void setModF(float f)
  {
    modF = f;
    mod.frequency.setLastValue(f);
  }
  
  // Sets the amplitude of the modulator
  void setModAmp(float amp)
  {
    modAmp = amp;
    mod.amplitude.setLastValue(amp);
  }
  
  // Triggers the sound file to play once
  void trigger()
  {
    snd.trigger();
  }
}