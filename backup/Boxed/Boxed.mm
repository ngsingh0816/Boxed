// Boxed.mm

#import <MovieDraw/MovieDraw.h>

float timer = 0;

// Camera stuff
MDVector3 midPoint;
MDVector3 lookPoint;
float rotateAngle = M_PI;
float cameraHeight = 0;

// Movement
BOOL jumping = FALSE;

// Collection
unsigned int boxesCollected = 0;
unsigned int totalBoxes = 0;
int boxCollecting = 0;
float boxCollectAlpha = 0;
BOOL boxAlready = FALSE;
NSMutableArray* boxes = nil;

// Level
BOOL loadSame = FALSE;
BOOL inMenu = TRUE;

// Other
#define FADING_OUT	(1 << 1)
#define FADING_IN	(1 << 2)
unsigned int commandFlag = 0;

void SceneLoaded(NSString* scene)
{
	boxesCollected = 0;
	totalBoxes = 0;
	if (boxes)
		[ boxes release ];
	boxes = [ [ NSMutableArray alloc ] init ];
	NSArray* objects = MDObjects();
	for (unsigned long z = 0; z < [ objects count ]; z++)
	{
		if ([ [ [ [ objects objectAtIndex:z ] instance ] name ] isEqualToString:@"Box" ])
		{
			totalBoxes++;
			[ boxes addObject:[ objects objectAtIndex:z ] ];
		}
	}
	rotateAngle = M_PI;
	jumping = FALSE;
	
	inMenu = ![ scene hasPrefix:@"Level" ];
}

void CustomDraw()
{
	if (!inMenu)
	{
		[ MDGLView() writeString:[ NSString stringWithFormat:@"%i / %i", boxesCollected, totalBoxes ] textColor:[ NSColor whiteColor ]
			boxColor:[ NSColor clearColor ] borderColor:[ NSColor clearColor ] atLocation:NSMakePoint(0, -15) withSize:15
			withFontName:@"Zapfino" rotation:0 center:NSLeftTextAlignment ];
		
		if (boxCollecting != 0)
		{
			[ MDGLView() writeString:@"Box Collected" textColor:[ NSColor colorWithCalibratedRed:1.0 green:1.0 blue:1.0 alpha:(boxAlready ? 1 : boxCollectAlpha) ]
				boxColor:[ NSColor clearColor ] borderColor:[ NSColor clearColor ] atLocation:NSMakePoint(resolution.width / 2, resolution.height - 100) withSize:30
				withFontName:@"Zapfino" rotation:0 center:NSCenterTextAlignment ];
			if (boxCollecting == 1)
			{
				boxCollectAlpha += MDElapsedTime() / 1000.0;
				if (boxCollectAlpha > 1)
				{
					boxCollectAlpha = 1;
					boxCollecting = 2;
					boxAlready = FALSE;
				}
			}
			else if (boxCollecting == 2)
			{
				boxCollectAlpha -= MDElapsedTime() / 1000.0;
				if (boxCollectAlpha < 0)
				{
					boxCollectAlpha = 0;
					boxCollecting = 0;
				}
			}
		}
	}
}

// Init - this is what's called when the application is started. If NO is returned, the app will exit.
BOOL init()
{
	MDSetGravity(MDVector3Create(0, -25, 0));
	MDSetLoadSceneFunction(SceneLoaded);
	MDSetCustomDrawFunction(CustomDraw);
	
	MDControlView* controlView = [ [ MDControlView alloc ] initWithFrame:MakeRect(0, 0, resolution.width, resolution.height) 
						background:[ NSColor colorWithCalibratedRed:0.0 green:0.0 blue:0.0 alpha:1.0 ] ];
	[ controlView setIdentity:@"Black Fade" ];
	[ controlView release ];
	commandFlag |= FADING_IN;
	
	return YES;
}

