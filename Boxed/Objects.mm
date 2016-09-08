// Objects.mm

#import "Objects.h"

BOOL paused = FALSE;

// Cache
std::vector<MovingPlatform> platforms;
std::vector<Switch> switches;
std::vector<Target> targets;
std::vector<Gravity> gravities;
NSMutableArray* barrels = nil;

// Camera stuff
MDVector3 midPoint;
MDVector3 lookPoint;
float rotateAngle = M_PI;
float rotateZAngle = 0;
float cameraHeight = 0;
BOOL customCamera = FALSE;
float zAngle = 1;

// Movement
BOOL jumping = FALSE;
BOOL canMove = TRUE;
float changeVel = 0;
MDVector3 oldVel;
float gravityStrength = 25;

// Collection
unsigned int boxesCollected = 0;
unsigned int totalBoxes = 0;
int boxCollecting = 0;
float boxCollectAlpha = 0;
NSMutableArray* boxes = nil;
NSMutableArray* blueBoxes = nil;
GLString* boxString = nil, *collectedString = nil, *bulletString = nil;

// Level
int loadSame = 0;
BOOL inMenu = TRUE;
int loadedLevel = -1;
int loadedPack = -1;
int items = MD_NONE;
NSMutableArray* bullets = nil;

void PushSwitch(unsigned int z, MDObject* obj, BOOL action)
{
	float sign = switches[z].originalScale / fabs(switches[z].originalScale);
	switches[z].obj.scaleY = 0.034 * sign;
	switches[z].obj.translateY = switches[z].originalTranslate - switches[z].originalScale / 2 + 0.01 * sign;
	switches[z].dCounter = 2;
	MDObjectDisable(switches[z].obj);
	if (switches[z].hasCamera && !customCamera)
	{
		switches[z].animation = 2;
		customCamera = TRUE;
	}
	else
		switches[z].animation = 5;
	switches[z].down = TRUE;
	switches[z].doAction = (action ? 1 : 0);
}

void ReleaseSwitch(unsigned int z, MDObject* obj, BOOL action)
{
	switches[z].obj.scaleY = switches[z].originalScale;
	switches[z].obj.translateY = switches[z].originalTranslate;
	switches[z].dCounter = 0;
	MDObjectEnable(switches[z].obj);
	if (switches[z].hasEnd && !customCamera)
	{
		switches[z].animation = 7;
		customCamera = TRUE;
	}	
	else
		switches[z].animation = 0;
	switches[z].down = FALSE;
	switches[z].doAction = (action ? 2 : 0);
}

