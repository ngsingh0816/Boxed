// Level.h

#import "Objects.h"

#define NUM_LEVELS	50

#define NUM_PACKS	3

extern const NSString* levelNames[NUM_PACKS];
extern const unsigned int levelAmounts[NUM_PACKS];

extern void (*LoadLevelFunctions[NUM_PACKS][NUM_LEVELS])();
extern void (*UpdateLevelFunctions[NUM_PACKS][NUM_LEVELS])(MDObject* obj);

void InitLevels();