// Draw - this is what's called everytime before drawing 60 times a second.
void draw()
{
	NSString* sceneName = MDLoadedScene();
	if ([ sceneName isEqualToString:@"Menu" ])
	{
		// Rotate camera and light around
		MDCamera* camera = MDOtherObjectNamed(@"Camera");
		MDLight* light = MDOtherObjectNamed(@"Camera Light");
		MDCurve* cameraCurve = MDOtherObjectNamed(@"Camera Curve");
		MDCurve* lightCurve = MDOtherObjectNamed(@"Light Circle");
		
		[ camera setMidPoint:[ cameraCurve interpolate:timer ] ];
		[ light setPosition:[ lightCurve interpolate:timer ] ];
		
		MDSetCamera(camera);
		
		// Update particle colors
		static MDVector3 startColors[] = { { 1.0, 0.5, 0.0 }, { 0.5, 0.0, 0.5 }, { 0.5, 1.0, 1.0 }, { 0.5, 1.0, 0.0 }, };
		static MDVector3 endColors[] = { { 1.0, 0.0, 0.0 }, { 1.0, 0.0, 1.0 }, { 0.0, 1.0, 1.0 }, { 0.0, 1.0, 0.0 }, };
		const int numberOfColors = 4;
		static unsigned int colorIndex = 1;
		int oldIndex = colorIndex - 1;
		if (oldIndex < 0)
			oldIndex += numberOfColors;
		
		MDParticleEngine* ffl = MDOtherObjectNamed(@"Fire Front Left");
		MDParticleEngine* ffr = MDOtherObjectNamed(@"Fire Front Right");
		MDParticleEngine* fbl = MDOtherObjectNamed(@"Fire Back Left");
		MDParticleEngine* fbr = MDOtherObjectNamed(@"Fire Back Right");
		
		MDVector4 sColor = MDVector4Create((startColors[colorIndex] - startColors[oldIndex]) * timer + startColors[oldIndex], ffl.startColor.w);
		MDVector4 eColor = MDVector4Create((endColors[colorIndex] - endColors[oldIndex]) * timer + endColors[oldIndex], ffl.endColor.w);		
		[ ffl setStartColor:sColor ];
		[ ffr setStartColor:sColor ];
		[ fbl setStartColor:sColor ];
		[ fbr setStartColor:sColor ];
		[ ffl setEndColor:eColor ];
		[ ffr setEndColor:eColor ];
		[ fbl setEndColor:eColor ];
		[ fbr setEndColor:eColor ];
		
		timer += MDElapsedTime() / 1000.0 / 10.0;
		if (timer > 1)
		{
			timer -= 1;
			colorIndex++;
			if (colorIndex >= numberOfColors)
				colorIndex -= numberOfColors;
		}
		
		if (commandFlag & FADING_IN)
		{
			MDControlView* controlView = ViewForIdentity(@"Black Fade");
			float newAlpha = [ [ controlView backgroundAtIndex:0 ] alphaComponent ] - (MDElapsedTime() / 1000.0);
			[ controlView setAlpha:(newAlpha < 0) ? 0 : newAlpha ];
			[ controlView setFrame:MakeRect(0, 0, resolution.width, resolution.height) ];
			if (newAlpha < 0)
			{
				newAlpha = 0;
				commandFlag &= ~FADING_IN;
			}
		}
	}
	else		// Ingame
	{
		MDObject* obj = MDObjectWithName(@"Player", @"Player");
		
		// Setup the camera
		midPoint = [ obj midPoint ];
		// Check if out of bounds
		if (midPoint.y < -100)
		{
			commandFlag |= FADING_OUT;
			loadSame = TRUE;
		}
		const float depth = 5;
		lookPoint = MDVector3Create(midPoint.x + depth * sin(rotateAngle), midPoint.y + cameraHeight, midPoint.z + depth * cos(rotateAngle));
		
		MDSetCamera(midPoint, lookPoint, MDVector3Create(0, 0, 0), 0, TRUE);
		
		// Limit speed
		MDVector3 vel = MDLinearVelocity(obj);
		const float decay = pow(0.9, 60.0 * MDElapsedTime() / 1000.0);
		vel.x *= decay; vel.z *= decay;
		static BOOL pastTwo = FALSE;
		if (vel.y < -0.05 && jumping && !pastTwo)
			pastTwo = TRUE;
		if (vel.y > -0.05 && jumping && pastTwo)
		{
			pastTwo = FALSE;
			jumping = FALSE;
			vel.y = 0;
		}
		MDSetLinearVelocity(obj, vel);
		cameraHeight *= 0.95;
		
		// Test if over box
		for (unsigned long z = 0; z < [ boxes count ]; z++)
		{
			MDObject* obj = [ boxes objectAtIndex:z ];
			MDVector3 mid = [ obj midPoint ];
			if (MDVector3Distance(mid, midPoint) < 1.5)
			{
				if (boxCollecting == 0)
				{
					boxCollecting = 1;
					boxCollectAlpha = 0;
				}
				else
					boxAlready = TRUE;
				boxesCollected++;
				[ obj setShouldDraw:NO ];
				[ obj setTranslateX:-100000 ];
				[ obj setTranslateY:-100000 ];
				[ obj setTranslateZ:-100000 ];
				[ boxes removeObjectAtIndex:z ];
				z--;
				
				if (boxesCollected == totalBoxes)
					commandFlag |= FADING_OUT;
			}
		}
	}
	
	if (commandFlag & FADING_OUT)
	{
		MDControlView* controlView = ViewForIdentity(@"Black Fade");
		float newAlpha = [ [ controlView backgroundAtIndex:0 ] alphaComponent ] + (MDElapsedTime() / 1000.0);
		[ controlView setAlpha:(newAlpha > 1) ? 1 : newAlpha ];
		[ controlView setFrame:MakeRect(0, 0, resolution.width, resolution.height) ];
		if (newAlpha > 1)
		{
			newAlpha = 1;
			commandFlag &= ~FADING_OUT;
			commandFlag |= FADING_IN;
			
			// Load Next Level
			unsigned int currentLevel = [ [ MDLoadedScene() substringFromIndex:6 ] intValue ];
			MDLoadScene([ NSString stringWithFormat:@"Level %i", (loadSame ? currentLevel : (currentLevel + 1)) ]);
			loadSame = FALSE;
		}
	}
	else if (commandFlag & FADING_IN)
	{
		MDControlView* controlView = ViewForIdentity(@"Black Fade");
		float newAlpha = [ [ controlView backgroundAtIndex:0 ] alphaComponent ] - (MDElapsedTime() / 1000.0);
		[ controlView setAlpha:(newAlpha < 0) ? 0 : newAlpha ];
		[ controlView setFrame:MakeRect(0, 0, resolution.width, resolution.height) ];
		if (newAlpha < 0)
		{
			newAlpha = 0;
			commandFlag &= ~FADING_IN;
		}
	}
}

