Dialog for loading and firing a torpedo.
Used in the torpDialog object (of class HorReSeq).
The project description document has a state-transition table for the FSM that controls the Torpedo.  These lines are triggered at some of the state transitions.  You'll want to replace these placeholder lines with better stuff.

Lines are:
TorpLine0.mp3: loading torpedo
TorpLine1.mp3: firing torpedo
TorpLine2.mp3: torpedo exploded
TorpLine3.mp3: already loaded
TorpLine4.mp3: already launched
TorpLine5.mp3: one at a time
TorpLine6.mp3: all gone
TorpLine7.mp3: have to load it first

File TorpLineGains.txt contains gain levels that will be applied to the individual lines, one gain per line, corresponding to the sound files.