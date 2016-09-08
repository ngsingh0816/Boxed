// Boxed.mm

#import <MovieDraw/MovieDraw.h>
#import "Level.h"
#import "Menu.h"

float timer = 0;

// Other
unsigned int commandFlag = 0;
float pauseTimer = 0;
CGDirectDisplayID cgDisplay;
MDObject* grabObject = nil;
MDVector4 grabColor = MDVector4Create(1, 1, 1, 1);
MDVector3 grabGravity = MDVector3Create(0, 0, 0);
MDVector3 prevGrabGravity = MDVector3Create(0, -gravityStrength, 0);
MDRect grabBox;
float grabCounter = 0;
float grabRot = 0;
float jumpStrength = 12;
unsigned long mouseHidden = 0;
BOOL firstFrame = FALSE;
unsigned int numBullets = 0;

void RightMouseDown(NSEvent* event);
void RightMouseDragged(NSEvent* event);
void Reshape(NSSize size);
void UpdateMouse(float dx, float dy);

void SceneLoaded(NSString* scene)
{
	// Set gravity
	MDSetGravity(MDVector3Create(0, -gravityStrength, 0));
	zAngle = 1;
	rotateZAngle = 0;
	customCamera = FALSE;
	cameraHeight = 0;
	rotateAngle = 0;
	canMove = TRUE;
	
	boxesCollected = 0;
	totalBoxes = 0;
	if (boxes)
		[ boxes release ];
	boxes = [ [ NSMutableArray alloc ] init ];
	if (blueBoxes)
		[ blueBoxes release ];
	blueBoxes = [ [ NSMutableArray alloc ] init ];
	NSArray* objects = MDObjects();
	for (unsigned long z = 0; z < [ objects count ]; z++)
	{
		if ([ [ [ [ objects objectAtIndex:z ] instance ] name ] isEqualToString:@"Box" ] || [ [ [ [ objects objectAtIndex:z ] instance ] name ] isEqualToString:@"Blue Box" ])
		{
			totalBoxes++;
			[ boxes addObject:[ objects objectAtIndex:z ] ];
			if ([ [ [ [ objects objectAtIndex:z ] instance ] name ] isEqualToString:@"Blue Box" ])
			{
				MDSetObjectGravity([ objects objectAtIndex:z ], MDVector3Create(0, 0, 0));
				[ blueBoxes addObject:[ objects objectAtIndex:z ] ];
			}
		}
	}
	rotateAngle = M_PI;
	jumping = FALSE;
	
	if (grabObject)
		grabObject = nil;
	
	inMenu = [ scene isEqualToString:@"Menu" ];
	// Find level pack
	if (!inMenu)
	{
		HideMenu();
		NSMutableString* string = [ [ NSMutableString alloc ] init ];
		for (long z = [ scene length ] - 1; z >= 0; z--)
		{
			unsigned char cmd = [ scene characterAtIndex:z ];
			if (cmd == ' ')
				break;
			[ string insertString:[ NSString stringWithFormat:@"%c", cmd ] atIndex:0 ];
		}
		
		loadedPack = -1;
		loadedLevel = [ string intValue ];
		for (unsigned long z = 0; z < NUM_PACKS; z++)
		{
			if ([ [ scene substringToIndex:[ scene length ] - [ string length ] - 1 ] isEqualToString:levelNames[z] ])
			{
				loadedPack = z;
				break;
			}
		}
	}
	else
	{
		//if (!ViewForIdentity(@"Main Menu View"))
		{
			DeallocMenu();
			DeallocBlack();
			InitMenu();
			InitBlack();
			[ (MDControlView*)ViewForIdentity(@"Black Fade") setAlpha:1 ];
		}
		loadedPack = -1;
		loadedLevel = -1;
		ShowMenu();
	}
	[ ViewForIdentity(@"Aim View") setVisible:!inMenu ];
	//[ ViewForIdentity(@"Bullet View") setVisible:NO ];
	
	if (collectedString)
		[ collectedString release ];
	collectedString = [ MDGLView() createString:@"Box Collected" textColor:[ NSColor whiteColor ] withSize:30
								   withFontName:@"Zapfino" ];
	if (boxString)
		[ boxString release ];
	boxString = [ MDGLView() createString:[ NSString stringWithFormat:@"%i / %i", boxesCollected, totalBoxes ]
								textColor:[ NSColor whiteColor ] withSize:15 withFontName:@"Zapfino" ];
	if (bulletString)
	{
		[ bulletString release ];
		bulletString = nil;
	}
	
	LoadScene();
	
	// Check which items there are
	items = MD_NONE;
	if (MDObjectWithName(@"Bullet", @"Bullet"))
	{
		//[ ViewForIdentity(@"Bullet View") setVisible:YES ];
		bulletString = [ MDGLView() createString:@"0 / 10" textColor:[ NSColor whiteColor ] withSize:15 withFontName:@"Zapfino" ];
		
		items |= MD_BULLET;
		MDObjectDisable(MDObjectWithName(@"Bullet", @"Bullet"));
	}
	if (bullets)
		[ bullets release ];
	bullets = [ [ NSMutableArray alloc ] init ];
	
	if (loadedLevel >= 0 && loadedPack >= 0)
		LoadLevelFunctions[loadedPack][loadedLevel]();
	
	UpdateMouse(0, 0);
}

