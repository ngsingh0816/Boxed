// Level.mm

#import "Level.h"

const NSString* levelNames[NUM_PACKS] = { @"Intro", @"Shoot", @"The Blue Box" };
const unsigned int levelAmounts[NUM_PACKS] = { 11, 5, 5 };

void (*LoadLevelFunctions[NUM_PACKS][NUM_LEVELS])();
void (*UpdateLevelFunctions[NUM_PACKS][NUM_LEVELS])(MDObject* obj);

void EmptyFunction()
{
}

void EmptyFunction2(MDObject* obj)
{
}

void SetGravityBlue(MDVector3 gravity)
{
	MDSetGravity(gravity);
	for (unsigned long z = 0; z < [ boxes count ]; z++)
	{
		if ([ [ [ [ boxes objectAtIndex:z ] instance ] name ] isEqualToString:@"Blue Box" ])
			MDSetObjectGravity([ boxes objectAtIndex:z ], MDVector3Create(0, 0, 0));
	}
	for (unsigned long z = 0; z < gravities.size(); z++)
		MDSetObjectGravity(gravities[z].obj, MDVector3Create(0, 0, 0));
}

void LoadLevel6()
{
	PushSwitch(1, MDObjectWithName(@"Player", @"Player"), NO);
}

void LoadLevel7()
{
	PushSwitch(3, MDObjectWithName(@"Player", @"Player"), NO);
}

void LoadLevel10()
{
	PushSwitch(3, MDObjectWithName(@"Player", @"Player"), NO);
}

void LoadLevel11()
{
	PushSwitch(7, MDObjectWithName(@"Player", @"Player"), NO);
}

void LoadLevel4()
{
	MDSetObjectPosition(MDObjectWithName(@"Platform", @"Object 1"), MDVector3Create(0, -1, 0));
}

void Level5(MDObject* obj)
{		
	// Have the rotation for the tops
	static float counter = 0;
	static BOOL animating = FALSE;
	for (unsigned long z = 0; z < switches.size(); z++)
	{
		if (switches[z].doAction == 1)
		{
			switches[z].doAction = 0;
			animating = TRUE;
		}
	}
	
	if (animating)
	{
		MDObject* left = MDObjectWithName(@"Left Top", @"Gray Wall");
		MDObject* right = MDObjectWithName(@"Right Top", @"Gray Wall");
		
		float real = MDTweenEaseOutBounce(counter);
		MDSetObjectRotation(left, MDVector3Create(0, 0, 1), -45 * real);
		MDSetObjectRotation(right, MDVector3Create(0, 0, 1), 45 * real);
		MDSetObjectPosition(left, MDVector3Create(-5, 9.5, 0) - MDVector3Create(2.5 * cos(real * 45 / 180 * M_PI), 4 * sin(real * 45 / 180 * M_PI), 0));
		MDSetObjectPosition(right, MDVector3Create(5, 9.5, 0) - MDVector3Create(-2.5 * cos(real * 45 / 180 * M_PI), 4 * sin(real * 45 / 180 * M_PI), 0));
		
		counter += MDElapsedTime() / 1000.0 / 2;
		if (counter > 1)
		{
			counter = 0;
			animating = FALSE;
		}
	}
}

void Level6(MDObject* obj)
{
	static float counter = 0;
	static int animating = 0;
	static float oldCam = 0;
	
	for (unsigned long z = 0; z < switches.size(); z++)
	{
		if (z == 0)	// Up
		{
			if (switches[z].doAction == 1)
			{
				switches[z].doAction = 0;
				// Set gravity to be up
				MDSetGravity(MDVector3Create(0, gravityStrength, 0));
				counter = 0;
				animating = 1;
				canMove = FALSE;
				oldCam = cameraHeight;
			}
		}
		else if (z == 1)	// Down
		{
			if (switches[z].doAction == 1)
			{
				switches[z].doAction = 0;
				// Set gravity to be down
				MDSetGravity(MDVector3Create(0, -gravityStrength, 0));
				counter = 0;
				animating = 2;
				canMove = FALSE;
				oldCam = cameraHeight;
			}
		}
	}
	
	if (animating == 1)
	{
		rotateZAngle = 180 * MDTweenEaseInOutQuadratic(counter);
		cameraHeight = oldCam * (1 - (counter * 2));
		counter += MDElapsedTime() / 1000.0;
		if (counter > 1)
		{
			counter = 0;
			rotateZAngle = 180;
			animating = 0;
			canMove = TRUE;
			zAngle = -1;
			ReleaseSwitch(1, obj, NO);
			cameraHeight = -oldCam;
		}
	}
	else if (animating == 2)
	{
		rotateZAngle = 180 - 180 * MDTweenEaseInOutQuadratic(counter);
		cameraHeight = oldCam * (1 - (counter * 2));
		counter += MDElapsedTime() / 1000.0;
		if (counter > 1)
		{
			counter = 0;
			rotateZAngle = 0;
			animating = 0;
			canMove = TRUE;
			zAngle = 1;
			ReleaseSwitch(0, obj, NO);
			cameraHeight = -oldCam;
		}
	}
}

void Level7(MDObject* obj)
{
	static float counter = 0;
	static int animating = 0;
	static float oldCam = 0;
	
	if (switches[0].doAction == 1)
	{
		animating = 1;
		counter = 0;
		switches[0].doAction = 0;
	}
	else if (switches[2].doAction == 1)
	{
		animating = 3;
		counter = 0;
		switches[2].doAction = 0;
	}
	else if (switches[6].doAction == 1)
	{
		animating = 5;
		counter = 0;
		switches[6].doAction = 0;
	}
	
	if (switches[1].doAction == 1)
	{
		switches[1].doAction = 0;
		// Set gravity to be up
		MDSetGravity(MDVector3Create(0, gravityStrength, 0));
		counter = 0;
		animating = 2;
		canMove = FALSE;
		oldCam = cameraHeight;
	}
	else if (switches[3].doAction == 1)
	{
		switches[3].doAction = 0;
		// Set gravity to be down
		MDSetGravity(MDVector3Create(0, -gravityStrength, 0));
		counter = 0;
		animating = 4;
		canMove = FALSE;
		oldCam = cameraHeight;
	}
	
	if (switches[4].down)
	{
		MDObject* plat = MDObjectWithName(@"Platform", @"Platform");
		MDVector3 add = MDVector3Create(0, 0, 5 * MDElapsedTime() / 1000.0);
		if (!([ plat midPoint ].z + add.z > 10))
		{
			MDSetObjectPosition(plat, [ plat midPoint ] + add);
			MDSetObjectPosition(switches[4].obj, [ switches[4].obj midPoint ] + add);
			MDSetObjectPosition(switches[5].obj, [ switches[5].obj midPoint ] + add);
			MDSetObjectPosition(obj, [ obj midPoint ] + add);
		}
	}
	
	if (switches[5].down)
	{
		MDObject* plat = MDObjectWithName(@"Platform", @"Platform");
		MDVector3 add = MDVector3Create(0, 0, 5 * MDElapsedTime() / 1000.0);
		if (!([ plat midPoint ].z - add.z < -17.5))
		{
			MDSetObjectPosition(plat, [ plat midPoint ] - add);
			MDSetObjectPosition(switches[4].obj, [ switches[4].obj midPoint ] - add);
			MDSetObjectPosition(switches[5].obj, [ switches[5].obj midPoint ] - add);
			MDSetObjectPosition(obj, [ obj midPoint ] - add);
		}
	}
	
	if (animating == 1)
	{
		counter += MDElapsedTime() / 1000.0;
		if (counter > 1)
		{
			// Middle Door
			MDObject* left = MDObjectWithName(@"Left Middle Door", @"Gray Wall");
			MDObject* right = MDObjectWithName(@"Right Middle Door", @"Gray Wall");
			
			float real = MDTweenEaseOutQuadratic((counter - 1) / 2);
		
			MDSetObjectPosition(left, MDVector3Create(-2.5 - real * 5, 4.25, -25));
			MDSetObjectPosition(right, MDVector3Create(2.5 + real * 5, 4.25, -25));
			
			if (counter > 3)
			{
				counter = 0;
				animating = 0;
				
				[ left setShouldDraw:NO ];
				MDObjectDisable(left);
				[ right setShouldDraw:NO ];
				MDObjectDisable(right);
			}
		}
	}
	else if (animating == 2)
	{
		rotateZAngle = 180 * MDTweenEaseInOutQuadratic(counter);
		cameraHeight = oldCam * (1 - (counter * 2));
		counter += MDElapsedTime() / 1000.0;
		if (counter > 1)
		{
			counter = 0;
			rotateZAngle = 180;
			animating = 0;
			canMove = TRUE;
			zAngle = -1;
			ReleaseSwitch(3, obj, NO);
			cameraHeight = -oldCam;
		}
	}
	else if (animating == 3)
	{
		counter += MDElapsedTime() / 1000.0;
		if (counter > 1)
		{
			// Left Door
			MDObject* left = MDObjectWithName(@"Left Left Door", @"Gray Wall");
			MDObject* right = MDObjectWithName(@"Right Left Door", @"Gray Wall");
			
			float real = MDTweenEaseOutQuadratic((counter - 1) / 2);
		
			MDSetObjectPosition(left, MDVector3Create(-17.5 - real * 5, 4.25, -25));
			MDSetObjectPosition(right, MDVector3Create(-12.5 + real * 5, 4.25, -25));
			
			if (counter > 3)
			{
				counter = 0;
				animating = 0;
				
				[ left setShouldDraw:NO ];
				MDObjectDisable(left);
				[ right setShouldDraw:NO ];
				MDObjectDisable(right);
			}
		}
	}
	else if (animating == 4)
	{
		rotateZAngle = 180 - 180 * MDTweenEaseInOutQuadratic(counter);
		cameraHeight = oldCam * (1 - (counter * 2));
		counter += MDElapsedTime() / 1000.0;
		if (counter > 1)
		{
			counter = 0;
			rotateZAngle = 0;
			animating = 0;
			canMove = TRUE;
			zAngle = 1;
			ReleaseSwitch(1, obj, NO);
			cameraHeight = -oldCam;
		}
	}
	else if (animating == 5)
	{
		counter += MDElapsedTime() / 1000.0;
		if (counter > 1)
		{
			// Right Door
			MDObject* left = MDObjectWithName(@"Left Right Door", @"Gray Wall");
			MDObject* right = MDObjectWithName(@"Right Right Door", @"Gray Wall");
			
			float real = MDTweenEaseOutQuadratic((counter - 1) / 2);
		
			MDSetObjectPosition(left, MDVector3Create(12.5 - real * 5, 4.25, -25));
			MDSetObjectPosition(right, MDVector3Create(17.5 + real * 5, 4.25, -25));
			
			if (counter > 3)
			{
				counter = 0;
				animating = 0;
				
				[ left setShouldDraw:NO ];
				MDObjectDisable(left);
				[ right setShouldDraw:NO ];
				MDObjectDisable(right);
			}
		}
	}
}