void LoadScene()
{
	NSMutableArray* objects = MDObjects();
	// Cache objects
	platforms.clear();
	switches.clear();
	targets.clear();
	gravities.clear();
	for (unsigned long z = 0; z < [ objects count ]; z++)
	{
		NSDictionary* properties = [ [ objects objectAtIndex:z ] properties ];
		if ([ [ properties objectForKey:@"Type" ] isEqualToString:@"Move" ])
		{
			MovingPlatform platform;
			platform.currentStep = 0;
			platform.obj = [ objects objectAtIndex:z ];
			platform.count = -1;
			platform.startCount = -1;
			platform.currentStep = -1;
			MDVector3 mid = [ platform.obj midPoint ];
			MDSetObjectGravity(platform.obj, MDVector3Create(0, 0, 0));
			unsigned int steps = [ [ properties objectForKey:@"Steps" ] intValue ];
			for (unsigned long q = 0; q < steps; q++)
			{
				PlatformStep step;
				NSString* inter = [ properties objectForKey:[ NSString stringWithFormat:@"Interpolation %i", q ] ];
				if ([ inter isEqualToString:@"Quadratic" ])
					step.interpolation = 1;
				else
					step.interpolation = 0;
				step.speed = [ [ properties objectForKey:[ NSString stringWithFormat:@"Speed %i", q ] ] floatValue ];
				sscanf([ [ properties objectForKey:[ NSString stringWithFormat:@"Position %i", q ] ] UTF8String ], "(%f, %f, %f)",
					&step.position.x, &step.position.y, &step.position.z);
				/*if (q == 0)
				{
					platform.add = MDVector3Normalize((step.position - mid)) * step.speed;
					platform.count = MDVector3Distance(step.position, mid) / step.speed;
					platform.startCount = platform.count;
				}*/
				platform.steps.push_back(step);
			}
			platforms.push_back(platform);
		}
		else if ([ [ [ [ objects objectAtIndex:z ] instance ] name ] isEqualToString:@"Switch" ])
		{
			Switch sw;
			sw.obj = [ objects objectAtIndex:z ];
			sw.originalScale = sw.obj.scaleY;
			sw.originalTranslate = sw.obj.translateY;
			sw.hasCamera = FALSE;
			sw.midCurve = sw.lookCurve = sw.endMidCurve = sw.endLookCurve = nil;
			if ([ properties objectForKey:@"Camera Position" ])
			{
				if (![ [ properties objectForKey:@"Camera Position" ] isEqualToString:@"Current" ])
				{
					if ([ [ properties objectForKey:@"Camera Position" ] hasPrefix:@"(" ])
					{
						MDVector3 pos;
						sscanf([ [ properties objectForKey:@"Camera Position" ] UTF8String ], "(%f, %f, %f)",
							&pos.x, &pos.y, &pos.z);
						sw.midCurve = [ [ MDCurve alloc ] init ];
						[ sw.midCurve addPoint:MDVector3Create(0, 0, 0) ];
						[ sw.midCurve addPoint:pos ];
						[ MDOtherObjects() addObject:sw.midCurve ];
						[ sw.midCurve release ];
					}
					else
					{
						MDCurve* curve = MDOtherObjectNamed([ properties objectForKey:@"Camera Position" ]);
						sw.midCurve = curve;
					}
				}
				if ([ [ properties objectForKey:@"Look Position" ] hasPrefix:@"(" ])
				{
					MDVector3 pos;
					sscanf([ [ properties objectForKey:@"Look Position" ] UTF8String ], "(%f, %f, %f)",
						&pos.x, &pos.y, &pos.z);
					sw.lookCurve = [ [ MDCurve alloc ] init ];
					[ sw.lookCurve addPoint:MDVector3Create(0, 0, 0) ];
					[ sw.lookCurve addPoint:pos ];
					[ MDOtherObjects() addObject:sw.lookCurve ];
					[ sw.lookCurve release ];
				}
				else
				{
					MDCurve* curve = MDOtherObjectNamed([ properties objectForKey:@"Look Position" ]);
					sw.lookCurve = curve;
				}
				sw.hasCamera = TRUE;
			}
			
			sw.hasEnd = FALSE;
			if ([ properties objectForKey:@"Camera End" ])
			{
				if (![ [ properties objectForKey:@"Camera End" ] isEqualToString:@"Current" ])
				{
					if ([ [ properties objectForKey:@"Camera End" ] hasPrefix:@"(" ])
					{
						MDVector3 pos;
						sscanf([ [ properties objectForKey:@"Camera End" ] UTF8String ], "(%f, %f, %f)",
							&pos.x, &pos.y, &pos.z);
						sw.endMidCurve = [ [ MDCurve alloc ] init ];
						[ sw.endMidCurve addPoint:MDVector3Create(0, 0, 0) ];
						[ sw.endMidCurve addPoint:pos ];
						[ MDOtherObjects() addObject:sw.endMidCurve ];
						[ sw.endMidCurve release ];
					}
					else
					{
						MDCurve* curve = MDOtherObjectNamed([ properties objectForKey:@"Camera End" ]);
						sw.endMidCurve = curve;
					}
				}
				if ([ [ properties objectForKey:@"Look End" ] hasPrefix:@"(" ])
				{
					MDVector3 pos;
					sscanf([ [ properties objectForKey:@"Look End" ] UTF8String ], "(%f, %f, %f)",
						&pos.x, &pos.y, &pos.z);
					sw.endLookCurve = [ [ MDCurve alloc ] init ];
					[ sw.endLookCurve addPoint:MDVector3Create(0, 0, 0) ];
					[ sw.endLookCurve addPoint:pos ];
					[ MDOtherObjects() addObject:sw.endLookCurve ];
					[ sw.endLookCurve release ];
				}
				else
				{
					MDCurve* curve = MDOtherObjectNamed([ properties objectForKey:@"Look End" ]);
					sw.endLookCurve = curve;
				}
				sw.hasEnd = TRUE;
			}
			sw.cTime = [ [ properties objectForKey:@"CTime" ] floatValue ];
			sw.eTime = [ [ properties objectForKey:@"ETime" ] floatValue ];
			sw.time = [ [ properties objectForKey:@"Time" ] floatValue ];
			sw.counter = 0;
			sw.cCounter = 0;
			sw.dCounter = 0;
			sw.animation = 0;
			sw.down = FALSE;
			sw.doAction = FALSE;
			switches.push_back(sw);
		}
		else if ([ [ [ [ objects objectAtIndex:z ] instance ] name ] isEqualToString:@"Target" ])
		{
			Target target;
			target.obj = [ objects objectAtIndex:z ];
			target.state = 0;
			target.doAction = FALSE;
			target.changed = FALSE;
			targets.push_back(target);
		}
		else if ([ [ [ [ objects objectAtIndex:z ] instance ] name ] isEqualToString:@"Gravity" ])
		{
			Gravity gravity;
			gravity.obj = [ objects objectAtIndex:z ];
			MDSetObjectGravity(gravity.obj, MDVector3Create(0, 0, 0));
			gravity.power = 0;
			gravity.changed = 0;
			if ([ properties objectForKey:@"Power" ])
			{
				gravity.power = round([ [ properties objectForKey:@"Power" ] floatValue ]);
				if (gravity.power > 0.5)
					[ gravity.obj setColorMultiplier:MDVector4Create(1, 0.3, 0.3, 1) ];
				else
					[ gravity.obj setColorMultiplier:MDVector4Create(1, 1, 1, 1) ];
			}
			gravity.counter = 0;
			gravities.push_back(gravity);
		}
	}
	
	if (barrels)
		[ barrels release ];
	barrels = [ [ NSMutableArray alloc ] init ];
	for (unsigned long z = 0; z < [ objects count ]; z++)
	{
		MDObject* obj = [ objects objectAtIndex:z ];
		if ([ [ [ obj instance ] name ] isEqualToString:@"Barrel" ])
			[ barrels addObject:obj ];
	}
}