void CustomDraw()
{
	if (!inMenu && !paused)
	{
		[ MDGLView() drawString:boxString atLocation:NSMakePoint(0, -15) rotation:0 center:NO ];
		
		if (boxCollecting != 0)
		{
			[ collectedString setTextColor:[ NSColor colorWithCalibratedRed:1.0 green:1.0 blue:1.0 alpha:boxCollectAlpha ] ];
			[ MDGLView() drawString:collectedString atLocation:NSMakePoint(resolution.width / 2, resolution.height - 100) rotation:0 center:YES ];
			if (boxCollecting == 1)
			{
				boxCollectAlpha += MDElapsedTime() / 1000.0;
				if (boxCollectAlpha > 1)
				{
					boxCollectAlpha = 1;
					boxCollecting = 2;
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
		
		if (items & MD_BULLET)
			[ MDGLView() drawString:bulletString atLocation:NSMakePoint(0, resolution.height - 55) rotation:0 center:NO ];
	}
}

// Init - this is what's called when the application is started. If NO is returned, the app will exit.
BOOL init()
{
	// Check if the sandbox folder is there
	NSString* path = [ NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0 ];
	BOOL dir = FALSE;
	BOOL exists = [ [ NSFileManager defaultManager ] fileExistsAtPath:path isDirectory:&dir ];
	if (!dir)
	{
		[ [ NSFileManager defaultManager ] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil ];
	}
	ApplyVideoOptions();
	
	return TRUE;
}

BOOL initGL()
{
	// Just to apply the video options
	init();
	[ MDGLView() reshape ];
	
	// Get main screen
	cgDisplay = CGMainDisplayID();
	
	MDSetRightMouseDown(RightMouseDown);
	MDSetRightMouseDragged(RightMouseDragged);
	MDSetLoadSceneFunction(SceneLoaded);
	MDSetCustomDrawFunction(CustomDraw);
	MDSetReshapeFunction(Reshape);
	MDSetCollisionFunction(CollisionDetected);
	
	// Setup GUI
	InitMenu();
	InitBlack();
	
	commandFlag |= FADING_IN;
	
	InitLevels();
	
	return YES;
}

void Reshape(NSSize size)
{
	/*ResizeBlack();
	ResizePauseMenu();
	ResizeMenu();*/
}

void CollectBox(MDObject* obj)
{
	if (boxCollecting == 0)
	{
		boxCollecting = 1;
		boxCollectAlpha = 0;
	}
	else if (boxCollecting == 2)
		boxCollecting = 1;
	boxesCollected++;
	[ obj setShouldDraw:NO ];
	[ obj setTranslateX:-100000 ];
	[ obj setTranslateY:-100000 ];
	[ obj setTranslateZ:-100000 ];
	MDObjectDisable(obj);
	[ boxes removeObject:obj ];
	
	// Update count
	if (boxString)
		[ boxString release ];
	boxString = [ MDGLView() createString:[ NSString stringWithFormat:@"%i / %i", boxesCollected, totalBoxes ]
								textColor:[ NSColor whiteColor ] withSize:15 withFontName:@"Zapfino" ];
	
	if (boxesCollected == totalBoxes)
	{
		commandFlag |= FADING_OUT;
		if (grabObject)
			RightMouseDown(nil);
		
		FinishLevel(loadedPack, loadedLevel);
	}
}

// Draw - this is what's called everytime before drawing 60 times a second.
void draw()
{
	UpdateMenu();
	
	NSString* sceneName = MDLoadedScene();
	if (inMenu)
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
			float newAlpha = [ [ controlView background ] alphaComponent ] - (MDElapsedTime() / 1000.0);
			[ controlView setAlpha:(newAlpha < 0) ? 0 : newAlpha ];
			[ controlView setFrame:MakeRect(0, 0, resolution.width, resolution.height) ];
			if (newAlpha < 0)
			{
				newAlpha = 0;
				commandFlag &= ~FADING_IN;
			}
		}
	}
	else if (!paused)	// Ingame
	{
		MDObject* obj = MDObjectWithName(@"Player", @"Player");
		
		// Setup the camera
		const float depth = 5;
		if (!customCamera)
		{
			midPoint = [ obj midPoint ];
			// Check if out of bounds
			if (midPoint.y < -100)
			{
				commandFlag |= FADING_OUT;
				loadSame = TRUE;
			}
			lookPoint = MDVector3Create(midPoint.x + depth * sin(rotateAngle), midPoint.y + cameraHeight, midPoint.z + depth * cos(rotateAngle));
			MDVector3 camHeight = MDVector3Create(sin(rotateZAngle / 180 * M_PI), cos(rotateZAngle / 180 * M_PI), 0);
			MDSetCamera(midPoint + camHeight, lookPoint + camHeight, MDVector3Create(0, 0, 0), rotateZAngle, TRUE);
		}
		else
			MDSetCamera(midPoint, lookPoint, MDVector3Create(0, 0, 0), rotateZAngle, TRUE);
		
		// Limit speed
		MDVector3 vel = MDLinearVelocity(obj);
		changeVel = vel.y - oldVel.y;
		const float decay = pow(0.9, 60.0 * MDElapsedTime() / 1000.0);
		vel.x *= decay; vel.z *= decay;
		static BOOL pastTwo = FALSE;
		if (zAngle == 1)
		{
			if (vel.y < -0.05 && jumping && !pastTwo)
				pastTwo = TRUE;
			if (vel.y > -0.05 && jumping && pastTwo)
			{
				pastTwo = FALSE;
				jumping = FALSE;
				vel.y = 0;
			}
		}
		else
		{
			if (vel.y > 0.05 && jumping && !pastTwo)
				pastTwo = TRUE;
			if (vel.y < 0.05 && jumping && pastTwo)
			{
				pastTwo = FALSE;
				jumping = FALSE;
				vel.y = 0;
			}
		}
		MDSetLinearVelocity(obj, vel);
		oldVel = vel;
		// Only limit camera height if keyboard control scheme
		//cameraHeight *= 0.95;
		
		// Test if over box
		for (unsigned long z = 0; z < [ boxes count ]; z++)
		{
			MDObject* obj = [ boxes objectAtIndex:z ];
			MDVector3 mid = [ obj midPoint ];
			if (MDVector3Distance(mid, midPoint) < 1 + [ obj scaleX ])
			{
				CollectBox(obj);
				z--;
			}
		}
		
		if (grabObject)
		{
			MDObject* obj = MDObjectWithName(@"Player", @"Player");
			MDVector3 normal = MDVector3Normalize(lookPoint - midPoint);
			MDSetAngularVelocity(grabObject, MDVector3Create(0, 0, 0));
			if (grabCounter < 1)
			{
				grabCounter += MDElapsedTime() / 1000.0 * 2;
				float rot = (1 - MDTweenEaseInOutQuadratic(grabCounter)) * grabRot;
				MDSetObjectRotation(grabObject, [ grabObject rotateAxis ], rot);
			}
			else
				MDSetObjectRotation(grabObject, MDVector3Create(0, 0, 0), 0);
			
			// So we can have collisions / lag
			MDVector3 pos = [ obj midPoint ] + MDVector3Create(0, zAngle * fabs(grabBox.height) / 2, 0) + normal * fabs(grabBox.depth) * 2;
			MDSetLinearVelocity(grabObject, (pos - [ grabObject midPoint ]) * 20);
		}
		
		// Manage bullets
		BOOL calcAlpha = FALSE;
		for (unsigned long z = 0; z < [ bullets count ]; z++)
		{
			MDObject* bullet = [ bullets objectAtIndex:z ];
			MDVector3 vel = MDLinearVelocity(bullet);
			float mag = MDVector3Magnitude(vel);
			if (mag < 10)
			{
				// Probably should animate a fade out
				[ bullet setColorMultiplier:MDVector4Create(1, 1, 1, (mag - 5) / 5.0) ];
				calcAlpha = TRUE;
			}
			if (mag < 5)
			{
				MDRemoveObject(bullet);
				[ bullets removeObject:bullet ];
				z--;
			}
		}
		if (calcAlpha)
			[ MDGLView() calculateAlphaObjects ];
		
		if ([ bullets count ] != numBullets)
		{
			if (bulletString)
				[ bulletString release ];
			bulletString = [ MDGLView() createString:[ NSString stringWithFormat:@"%i / 10", [ bullets count ] ] textColor:[ NSColor whiteColor ] withSize:15 withFontName:@"Zapfino" ];
			numBullets = [ bullets count ];
		}
		
		UpdateObjects(obj, depth);
		
		UpdateLevelFunctions[loadedPack][loadedLevel](obj);
	}
	
	if (commandFlag & FADING_OUT)
	{
		MDControlView* controlView = ViewForIdentity(@"Black Fade");
		float newAlpha = [ [ controlView background ] alphaComponent ] + (MDElapsedTime() / 1000.0);
		[ controlView setAlpha:(newAlpha > 1) ? 1 : newAlpha ];
		[ controlView setFrame:MakeRect(0, 0, resolution.width, resolution.height) ];
		if (newAlpha > 1)
		{
			newAlpha = 1;
			commandFlag &= ~FADING_OUT;
			commandFlag |= FADING_IN;
			firstFrame = TRUE;
			
			boxCollecting = 0;
			boxCollectAlpha = 0;
			// Load Next Level
			if (loadedPack == -2)
			{
				loadedPack = -1;
				loadedLevel = 0;
				MDLoadScene(@"Menu");
			}
			else
			{
				NSString* name = nil;
				if (loadedPack == -1)
				{
					name = levelNames[0];
					loadedPack = 0;
					loadedLevel = 0;
				}
				else if (loadedPack < NUM_PACKS)
					name = levelNames[loadedPack];
				
				if (!loadSame && loadedLevel + 1 > levelAmounts[loadedPack])
				{
					loadedPack++;
					if (loadedPack >= NUM_PACKS)
					{
						loadedPack = -1;
						loadedLevel = 0;
						MDLoadScene(@"Menu");
					}
					else
					{
						name = levelNames[loadedPack];
						loadedLevel = 0;
						MDLoadScene([ NSString stringWithFormat:@"%@ %i", name, loadedLevel + 1 ]);
					}
				}
				else
				{
					MDLoadScene([ NSString stringWithFormat:@"%@ %i", name, (loadSame ? loadedLevel : (loadedLevel + 1)) ]);
					loadSame = FALSE;
				}
			}
		}
	}
	else if (commandFlag & FADING_IN && !inMenu)
	{
		if (firstFrame)
			firstFrame = FALSE;
		else
		{
			MDControlView* controlView = ViewForIdentity(@"Black Fade");
			float newAlpha = [ [ controlView background ] alphaComponent ] - (MDElapsedTime() / 1000.0);
			[ controlView setAlpha:(newAlpha < 0) ? 0 : newAlpha ];
			[ controlView setFrame:MakeRect(0, 0, resolution.width, resolution.height) ];
			if (newAlpha < 0)
			{
				newAlpha = 0;
				commandFlag &= ~FADING_IN;
			}
		}
	}
	
	if (commandFlag & COMMAND_PAUSE)
	{
		MDControlView* controlView = ViewForIdentity(@"Black Fade 2");
		float newAlpha = MDTweenEaseInOutQuadratic(pauseTimer * 2) / 2;
		[ controlView setAlpha:(newAlpha > 0.5) ? 0.5 : newAlpha ];
		[ controlView setFrame:MakeRect(0, 0, resolution.width, resolution.height) ];
		
		MDControlView* pauseView = ViewForIdentity(@"Pause View");
		float newY = MDTweenEaseOutQuadratic(pauseTimer * 2) * resolution.height - resolution.height * 3 / 4;
		[ pauseView setFrame:MakeRect(resolution.width / 8, newY, resolution.width / 4 * 3, resolution.height / 2) ];
		
		pauseTimer += MDElapsedTime() / 1000.0;
		if (pauseTimer > 0.5)
		{
			[ controlView setAlpha:0.5 ];
			commandFlag &= ~COMMAND_PAUSE;
			pauseTimer = 0;
		}
	}
	else if (commandFlag & COMMAND_RESUME)
	{
		MDControlView* controlView = ViewForIdentity(@"Black Fade 2");
		float newAlpha = (1 - MDTweenEaseInOutQuadratic(pauseTimer * 2)) / 2;
		[ controlView setAlpha:(newAlpha > 0.5) ? 0.5 : newAlpha ];
		[ controlView setFrame:MakeRect(0, 0, resolution.width, resolution.height) ];
		
		MDControlView* pauseView = ViewForIdentity(@"Pause View");
		float newY = MDTweenEaseOutQuadratic(pauseTimer * 2) * resolution.height + resolution.height / 4;
		[ pauseView setFrame:MakeRect(resolution.width / 8, newY, resolution.width / 4 * 3, resolution.height / 2) ];
		
		pauseTimer += MDElapsedTime() / 1000.0;
		if (pauseTimer > 0.5)
		{
			[ controlView setAlpha:0 ];
			commandFlag &= ~COMMAND_RESUME;
			pauseTimer = 0;
			MDSetDefaultPhysics(TRUE);
			paused = FALSE;
			// Hide mouse
			UpdateMouse(0, 0);
			[ pauseView setVisible:NO ];
			DeallocPauseMenu();
		}
	}
}

// Key Down - called when a key is down (for typing)
void KeyDown(NSEvent* event)
{
	short key = [ [ event charactersIgnoringModifiers ] characterAtIndex:0 ];
	if (key == NSCarriageReturnCharacter || key == NSNewlineCharacter || key == NSEnterCharacter)
	{
		if (!inMenu && commandFlag == 0)
		{
			if (paused)
			{
				ExitPause();
				commandFlag = COMMAND_RESUME;
				[ ViewForIdentity(@"Aim View") setVisible:YES ];
			}
			else
			{
				// Show mouse
				commandFlag = COMMAND_PAUSE;
				MDSetDefaultPhysics(FALSE);
				paused = TRUE;
				pauseTimer = 0;
				UpdateMouse(0, 0);
				InitPauseMenu();
				[ ViewForIdentity(@"Pause View") setVisible:YES ];
				[ ViewForIdentity(@"Aim View") setVisible:NO ];
			}
		}
	}
	/*else if (!inMenu && (key == 'b' || key == 'B'))
	 {
	 MDObject* obj = MDObjectWithName(@"Player", @"Player");
	 // Check if objects are there
	 NSArray* objects = MDObjects();
	 for (unsigned long y = 0; y < [ objects count ]; y++)
	 {
	 if ([ objects objectAtIndex:y ] == obj)
	 continue;
	 if ([ [ objects objectAtIndex:y ] mass ] != 0)
	 {
	 float scaleX = fabs([ [ objects objectAtIndex:y ] scaleX ]);
	 if (MDVector3Distance([ obj midPoint ], [ [ objects objectAtIndex:y ] midPoint ]) < 4.0 * scaleX)
	 {
	 grabObject = [ objects objectAtIndex:y ];
	 MDSetObjectRotation(grabObject, MDVector3Create(0, 0, 0), 0);
	 grabBox = MDBoundingBoxRotate(grabObject);
	 MDSetObjectGravity(grabObject, MDVector3Create(0, 0, 0));
	 break;
	 }
	 }
	 }
	 }*/
}

// Key Up - called when a key is released (for typing)
void KeyUp(NSEvent* event)
{
	short key = [ [ event charactersIgnoringModifiers ] characterAtIndex:0 ];
	/*if (!inMenu && (key == 'b' || key == 'B'))
	 {
	 if (grabObject)
	 {
	 // Restore gravity to it
	 MDSetObjectGravity(grabObject, MDGravity());
	 grabObject = nil;
	 }
	 }*/
}

// Process Keys - called 60 times a second for smooth key calling
void ProcessKeys(NSArray* keys)
{
	float speed = 240 * MDElapsedTime() / 1000.0;
	float strideDamp = 0.5 * zAngle;
	for (unsigned long z = 0; z < [ keys count ]; z++)
	{
		unsigned short key = [ [ keys objectAtIndex:z ] unsignedShortValue ];
		if (!customCamera && canMove && !paused)
		{
			/*// Arrow Key Movement Method
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
			 rotateAngle += 3.0 * MDElapsedTime() / 1000.0 * zAngle;
			 else if (key == NSRightArrowFunctionKey)
			 rotateAngle -= 3.0 * MDElapsedTime() / 1000.0 * zAngle;
			 else if (key == 'w' || key == 'W')
			 cameraHeight += 12 * MDElapsedTime() / 1000.0 * zAngle;
			 else if (key == 's' || key == 'S')					cameraHeight -= 12 * MDElapsedTime() / 1000.0 * zAngle;*/
			// Mouse Movement Method
			if (key == 'w' || key == 'W')
			{
				MDObject* obj = MDObjectWithName(@"Player", @"Player");
				MDVector3 vel = MDLinearVelocity(obj);
				vel += MDVector3Create(sin(rotateAngle) * speed, 0, cos(rotateAngle) * speed);
				MDSetLinearVelocity(obj, vel);
			}
			else if (key == 's' || key == 'S')
			{
				MDObject* obj = MDObjectWithName(@"Player", @"Player");
				MDVector3 vel = MDLinearVelocity(obj);
				vel -= MDVector3Create(speed * sin(rotateAngle), 0, speed * cos(rotateAngle));
				MDSetLinearVelocity(obj, vel);
			}
			else if (key == 'a' || key == 'A')
			{
				MDObject* obj = MDObjectWithName(@"Player", @"Player");
				MDVector3 vel = MDLinearVelocity(obj);
				vel += MDVector3Create(speed * cos(rotateAngle), 0, -speed * sin(rotateAngle)) * strideDamp;
				MDSetLinearVelocity(obj, vel);
			}
			else if (key == 'd' || key == 'D')
			{
				MDObject* obj = MDObjectWithName(@"Player", @"Player");
				MDVector3 vel = MDLinearVelocity(obj);
				vel -= MDVector3Create(speed * cos(rotateAngle), 0, -speed * sin(rotateAngle)) * strideDamp;
				MDSetLinearVelocity(obj, vel);
			}
			else if (key == ' ')
			{
				MDObject* obj = MDObjectWithName(@"Player", @"Player");
				MDVector3 vel = MDLinearVelocity(obj);
				
				if (!jumping && ((((zAngle == 1) && vel.y > -0.05) || ((zAngle == -1) && vel.y < 0.05)) || fabs(changeVel) < 0.05))
				{
					vel.y = jumpStrength * zAngle;
					jumping = TRUE;
				}
				
				MDSetLinearVelocity(obj, vel);
			}
			/*else if (key == 't')	// Levitate
			{
				static float angle = 0;
				MDObject* obj = MDObjectWithName(@"Player", @"Player");
				MDVector3 vel = MDLinearVelocity(obj);
				vel.y = (sin(angle) + 0.23) * zAngle;        // 0.23 is not exact
				angle += MDElapsedTime() / 1000.0 * M_PI * 2;
				MDSetLinearVelocity(obj, vel);
			}
			else if (key == 'r')	// Rise
			{
				MDObject* obj = MDObjectWithName(@"Player", @"Player");
				MDVector3 vel = MDLinearVelocity(obj);
				vel.y = 5 * zAngle;
				MDSetLinearVelocity(obj, vel);
			}
			else if (key == 'p' || key == 'P')
			{
				commandFlag |= FADING_OUT;
				loadSame = TRUE;
			}*/
		}
	}
}

// Um
/*void UpdateSparkVelocity(MDParticle* p, float xVal, float aVal, MDParticleEngine* engine)
 {
 MDVector3 velocities = [ engine velocities ];
 // Sphere Explosion - no tail
 p->position[0] = p->startPos[0] + p->seed[0] * xVal * 5 * velocities.x;
 p->position[1] = p->startPos[1] + fabs(p->seed[1]) * xVal * 5 * velocities.y;
 p->position[2] = p->startPos[2] + p->seed[2] * xVal * 5 * velocities.z;
 p->color[3] = 0.2 - (0.2 * xVal);
 }*/

// Mouse Down - called when the mouse is down.
void MouseDown(NSEvent* event)
{
	if ([ event modifierFlags ] & NSControlKeyMask)
	{
		RightMouseDown(event);
		return;
	}
	
	if (!paused && !inMenu && !customCamera && canMove && grabObject/* && [ [ [ grabObject instance ] name ] isEqualToString:@"Gravity" ]*/)
	{
		MDObject* obj = MDObjectWithName(@"Player", @"Player");
		MDSetObjectGravity(grabObject, grabGravity);
		[ grabObject setColorMultiplier:grabColor ];
		
		MDVector3 realMid = midPoint + MDVector3Create(0, 1, 0);
		MDVector3 direction = MDVector3Normalize(lookPoint - midPoint);
		
		MDRect box = MDBoundingBoxRotate(grabObject);
		// Maybe include the player's linear velocity
		MDSetLinearVelocity(grabObject, direction * 20 + MDLinearVelocity(obj));
		MDSetObjectPosition(grabObject, realMid + direction * 2 * fabs(box.depth));
		float angle = MDVector3Angle(MDVector3Create(0, 1, 0), direction);
		MDVector3 axis = MDVector3Normalize(MDVector3CrossProduct(MDVector3Create(0, 1, 0), direction));
		MDSetObjectRotation(grabObject, axis, angle);
		MDSetAngularVelocity(grabObject, MDVector3Create(0, 0, 0));
		
		grabObject = nil;
	}
	else if (!paused && !inMenu && !customCamera && canMove && !grabObject && (items & MD_BULLET))
	{
		/*MDObject* bullet = MDObjectWithName(@"Bullet", @"Bullet");
		 MDVector3 vel = MDLinearVelocity(bullet);
		 // Not sure if i like waiting for it to stop
		 //if (MDVector3Magnitude(vel) < 5)*/
		if ([ bullets count ] < 10)
		{
			// Shoot bullet
			MDObject* bullet = [ [ MDObject alloc ] initWithObject:MDObjectWithName(@"Bullet", @"Bullet") ];
			[ bullet setShouldDraw:YES ];
			MDAddObject(bullet);
			[ bullets addObject:bullet ];
			[ bullet release ];
			MDObject* obj = MDObjectWithName(@"Player", @"Player");
			MDVector3 realMid = midPoint + MDVector3Create(0, 1, 0);
			MDVector3 direction = MDVector3Normalize(lookPoint - midPoint);
			
			// Maybe include the player's linear velocity
			MDSetLinearVelocity(bullet, direction * 80 + MDLinearVelocity(obj));
			MDSetObjectPosition(bullet, realMid + direction * 2);
			float angle = MDVector3Angle(MDVector3Create(0, 1, 0), direction);
			MDVector3 axis = MDVector3Normalize(MDVector3CrossProduct(MDVector3Create(0, 1, 0), direction));
			MDSetObjectRotation(bullet, axis, angle);
			MDSetAngularVelocity(bullet, MDVector3Create(0, 0, 0));
			
			// Create a spark
			/*[ MDOtherObjects() removeObject:MDOtherObjectNamed(@"Bullet Shot") ];
			 MDParticleEngine* engine = [ [ MDParticleEngine alloc ] init ];
			 [ engine setPosition:[ bullet midPoint ] ];
			 [ engine setOneShot:YES ];
			 [ engine setUpdateVelocityFunction:UpdateSparkVelocity ];
			 [ engine setStartColor:MDVector4Create(1.0, 0.5, 0.0, 0.2) ];
			 [ engine setEndColor:MDVector4Create(1.0, 0.0, 0.0, 0.0) ];
			 [ engine setNumberOfParticles:100 ];
			 [ engine setParticleSize:5 ];
			 [ engine reloadModel ];
			 [ engine setName:@"Bullet Shot" ];
			 [ MDOtherObjects() addObject:engine ];
			 [ engine release ];*/
		}
	}
	else if (!paused && !inMenu && !customCamera && canMove && !grabObject)
	{
		unsigned long y = MDPick([ event locationInWindow ]);
		NSArray* objects = MDObjects();
		for (unsigned long z = 0; z < gravities.size(); z++)
		{
			if (gravities[z].obj == [ objects objectAtIndex:y ])
			{
				if (gravities[z].changed || (MDVector3Distance([ gravities[z].obj midPoint ], [ MDObjectWithName(@"Player", @"Player") midPoint ]) > 5.0))
					break;
				
				gravities[z].power = round(gravities[z].power);
				gravities[z].changed = (gravities[z].power > 0.5) ? -1 : 1;
				gravities[z].counter = 0;
				
				break;
			}
		}
	}
}

// Mouse Up - called when the mouse is released.
void MouseUp(NSEvent* event)
{
}

void RightMouseDown(NSEvent* event)
{
	if (!paused && !inMenu && !customCamera && canMove)
	{
		if (!grabObject)
		{
			MDObject* obj = MDObjectWithName(@"Player", @"Player");
			
			unsigned long y = MDPick([ event locationInWindow ]);
			NSArray* objects = MDObjects();
			if (y < [ objects count ])
			{
				if ([ [ objects objectAtIndex:y ] mass ] != 0)
				{
					if (MDVector3Distance([ obj midPoint ], [ [ objects objectAtIndex:y ] midPoint ]) < 5.0)
					{
						if ([ boxes containsObject:[ objects objectAtIndex:y ] ])
							CollectBox([ objects objectAtIndex:y ]);
						else
						{
							grabObject = [ objects objectAtIndex:y ];
							//MDSetObjectRotation(grabObject, MDVector3Create(0, 0, 0), 0);
							grabRot = [ grabObject rotateAngle ];
							grabCounter = 0;
							grabBox = MDBoundingBoxRotate(grabObject);
							if (fabs(grabBox.depth) < 2)
							{
								float old = grabBox.depth;
								grabBox.depth = fabs(grabBox.depth) / grabBox.depth * 2;
								float delta = grabBox.depth - old;
								grabBox.z -= delta / 2;
							}
							grabGravity = MDObjectGravity(grabObject);
							prevGrabGravity = MDGravity();
							MDSetObjectGravity(grabObject, MDVector3Create(0, 0, 0));
							grabColor = [ grabObject colorMultiplier ];
							[ grabObject setColorMultiplier:MDVector4Create(grabColor.x, grabColor.y, grabColor.z, 0.5) ];
							[ MDGLView() calculateAlphaObjects ];
						}
					}
				}
			}
		}
		else
		{
			if (grabObject)
			{
				// Restore gravity and its instance to it
				MDObject* obj = MDObjectWithName(@"Player", @"Player");
				if (prevGrabGravity == grabGravity && !(prevGrabGravity == MDGravity()))
					MDSetObjectGravity(grabObject, MDGravity());
				else
					MDSetObjectGravity(grabObject, grabGravity);
				[ grabObject setColorMultiplier:grabColor ];
				//MDVector3 vel = ([ obj midPoint ] + MDVector3Create(0, zAngle * fabs(grabBox.height) / 2, 0) + normal * fabs(grabBox.depth) * 2) - [ grad midPoint ];
				//MDSetAngularVelocity(grabObject, vel);
				//MDSetLinearVelocity(obj, vel * 5.0 / [ grabObject mass ]);
				grabObject = nil;
			}
		}
	}
}

void UpdateMouse(float dx, float dy)
{
	if (!inMenu && !paused)
	{
		// Move the mouse to the center
		NSRect frame = [ MDGLWindow() frame ];
		NSScreen* screen = [ NSScreen mainScreen ];
		NSRect screenRect = [ screen frame ];
		CGDisplayMoveCursorToPoint(cgDisplay, NSMakePoint(frame.origin.x + frame.size.width / 2, screenRect.size.height - (frame.origin.y + frame.size.height / 2)));
		
		// Hide mouse
		[ NSCursor hide ];
		mouseHidden++;
		
		if (!customCamera && canMove)
		{
			rotateAngle -= dx * 0.0025 * zAngle;
			cameraHeight -= dy * 0.0125 * zAngle;
			if (cameraHeight > 7.5)
				cameraHeight = 7.5;
			else if (cameraHeight < -5)
				cameraHeight = -5;
		}
	}
	else
	{
		// Show mouse
		for (unsigned long z = 0; z < mouseHidden; z++)
			[ NSCursor unhide ];
		mouseHidden = 0;
	}
}

// Mouse Dragged - called when the mouse is dragged.
void MouseDragged(NSEvent* event)
{
	UpdateMouse([ event deltaX ], [ event deltaY ]);
}

void RightMouseDragged(NSEvent* event)
{
	UpdateMouse([ event deltaX ], [ event deltaY ]);
}
// Mouse Moved - called when the mouse is moved.
void MouseMoved(NSEvent* event)
{
	UpdateMouse([ event deltaX ], [ event deltaY ]);
}

// Dealloc - called when the app is exited
void Dealloc()
{
	if (boxes)
	{
		[ boxes release ];
		boxes = nil;
	}
	if (blueBoxes)
	{
		[ blueBoxes release ];
		blueBoxes = nil;
	}
	if (collectedString)
	{
		[ collectedString release ];
		collectedString = nil;
	}
	if (boxString)
	{
		[ boxString release ];
		boxString = nil;
	}
	if (bulletString)
	{
		[ bulletString release ];
		bulletString = nil;
	}
	if (barrels)
	{
		[ barrels release ];
		barrels = nil;
	}
	if (bullets)
	{
		[ bullets release ];
		bullets = nil;
	}
	
	DeallocMenu();
	DeallocPauseMenu();
	MDRemoveView(ViewForIdentity(@"Black Fade"));
	MDRemoveView(ViewForIdentity(@"Black Fade 2"));
	MDRemoveView(ViewForIdentity(@"Aim View"));
}