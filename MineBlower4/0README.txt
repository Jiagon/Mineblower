MineBlower submarine game for IGME-571/671, by Al Biles

There are 18 classes, organized in separate source files. 7 of the classes (.pde files) are audio-related.  The Audio.pde source file contains the main Audio class.  The tabs beginning with "Aud" contain code for specialized audio classes (class name is same as the file name without "Aud").

The Audio folder contains all the audio assets, which are loaded either into the Audio object itself (for simple sounds) or into folders for objects of the specialized classes.

The Graphics folder contains all the graphics assets (sprites and animation frames), all of which are loaded into the Graphics object.

MineBlower uses the Minim class for all audio functionality and has been tested successfully in Version 3.2.3 of Processing.