void Level8(MDObject* obj)
{
	static int animating = 0;
	static float counter = 0;
	
	if (switches[0].doAction == 1)
	{
		animating = 1;
		counter = 0;
		switches[0].doAction = 0;
	}
	else if (switches[0].doAction == 2)
	{
		animating = 2;
		counter = 0;
		switches[0].doAction = 0;
	}
	
	if (animating == 1)
	{
		counter += MDElapsedTime() / 1000.0;
		
		// Door
		MDObject* left = MDObjectWithName(@"Left Door", @"Gray Wall");
		MDObject* right = MDObjectWithName(@"Right Door", @"Gray Wall");
		
		float real = MDTweenEaseOutQuadratic(counter * 2);
		
		MDSetObjectPosition(left, MDVector3Create(-5 - real * 9.5, 4.5, -65));
		MDSetObjectPosition(right, MDVector3Create(5 + real * 9.5, 4.5, -65));
		
		if (counter > 0.5)
		{
			counter = 0;
			animating = 0;
			
			MDSetObjectPosition(left, MDVector3Create(-14.5, 4.5, -65));
			MDSetObjectPosition(right, MDVector3Create(14.5, 4.5, -65));
		}
	}
	else if (animating == 2)
	{
		counter += MDElapsedTime() / 1000.0;
		
		// Door
		MDObject* left = MDObjectWithName(@"Left Door", @"Gray Wall");
		MDObject* right = MDObjectWithName(@"Right Door", @"Gray Wall");
		
		float real = MDTweenEaseOutQuadratic(counter * 2);
		
		MDSetObjectPosition(left, MDVector3Create(-14.5 + real * 9.5, 4.5, -65));
		MDSetObjectPosition(right, MDVector3Create(14.5 - real * 9.5, 4.5, -65));
		
		if (counter > 0.5)
		{
			counter = 0;
			animating = 0;
			
			MDSetObjectPosition(left, MDVector3Create(-5, 4.5, -65));
			MDSetObjectPosition(right, MDVector3Create(5, 4.5, -65));
		}
	}
}

void Level9(MDObject* obj)
{
	static int animating = 0, animatingThing = 0, doneThing = 0;
	static int doRed = 0, doGreen = 0, doBlue = 0;
	static float counterR = 0, counterG = 0, counterB = 0, counter = 0;
	
	if (switches[0].doAction == 1)
	{
		animating = 1;
		doRed = 1;
		counterR = 0;
		switches[0].doAction = 0;
	}
	else if (switches[0].doAction == 2)
	{
		animating = 1;
		doRed = -1;
		counterR = 0;
		switches[0].doAction = 0;
	}
	
	if (switches[1].doAction == 1)
	{
		animating = 1;
		doGreen = 1;
		counterG = 0;
		switches[1].doAction = 0;
	}
	else if (switches[1].doAction == 2)
	{
		animating = 1;
		doGreen = -1;
		counterG = 0;
		switches[1].doAction = 0;
	}
	
	if (switches[2].doAction == 1)
	{
		animating = 1;
		doBlue = 1;
		counterB = 0;
		switches[2].doAction = 0;
	}
	else if (switches[2].doAction == 2)
	{
		animating = 1;
		doBlue = -1;
		counterB = 0;
		switches[2].doAction = 0;
	}
	
	if (switches[3].doAction == 1)
	{
		animating = 2;
		counter = 0;
		switches[3].doAction = 0;
	}
	if (switches[4].doAction == 1)
	{
		MDObject* barrel = MDObjectWithName(@"Left Barrel", @"Barrel");
		MDObjectEnable(barrel);
		MDSetObjectPosition(barrel, [ barrel midPoint ] + MDVector3Create(0, -10, 0));
		switches[4].doAction = 0;
	}
	if (switches[5].doAction == 1)
	{
		MDObject* barrel = MDObjectWithName(@"Right Barrel", @"Barrel");
		MDObjectEnable(barrel);
		MDSetObjectPosition(barrel, [ barrel midPoint ] + MDVector3Create(0, -10, 0));
		switches[5].doAction = 0;
	}
	
	if (switches[0].down == 1 && switches[1].down == 1 && switches[2].down == 1 && !doneThing && !animating &&
		switches[0].doAction == 0 && switches[1].doAction == 0 && switches[2].doAction == 0 && switches[0].animation == 5 &&
		switches[1].animation == 5 && switches[2].animation == 5)
	{
		doneThing = 1;
		animatingThing = 1;
		counter = 0;
		animating = 1;		
		doRed = -1;
		doGreen = -1;
		doBlue = -1;
		counterR = 0;
		counterG = 0;
		counterB = 0;
		
		switches[0].time = 0;
		switches[1].time = 0;
		switches[2].time = 0;
	}
	else if (!(switches[0].down == 1 && switches[1].down == 1 && switches[2].down == 1 && switches[0].animation == 5 &&
		switches[1].animation == 5 && switches[2].animation == 5))
		doneThing = 0;
	
	if (animating == 1)
	{
		float red = (doRed == 1) ? MDTweenEaseInOutQuadratic(counterR) : MDTweenEaseInOutQuadratic(1 - counterR);
		float green = (doGreen == 1) ? MDTweenEaseInOutQuadratic(counterG) : MDTweenEaseInOutQuadratic(1 - counterG);
		float blue = (doBlue == 1) ? MDTweenEaseInOutQuadratic(counterB) : MDTweenEaseInOutQuadratic(1 - counterB);
		
		MDLight* light = MDOtherObjectNamed(@"Mid Spot");
		MDVector4 color = [ light diffuseColor ];
		[ light setAmbientColor:MDVector4Create((doRed == 0) ? color.x : red, (doGreen == 0) ? color.y : green, (doBlue == 0) ? color.z : blue, 1) ];
		[ light setDiffuseColor:MDVector4Create((doRed == 0) ? color.x : red, (doGreen == 0) ? color.y : green, (doBlue == 0) ? color.z : blue, 1) ];
		
		if (doRed != 0)
			counterR += MDElapsedTime() / 1000.0;
		if (doGreen != 0)
			counterG += MDElapsedTime() / 1000.0;
		if (doBlue != 0)
			counterB += MDElapsedTime() / 1000.0;
		
		if (counterR > 1)
		{
			doRed = 0;
			counterR = 0;
		}
		if (counterG > 1)
		{
			doGreen = 0;
			counterG = 0;
		}
		if (counterB > 1)
		{
			doBlue = 0;
			counterB = 0;
		}
	}
	else if (animating == 2)
	{
		MDObject* wall = MDObjectWithName(@"Right Wall", @"Gray Wall");
		
		float value = MDTweenEaseInOutQuadratic(counter - 1);
		counter += MDElapsedTime() / 1000.0;
		
		if (counter > 1)
			MDSetObjectPosition(wall, MDVector3Create(30, 5.5 + 11 * value, 0));
		
		if (counter > 2)
		{
			MDObjectDisable(wall);
			[ wall setShouldDraw:NO ];
			counter = 0;
			animating = 0;
		}
	}
	
	if (animatingThing == 1)
	{
		MDObject* left = MDObjectWithName(@"Left Front", @"Gray Wall");
		MDObject* right = MDObjectWithName(@"Right Front", @"Gray Wall");
		
		float value = MDTweenEaseInOutQuadratic(counter / 2);
		counter += MDElapsedTime() / 1000.0;
		
		MDSetObjectPosition(left, MDVector3Create(-15 - 10 * value, 5.5, -15));
		MDSetObjectPosition(right, MDVector3Create(15 + 10 * value, 5.5, -15));
		
		if (counter > 2)
		{
			counter = 0;
			animatingThing = 0;
		}
	}
	
	if (doRed == 0 && doGreen == 0 && doBlue == 0 && animating == 1)		animating = 0;
}