// Key Down - called when a key is down (for typing)
void KeyDown(NSEvent* event)
{
}

// Process Keys - called 60 times a second for smooth key calling
void ProcessKeys(NSArray* keys)
{
	float speed = 240 * MDElapsedTime() / 1000.0;
	for (unsigned long z = 0; z < [ keys count ]; z++)
	{
		unsigned short key = [ [ keys objectAtIndex:z ] unsignedShortValue ];
		if (key == NSUpArrowFunctionKey)
		{
			MDObject* obj = MDObjectWithName(@"Player", @"Player");
			MDVector3 vel = MDLinearVelocity(obj);
			vel += MDVector3Create(sin(rotateAngle) * speed, 0, cos(rotateAngle) * speed);
			MDSetLinearVelocity(obj, vel);
		}
		else if (key == NSDownArrowFunctionKey)
		{
			MDObject* obj = MDObjectWithName(@"Player", @"Player");
			MDVector3 vel = MDLinearVelocity(obj);
			vel -= MDVector3Create(speed * sin(rotateAngle), 0, speed * cos(rotateAngle));
			MDSetLinearVelocity(obj, vel);
		}
		else if (key == NSLeftArrowFunctionKey)
		{
			rotateAngle += 3.0 * MDElapsedTime() / 1000.0;
		}
		else if (key == NSRightArrowFunctionKey)
		{
			rotateAngle -= 3.0 * MDElapsedTime() / 1000.0;
		}
		else if (key == 'w' || key == 'W')
			cameraHeight += 12 * MDElapsedTime() / 1000.0;
		else if (key == 's' || key == 'S')
			cameraHeight -= 12 * MDElapsedTime() / 1000.0;
		else if (key == ' ')
		{
			MDObject* obj = MDObjectWithName(@"Player", @"Player");
			MDVector3 vel = MDLinearVelocity(obj);
			
			if (!jumping)
			{
				vel.y = 12;
				jumping = TRUE;
			}
			
			MDSetLinearVelocity(obj, vel);
		}
	}
}

// Mouse Down - called when the mouse is down.
void MouseDown(NSEvent* event)
{
}

// Mouse Up - called when the mouse is released.
void MouseUp(NSEvent* event)
{
}

// Mouse Dragged - called when the mouse is dragged.
void MouseDragged(NSEvent* event)
{
}

// Mouse Moved - called when the mouse is moved.
void MouseMoved(NSEvent* event)
{
}

// Dealloc - called when the app is exited
void Dealloc()
{
	if (boxes)
	{
		[ boxes release ];
		boxes = nil;
	}
	MDRemoveView(ViewForIdentity(@"Black Fade"));
}