void UpdateObjects(MDObject* obj, float depth)
{
	// Move platforms
	for (unsigned long z = 0; z < platforms.size(); z++)
	{	
		if (platforms[z].steps.size() == 0)
			continue;
		
		if (platforms[z].count <= 0)
		{
			platforms[z].currentStep++;
			if (platforms[z].currentStep >= platforms[z].steps.size())
				platforms[z].currentStep = 0;
			PlatformStep step = platforms[z].steps[platforms[z].currentStep];
			MDVector3 mid = [ platforms[z].obj midPoint ];
			platforms[z].count = MDVector3Distance(step.position, mid) / step.speed;
			platforms[z].start = mid;
			platforms[z].startCount = platforms[z].count;
		}
		
		PlatformStep step = platforms[z].steps[platforms[z].currentStep];
		/*if (step.interpolation == 1)
		{
			float time = (platforms[z].startCount - platforms[z].count) / platforms[z].startCount;
			//MDSetLinearVelocity(platforms[z].obj, platforms[z].add * 60.0 / 3.0 * 60.0 * MDElapsedTime() / 1000.0 * time * 2);
			MDSetObjectPosition(platforms[z].obj, [ platforms[z].obj midPoint ] + platforms[z].add * MDElapsedTime());
		}
		else*/
		if (platforms[z].startCount != 0)
		{
			//MDSetLinearVelocity(platforms[z].obj, platforms[z].add * 60.0 / 3.0 * 60.0 * MDElapsedTime() / 1000.0);
			MDSetObjectPosition(platforms[z].obj, platforms[z].start + (platforms[z].steps[platforms[z].currentStep].position - platforms[z].start) * (1 - platforms[z].count / platforms[z].startCount));
		}
		platforms[z].count -= MDElapsedTime() / 1000.0;
	}
	
	// Switches
	for (unsigned long z = 0; z < switches.size(); z++)
	{
		MDVector3 mid = [ switches[z].obj midPoint ];
		
		BOOL shouldDown = (MDVector3Distance(mid, midPoint) < 2.5);
		if (!shouldDown)
		{
			// Check if barrels are there
			for (unsigned long y = 0; y < [ barrels count ]; y++)
			{
				float scaleX = fabs([ [ barrels objectAtIndex:y ] scaleX ]);
				if (MDVector3Distance(mid, [ [ barrels objectAtIndex:y ] midPoint ]) < 3.0 * scaleX)
				{
					shouldDown = TRUE;
					break;
				}								
			}
		}
		
		if (shouldDown)
		{				
			// Start going down
			if (switches[z].dCounter < 1 && switches[z].animation == 0)
			{
				switches[z].animation = 1;
				switches[z].doAction = 0;
			}
		}
		else
		{
			// Wait to come back up
			if (switches[z].animation == 5)
			{
				switches[z].counter += MDElapsedTime() / 1000.0;
				BOOL enable = MDIsObjectEnabled(switches[z].obj);
				if ((switches[z].counter > switches[z].time && switches[z].time != 0) || enable)
				{
					switches[z].animation = 6;
					switches[z].counter = 0;
					MDObjectEnable(switches[z].obj);
				}
			}
		}
		
		if (switches[z].dCounter < 1 && switches[z].animation == 1)
		{
			// Going down
			float sign = switches[z].originalScale / fabs(switches[z].originalScale);
			switches[z].obj.scaleY = (1 - switches[z].dCounter) * switches[z].originalScale;
			switches[z].obj.translateY = (switches[z].originalTranslate - switches[z].originalScale * switches[z].dCounter * 0.5) + 0.01 * sign;
			switches[z].dCounter += MDElapsedTime() / 1000.0 * 2;
			if (switches[z].dCounter > 1)
			{
				//switches[z].obj.scaleY = 0.034 * sign;
				switches[z].obj.translateY = switches[z].originalTranslate - switches[z].originalScale / 2 + 0.01 * sign;
				switches[z].dCounter = 2;
				MDObjectDisable(switches[z].obj);
				if (switches[z].hasCamera && !customCamera)
				{
					switches[z].animation = 2;
					customCamera = TRUE;
					
					if (switches[z].midCurve)
					{
						std::vector<MDVector3> points = *[ switches[z].midCurve curvePoints ];
						MDVector3 camHeight = MDVector3Create(0, zAngle, 0);
						points[0] = midPoint + camHeight;
						[ switches[z].midCurve setPoints:points ];
					}
					if (switches[z].lookCurve)
					{
						std::vector<MDVector3> points = *[ switches[z].lookCurve curvePoints ];
						MDVector3 camHeight = MDVector3Create(sin(rotateZAngle / 180 * M_PI), cos(rotateZAngle / 180 * M_PI), 0);
						points[0] = lookPoint + camHeight;
						[ switches[z].lookCurve setPoints:points ];
					}
				}
				else
					switches[z].animation = 5;
				switches[z].down = TRUE;
				switches[z].doAction = 1;
			}
		}
		else if (switches[z].dCounter > 1 && switches[z].animation == 6)
		{
			// Coming back up
			switches[z].obj.scaleY = (2 - switches[z].dCounter) * switches[z].originalScale;
			switches[z].obj.translateY = (switches[z].originalTranslate - switches[z].originalScale * (switches[z].dCounter - 1) * 0.5) + 0.01;
			switches[z].dCounter -= MDElapsedTime() / 1000.0 * 2;
			if (switches[z].dCounter < 1)
			{
				switches[z].obj.scaleY = switches[z].originalScale;
				switches[z].obj.translateY = switches[z].originalTranslate;
				switches[z].dCounter = 0;
				if (switches[z].hasEnd && !customCamera)
				{
					switches[z].animation = 7;
					customCamera = TRUE;
					
					if (switches[z].endMidCurve)
					{
						std::vector<MDVector3> points = *[ switches[z]. endMidCurve curvePoints ];
						MDVector3 camHeight = MDVector3Create(0, zAngle, 0);
						points[0] = midPoint + camHeight;
						[ switches[z]. endMidCurve setPoints:points ];
					}
					if (switches[z].endLookCurve)
					{
						std::vector<MDVector3> points = *[ switches[z]. endLookCurve curvePoints ];
						MDVector3 camHeight = MDVector3Create(sin(rotateZAngle / 180 * M_PI), cos(rotateZAngle / 180 * M_PI), 0);
						points[0] = lookPoint + camHeight;
						[ switches[z]. endLookCurve setPoints:points ];
					}
				}
				else
					switches[z].animation = 0;
				switches[z].down = FALSE;
				switches[z].doAction = 2;
			}
		}
			
		// Camera moving
		if (switches[z].animation == 2)
		{
			// Move camera to camera point
			float tween = MDTweenEaseInOutQuadratic(switches[z].cCounter);
			if (switches[z].midCurve)
				midPoint = [ switches[z].midCurve interpolate:tween ];
			if (switches[z].lookCurve)
				lookPoint = [ switches[z].lookCurve interpolate:tween ];
			switches[z].cCounter += MDElapsedTime() / 1000.0;
			if (switches[z].cCounter > 1)
			{
				switches[z].cCounter = 0;
				switches[z].animation = 3;
				midPoint = (switches[z].midCurve ? [ switches[z].midCurve interpolate:1 ] : midPoint);
				lookPoint = (switches[z].lookCurve ? [ switches[z].lookCurve interpolate:1 ] : lookPoint);
			}
		}
		else if (switches[z].animation == 3)
		{
			// Wait camera time
			switches[z].cCounter += MDElapsedTime() / 1000.0;
			if (switches[z].cCounter > switches[z].cTime && switches[z].cTime != 0)
			{
				switches[z].animation = 4;
				switches[z].cCounter = 0;
				
				if (switches[z].midCurve)
				{
					std::vector<MDVector3> points = *[ switches[z].midCurve curvePoints ];
					MDVector3 camHeight = MDVector3Create(0, zAngle, 0);
					points[0] = [ obj midPoint ] + camHeight;
					[ switches[z].midCurve setPoints:points ];
				}
				if (switches[z].lookCurve)
				{
					MDVector3 mid = [ obj midPoint ];
					std::vector<MDVector3> points = *[ switches[z].lookCurve curvePoints ];
					MDVector3 camHeight = MDVector3Create(sin(rotateZAngle / 180 * M_PI), cos(rotateZAngle / 180 * M_PI), 0);
					points[0] = MDVector3Create(mid.x + depth * sin(rotateAngle), mid.y + cameraHeight, mid.z + depth * cos(rotateAngle)) + camHeight;
					[ switches[z].lookCurve setPoints:points ];
				}
			}
		}
		else if (switches[z].animation == 4)
		{
			// Move camera point back to real camera
			float tween = MDTweenEaseInOutQuadratic(switches[z].cCounter);
			if (switches[z].midCurve)
				midPoint = [ switches[z].midCurve interpolate:(1 - tween) ];
			if (switches[z].lookCurve)
				lookPoint = [ switches[z].lookCurve interpolate:(1 - tween) ];
			switches[z].cCounter += MDElapsedTime() / 1000.0;
			if (switches[z].cCounter > 1)
			{
				switches[z].cCounter = 0;
				switches[z].animation = 5;
				customCamera = FALSE;
			}
		}
		else if (switches[z].animation == 7)
		{
			// Move camera to camera point (end)
			float tween = MDTweenEaseInOutQuadratic(switches[z].cCounter);
			if (switches[z].endMidCurve)
				midPoint = [ switches[z].endMidCurve interpolate:tween ];
			if (switches[z].endLookCurve)
				lookPoint = [ switches[z].endLookCurve interpolate:tween ];
			switches[z].cCounter += MDElapsedTime() / 1000.0;
			if (switches[z].cCounter > 1)
			{
				switches[z].cCounter = 0;
				switches[z].animation = 8;
				midPoint = (switches[z].endMidCurve ? [ switches[z].endMidCurve interpolate:1 ] : midPoint);
				lookPoint = (switches[z].endLookCurve ? [ switches[z].endLookCurve interpolate:1 ] : lookPoint);
			}
		}
		else if (switches[z].animation == 8)
		{
			// Wait camera time (end)
			switches[z].cCounter += MDElapsedTime() / 1000.0;
			if (switches[z].cCounter > switches[z].eTime && switches[z].eTime != 0)
			{
				switches[z].animation = 9;
				switches[z].cCounter = 0;
				
				if (switches[z].endMidCurve)
				{
					std::vector<MDVector3> points = *[ switches[z]. endMidCurve curvePoints ];
					MDVector3 camHeight = MDVector3Create(0, zAngle, 0);
					points[0] = [ obj midPoint ] + camHeight;
					[ switches[z]. endMidCurve setPoints:points ];
				}
				if (switches[z].endLookCurve)
				{
					MDVector3 mid = [ obj midPoint ];
					std::vector<MDVector3> points = *[ switches[z]. endLookCurve curvePoints ];
					MDVector3 camHeight = MDVector3Create(sin(rotateZAngle / 180 * M_PI), cos(rotateZAngle / 180 * M_PI), 0);
					points[0] = MDVector3Create(mid.x + depth * sin(rotateAngle), mid.y + cameraHeight, mid.z + depth * cos(rotateAngle)) + camHeight;
					[ switches[z]. endLookCurve setPoints:points ];
				}
			}
		}
		else if (switches[z].animation == 9)
		{
			// Move camera point back to real camera (end)
			float tween = MDTweenEaseInOutQuadratic(switches[z].cCounter);
			if (switches[z].endMidCurve)
				midPoint = [ switches[z].endMidCurve interpolate:(1 - tween) ];
			if (switches[z].endLookCurve)
				lookPoint = [ switches[z].endLookCurve interpolate:(1 - tween) ];
			switches[z].cCounter += MDElapsedTime() / 1000.0;
			if (switches[z].cCounter > 1)
			{
				switches[z].cCounter = 0;
				switches[z].animation = 0;
				customCamera = FALSE;
			}
		}
	}
	
	// Targets
	for (unsigned long z = 0; z < targets.size(); z++)
	{
		// Impervious Period
		if (targets[z].changed)
		{
			targets[z].counter += MDElapsedTime() / 1000.0;
			float real = MDTweenEaseInOutQuadratic(targets[z].counter);
			if (targets[z].state == 1)
				[ targets[z].obj setColorMultiplier:MDVector4Create(1, 1, 1 - real, 1) ];
			else
				[ targets[z].obj setColorMultiplier:MDVector4Create(1, 1, real, 1) ];
			if (targets[z].counter > 1)
			{
				targets[z].counter = 0;
				targets[z].changed = FALSE;
				if (targets[z].state == 1)
					[ targets[z].obj setColorMultiplier:MDVector4Create(1, 1, 0, 1) ];
				else
					[ targets[z].obj setColorMultiplier:MDVector4Create(1, 1, 1, 1) ];
			}
			continue;
		}
		
		if (![ targets[z].obj shouldDraw ])
			continue;
			
	/*	for (unsigned long y = 0; y < [ bullets count ]; y++)
		{
			MDObject* bullet = [ bullets objectAtIndex:y ];
			MDVector3 bulletMid = MDObjectPosition(bullet);
			MDVector3 targetMid = MDObjectPosition(targets[z].obj);
			// Need to make the collision detection better
			if ([ bullet shouldDraw ] && MDVector3Distance(bulletMid, targetMid) <= 1.1)
			{
				// Check bounding box
				if (bulletMid.x >= targetMid.x - 0.75 && bulletMid.x <= targetMid.x + 0.75 &&
					bulletMid.y >= targetMid.y - 0.75 && bulletMid.y <= targetMid.y + 0.75)
				{
					targets[z].state = !targets[z].state;
					targets[z].doAction = (targets[z].state ? 1 : -1);
					targets[z].changed = TRUE;
					targets[z].counter = 0;
					break;
				}
			}
		}*/
	}
	
	for (unsigned long z = 0; z < gravities.size(); z++)
	{
		if (gravities[z].changed != 0)
		{
			float real = MDTweenEaseInOutQuadratic(gravities[z].counter);
			gravities[z].counter += MDElapsedTime() / 1000.0;
			float alpha = [ gravities[z].obj colorMultiplier ].w;
			
			
			if (gravities[z].changed == 1)
			{
				gravities[z].power = real;
				MDVector4 color = MDVector4Create(1, 1 - (0.7 * real), 1 - (0.7 * real), alpha);
				[ gravities[z].obj setColorMultiplier:color ];
				if (grabObject == gravities[z].obj)
					grabColor = color;
			}
			else
			{
				gravities[z].power = 1 - real;
				MDVector4 color = MDVector4Create(1, 0.3 + (0.7 * real), 0.3 + (0.7 * real), alpha);
				[ gravities[z].obj setColorMultiplier:color ];
				if (grabObject == gravities[z].obj)
					grabColor = color;
			}
			
			if (gravities[z].counter > 1)
			{
				gravities[z].counter = 0;
				if (gravities[z].changed == 1)
				{
					gravities[z].power = 1;
					MDVector4 color = MDVector4Create(1, 0.3, 0.3, alpha);
					[ gravities[z].obj setColorMultiplier:color ];
					if (grabObject == gravities[z].obj)
						grabColor = color;
				}
				else
				{
					gravities[z].power = 0;
					MDVector4 color = MDVector4Create(1, 1, 1, alpha);
					[ gravities[z].obj setColorMultiplier:color ];
					if (grabObject == gravities[z].obj)
						grabColor = color;
				}
				gravities[z].changed = FALSE;
			}
			
			if (grabObject == gravities[z].obj)
				grabColor.w = 1;
		}
		
		// Move all blue boxes towards it based on the power and mass
		float power = gravities[z].power * [ gravities[z].obj mass ];
		for (unsigned long y = 0; y < [ blueBoxes count ]; y++)
		{
			MDObject* box = [ blueBoxes objectAtIndex:y ];
			MDVector3 dir = ([ gravities[z].obj midPoint ] - [ box midPoint ]);
			float dist = MDVector3Magnitude(dir);
			dir /= dist;
			MDVector3 accel = G_CONSTANT * dir * (power / dist / dist / [ box mass ]);
			MDSetLinearVelocity(box, MDLinearVelocity(box) + accel);
			MDVector3 temp = MDLinearVelocity(box);
		}
		// Also do this with bullets
		for (unsigned long y = 0; y < [ bullets count ]; y++)
		{
			MDObject* bullet = [ bullets objectAtIndex:y ];
			MDVector3 dir = ([ gravities[z].obj midPoint ] - [ bullet midPoint ]);
			float dist = MDVector3Magnitude(dir);
			dir /= dist;
			MDVector3 accel = G_CONSTANT * dir * (power / dist / dist / [ bullet mass ]);
			MDSetLinearVelocity(bullet, MDLinearVelocity(bullet) + accel);
			MDVector3 temp = MDLinearVelocity(bullet);
		}
		// And barrels
		for (unsigned long y = 0; y < [ barrels count ]; y++)
		{
			MDObject* barrel = [ barrels objectAtIndex:y ];
			MDVector3 dir = ([ gravities[z].obj midPoint ] - [ barrel midPoint ]);
			float dist = MDVector3Magnitude(dir);
			dir /= dist;
			MDVector3 accel = G_CONSTANT * dir * (power / dist / dist / [ barrel mass ]);
			MDSetLinearVelocity(barrel, MDLinearVelocity(barrel) + accel);
			MDVector3 temp = MDLinearVelocity(barrel);
		}
		
		for (unsigned long y = 0; y < [ bullets count ]; y++)
		{
			MDObject* bullet = [ bullets objectAtIndex:y ];
			if ([ bullet shouldDraw ] && MDVector3Distance([ bullet midPoint ], [ gravities[z].obj midPoint ]) <= 1)
			{
				gravities[z].changed = (round(gravities[z].power) == 1) ? -1 : 1;
				MDRemoveObject(bullet);
				[ bullets removeObject:bullet ];
				break;
			}
		}
	}
}

void CollisionDetected(MDObject* obj1, MDObject* obj2, MDVector3 point, MDVector3 normal)
{
	// Check for only collisions between the bullet and the targets
	
	// Check if a bullet was involved
	MDObject* bullet = nil;
	for (unsigned long z = 0; z < [ bullets count ]; z++)
	{
		if ([ bullets objectAtIndex:z ] == obj1)
		{
			bullet = obj1;
			break;
		}
		else if ([ bullets objectAtIndex:z ] == obj2)
		{
			bullet = obj2;
			break;
		}
	}
	if (!bullet || ![ bullet shouldDraw	])
		return;
		
	// Check a target was involved
	MDObject* target = nil;
	unsigned long z = 0;
	for (z = 0; z < targets.size(); z++)
	{
		if (targets[z].obj == obj1)
		{
			target = obj1;
			break;
		}
		else if (targets[z].obj == obj2)
		{
			target = obj2;
			break;
		}
	}
	if (!target || ![ target shouldDraw ])
		return;
	
	// Target was hit
	if (!targets[z].changed)
	{
		targets[z].state = !targets[z].state;
		targets[z].doAction = (targets[z].state ? 1 : -1);
		targets[z].changed = TRUE;
		targets[z].counter = 0;
	}
}