void Level10(MDObject* obj)
{
	static float counter = 0;
	static int animating = 0;
	static float oldCam = 0;
	
	if (switches[0].doAction == 1)
	{
		animating = 1;
		counter = 0;
		switches[0].doAction = 0;
	}
	
	if (switches[1].doAction == 1)
	{
		switches[1].doAction = 0;
		// Set gravity to be up
		MDSetGravity(MDVector3Create(0, gravityStrength, 0));
		counter = 0;
		animating = 2;
		canMove = FALSE;
		oldCam = cameraHeight;
	}
	else if (switches[3].doAction == 1)
	{
		switches[3].doAction = 0;
		// Set gravity to be down
		MDSetGravity(MDVector3Create(0, -gravityStrength, 0));
		counter = 0;
		animating = 3;
		canMove = FALSE;
		oldCam = cameraHeight;
	}
	
	if (switches[2].doAction == 1)
	{
		animating = 4;
		counter = 0;
		switches[2].doAction = 0;
	}
	else if (switches[2].doAction == 2)
	{
		animating = 5;
		counter = 0;
		switches[2].doAction = 0;
	}
	
	if (animating == 1)
	{
		counter += MDElapsedTime() / 1000.0;
		if (counter > 1)
		{
			// Middle Door
			MDObject* left = MDObjectWithName(@"Left Middle Wall", @"Gray Wall");
			MDObject* right = MDObjectWithName(@"Right Middle Wall", @"Gray Wall");
			
			float real = MDTweenEaseOutQuadratic((counter - 1) / 2);
		
			MDSetObjectPosition(left, MDVector3Create(-5 - real * 10, 5.25, -30));
			MDSetObjectPosition(right, MDVector3Create(5 + real * 10, 5.25, -30));
			
			if (counter > 3)
			{
				counter = 0;
				animating = 0;
				
				[ left setShouldDraw:NO ];
				MDObjectDisable(left);
				[ right setShouldDraw:NO ];
				MDObjectDisable(right);
			}
		}
	}
	else if (animating == 2)
	{
		rotateZAngle = 180 * MDTweenEaseInOutQuadratic(counter);
		cameraHeight = oldCam * (1 - (counter * 2));
		counter += MDElapsedTime() / 1000.0;
		if (counter > 1)
		{
			counter = 0;
			rotateZAngle = 180;
			animating = 0;
			canMove = TRUE;
			zAngle = -1;
			ReleaseSwitch(3, obj, NO);
			cameraHeight = -oldCam;
		}
	}
	else if (animating == 3)
	{
		rotateZAngle = 180 - 180 * MDTweenEaseInOutQuadratic(counter);
		cameraHeight = oldCam * (1 - (counter * 2));
		counter += MDElapsedTime() / 1000.0;
		if (counter > 1)
		{
			counter = 0;
			rotateZAngle = 0;
			animating = 0;
			canMove = TRUE;
			zAngle = 1;
			ReleaseSwitch(1, obj, NO);
			cameraHeight = -oldCam;
		}
	}
	else if (animating == 4)
	{
		counter += MDElapsedTime() / 1000.0;
		
		// Door
		MDObject* left = MDObjectWithName(@"Left Slide", @"Gray Wall");
		MDObject* right = MDObjectWithName(@"Right Slide", @"Gray Wall");
		
		float real = MDTweenEaseOutQuadratic(counter * 2);
		
		MDSetObjectPosition(left, MDVector3Create(-5 - real * 9.5, 38.75, -90));
		MDSetObjectPosition(right, MDVector3Create(5 + real * 9.5, 38.75, -90));
		
		if (counter > 0.5)
		{
			counter = 0;
			animating = 0;
			
			MDSetObjectPosition(left, MDVector3Create(-14.5, 38.75, -90));
			MDSetObjectPosition(right, MDVector3Create(14.5, 38.75, -90));
		}
	}
	else if (animating == 5)
	{
		counter += MDElapsedTime() / 1000.0;
		
		// Door
		MDObject* left = MDObjectWithName(@"Left Slide", @"Gray Wall");
		MDObject* right = MDObjectWithName(@"Right Slide", @"Gray Wall");
		
		float real = MDTweenEaseOutQuadratic(counter * 2);
		
		MDSetObjectPosition(left, MDVector3Create(-14.5 + real * 9.5, 38.75, -90));
		MDSetObjectPosition(right, MDVector3Create(14.5 - real * 9.5, 38.75, -90));
		
		if (counter > 0.5)
		{
			counter = 0;
			animating = 0;
			
			MDSetObjectPosition(left, MDVector3Create(-5, 38.75, -90));
			MDSetObjectPosition(right, MDVector3Create(5, 38.75, -90));
		}
	}
}

