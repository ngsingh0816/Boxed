// Objects.h

#import <Cocoa/Cocoa.h>
#import <MovieDraw/MovieDraw.h>
#include <vector>

// 1.0 / 5000.0 * 20.0
#define G_CONSTANT	0.004

#define FADING_OUT	(1 << 1)
#define FADING_IN	(1 << 2)
#define COMMAND_PAUSE (1 << 3)
#define COMMAND_RESUME (1 << 4)

extern BOOL paused;
extern unsigned int commandFlag;

// Platform attributes
typedef struct
{
	MDVector3 position;
	float speed;
	int interpolation;
} PlatformStep;

typedef struct
{
	MDObject* obj;
	std::vector<PlatformStep> steps;
	unsigned int currentStep;
	MDVector3 add;
	float count;
	float startCount;
	MDVector3 start;
} MovingPlatform;
extern std::vector<MovingPlatform> platforms;

// Cache
extern NSMutableArray* barrels;

// Camera stuff
extern MDVector3 midPoint;
extern MDVector3 lookPoint;
extern float rotateAngle;
extern float rotateZAngle;
extern float cameraHeight;;
extern BOOL customCamera;
extern float zAngle;

// Movement
extern BOOL jumping;
extern BOOL canMove;
extern float changeVel;
extern MDVector3 oldVel;
extern float gravityStrength;

// Collection
extern unsigned int boxesCollected;
extern unsigned int totalBoxes;
extern int boxCollecting;
extern float boxCollectAlpha;
extern NSMutableArray* boxes;
extern NSMutableArray* blueBoxes;
extern GLString* boxString;
extern GLString* collectedString;
extern GLString* bulletString;

// Level
extern int loadSame;
extern BOOL inMenu;
extern int loadedLevel;
extern int loadedPack;
typedef enum
{
	MD_NONE = 0,
	MD_BULLET = (1 << 1),
} MDItem;
extern int items;
extern NSMutableArray* bullets;
extern MDObject* grabObject;
extern MDVector4 grabColor;

// Switches
typedef struct
{
	MDObject* obj;
	MDCurve* midCurve;
	MDCurve* lookCurve;
	MDCurve* endMidCurve;
	MDCurve* endLookCurve;
	float cTime;
	float cCounter;
	float eTime;
	float time;	
	float counter;
	float dCounter;
	float originalScale;
	float originalTranslate;
	int animation;
	BOOL down;
	int doAction;
	BOOL hasCamera;
	BOOL hasEnd;
} Switch;
extern std::vector<Switch> switches;

// Targets
typedef struct
{
	MDObject* obj;
	int state;
	int doAction;
	BOOL changed;
	float counter;
} Target;
extern std::vector<Target> targets;

// Gravity Manipulators
typedef struct
{
	MDObject* obj;
	float power;
	int changed;
	float counter;
} Gravity;
extern std::vector<Gravity> gravities;

void PushSwitch(unsigned int z, MDObject* obj, BOOL action);
void ReleaseSwitch(unsigned int z, MDObject* obj, BOOL action);
void LoadScene();
void UpdateObjects(MDObject* obj, float depth);
void CollisionDetected(MDObject* obj1, MDObject* obj2, MDVector3 point, MDVector3 normal);