void Level11(MDObject* obj)
{
	static float counter = 0, counter2 = 0, counter3 = 0;
	static int animating = 0, lastDown = -1;
	
	if (switches[5].doAction == 1)
	{
		animating |= (1 << 0);
		counter = 0;
		switches[5].doAction = 0;
	}
	else if (switches[5].doAction == 2)
	{
		animating |= (1 << 1);
		counter = 0;
		switches[5].doAction = 0;
	}
	if (switches[6].doAction == 1)
	{
		animating |= (1 << 2);
		counter2 = 0;
		switches[6].doAction = 0;
	}
	else if (switches[6].doAction == 2)
	{
		animating |= (1 << 3);
		counter2 = 0;
		switches[6].doAction = 0;
	}
	
	if (switches[7].doAction == 1)
	{
		animating |= (1 << 5);
		counter3 = 0;
		switches[7].doAction = 0;
		for (unsigned long z = 0; z < 5; z++)
			ReleaseSwitch(z, obj, NO);
		for (unsigned long q = 0; q < 5; q++)
		{
			switches[q].time = 0.01;
			switches[q].doAction = 0;
			switches[q].counter = 0;
			switches[q].midCurve = nil;
			switches[q].lookCurve = nil;
			switches[q].hasCamera = NO;
			switches[q].cTime = 0;
		}
		lastDown = -1;
	}
	
	if (lastDown < 4)
	{
		for (unsigned long z = 0; z < 5; z++)
		{
			if (z == lastDown + 1 && switches[z].doAction == 1)
			{
				switches[z].time = 0;
				switches[z].doAction = 0;
				lastDown++;
			}
			else if (switches[z].doAction == 1)
			{
				for (unsigned long q = 0; q < 5; q++)
				{
					switches[q].time = 0.01;
					switches[q].doAction = 0;
					switches[q].counter = 0;
					switches[q].midCurve = nil;
					switches[q].lookCurve = nil;
					switches[q].hasCamera = NO;
					switches[q].cTime = 0;
				}
				lastDown = -1;
				break;
			}	
		}
	}	
	else if (lastDown == 4)
	{
		lastDown++;
		ReleaseSwitch(7, obj, NO);
		counter3 = 0;
		animating |= (1 << 4);
		
		switches[4].hasCamera = YES;
		switches[4].midCurve = MDOtherObjectNamed(@"Mid Curve");
		switches[4].lookCurve = MDOtherObjectNamed(@"Look Curve");
		switches[4].cTime = 2;
		switches[4].animation = 2;
		switches[4].cCounter = 0;
		customCamera = TRUE;
		if (switches[4].midCurve)
		{
			std::vector<MDVector3> points = *[ switches[4].midCurve curvePoints ];
			MDVector3 camHeight = MDVector3Create(0, zAngle, 0);
			points[0] = midPoint + camHeight;		
			midPoint += camHeight;
			[ switches[4].midCurve setPoints:points ];
		}
		if (switches[4].lookCurve)
		{
			std::vector<MDVector3> points = *[ switches[4].lookCurve curvePoints ];
			MDVector3 camHeight = MDVector3Create(sin(rotateZAngle / 180 * M_PI), cos(rotateZAngle / 180 * M_PI), 0);
			points[0] = lookPoint + camHeight;
			lookPoint += camHeight;
			[ switches[4].lookCurve setPoints:points ];		}
	}	
		
	if (animating & (1 << 0))
	{
		counter += MDElapsedTime() / 1000.0;
		
		// Door
		MDObject* left = MDObjectWithName(@"Left Left Door", @"Gray Wall");
		MDObject* right = MDObjectWithName(@"Left Right Door", @"Gray Wall");
		
		float real = MDTweenEaseOutQuadratic(counter * 2);
		
		MDSetObjectPosition(left, MDVector3Create(-30.5 , -10.75, -32.5 + real * 5));
		MDSetObjectPosition(right, MDVector3Create(-30.5, -10.75, -37.5 - real * 5));
		
		if (counter > 0.5)
		{
			counter = 0;
			animating &= ~(1 << 0);
			
			MDSetObjectPosition(left, MDVector3Create(-30.5, -10.75, -27.5));
			MDSetObjectPosition(right, MDVector3Create(-30.5, -10.75, -42.5));
		}
	}
	else if (animating & (1 << 1))
	{
		counter += MDElapsedTime() / 1000.0;
		
		// Door
		MDObject* left = MDObjectWithName(@"Left Left Door", @"Gray Wall");
		MDObject* right = MDObjectWithName(@"Left Right Door", @"Gray Wall");
		
		float real = MDTweenEaseOutQuadratic(counter * 2);
		
		MDSetObjectPosition(left, MDVector3Create(-30.5 , -10.75, -27.5 - real * 5));
		MDSetObjectPosition(right, MDVector3Create(-30.5, -10.75, -42.5 + real * 5));
		
		if (counter > 0.5)
		{
			counter = 0;
			animating &= ~(1 << 1);
			
			MDSetObjectPosition(left, MDVector3Create(-30.5, -10.75, -32.5));
			MDSetObjectPosition(right, MDVector3Create(-30.5, -10.75, -37.5));
		}
	}
	if (animating & (1 << 2))
	{
		counter2 += MDElapsedTime() / 1000.0;
		
		// Door
		MDObject* left = MDObjectWithName(@"Left Mid Door", @"Gray Wall");
		MDObject* right = MDObjectWithName(@"Right Mid Door", @"Gray Wall");
		
		float real = MDTweenEaseOutQuadratic(counter2 * 2);
		
		MDSetObjectPosition(left, MDVector3Create(-2.5 - real * 5, 4.25, 15));
		MDSetObjectPosition(right, MDVector3Create(2.5 + real * 5, 4.25, 15));
		
		if (counter2 > 0.5)
		{
			counter2 = 0;
			animating &= ~(1 << 2);
			
			MDSetObjectPosition(left, MDVector3Create(-7.5, 4.25, 15));
			MDSetObjectPosition(right, MDVector3Create(7.5, 4.25, 15));
		}
	}
	else if (animating & (1 << 3))
	{
		counter2 += MDElapsedTime() / 1000.0;
		
		// Door
		MDObject* left = MDObjectWithName(@"Left Mid Door", @"Gray Wall");
		MDObject* right = MDObjectWithName(@"Right Mid Door", @"Gray Wall");
		
		float real = MDTweenEaseOutQuadratic(counter2 * 2);
		
		MDSetObjectPosition(left, MDVector3Create(-7.5 + real * 5, 4.25, 15));
		MDSetObjectPosition(right, MDVector3Create(7.5 - real * 5, 4.25, 15));
		
		if (counter2 > 0.5)
		{
			counter2 = 0;
			animating &= ~(1 << 3);
			
			MDSetObjectPosition(left, MDVector3Create(-2.5, 4.25, 15));
			MDSetObjectPosition(right, MDVector3Create(2.5, 4.25, 15));
		}
	}
	if (animating & (1 << 4))
	{
		counter3 += MDElapsedTime() / 1000.0;
		
		// Floor
		MDObject* floor = MDObjectWithName(@"Floor", @"Gray Wall");
		
		float real = MDTweenEaseOutQuadratic(counter3);
		MDSetObjectPosition(floor, MDVector3Create(0, -15 + real * 15, -35));
		
		if (counter3 > 1)
		{
			counter3 = 0;
			animating &= ~(1 << 4);
			
			MDSetObjectPosition(floor, MDVector3Create(0, 0, -35));
		}
	}
	else if (animating & (1 << 5))
	{
		counter3 += MDElapsedTime() / 1000.0;
		
		// Floor
		MDObject* floor = MDObjectWithName(@"Floor", @"Gray Wall");
		
		float real = MDTweenEaseOutQuadratic(counter3);
		MDSetObjectPosition(floor, MDVector3Create(0, 0 - real * 15, -35));
		
		if (counter3 > 1)
		{
			counter3 = 0;
			animating &= ~(1 << 5);
			
			MDSetObjectPosition(floor, MDVector3Create(0, -15, -35));
		}
	}
}

void Shoot2(MDObject* obj)
{		
	static int animating2 = 0;
	static float counter2 = 0;
	
	if (targets[0].doAction == 1)
	{		
		animating2 = 1;
		counter2 = 0;
		targets[0].doAction = 0;
	}	
	else if (targets[0].doAction == -1)
	{		
		animating2 = 2;
		counter2 = 0;
		targets[0].doAction = 0;
		MDObject* wall = MDObjectWithName(@"Wall", @"Glass Wall");
		[ wall setShouldDraw:YES ];
		MDObjectEnable(wall);
	}	
	
	if (animating2 == 1)
	{
		counter2 += MDElapsedTime() / 1000.0;
		float real = MDTweenEaseInOutQuadratic(counter2);
		MDObject* wall = MDObjectWithName(@"Wall", @"Glass Wall");
		MDVector4 color = [ wall colorMultiplier ];
		[ wall setColorMultiplier:MDVector4Create(color.x, color.y, color.z, 1 - real) ];
		
		if (counter2 > 1)
		{
			[ wall setShouldDraw:NO ];
			MDObjectDisable(wall);
			counter2 = 0;
			animating2 = 0;
		}
	}
	else if (animating2 == 2)
	{
		counter2 += MDElapsedTime() / 1000.0;
		float real = MDTweenEaseInOutQuadratic(counter2);
		MDObject* wall = MDObjectWithName(@"Wall", @"Glass Wall");
		MDVector4 color = [ wall colorMultiplier ];
		[ wall setColorMultiplier:MDVector4Create(color.x, color.y, color.z, real) ];
		
		if (counter2 > 1)
		{
			counter2 = 0;
			animating2 = 0;
		}
	}

	
	static float counter = 0;
	static int animating = 0;
	
	if (targets[1].doAction == 1)
	{
		animating = 1;
		counter = 0;
		targets[1].doAction = 0;
	}
	else if (targets[1].doAction == -1)
	{
		animating = 2;
		counter = 0;
		targets[1].doAction = 0;
	}
	
	if (animating == 1)
	{
		counter += MDElapsedTime() / 1000.0;
		
		// Bridge
		MDObject* bridge = MDObjectWithName(@"Bridge", @"Gray Wall");
		
		float real = MDTweenEaseInOutQuadratic(counter);
		MDSetObjectPosition(bridge, MDVector3Create(0, -14 + real * 14, -40));
		
		if (counter > 1)
		{
			counter = 0;
			animating = 0;
			
			MDSetObjectPosition(bridge, MDVector3Create(0, 0, -40));
		}
	}
	else if (animating == 2)
	{
		counter += MDElapsedTime() / 1000.0;
		
		// Bridge
		MDObject* bridge = MDObjectWithName(@"Bridge", @"Gray Wall");
		
		float real = MDTweenEaseInOutQuadratic(counter);
		MDSetObjectPosition(bridge, MDVector3Create(0, 0 - real * 14, -40));
		
		if (counter > 1)
		{
			counter = 0;
			animating = 0;
			
			MDSetObjectPosition(bridge, MDVector3Create(0, -14, -40));
		}
	}
}

void Shoot3(MDObject* obj)
{
	static float circleCounter = 0;
	
	unsigned int totalTargets = 0;
	for (unsigned long z = 0; z < 12; z++)
	{
		float angle = z * (360.0 / 12) / 180 * M_PI + circleCounter;
		MDObject* obj = targets[z].obj;
		if (![ obj shouldDraw ])
			continue;
		totalTargets++;
		MDSetObjectPosition(obj, MDVector3Create(sin(angle) * 10, 5 + cos(angle) * 10, -45));
	}
	
	for (unsigned long z = 0; z < 12; z++)
	{
		if (targets[z].doAction == 1)
		{
			targets[z].doAction = 0;
			[ targets[z].obj setShouldDraw:NO ];
			MDObjectDisable(targets[z].obj);
			
			float angle = z * (360.0 / 12) / 180 * M_PI;
			MDObject* box = MDObjectWithName([ NSString stringWithFormat:@"Object %i", z + 4 ], @"Box");
			MDSetObjectPosition(box, MDVector3Create(sin(angle) * 10, 29, 15 + cos(angle) * 10));
		}
	}
	
	circleCounter += 0.12 / totalTargets * MDElapsedTime() / 1000.0 * 60;
	if (circleCounter >= 2 * M_PI)
		circleCounter -= 2 * M_PI;
}

void Shoot4(MDObject* obj)
{
	static int animating = 0;
	static float counter = 0;
	static int targetIndex = 0;
	static int order[] = { 0, 3, 5, 6, 9 };
	static float zPoint = -30;
	static float startZ = 0;
	static float objZ = 0;
	static BOOL doObj = FALSE;
	
	if (switches[0].doAction == 1)
	{
		switches[0].doAction = 0;
		animating = 1;
		counter = 0;
	}
	
	if (animating == 1)
	{
		counter += MDElapsedTime() / 1000.0;
		if (counter >= 1)
		{
			counter = 0;
			animating = 2;	
			targetIndex = 0;
		}	
	}
	else if (animating == 2)
	{	
		[ targets[order[targetIndex]].obj setColorMultiplier:MDVector4Create(1, 1, 0, 1) ];
		float real = MDTweenEaseInOutQuadratic(counter * sizeof(order) / sizeof(int) / 2);
		[ targets[order[targetIndex]].obj setScaleX:real + 1 ];
		[ targets[order[targetIndex]].obj setScaleY:real + 1 ];
		
		counter += MDElapsedTime() / 1000.0;
		
		if (counter >= 2.0 / (sizeof(order) / sizeof(int)))
		{
			counter -= 2.0 / (sizeof(order) / sizeof(int));			[ targets[order[targetIndex]].obj setColorMultiplier:MDVector4Create(1, 1, 1, 1) ];
			targetIndex++;
			if (targetIndex == sizeof(order) / sizeof(int))
			{
				animating = 3;
				targetIndex = 0;
				counter = 0;	
			}	
		}
	}
	else if (animating == 3)
	{
		float real = MDTweenEaseInOutQuadratic(1 - counter);
		for (unsigned int z = 0; z < sizeof(order) / sizeof(int); z++)
		{
			[ targets[order[z]].obj setScaleX:real + 1 ];
			[ targets[order[z]].obj setScaleY:real + 1 ];
		}
		counter += MDElapsedTime() / 1000.0;
		if (counter >= 1)
		{
			for (unsigned int z = 0; z < sizeof(order) / sizeof(int); z++)
			{
				[ targets[order[z]].obj setScaleX:1 ];
				[ targets[order[z]].obj setScaleY:1 ];
			}
			counter = 0;
			animating = 0;
		}
	}
	else if (animating == 4)
	{
		MDObject* platform = MDObjectWithName(@"Platform", @"Platform");
		MDVector3 mid = [ platform midPoint ];
		MDVector3 objMid = [ obj midPoint ];
		
		float real = MDTweenEaseInOutQuadratic(counter * 1);
		MDSetObjectPosition(platform, MDVector3Create(mid.x, mid.y, startZ + (zPoint - startZ) * real));
		if (doObj)
			MDSetObjectPosition(obj, MDVector3Create(objMid.x, objMid.y, objZ + (zPoint - startZ) * real));
		
		counter += MDElapsedTime() / 1000.0;
		if (counter >= 1)
		{
			counter = 0;
			animating = 0;
			MDSetObjectPosition(platform, MDVector3Create(mid.x, mid.y, zPoint));
			if (doObj)
				MDSetObjectPosition(obj, MDVector3Create(objMid.x, objMid.y, objZ + zPoint - startZ));
			//canMove = TRUE;
			doObj = FALSE;
		}
	}
	
	if (targetIndex < sizeof(order) / sizeof(int))
	{
		for (unsigned int z = 0; z < targets.size(); z++)
		{
			if (targets[z].doAction != 0)
			{
				MDObject* platform = MDObjectWithName(@"Platform", @"Platform");
				targets[z].doAction = 0;
				if (z == order[targetIndex])
				{
					animating = 4;
					counter = 0;
					zPoint -= 15;
					if (targetIndex == sizeof(order) / sizeof(int) - 1)
						zPoint = -127.5;
					MDVector3 platMid = [ platform midPoint ];
					startZ = platMid.z;
					MDVector3 objMid = [ obj midPoint ];
					objZ = objMid.z;
					doObj = (objMid.x >= platMid.x - 6 && objMid.x <= platMid.x + 6 &&
						objMid.y >= platMid.y - 8 && objMid.y <= platMid.y + 3 &&
						objMid.z >= platMid.z - 6 && objMid.z <= platMid.z + 6 &&
						!jumping);
					targetIndex++;
					if (!switches[0].down)
					{	
						PushSwitch(0, obj, NO);
						customCamera = FALSE;
						switches[0].animation = 5;
					}	
					break;
				}
				else
				{
					animating = 4;
					counter = 0;
					zPoint = -30;
					MDVector3 platMid = [ platform midPoint ];
					startZ = platMid.z;
					MDVector3 objMid = [ obj midPoint ];
					objZ = objMid.z;
					doObj = (objMid.x >= platMid.x - 6 && objMid.x <= platMid.x + 6 &&
						objMid.y >= platMid.y - 8 && objMid.y <= platMid.y + 3 &&
						objMid.z >= platMid.z - 6 && objMid.z <= platMid.z + 6 &&
						!jumping);
					ReleaseSwitch(0, obj, NO);
					targetIndex = 0;
					
					for (unsigned int q = 0; q < targets.size(); q++)
					{
						targets[q].state = 0;
						targets[q].changed = TRUE;
					}
					break;
				}	
			}
		}
	}
	else
	{
		for (unsigned int z = 0; z < targets.size(); z++)
		{
			if (targets[z].doAction == 1)
			{
				MDObject* platform = MDObjectWithName(@"Platform", @"Platform");
				targets[z].doAction = 0;
				animating = 4;
				counter = 0;
				zPoint = -30;
				MDVector3 platMid = [ platform midPoint ];
				startZ = platMid.z;
				MDVector3 objMid = [ obj midPoint ];
				objZ = objMid.z;
				doObj = (objMid.x >= platMid.x - 6 && objMid.x <= platMid.x + 6 &&
					objMid.y >= platMid.y - 8 && objMid.y <= platMid.y + 3 &&
					objMid.z >= platMid.z - 6 && objMid.z <= platMid.z + 6 &&
					!jumping);
				ReleaseSwitch(0, obj, NO);
				targetIndex = 0;
				for (unsigned int q = 0; q < targets.size(); q++)
				{
					targets[q].state = 0;
					targets[q].changed = TRUE;
				}
				break;
			}	
		}	
	}
}

void LoadShoot5()
{
	for (unsigned long z = 0; z < 5; z++)
		MDObjectDisable([ boxes objectAtIndex:z ]);
}

void Shoot5(MDObject* obj)
{
	static int part;
	static float timing[5];
	static int animating = 0;
	
	if (switches[0].doAction)
	{
		for (unsigned long z = 0; z < 5; z++)
		{
			timing[z] = 0;
			targets[z].state = 0;
			[ targets[z].obj setColorMultiplier:MDVector4Create(1, 1, 1, 1) ];
			MDSetObjectPosition(targets[z].obj, MDVector3Create(-10 + z * 5, 40, -45));
		}
		part = 0;
		switches[0].doAction = 0;
		animating = 0;
	}
	
	// Only do the target game if the switch is down
	if (switches[0].down)
	{
		if (part == 0)
		{
			float real = MDTweenEaseOutQuadratic(timing[0]);
			MDSetObjectPosition(targets[0].obj, MDVector3Create(0, -17.5 + 25 * real, -45));
			
			timing[0] += MDElapsedTime() / 1000.0;
			if (timing[0] > 1)
			{
				timing[0] = 0;
				MDSetObjectPosition(targets[0].obj, MDVector3Create(0, 7.5, -45));
				part++;
			}
		}
		else if (part == 1)
		{
			timing[0] += MDElapsedTime() / 1000.0;
			if (timing[0] > 1.0)
			{
				timing[0] = 0;
				part++;
			}
		}
		else if (part == 2)
		{
			float real = MDTweenEaseInQuadratic(timing[0]);
			MDSetObjectPosition(targets[0].obj, MDVector3Create(0, 7.5 + 25 * real, -45));
			
			timing[0] += MDElapsedTime() / 1000.0;
			if (timing[0] > 1)
			{
				if (!targets[0].state)
				{
					part = -1;
					switches[0].animation = 6;
				}
				else
				{
					timing[0] = 0;
					part++;
					animating |= (1 << 0);
					
					targets[0].state = 0;
					[ targets[0].obj setColorMultiplier:MDVector4Create(1, 1, 1, 1) ];
				}
			}
		}
		else if (part == 3)
		{
			if (animating & (1 << 0))
			{
				float real = MDTweenEaseOutQuadratic(timing[0]);
				MDSetObjectPosition(targets[0].obj, MDVector3Create(-5, -17.5 + 25 * real, -45));
			
				timing[0] += MDElapsedTime() / 1000.0;
				if (timing[0] > 1 / 3.0)
					animating |= (1 << 3);
				if (timing[0] > 1)
				{
					timing[0] = 0;
					MDSetObjectPosition(targets[0].obj, MDVector3Create(-5, 7.5, -45));
					animating &= ~(1 << 0);
					animating |= (1 << 1);
				}
			}
			else if (animating & (1 << 1))
			{
				timing[0] += MDElapsedTime() / 1000.0;
				if (timing[0] > 2)
				{
					timing[0] = 0;
					animating &= ~(1 << 1);
					animating |= (1 << 2);
				}
			}
			else if (animating & (1 << 2))
			{
				float real = MDTweenEaseInQuadratic(timing[0]);
				MDSetObjectPosition(targets[0].obj, MDVector3Create(-5, 7.5 + 25 * real, -45));
				
				timing[0] += MDElapsedTime() / 1000.0;
				if (timing[0] > 1)
				{
					timing[0] = 0;
					animating &= ~(1 << 2);
				}
			}
			if (animating & (1 << 3))
			{
				float real = MDTweenEaseOutQuadratic(timing[1]);
				MDSetObjectPosition(targets[1].obj, MDVector3Create(0, -17.5 + 25 * real, -45));
				
				timing[1] += MDElapsedTime() / 1000.0;
				if (timing[1] > 1 / 3.0)
					animating |= (1 << 6);
				if (timing[1] > 1)
				{
					timing[1] = 0;
					MDSetObjectPosition(targets[1].obj, MDVector3Create(0, 7.5, -45));
					animating &= ~(1 << 3);
					animating |= (1 << 4);
				}
			}
			else if (animating & (1 << 4))
			{
				timing[1] += MDElapsedTime() / 1000.0;
				if (timing[1] > 2)
				{
					timing[1] = 0;
					animating &= ~(1 << 4);
					animating |= (1 << 5);
				}
			}
			else if (animating & (1 << 5))
			{
				float real = MDTweenEaseInQuadratic(timing[1]);
				MDSetObjectPosition(targets[1].obj, MDVector3Create(0, 7.5 + 25 * real, -45));
				
				timing[1] += MDElapsedTime() / 1000.0;
				if (timing[1] > 1)
				{
					timing[1] = 0;
					animating &= ~(1 << 5);
				}
			}
			if (animating & (1 << 6))
			{
				float real = MDTweenEaseOutQuadratic(timing[2]);
				MDSetObjectPosition(targets[2].obj, MDVector3Create(5, -17.5 + 25 * real, -45));
				
				timing[2] += MDElapsedTime() / 1000.0;
				if (timing[2] > 1)
				{
					timing[2] = 0;
					MDSetObjectPosition(targets[2].obj, MDVector3Create(5, 7.5, -45));
					animating &= ~(1 << 6);
					animating |= (1 << 7);
				}
			}
			else if (animating & (1 << 7))
			{
				timing[2] += MDElapsedTime() / 1000.0;
				if (timing[2] > 2)
				{
					timing[2] = 0;
					animating &= ~(1 << 7);
					animating |= (1 << 8);
				}
			}
			else if (animating & (1 << 8))
			{
				float real = MDTweenEaseInQuadratic(timing[2]);
				MDSetObjectPosition(targets[2].obj, MDVector3Create(5, 7.5 + 25 * real, -45));
				
				timing[2] += MDElapsedTime() / 1000.0;
				if (timing[2] > 1)
				{
					if (!targets[0].state || !targets[1].state || !targets[2].state)
					{
						part = -1;
						switches[0].animation = 6;
					}
					else
					{
						for (unsigned long z = 0; z < 3; z++)
						{
							timing[z] = 0;
							targets[z].state = 0;
							[ targets[z].obj setColorMultiplier:MDVector4Create(1, 1, 1, 1) ];
						}
						animating &= ~(1 << 8);
						part++;
					}
				}
			}
		}
		else if (part == 4)
		{
			for (unsigned long z = 0; z < 5; z++)
			{
				float real = MDTweenLinear((timing[0] / 6) - z / 5.0);
				if (real < 0)
					real = 0;
				MDSetObjectPosition(targets[z].obj, MDVector3Create(-32 + real * 64, 7.5, -45));
			}
			
			timing[0] += MDElapsedTime() / 1000.0;
			if (timing[0] > 6 + 30 / 5.0)
			{
				if (!targets[0].state || !targets[1].state || !targets[2].state || !targets[3].state || !targets[4].state)
				{
					part = -1;
					switches[0].animation = 6;
				}
				else
				{
					for (unsigned long z = 0; z < 5; z++)
					{
						timing[z] = 0;
						targets[z].state = 0;
						[ targets[z].obj setColorMultiplier:MDVector4Create(1, 1, 1, 1) ];
					}
					part++;
				}
			}
		}
		else if (part == 5)
		{
			for (unsigned long z = 0; z < 3; z++)
			{
				if (timing[0] < (1 + z / 3.0) / 2)
				{
					float real = MDTweenEaseInOutQuadratic((timing[0] * 2 - z / 3.0));
					if ((timing[0] * 2 - z / 3.0) < 0)
						real = 0;
					[ targets[z].obj setColorMultiplier:MDVector4Create(1, 1, 1, real) ];
					MDSetObjectPosition(targets[z].obj, MDVector3Create(-5.0 + z * 5, 7.5, -45));
				}
				else
					[ targets[z].obj setColorMultiplier:MDVector4Create(1, 1, 1, 1) ];
			}
			
			timing[0] += MDElapsedTime() / 1000.0;
			if (timing[0] > 1)
			{
				timing[0] = 0;
				part++;
			}
		}
		else if (part == 6)
		{
			for (unsigned long z = 0; z < 3; z++)
			{
				float real = MDTweenLinear((timing[0] / 3) - z / 10.0);
				if (real < 0)
					real = 0;
				MDSetObjectPosition(targets[z].obj, MDVector3Create(-5.0 + z * 5, 7.5 + sin(real * M_PI * 2) * 5, -45));
			}
			
			timing[0] += MDElapsedTime() / 1000.0;
			if (timing[0] > 6 + 15 / 10.0)
			{
				timing[0] = 0;
				part++;
			}
		}
		else if (part == 7)
		{
			for (unsigned long z = 0; z < 3; z++)
			{
				if (timing[0] < (1 + z / 3.0) / 2)
				{
					float real = MDTweenEaseInOutQuadratic((timing[0] * 2 - z / 3.0));
					if ((timing[0] * 2 - z / 3.0) < 0)
						real = 0;
					real = 1 - real;
					MDVector4 color = MDVector4Create(1, 1, 1, real);
					if (targets[z].state)
						color = MDVector4Create(1, 1, 0, real);
					[ targets[z].obj setColorMultiplier:color ];
				}
				else
					[ targets[z].obj setColorMultiplier:MDVector4Create(1, 1, 1, 0) ];
			}
			
			timing[0] += MDElapsedTime() / 1000.0;
			if (timing[0] > 1)
			{
				if (!targets[0].state || !targets[1].state || !targets[2].state)
				{
					part = -1;
					switches[0].animation = 6;
				}
				else
				{
					for (unsigned long z = 0; z < 5; z++)
					{
						timing[z] = 0;
						targets[z].state = 0;
						[ targets[z].obj setColorMultiplier:MDVector4Create(1, 1, 1, 1) ];
						MDSetObjectPosition(targets[z].obj, MDVector3Create(-10 + z * 5, 40, -45));
					}
					part++;
					if ([ boxes count ] < 5)
						part++;
				}
			}
		}
		else if (part == 8)
		{
			for (unsigned long z = 0; z < 5; z++)
			{
				if (timing[0] < 1 + z / 5)
				{
					float real = MDTweenEaseInOutQuadratic(timing[0] - z / 5.0);
					if (timing[0] - z / 5.0 < 0)
						real = 0;
					[ [ boxes objectAtIndex:z ] setColorMultiplier:MDVector4Create(1, 1, 1, real) ];
				}
				else
				{
					[ [ boxes objectAtIndex:z ] setColorMultiplier:MDVector4Create(1, 1, 1, 1) ];
					MDObjectEnable([ boxes objectAtIndex:z ]);
				}
			}
			
			timing[0] += MDElapsedTime() / 1000.0;
			if (timing[0] > 2)
			{
				timing[0] = 0;
				part = -1;
			}
		}
	}
}

void LoadBlueBox1()
{
	PushSwitch(1, MDObjectWithName(@"Player", @"Player"), NO);
}

void BlueBox1(MDObject* obj)
{
	static float counter = 0;
	static int animating = 0;
	static float oldCam = 0;
	
	if (switches[0].doAction == 1)
	{
		switches[0].doAction = 0;
		// Set gravity to be up
		SetGravityBlue(MDVector3Create(0, gravityStrength, 0));
		counter = 0;
		animating = 1;
		canMove = FALSE;
		oldCam = cameraHeight;
	}
	else if (switches[1].doAction == 1)
	{
		switches[1].doAction = 0;
		// Set gravity to be down
		SetGravityBlue(MDVector3Create(0, -gravityStrength, 0));
		counter = 0;
		animating = 2;
		canMove = FALSE;
		oldCam = cameraHeight;
	}
	
	if (animating == 1)
	{
		rotateZAngle = 180 * MDTweenEaseInOutQuadratic(counter);
		cameraHeight = oldCam * (1 - (counter * 2));
		counter += MDElapsedTime() / 1000.0;
		if (counter > 1)
		{
			counter = 0;
			rotateZAngle = 180;
			animating = 0;
			canMove = TRUE;
			zAngle = -1;
			ReleaseSwitch(1, obj, NO);
			cameraHeight = -oldCam;
		}
	}
	else if (animating == 2)
	{
		rotateZAngle = 180 - 180 * MDTweenEaseInOutQuadratic(counter);
		cameraHeight = oldCam * (1 - (counter * 2));
		counter += MDElapsedTime() / 1000.0;
		if (counter > 1)
		{
			counter = 0;
			rotateZAngle = 0;
			animating = 0;
			canMove = TRUE;
			zAngle = 1;
			ReleaseSwitch(0, obj, NO);
			cameraHeight = -oldCam;
		}
	}
}

BOOL reset = FALSE;
void LoadBlueBox2()
{
	for (unsigned long z = 2; z < [ boxes count ]; z++)
		MDObjectDisable([ boxes objectAtIndex: z ]);
	reset = TRUE;
}

void BlueBox2(MDObject* obj)
{
	static float counter = 0;
	static int animating = 0;
	static MDVector3 boxPos;
	static float boxRot;
	static BOOL hit = FALSE;
	
	if (reset)
	{
		hit = FALSE;
		reset = FALSE;
	}
	
	MDObject* box = nil;
	if ([ boxes count ] != 0)
		box = [ boxes objectAtIndex:0 ];
	
	if (switches[0].doAction == 1)
	{
		switches[0].doAction = 0;
		counter = 0;
		animating = 1;
		boxPos = MDObjectPosition(box);
		MDObjectRotation(box, &boxRot);
		MDSetLinearVelocity(box, MDVector3Create(0, 0, 0));
		MDSetAngularVelocity(box, MDVector3Create(0, 0, 0));
	}
	
	if (animating == 1)
	{
		if (counter > 1)
		{
			float real = MDTweenEaseOutElastic(counter - 1);
			
			MDSetObjectPosition(box, boxPos + ((MDVector3Create(0, 7.5, -25) - boxPos) * real));
			MDSetObjectRotation(box, MDObjectRotation(box, NULL), boxRot * (1 - real));
		}
		
		counter += MDElapsedTime() / 1000.0;
		
		if (counter >  2)
		{			
			MDSetObjectPosition(box, MDVector3Create(0, 7.5, -25));
			MDSetObjectRotation(box, MDVector3Create(0, 0, 0), 0);
			
			counter = 0;
			animating = 0;
		}
	}
	else if (animating == 2)
	{
		float real = MDTweenEaseInOutQuadratic(counter);
		for (unsigned long z = 2; z < [ boxes count ]; z++)
			[ [ boxes objectAtIndex:z ] setColorMultiplier:MDVector4Create(1, 1, 1, real) ];
		
		counter += MDElapsedTime() / 1000.0;
		
		if (counter > 1)
		{
			for (unsigned long z = 2; z < [ boxes count ]; z++)
			{
				[ [ boxes objectAtIndex:z ] setColorMultiplier:MDVector4Create(1, 1, 1, 1) ];
				MDObjectEnable([ boxes objectAtIndex:z ]);
			}	
			counter = 0;
			animating = 0;
		}
	}
	
	if (!hit && MDVector3Distance([ box midPoint ], [ targets[0].obj midPoint ]) < 5.5 &&
		[ box midPoint ].z < -48.5)
	{
		targets[0].state = 1;
		targets[0].changed = 1;
		hit = TRUE;
		if ([ [ boxes objectAtIndex:2 ] colorMultiplier ].w < 0.5)
		{
			animating = 2;
			counter = 0;
		}	
	}
	
	if (!hit)
	{
		targets[0].changed = FALSE;
		targets[0].state = 0;
		[ targets[0].obj setColorMultiplier:MDVector4Create(1, 1, 1, 1) ];
	}
	else if (!targets[0].changed && targets[0].state == 1)
	{
		targets[0].changed = 1;
		targets[0].state = 0;
	}	
	//else if (!targets[0].changed)
	//	hit = FALSE;
}

void BlueBox3(MDObject* obj)
{
	static float counter = 0;
	static int animating = 0;
	static MDVector3 gravPos;
	
	if (switches[0].doAction)
	{
		switches[0].doAction = 0;
		
		if (grabObject != gravities[0].obj)
		{
			counter = 0;
			animating = 1;
			gravPos = MDObjectPosition(gravities[0].obj);
			MDSetLinearVelocity(gravities[0].obj, MDVector3Create(0, 0, 0));
			MDSetAngularVelocity(gravities[0].obj, MDVector3Create(0, 0, 0));
		}
	}
	
	if (animating == 1)
	{
		float real = MDTweenEaseOutElastic(counter);
		
		MDSetObjectPosition(gravities[0].obj, gravPos + ((MDVector3Create(0, 3, 0) - gravPos) * real));
		
		counter += MDElapsedTime() / 1000.0;
		if (counter > 1)
		{
			MDSetObjectPosition(gravities[0].obj, MDVector3Create(0, 3, 0));
			counter = 0;
			animating = 0;
		}
	}
}

void BlueBox4(MDObject* obj)
{
	static float counter = 0;
	static int animating = 0;
	static MDVector3 gravPos;
	
	if (switches[0].doAction)
	{
		switches[0].doAction = 0;
		
		if (grabObject != gravities[0].obj)
		{
			counter = 0;
			animating = 1;
			gravPos = MDObjectPosition(gravities[0].obj);
			MDSetLinearVelocity(gravities[0].obj, MDVector3Create(0, 0, 0));
			MDSetAngularVelocity(gravities[0].obj, MDVector3Create(0, 0, 0));
		}
	}
	
	MDVector3 gravityMid = [ gravities[0].obj midPoint ];
	if (animating == 1)
	{
		float real = MDTweenEaseOutElastic(counter);
		
		MDSetObjectPosition(gravities[0].obj, gravPos + ((MDVector3Create(0, 20, -25) - gravPos) * real));
		
		counter += MDElapsedTime() / 1000.0;
		if (counter > 1)
		{
			MDSetObjectPosition(gravities[0].obj, MDVector3Create(0, 20, -25));
			counter = 0;
			animating = 0;
		}
	}
	else
	{
		// Controls
		const float speed = 0.1;
		if (switches[1].down && switches[1].animation != 6)	// Move down
			MDSetObjectPosition(gravities[0].obj, gravityMid + MDVector3Create(0, -speed, 0));
		if (switches[2].down && switches[2].animation != 6)	// Move up
			MDSetObjectPosition(gravities[0].obj, gravityMid + MDVector3Create(0, speed, 0));
		if (switches[3].down && switches[3].animation != 6)	// Move Right
			MDSetObjectPosition(gravities[0].obj, gravityMid + MDVector3Create(speed, 0, 0));
		if (switches[4].down && switches[4].animation != 6)	// Move Left
			MDSetObjectPosition(gravities[0].obj, gravityMid + MDVector3Create(-speed, 0, 0));
		MDSetLinearVelocity(gravities[0].obj, MDVector3Create(0, 0, 0));
	}
	
	// Check if any box goes above the top wall
	for (unsigned long z = 0; z < [ blueBoxes count ]; z++)
	{
		if (MDObjectPosition([ blueBoxes objectAtIndex:z ]).y > 30.5)
			MDSetObjectPosition([ blueBoxes objectAtIndex:z ], MDVector3Create(0, 20, -25));
	}
	
	MDSetObjectPosition(MDObjectWithName(@"Top Box", @"Gray Wall"), gravityMid + MDVector3Create(0, 1.5, 0));
	MDSetObjectPosition(MDObjectWithName(@"Bottom Box", @"Gray Wall"), gravityMid + MDVector3Create(0, -1.5, 0));
	MDSetObjectPosition(MDObjectWithName(@"Left Box", @"Gray Wall"), gravityMid + MDVector3Create(-1.5, 0, 0));
	MDSetObjectPosition(MDObjectWithName(@"Right Box", @"Gray Wall"), gravityMid + MDVector3Create(1.5, 0, 0));
}

void BlueBox5(MDObject* obj)
{
	static float counter = 0, counter1 = 0;
	static int animating = 0;
	static MDVector3 gravPos;
	
	if (switches[0].doAction)
	{
		switches[0].doAction = 0;
		
		if (grabObject != gravities[0].obj)
		{
			counter = 0;
			animating |= (1 << 0);
			gravPos = MDObjectPosition(gravities[0].obj);
			MDSetLinearVelocity(gravities[0].obj, MDVector3Create(0, 0, 0));
			MDSetAngularVelocity(gravities[0].obj, MDVector3Create(0, 0, 0));
		}
	}
	
	MDObject* plat = MDObjectWithName(@"Platform 1", @"Platform");
	MDVector3 platMid = [ plat midPoint ];
	if (switches[1].down && platMid.y > 10 && animating < 2)
	{
		animating |= (1 << 1);
		counter1 = 0;
	}
	else if (!switches[1].down && platMid.y < 10 && animating < 2)
	{
		animating |= (1 << 2);
		counter1 = 0;
	}
	
	if (animating & (1 << 0))
	{
		float real = MDTweenEaseOutElastic(counter);
		
		MDSetObjectPosition(gravities[0].obj, gravPos + ((MDVector3Create(0, 2, 0) - gravPos) * real));
		
		counter += MDElapsedTime() / 1000.0;
		if (counter > 1)
		{
			MDSetObjectPosition(gravities[0].obj, MDVector3Create(0, 2, 0));
			counter = 0;
			animating &= ~(1 << 0);
		}
	}
	if (animating & (1 << 1))
	{
		float real = MDTweenEaseInOutQuadratic(counter1);
		
		MDSetObjectPosition(plat, MDVector3Create(25, 4 + 16 * (1 -real), -15));
		
		counter1 += MDElapsedTime() / 1000.0 * MDFPS() / 60.0;
		if (counter1 > 1)
		{
			MDSetObjectPosition(plat, MDVector3Create(25, 4, -15));
			counter1 = 0;
			animating &= ~(1 << 1);
		}
	}
	else if (animating & (1 << 2))
	{
		float real = MDTweenEaseInOutQuadratic(counter1);
		
		MDSetObjectPosition(plat, MDVector3Create(25, 4 + 16 * real, -15));
		
		counter1 += MDElapsedTime() / 1000.0 * MDFPS() / 60.0;
		if (counter1 > 1)
		{
			MDSetObjectPosition(plat, MDVector3Create(25, 20, -15));
			counter1 = 0;
			animating &= ~(1 << 2);
		}
	}
}

void InitLevels()
{
	for (unsigned long y = 0; y < NUM_PACKS; y++)
	{
		for (unsigned long z = 0; z < NUM_LEVELS; z++)
		{
			LoadLevelFunctions[y][z] = EmptyFunction;
			UpdateLevelFunctions[y][z] = EmptyFunction2;
		}
	}	
	
	// Intro
	LoadLevelFunctions[0][4] = LoadLevel4;
	LoadLevelFunctions[0][6] = LoadLevel6;
	LoadLevelFunctions[0][7] = LoadLevel7;
	LoadLevelFunctions[0][10] = LoadLevel10;
	LoadLevelFunctions[0][11] = LoadLevel11;
	
	UpdateLevelFunctions[0][5] = Level5;
	UpdateLevelFunctions[0][6] = Level6;
	UpdateLevelFunctions[0][7] = Level7;
	UpdateLevelFunctions[0][8] = Level8;
	UpdateLevelFunctions[0][9] = Level9;
	UpdateLevelFunctions[0][10] = Level10;
	UpdateLevelFunctions[0][11] = Level11;
	
	// Shoot
	LoadLevelFunctions[1][5] = LoadShoot5;
	
	UpdateLevelFunctions[1][2] = Shoot2;
	UpdateLevelFunctions[1][3] = Shoot3;
	UpdateLevelFunctions[1][4] = Shoot4;
	UpdateLevelFunctions[1][5] = Shoot5;
	
	// The Blue Box
	LoadLevelFunctions[2][1] = LoadBlueBox1;
	LoadLevelFunctions[2][2] = LoadBlueBox2;

	UpdateLevelFunctions[2][1] = BlueBox1;
	UpdateLevelFunctions[2][2] = BlueBox2;
	UpdateLevelFunctions[2][3] = BlueBox3;
	UpdateLevelFunctions[2][4] = BlueBox4;
	UpdateLevelFunctions[2][5] = BlueBox5;
}
