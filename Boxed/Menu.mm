// Menu.mm

#import "Menu.h"
#import <MovieDraw/MovieDraw.h>
#import "Objects.h"
#import "Level.h"

int animating[7] = { 0, 0, 0, 0, 0, 0, 0 };
float counter[7] = { 0, 0, 0, 0, 0, 0, 0 };
BOOL menu = FALSE;
unsigned int selPack = 0, selLevel = 0;

@interface Actions : NSObject
{
}

@end

@implementation Actions

// Main
+ (void) playPressed
{
	if (animating[0] != 0)
		return;
	
	menu = TRUE;
	selPack = 0;
	InitPacks();
	[ ViewForIdentity(@"Packs View") setVisible:NO ];
	animating[0] = 1;
	animating[5] = 1;
	counter[0] = 0;
	counter[5] = 0;
}

+ (void) optionsPressed
{
	if (animating[0] != 0)
		return;
	
	menu = TRUE;
	InitOptions();
	[ ViewForIdentity(@"Options View") setVisible:NO ];
	animating[0] = 1;
	animating[1] = 1;
	counter[0] = 0;
	counter[1] = 0;
}

+ (void) exitPressed
{
	if (animating[0] != 0)
		return;
	
	[ [ NSApplication sharedApplication ] terminate:self ];
}

// Options
+ (void) videoPressed
{
	if (animating[1] != 0)
		return;
	
	InitVideo();
	[ ViewForIdentity(@"Video View") setVisible:NO ];
	animating[1] = 2;
	animating[2] = 1;
	counter[1] = 0;
	counter[2] = 0;
}

+ (void) audioPressed
{
	if (animating[1] != 0)
		return;
	
	InitAudio();
	[ ViewForIdentity(@"Audio View") setVisible:NO ];
	animating[1] = 2;
	animating[3] = 1;
	counter[1] = 0;
	counter[3] = 0;
}

+ (void) controlsPressed
{
	if (animating[1] != 0)
		return;
	
	InitControls();
	[ ViewForIdentity(@"Controls View") setVisible:NO ];
	animating[1] = 2;
	animating[4] = 1;
	counter[1] = 0;
	counter[4] = 0;
}

+ (void) backOptionsPressed
{
	if (animating[0] != 0)
		return;
	
	if (menu)
		InitMenu();
	else
		InitPauseMenu();
	[ ViewForIdentity(@"Main Menu View") setVisible:NO ];
	animating[0] = -1;
	animating[1] = -1;
	counter[0] = 0;
	counter[1] = 0;
}

// Video
+ (void) videoCancel
{
	if (animating[1] != 0)
		return;
	
	InitOptions();
	[ ViewForIdentity(@"Options View") setVisible:NO ];
	animating[1] = -2;
	animating[2] = -1;
	counter[1] = 0;
	counter[2] = 0;
}

+ (void) videoOk
{
	if (animating[1] != 0)
		return;
	
	MDControlView* view = ViewForIdentity(@"Video View");
	BOOL full = [ (MDCheckBox*)SubViewForIdentity(@"Fullscreen Check", view) state ];
	MDSetFullScreen(full);
	NSArray* size = [ [ (MDPopup*)SubViewForIdentity(@"Resolution Popup", view) stringValue ] componentsSeparatedByString:@" x " ];
	if ([ size count ] > 1 && !full)
		MDSetGLResolution(NSMakeSize([ [ size objectAtIndex:0 ] floatValue ], [ [ size objectAtIndex:1 ] floatValue ]));
	MDSetAntialias([ [ (MDPopup*)SubViewForIdentity(@"Antialias Popup", view) stringValue ] floatValue ]);
	if ([ [ (MDPopup*)SubViewForIdentity(@"FPS Popup", view) stringValue ] isEqualToString:@"Max" ])
		MDSetFPS(0);
	else
		MDSetFPS([ [ (MDPopup*)SubViewForIdentity(@"FPS Popup", view) stringValue ] floatValue ]);
	
	[ MDGLView() reshape ];
	
	if (!inMenu)
	{
		DeallocBlack();
		InitBlack();
		[ (MDControlView*)ViewForIdentity(@"Black Fade 2") setAlpha:0.5 ];
	}
	
	WriteVideoOptions();

/*	DeallocVideo();
	InitVideo();*/
		
	[ self videoCancel ];
}

// Audio
+ (void) audioBack
{
	if (animating[1] != 0)
		return;
	
	InitOptions();
	[ ViewForIdentity(@"Options View") setVisible:NO ];
	animating[1] = -2;
	animating[3] = -1;
	counter[1] = 0;
	counter[3] = 0;
}

// Control
+ (void) controlBack
{
	if (animating[1] != 0)
		return;
	
	InitOptions();
	[ ViewForIdentity(@"Options View") setVisible:NO ];
	animating[1] = -2;
	animating[4] = -1;
	counter[1] = 0;
	counter[4] = 0;
}

// Packs
+ (void) backPacksPressed
{
	if (animating[5] != 0)
		return;
	
	InitMenu();
	[ ViewForIdentity(@"Main Menu View") setVisible:NO ];
	animating[0] = -1;
	animating[5] = -1;
	counter[0] = 0;
	counter[5] = 0;
}

+ (void) selectPacksPressed
{
	if (animating[5] != 0)
		return;
	
	InitLevelsMenu();
	[ ViewForIdentity(@"Level View") setVisible:NO ];
	animating[5] = 2;
	animating[6] = 1;
	counter[5] = 0;
	counter[6] = 0;
}

+ (void) packsLeft
{
	if (selPack > 0)
	{
		selPack--;
		
		UpdatePacks();
	}
	
	MDControlView* view = ViewForIdentity(@"Packs View");
	[ SubViewForIdentity(@"Left Packs Button", view) setEnabled:(selPack != 0) ];
	[ SubViewForIdentity(@"Right Packs Button", view) setEnabled:(selPack != NUM_PACKS - 1) ];
}

+ (void) packsRight
{
	if (selPack < NUM_PACKS - 1)
	{
		selPack++;
	
		UpdatePacks();
	}
	
	MDControlView* view = ViewForIdentity(@"Packs View");
	[ SubViewForIdentity(@"Left Packs Button", view) setEnabled:(selPack != 0) ];
	[ SubViewForIdentity(@"Right Packs Button", view) setEnabled:(selPack != NUM_PACKS - 1) ];
}

// Levels
+ (void) backLevelPressed
{
	if (animating[5] != 0)
		return;
	
	InitPacks();
	[ ViewForIdentity(@"Packs View") setVisible:NO ];
	animating[5] = -2;
	animating[6] = -1;
	counter[5] = 0;
	counter[6] = 0;
}

+ (void) levelSelected: (id) sender
{
	if (animating[6] != 0)
		return;
	
	if ([ [ (MDImageView*)sender image ] hasSuffix:@"Unknown.png" ])
		return;
	
	MDControlView* view = ViewForIdentity(@"Level View");
	
	for (unsigned long z = 0; z < levelAmounts[selPack]; z++)
	{
		MDImageView* image = SubViewForIdentity([ NSString stringWithFormat:@"Level %lu Image", z ], view);
		if ([ [ image strokeColor ] redComponent ] > 0.1)
			[ image setStrokeColor:[ NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:1 ] ];
		if (sender == image)
			selLevel = z;
	}
	[ sender setStrokeColor:MD_BUTTON_DEFAULT_BUTTON_COLOR ];
}

+ (void) levelChosen: (id)sender
{
	if (animating[6] != 0)
		return;
	if ([ sender isKindOfClass:[ MDImageView class ] ] && [ [ sender strokeColor ] redComponent ] < 0.1)
		return;
	
	DeallocBlack();
	InitBlack();
	
	if (inMenu && commandFlag == 0)
	{
		animating[6] = -1;
		counter[6] = 0;
		commandFlag |= FADING_OUT;
		
		loadedPack = selPack;
		loadedLevel = selLevel;
	}
}

// Pause
+ (void) restartButton
{
	if (animating[0] != 0)
		return;
	
	menu = FALSE;
	commandFlag |= COMMAND_RESUME;
	animating[0] = 2;
}

+ (void) pauseOptions
{
	if (animating[0] != 0)
		return;
	
	menu = FALSE;
	InitOptions();
	[ ViewForIdentity(@"Options View") setVisible:NO ];
	animating[0] = 1;
	animating[1] = 1;
	counter[0] = 0;
	counter[1] = 0;
}

+ (void) pauseExit
{
	if (animating[0] != 0)
		return;
	
	menu = FALSE;
	commandFlag |= COMMAND_RESUME;
	animating[0] = 3;
}

@end

void InitBlack()
{
	MDControlView* controlView = [ [ MDControlView alloc ] initWithFrame:MakeRect(0, 0, resolution.width, resolution.height)
															  background:[ NSColor colorWithCalibratedRed:0.0 green:0.0 blue:0.0 alpha:0.0 ] ];
	[ controlView setRoundingRadius:0 ];
	[ controlView setStrokeSize:0 ];
	[ controlView setIdentity:@"Black Fade" ];
	[ controlView release ];
	
	MDControlView* controlView2 = [ [ MDControlView alloc ] initWithFrame:MakeRect(0, 0, resolution.width, resolution.height)
															   background:[ NSColor colorWithCalibratedRed:0.0 green:0.0 blue:0.0 alpha:0.0 ] ];
	[ controlView2 setRoundingRadius:0 ];
	[ controlView2 setStrokeSize:0 ];
	[ controlView2 setIdentity:@"Black Fade 2" ];
	[ controlView2 release ];
	
	MDImageView* aimView = [ [ MDImageView alloc ] initWithFrame:MakeRect(resolution.width / 2 - 32, resolution.height / 2 - 32, 64, 64)
													  background:[ NSColor colorWithCalibratedRed:1 green:1 blue:1 alpha:1 ] ];
	[ aimView setVisible:NO ];
	[ aimView setRoundingRadius:0 ];
	[ aimView setStrokeSize:0 ];
	[ aimView setImage:@"Aim.png" onThread:NO ];
	[ aimView setIdentity:@"Aim View" ];
	[ aimView release ];
	
	/*MDImageView* bulletView = [ [ MDImageView alloc ] initWithFrame:MakeRect(90, 4, 32, 32)
							background:[ NSColor colorWithCalibratedRed:1 green:1 blue:1 alpha:1 ] ];
	[ bulletView setVisible:NO ];
	[ bulletView setRoundingRadius:0 ];
	[ bulletView setStrokeSize:0 ];
	[ bulletView setImage:@"Bullet.png" onThread:NO ];
	[ bulletView setIdentity:@"Bullet View" ];
	[ bulletView release ];*/
}

void ResizeBlack()
{
	[ (MDControlView*)ViewForIdentity(@"Black Fade") setFrame:MakeRect(0, 0, resolution.width, resolution.height) ];
	[ (MDControlView*)ViewForIdentity(@"Black Fade 2") setFrame:MakeRect(0, 0, resolution.width, resolution.height) ];
	[ (MDImageView*)ViewForIdentity(@"Aim View") setFrame:MakeRect(resolution.width / 2 - 32, resolution.height / 2 - 32, 64, 64) ];
}

void DeallocBlack()
{
	MDRemoveView(ViewForIdentity(@"Aim View"));
	MDRemoveView(ViewForIdentity(@"Black Fade 2"));
	MDRemoveView(ViewForIdentity(@"Black Fade"));
}

void InitPauseMenu()
{
	MDControlView* pauseView = [ [ MDControlView alloc ] initWithFrame:MakeRect(resolution.width / 8, resolution.height / 4, resolution.width / 4 * 3, resolution.height / 2)
															background:[ NSColor colorWithCalibratedRed:0.4 green:0.4 blue:0.4 alpha:1.0 ] ];
	[ pauseView setVisible:NO ];
	[ pauseView setIdentity:@"Pause View" ];
	[ pauseView release ];
	
	MDButton* restartButton = [ [ MDButton alloc ] initWithFrame:MakeRect(resolution.width / 8 * 3 - resolution.width / 5, resolution.height * 0.325, resolution.width / 5 * 2, resolution.height / 10) background:[ NSColor colorWithCalibratedRed:1 green:1 blue:1 alpha:0.5 ] ];
	[ pauseView addSubView:restartButton ];
	[ restartButton setTextFont:[ NSFont systemFontOfSize:20 ] ];
	[ restartButton setText:@"Restart Level" ];
	[ restartButton setIdentity:@"Restart Button" ];
	[ restartButton setTarget:[ Actions class ] ];
	[ restartButton setAction:@selector(restartButton) ];
	[ restartButton release ];
	
	MDButton* optionsButton = [ [ MDButton alloc ] initWithFrame:MakeRect(resolution.width / 8 * 3 - resolution.width / 5, resolution.height * 0.20, resolution.width / 5 * 2, resolution.height / 10) background:[ NSColor colorWithCalibratedRed:1 green:1 blue:1 alpha:0.5 ] ];
	[ pauseView addSubView:optionsButton ];
	[ optionsButton setTextFont:[ NSFont systemFontOfSize:20 ] ];
	[ optionsButton setText:@"Options" ];
	[ optionsButton setIdentity:@"Pause Options Button" ];
	[ optionsButton setTarget:[ Actions class ] ];
	[ optionsButton setAction:@selector(pauseOptions) ];
	[ optionsButton release ];
	
	MDButton* exitButton = [ [ MDButton alloc ] initWithFrame:MakeRect(resolution.width / 8 * 3 - resolution.width / 5, resolution.height * 0.075, resolution.width / 5 * 2, resolution.height / 10) background:[ NSColor colorWithCalibratedRed:1 green:1 blue:1 alpha:0.5 ] ];
	[ pauseView addSubView:exitButton ];
	[ exitButton setTextFont:[ NSFont systemFontOfSize:20 ] ];
	[ exitButton setText:@"Exit To Menu" ];
	[ exitButton setIdentity:@"Exit To Menu Button" ];
	[ exitButton setTarget:[ Actions class ] ];
	[ exitButton setAction:@selector(pauseExit) ];
	[ exitButton release ];
}

void ResizePauseMenu()
{
	[ (MDControlView*)ViewForIdentity(@"Pause View") setFrame:MakeRect(resolution.width / 8, resolution.height / 4, resolution.width / 4 * 3, resolution.height / 2) ];
}

void DeallocPauseMenu()
{
	MDRemoveView(ViewForIdentity(@"Pause View"));
}

void ExitPause()
{
	if (ViewForIdentity(@"Options View"))
	{
		animating[1] = -1;
		counter[1] = 0;
	}
	else if (ViewForIdentity(@"Video View"))
	{
		animating[2] = -1;
		counter[2] = 0;
	}
	else if (ViewForIdentity(@"Audio View"))
	{
		animating[3] = -1;
		counter[3] = 0;
	}
	else if (ViewForIdentity(@"Control View"))
	{
		animating[4] = -1;
		counter[4] = 0;
	}
}

void InitMenu()
{
	MDControlView* menuView = [ [ MDControlView alloc ] initWithFrame:MakeRect(resolution.width / 8, resolution.height / 16, resolution.width / 4 * 3, resolution.height / 2) background:[ NSColor colorWithCalibratedRed:0.4 green:0.4 blue:0.4 alpha:0.5 ] ];
	[ menuView setIdentity:@"Main Menu View" ];
	[ menuView release ];
	
	MDButton* playButton = [ [ MDButton alloc ] initWithFrame:MakeRect(resolution.width / 8 * 3 - resolution.width / 5, resolution.height * 0.325, resolution.width / 5 * 2, resolution.height / 10) background:[ NSColor colorWithCalibratedRed:1 green:1 blue:1 alpha:0.5 ] ];
	[ menuView addSubView:playButton ];
	[ playButton setTextFont:[ NSFont systemFontOfSize:20 ] ];
	[ playButton setText:@"Play" ];
	[ playButton setIdentity:@"Play Button" ];
	[ playButton setTarget:[ Actions class ] ];
	[ playButton setAction:@selector(playPressed) ];
	[ playButton release ];
	
	MDButton* optionsButton = [ [ MDButton alloc ] initWithFrame:MakeRect(resolution.width / 8 * 3 - resolution.width / 5, resolution.height * 0.20, resolution.width / 5 * 2, resolution.height / 10) background:[ NSColor colorWithCalibratedRed:1 green:1 blue:1 alpha:0.5 ] ];
	[ menuView addSubView:optionsButton ];
	[ optionsButton setTextFont:[ NSFont systemFontOfSize:20 ] ];
	[ optionsButton setText:@"Options" ];
	[ optionsButton setIdentity:@"Options Button" ];
	[ optionsButton setTarget:[ Actions class ] ];
	[ optionsButton setAction:@selector(optionsPressed) ];
	[ optionsButton release ];
	
	MDButton* exitButton = [ [ MDButton alloc ] initWithFrame:MakeRect(resolution.width / 8 * 3 - resolution.width / 5, resolution.height * 0.075, resolution.width / 5 * 2, resolution.height / 10) background:[ NSColor colorWithCalibratedRed:1 green:1 blue:1 alpha:0.5 ] ];
	[ menuView addSubView:exitButton ];
	[ exitButton setTextFont:[ NSFont systemFontOfSize:20 ] ];
	[ exitButton setText:@"Exit" ];
	[ exitButton setIdentity:@"Exit Button" ];
	[ exitButton setTarget:[ Actions class ] ];
	[ exitButton setAction:@selector(exitPressed) ];
	[ exitButton release ];
	
	MDImageView* boxed = [ [ MDImageView alloc ] initWithFrame:MakeRect(resolution.width / 8, resolution.height * 0.45, resolution.width / 2, resolution.width / 1.92 / 2) background:[ NSColor colorWithCalibratedRed:1 green:1 blue:1 alpha:1 ] ];
	[ menuView addSubView:boxed ];
	[ boxed setImage:@"Boxed.png" onThread:NO ];
	[ boxed setIdentity:@"Boxed Image" ];
	[ boxed release ];
}

void ShowMenu()
{
	[ ViewForIdentity(@"Main Menu View") setVisible:YES ];
}

void HideMenu()
{
	[ ViewForIdentity(@"Main Menu View") setVisible:NO ];
}

void ResizeMenu()
{
	/*MDControlView* view = ViewForIdentity(@"Main Menu View");
	[ view setFrame:MakeRect(resolution.width / 8, resolution.height / 16, resolution.width / 4 * 3, resolution.height / 2) ];
	
	[ (MDControlView*)SubViewForIdentity(@"Play Button", view) setFrame:MakeRect(resolution.width / 8 * 3 - resolution.width / 5, resolution.height * 0.325, resolution.width / 5 * 2, resolution.height / 10) ];
	
	[ (MDControlView*)SubViewForIdentity(@"Options Button", view) setFrame:MakeRect(resolution.width / 8 * 3 - resolution.width / 5, resolution.height * 0.20, resolution.width / 5 * 2, resolution.height / 10) ];
	
	[ (MDControlView*)SubViewForIdentity(@"Exit Button", view) setFrame:MakeRect(resolution.width / 8 * 3 - resolution.width / 5, resolution.height * 0.075, resolution.width / 5 * 2, resolution.height / 10) ];
	
	[ (MDControlView*)SubViewForIdentity(@"Boxed Image", view) setFrame:MakeRect(resolution.width / 8, resolution.height * 0.45, resolution.width / 2, resolution.width / 1.92 / 2) ];*/
}

void DeallocMenu()
{
	MDRemoveView(ViewForIdentity(@"Main Menu View"));
}

void InitPacks()
{
	MDControlView* packView = [ [ MDControlView alloc ] initWithFrame:MakeRect(resolution.width / 4, resolution.height / 4 - resolution.height / 20, resolution.width / 2, resolution.height / 2 + resolution.height / 10) background:[ NSColor colorWithCalibratedRed:0.4 green:0.4 blue:0.4 alpha:1.0 ] ];
	[ packView setIdentity:@"Packs View" ];
	[ packView release ];
	
	MDImageView* name = [ [ MDImageView alloc ] initWithFrame:MakeRect(resolution.width / 8, resolution.height * 2.5 / 6, resolution.width / 4, resolution.height / 6) background:[ NSColor colorWithCalibratedRed:1 green:1 blue:1 alpha:1 ] ];
	[ name setImage:[ NSString stringWithFormat:@"Level Images/%@.png", levelNames[selPack] ] onThread:NO ];
	[ name setIdentity:@"Name View" ];
	[ packView addSubView:name ];
	[ name release ];
	
	MDImageView* image = [ [ MDImageView alloc ] initWithFrame:MakeRect(resolution.width / 8 + 2, resolution.height / 6 + 2, resolution.width / 4 - 4, resolution.height / 4 - 4) background:[ NSColor colorWithCalibratedRed:1 green:1 blue:1 alpha:1 ] ];
	[ image setImage:[ NSString stringWithFormat:@"Level Images/%@ 1.png", levelNames[selPack] ] onThread:NO ];
	[ image setIdentity:@"Image View" ];
	[ image setStrokeSize:2 ];
	[ packView addSubView:image ];
	[ image release ];
	
	MDButton* leftPack = [ [ MDButton alloc ] initWithFrame:MakeRect(15, resolution.height / 4, resolution.width / 10, resolution.height / 10) background:[ NSColor colorWithCalibratedRed:1 green:1 blue:1 alpha:0.5 ] ];
	[ packView addSubView:leftPack ];
	[ leftPack setTextFont:[ NSFont systemFontOfSize:20 ] ];
	[ leftPack setText:@"<" ];
	[ leftPack setEnabled:(selPack != 0) ];
	[ leftPack setIdentity:@"Left Packs Button" ];
	[ leftPack setTarget:[ Actions class ] ];
	[ leftPack setAction:@selector(packsLeft) ];
	[ leftPack release ];
	
	MDButton* rightPack = [ [ MDButton alloc ] initWithFrame:MakeRect(resolution.width / 2 - resolution.width / 10 - 15, resolution.height / 4, resolution.width / 10, resolution.height / 10) background:[ NSColor colorWithCalibratedRed:1 green:1 blue:1 alpha:0.5 ] ];
	[ packView addSubView:rightPack ];
	[ rightPack setTextFont:[ NSFont systemFontOfSize:20 ] ];
	[ rightPack setText:@">" ];
	[ rightPack setEnabled:(selPack != NUM_PACKS - 1) ];
	[ rightPack setIdentity:@"Right Packs Button" ];
	[ rightPack setTarget:[ Actions class ] ];
	[ rightPack setAction:@selector(packsRight) ];
	[ rightPack release ];
	
	MDButton* backButton = [ [ MDButton alloc ] initWithFrame:MakeRect(15, 15, resolution.width / 4 - 30, resolution.height / 10) background:[ NSColor colorWithCalibratedRed:1 green:1 blue:1 alpha:0.5 ] ];
	[ packView addSubView:backButton ];
	[ backButton setTextFont:[ NSFont systemFontOfSize:20 ] ];
	[ backButton setText:@"Back" ];
	[ backButton setIdentity:@"Back Packs Button" ];
	[ backButton setTarget:[ Actions class ] ];
	[ backButton setAction:@selector(backPacksPressed) ];
	[ backButton release ];
	
	MDButton* selectButton = [ [ MDButton alloc ] initWithFrame:MakeRect(resolution.width / 2 - resolution.width / 4 + 30 - 15, 15, resolution.width / 4 - 30, resolution.height / 10) background:MD_BUTTON_DEFAULT_BUTTON_COLOR ];
	[ packView addSubView:selectButton ];
	[ selectButton setTextFont:[ NSFont systemFontOfSize:20 ] ];
	[ selectButton setTextColor:[ NSColor colorWithCalibratedRed:1 green:1 blue:1 alpha:1 ] ];
	[ selectButton setText:@"Select" ];
	[ selectButton setIdentity:@"Select Packs Button" ];
	[ selectButton setTarget:[ Actions class ] ];
	[ selectButton setAction:@selector(selectPacksPressed) ];
	[ selectButton release ];
}

void UpdatePacks()
{
	if (LevelUnlocked(selPack, 0))
	{
		[ SubViewForIdentity(@"Image View", ViewForIdentity(@"Packs View")) setImage:[ NSString stringWithFormat:@"Level Images/%@ 1.png", levelNames[selPack] ] onThread:NO ];
		[ SubViewForIdentity(@"Select Packs Button", ViewForIdentity(@"Packs View")) setEnabled:YES ];
	}
	else
	{
		[ SubViewForIdentity(@"Image View", ViewForIdentity(@"Packs View")) setImage:@"Level Images/Unknown.png" onThread:NO ];
		[ SubViewForIdentity(@"Select Packs Button", ViewForIdentity(@"Packs View")) setEnabled:NO ];
	}
	[ SubViewForIdentity(@"Name View", ViewForIdentity(@"Packs View")) setImage:[ NSString stringWithFormat:@"Level Images/%@.png", levelNames[selPack] ] onThread:NO ];
}

void DeallocPacks()
{
	MDRemoveView(ViewForIdentity(@"Packs View"));
}

void InitLevelsMenu()
{
	MDControlView* levelView = [ [ MDControlView alloc ] initWithFrame:MakeRect(resolution.width / 8, resolution.height / 6, resolution.width / 4 * 3, resolution.height / 4 * 3) background:[ NSColor colorWithCalibratedRed:0.4 green:0.4 blue:0.4 alpha:1.0 ] ];
	[ levelView setIdentity:@"Level View" ];
	[ levelView release ];
	
	MDButton* backButton = [ [ MDButton alloc ] initWithFrame:MakeRect(resolution.width / 8 * 3 - (resolution.width / 4 - 30) - 30, -15 - resolution.height / 10, resolution.width / 4 - 30, resolution.height / 10) background:[ NSColor colorWithCalibratedRed:0.7 green:0.7 blue:0.7 alpha:1.0 ] ];
	[ levelView addSubView:backButton ];
	[ backButton setTextFont:[ NSFont systemFontOfSize:20 ] ];
	[ backButton setText:@"Back" ];
	[ backButton setIdentity:@"Back Level Button" ];
	[ backButton setTarget:[ Actions class ] ];
	[ backButton setAction:@selector(backLevelPressed) ];
	[ backButton release ];
	
	MDButton* selButton = [ [ MDButton alloc ] initWithFrame:MakeRect(resolution.width / 8 * 3 + 30, -15 - resolution.height / 10, resolution.width / 4 - 30, resolution.height / 10) background:MD_BUTTON_DEFAULT_BUTTON_COLOR ];
	[ levelView addSubView:selButton ];
	[ selButton setTextFont:[ NSFont systemFontOfSize:20 ] ];
	[ selButton setTextColor:[ NSColor colorWithCalibratedRed:1 green:1 blue:1 alpha:1 ] ];
	[ selButton setText:@"Select" ];
	[ selButton setIdentity:@"Select Level Button" ];
	[ selButton setTarget:[ Actions class ] ];
	[ selButton setAction:@selector(levelChosen:) ];
	[ selButton release ];
	
	// Rows of 4?
	NSPoint point = NSMakePoint(resolution.width / 20, resolution.width / 20 + resolution.height * .1325);
	for (unsigned long z = 0; z < levelAmounts[selPack]; z++)
	{
		MDImageView* view = [ [ MDImageView alloc ] initWithFrame:MakeRect(point.x, resolution.height * 3 / 4 - point.y, resolution.width * .1325, resolution.height * .1325) background:[ NSColor colorWithCalibratedRed:1 green:1 blue:1 alpha:1 ] ];
		[ levelView addSubView:view ];
		if (z == 0)
			[ view setStrokeColor:MD_BUTTON_DEFAULT_BUTTON_COLOR ];
		[ view setStrokeSize:3 ];
		if (LevelUnlocked(selPack, (z + 1)))
		{
			[ view setImage:[ NSString stringWithFormat:@"Level Images/%@ %lu.png", levelNames[selPack], (z + 1) ] onThread:NO ];
		}
		else
		{
			[ view setImage:@"Level Images/Unknown.png" onThread:NO ];
		}
		[ view setIdentity:[ NSString stringWithFormat:@"Level %lu Image", z ] ];
		[ view setTarget:[ Actions class ] ];
		[ view setAction:@selector(levelSelected:) ];
		[ view setDoubleAction:@selector(levelChosen:) ];
		[ view release ];
		
		MDLabel* label = [ [ MDLabel alloc ] initWithFrame:MakeRect(point.x + resolution.width * .1325 / 2, resolution.height * 3 / 4 - point.y - resolution.height * .0375 / 2 + 3, 0, 0) background:[ NSColor colorWithCalibratedRed:1 green:1 blue:1 alpha:1 ] ];
		[ label setTextAlignment:NSCenterTextAlignment ];
		[ label setText:[ NSString stringWithFormat:@"%@ %lu", levelNames[selPack], (z + 1) ] ];
		[ levelView addSubView:label ];
		[ label release ];
		
		point.x += resolution.width * .1625;
		if (point.x > resolution.width / 4 * 3 - resolution.width / 20 - resolution.width * .1625)
		{
			point.x = resolution.width / 20;
			point.y += resolution.height * .2;
			//if (point.y > resolution.height / 4 * 3 - resolution.height / 10 - 30)
		//		break;
		}
	}
}

void DeallocLevelsMenu()
{
	MDRemoveView(ViewForIdentity(@"Level View"));
}

void InitOptions()
{
	MDControlView* optionsView = [ [ MDControlView alloc ] initWithFrame:MakeRect(resolution.width / 8 * 3, resolution.height / 4, resolution.width / 4, resolution.height / 2) background:[ NSColor colorWithCalibratedRed:0.4 green:0.4 blue:0.4 alpha:0.5 ] ];
	[ optionsView setIdentity:@"Options View" ];
	[ optionsView release ];
	
	MDButton* videoButton = [ [ MDButton alloc ] initWithFrame:MakeRect(15, resolution.height * 0.325, resolution.width / 4 - 30, resolution.height / 10) background:[ NSColor colorWithCalibratedRed:1 green:1 blue:1 alpha:0.5 ] ];
	[ optionsView addSubView:videoButton ];
	[ videoButton setTextFont:[ NSFont systemFontOfSize:20 ] ];
	[ videoButton setText:@"Video" ];
	[ videoButton setIdentity:@"Video Button" ];
	[ videoButton setTarget:[ Actions class ] ];
	[ videoButton setAction:@selector(videoPressed) ];
	[ videoButton release ];
	
	/*MDButton* audioButton = [ [ MDButton alloc ] initWithFrame:MakeRect(15, resolution.height * 0.2, resolution.width / 4 - 30, resolution.height / 10) background:[ NSColor colorWithCalibratedRed:1 green:1 blue:1 alpha:0.5 ] ];
	[ optionsView addSubView:audioButton ];
	[ audioButton setTextFont:[ NSFont systemFontOfSize:20 ] ];
	[ audioButton setText:@"Audio" ];
	[ audioButton setIdentity:@"Audio Button" ];
	[ audioButton setTarget:[ Actions class ] ];
	[ audioButton setAction:@selector(audioPressed) ];
	[ audioButton release ];*/
	
	MDButton* controlsButton = [ [ MDButton alloc ] initWithFrame:MakeRect(15, resolution.height * 0.2, resolution.width / 4 - 30, resolution.height / 10) background:[ NSColor colorWithCalibratedRed:1 green:1 blue:1 alpha:0.5 ] ];
	[ optionsView addSubView:controlsButton ];
	[ controlsButton setTextFont:[ NSFont systemFontOfSize:20 ] ];
	[ controlsButton setText:@"Controls" ];
	[ controlsButton setIdentity:@"Controls Button" ];
	[ controlsButton setTarget:[ Actions class ] ];
	[ controlsButton setAction:@selector(controlsPressed) ];
	[ controlsButton release ];
	
	MDButton* backButton = [ [ MDButton alloc ] initWithFrame:MakeRect(15, resolution.height * .075, resolution.width / 4 - 30, resolution.height / 10) background:[ NSColor colorWithCalibratedRed:1 green:1 blue:1 alpha:0.5 ] ];
	[ optionsView addSubView:backButton ];
	[ backButton setTextFont:[ NSFont systemFontOfSize:20 ] ];
	[ backButton setText:@"Back" ];
	[ backButton setIdentity:@"Back Options Button" ];
	[ backButton setTarget:[ Actions class ] ];
	[ backButton setAction:@selector(backOptionsPressed) ];
	[ backButton release ];
	
	MDImageView* options = [ [ MDImageView alloc ] initWithFrame:MakeRect(0, resolution.height * 0.525, resolution.width / 4, resolution.width / 1.92 / 4) background:[ NSColor colorWithCalibratedRed:1 green:1 blue:1 alpha:1 ] ];
	[ optionsView addSubView:options ];
	[ options setImage:@"Options.png" onThread:NO ];
	[ options setIdentity:@"Options Image" ];
	[ options release ];
}

void DeallocOptions()
{
	MDRemoveView(ViewForIdentity(@"Options View"));
}

void InitVideo()
{
	MDControlView* videoView = [ [ MDControlView alloc ] initWithFrame:MakeRect(resolution.width / 4, resolution.height / 12, resolution.width / 2, resolution.height / 1.5) background:[ NSColor colorWithCalibratedRed:0.4 green:0.4 blue:0.4 alpha:1 ] ];
	[ videoView setIdentity:@"Video View" ];
	[ videoView release ];
	
	unsigned int resx = 0, resy = 0;
	unsigned char antialias = 0, fullscreen = 0;
	short fps = 0;
	ReadVideoOptions(&resx, &resy, &antialias, &fps, &fullscreen);
	
	MDLabel* resLabel = [ [ MDLabel alloc ] initWithFrame:MakeRect(15, resolution.height / 1.5 - 30, 0, 0) background:[ NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:1 ] ];
	[ videoView addSubView:resLabel ];
	[ resLabel setTextAlignment:NSLeftTextAlignment ];
	[ resLabel setText:@"Resolution:" ];
	[ resLabel setIdentity:@"Resolution Label" ];
	[ resLabel release ];
	
	MDPopup* resPopup = [ [ MDPopup alloc ] initWithFrame:MakeRect(95, resolution.height / 1.5 - 55, resolution.width / 2 - 95 - 25, 30) background:MD_POPUP_DEFAULT_COLOR ];
	[ videoView addSubView:resPopup ];
	[ resPopup addItem:@"844 x 447" ];
	[ resPopup addItem:@"1280 x 720" ];
	[ resPopup addItem:@"1440 x 810" ];
	[ resPopup addItem:@"1920 x 1080" ];
	float width = resx;
	NSSize rect = [ [ NSScreen mainScreen ] frame ].size;
	NSString* screen = [ NSString stringWithFormat:@"%i x %i", (int)rect.width, (int)rect.height ];
	BOOL found = NO;
	for (unsigned long z = 0; z < [ resPopup numberOfItems ]; z++)
	{
		NSString* item = [ resPopup itemAtIndex:z ];
		if ([ item isEqualToString:screen ])
			found = TRUE;
		if ([ item hasPrefix:[ NSString stringWithFormat:@"%i", (int)width ] ])
			[ resPopup selectItem:z ];
	}
	if (!found)
		[ resPopup addItem:screen ];
	[ resPopup setIdentity:@"Resolution Popup" ];
	[ resPopup release ];
	
	MDLabel* antialiasLabel = [ [ MDLabel alloc ] initWithFrame:MakeRect(15, resolution.height / 1.5 - 70, 0, 0) background:[ NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:1 ] ];
	[ videoView addSubView:antialiasLabel ];
	[ antialiasLabel setTextAlignment:NSLeftTextAlignment ];
	[ antialiasLabel setText:@"Antialias:" ];
	[ antialiasLabel setIdentity:@"Antialias Label" ];
	[ antialiasLabel release ];
	
	MDPopup* antialiasPopup = [ [ MDPopup alloc ] initWithFrame:MakeRect(82, resolution.height / 1.5 - 95, resolution.width / 2 - 82 - 25, 30) background:MD_POPUP_DEFAULT_COLOR ];
	[ videoView addSubView:antialiasPopup ];
	[ antialiasPopup addItem:@"1x MSAA" ];
	[ antialiasPopup addItem:@"2x MSAA" ];
	[ antialiasPopup addItem:@"4x MSAA" ];
	[ antialiasPopup addItem:@"8x MSAA" ];
	[ antialiasPopup addItem:@"16x MSAA" ];
	[ antialiasPopup selectItem:log2(antialias) ];
	[ antialiasPopup setIdentity:@"Antialias Popup" ];
	[ antialiasPopup release ];
	
	MDLabel* fpsLabel = [ [ MDLabel alloc ] initWithFrame:MakeRect(15, resolution.height / 1.5 - 110, 0, 0) background:[ NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:1 ] ];
	[ videoView addSubView:fpsLabel ];
	[ fpsLabel setTextAlignment:NSLeftTextAlignment ];
	[ fpsLabel setText:@"FPS:" ];
	[ fpsLabel setIdentity:@"FPS Label" ];
	[ fpsLabel release ];
	
	MDPopup* fpsPopup = [ [ MDPopup alloc ] initWithFrame:MakeRect(50, resolution.height / 1.5 - 135, resolution.width / 2 - 50 - 25, 30) background:MD_POPUP_DEFAULT_COLOR ];
	[ videoView addSubView:fpsPopup ];
	[ fpsPopup addItem:@"60" ];
	[ fpsPopup addItem:@"30" ];
	[ fpsPopup addItem:@"120" ];
	[ fpsPopup addItem:@"24" ];
	[ fpsPopup addItem:@"Max" ];
	if (fps == 0)
		[ fpsPopup selectItem:4 ];
	else
	{
		for (unsigned long z = 0; z < [ fpsPopup numberOfItems ]; z++)
		{
			NSString* item = [ fpsPopup itemAtIndex:z ];
			if ([ item hasPrefix:[ NSString stringWithFormat:@"%i", fps ] ])
			{
				[ fpsPopup selectItem:z ];
				break;
			}
		}
	}
	[ fpsPopup setIdentity:@"FPS Popup" ];
	[ fpsPopup release ];
	
	MDCheckBox* fullscreenBox = [ [ MDCheckBox alloc ] initWithFrame:MakeRect(20, resolution.height / 1.5 - 155, 14, 14) background:MD_CHECKBOX_DEFAULT_COLOR ];
	[ videoView addSubView:fullscreenBox ];
	[ fullscreenBox setText:@"Fullscreen" ];
	[ fullscreenBox setIdentity:@"Fullscreen Check" ];
	[ fullscreenBox setState:fullscreen ];
	[ fullscreenBox release ];
	
	MDRect noteFrame = MakeRect(15, resolution.height * 0.125 + 15, resolution.width / 2 - 30, 0);
	MDLabel* noteLabel = [ [ MDLabel alloc ] initWithFrame:noteFrame background:[ NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:1 ] ];
	[ noteLabel setText:@"Note: Antialiasing changes only take place after the game has been restarted." ];
	noteFrame.y += [ [ noteLabel glStr ] frameSize ].height;
	[ noteLabel setFrame:noteFrame ];
	[ noteLabel setTextAlignment:NSLeftTextAlignment ];
	[ noteLabel setIdentity:@"Note Label" ];
	[ videoView addSubView:noteLabel ];
	[ noteLabel release ];
	
	MDButton* okButton = [ [ MDButton alloc ] initWithFrame:MakeRect(15, resolution.height * .025, resolution.width / 4 - 30, resolution.height / 10) background:[ NSColor colorWithCalibratedRed:1 green:1 blue:1 alpha:0.5 ] ];
	[ videoView addSubView:okButton ];
	[ okButton setTextFont:[ NSFont systemFontOfSize:20 ] ];
	[ okButton setText:@"Ok" ];
	[ okButton setIdentity:@"Ok Video Button" ];
	[ okButton setTarget:[ Actions class ] ];
	[ okButton setAction:@selector(videoOk) ];
	[ okButton release ];
	
	MDButton* cancelButton = [ [ MDButton alloc ] initWithFrame:MakeRect(resolution.width / 2 - 15 - (resolution.width / 4 - 30), resolution.height * .025, resolution.width / 4 - 30, resolution.height / 10) background:[ NSColor colorWithCalibratedRed:1 green:1 blue:1 alpha:0.5 ] ];
	[ videoView addSubView:cancelButton ];
	[ cancelButton setTextFont:[ NSFont systemFontOfSize:20 ] ];
	[ cancelButton setText:@"Cancel" ];
	[ cancelButton setIdentity:@"Cancel Video Button" ];
	[ cancelButton setTarget:[ Actions class ] ];
	[ cancelButton setAction:@selector(videoCancel) ];
	[ cancelButton release ];
	
	MDImageView* video = [ [ MDImageView alloc ] initWithFrame:MakeRect(resolution.width / 8, resolution.height * 0.65, resolution.width / 4, resolution.width / 1.92 / 4) background:[ NSColor colorWithCalibratedRed:1 green:1 blue:1 alpha:1 ] ];
	[ videoView addSubView:video ];
	[ video setImage:@"Video.png" onThread:NO ];
	[ video setIdentity:@"Video Image" ];
	[ video release ];
}

void DeallocVideo()
{
	MDRemoveView(ViewForIdentity(@"Video View"));
}

void InitAudio()
{
	MDControlView* audioView = [ [ MDControlView alloc ] initWithFrame:MakeRect(resolution.width / 4, resolution.height / 12, resolution.width / 2, resolution.height / 1.5) background:[ NSColor colorWithCalibratedRed:0.4 green:0.4 blue:0.4 alpha:1 ] ];
	[ audioView setIdentity:@"Audio View" ];
	[ audioView release ];
	
	MDLabel* label = [ [ MDLabel alloc ] initWithFrame:MakeRect(15, resolution.height / 1.5 - 30, 0, 0) background:[ NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:1 ] ];
	[ audioView addSubView:label ];
	[ label setTextAlignment:NSLeftTextAlignment ];
	[ label setText:@"There are no options to configure." ];
	[ label setIdentity:@"Audio Label" ];
	[ label release ];
	
	MDButton* backButton = [ [ MDButton alloc ] initWithFrame:MakeRect(resolution.width / 8, resolution.height * .025, resolution.width / 4, resolution.height / 10) background:[ NSColor colorWithCalibratedRed:1 green:1 blue:1 alpha:0.5 ] ];
	[ audioView addSubView:backButton ];
	[ backButton setTextFont:[ NSFont systemFontOfSize:20 ] ];
	[ backButton setText:@"Back" ];
	[ backButton setIdentity:@"Back Audio Button" ];
	[ backButton setTarget:[ Actions class ] ];
	[ backButton setAction:@selector(audioBack) ];
	[ backButton release ];
	
	MDImageView* audio = [ [ MDImageView alloc ] initWithFrame:MakeRect(resolution.width / 8, resolution.height * 0.65, resolution.width / 4, resolution.width / 1.92 / 4) background:[ NSColor colorWithCalibratedRed:1 green:1 blue:1 alpha:1 ] ];
	[ audioView addSubView:audio ];
	[ audio setImage:@"Audio.png" onThread:NO ];
	[ audio setIdentity:@"Audio Image" ];
	[ audio release ];
}

void DeallocAudio()
{
	MDRemoveView(ViewForIdentity(@"Audio View"));
}

void InitControls()
{
	MDControlView* controlView = [ [ MDControlView alloc ] initWithFrame:MakeRect(resolution.width / 4, resolution.height / 12, resolution.width / 2, resolution.height / 1.5) background:[ NSColor colorWithCalibratedRed:0.4 green:0.4 blue:0.4 alpha:1 ] ];
	[ controlView setIdentity:@"Control View" ];
	[ controlView release ];
	
	MDLabel* upLabel = [ [ MDLabel alloc ] initWithFrame:MakeRect(15, resolution.height / 1.5 - 30, 0, 0) background:[ NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:1 ] ];
	[ controlView addSubView:upLabel ];
	[ upLabel setText:@"Up:" ];
	[ upLabel setTextAlignment:NSLeftTextAlignment ];
	[ upLabel setIdentity:@"Up Label" ];
	[ upLabel release ];
	
	MDLabel* upButton = [ [ MDButton alloc ] initWithFrame:MakeRect(50, resolution.height / 1.5 - 55, 100, 30) background:[ NSColor colorWithCalibratedRed:1 green:1 blue:1 alpha:0.5 ] ];
	[ controlView addSubView:upButton ];
	[ upButton setEnabled:NO ];
	[ upButton setText:@"W" ];
	[ upButton release ];
	
	MDLabel* downLabel = [ [ MDLabel alloc ] initWithFrame:MakeRect(15, resolution.height / 1.5 - 70, 0, 0) background:[ NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:1 ] ];
	[ controlView addSubView:downLabel ];
	[ downLabel setText:@"Down:" ];
	[ downLabel setTextAlignment:NSLeftTextAlignment ];
	[ downLabel setIdentity:@"Down Label" ];
	[ downLabel release ];
	
	MDLabel* downButton = [ [ MDButton alloc ] initWithFrame:MakeRect(65, resolution.height / 1.5 - 95, 100, 30) background:[ NSColor colorWithCalibratedRed:1 green:1 blue:1 alpha:0.5 ] ];
	[ controlView addSubView:downButton ];
	[ downButton setEnabled:NO ];
	[ downButton setText:@"S" ];
	[ downButton release ];
	
	MDLabel* leftLabel = [ [ MDLabel alloc ] initWithFrame:MakeRect(15, resolution.height / 1.5 - 110, 0, 0) background:[ NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:1 ] ];
	[ controlView addSubView:leftLabel ];
	[ leftLabel setText:@"Left:" ];
	[ leftLabel setTextAlignment:NSLeftTextAlignment ];
	[ leftLabel setIdentity:@"Left Label" ];
	[ leftLabel release ];
	
	MDLabel* leftButton = [ [ MDButton alloc ] initWithFrame:MakeRect(55, resolution.height / 1.5 - 135, 100, 30) background:[ NSColor colorWithCalibratedRed:1 green:1 blue:1 alpha:0.5 ] ];
	[ controlView addSubView:leftButton ];
	[ leftButton setEnabled:NO ];
	[ leftButton setText:@"A" ];
	[ leftButton release ];
	
	MDLabel* rightLabel = [ [ MDLabel alloc ] initWithFrame:MakeRect(15, resolution.height / 1.5 - 150, 0, 0) background:[ NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:1 ] ];
	[ controlView addSubView:rightLabel ];
	[ rightLabel setText:@"Right:" ];
	[ rightLabel setTextAlignment:NSLeftTextAlignment ];
	[ rightLabel setIdentity:@"Right Label" ];
	[ rightLabel release ];
	
	MDLabel* rightButton = [ [ MDButton alloc ] initWithFrame:MakeRect(65, resolution.height / 1.5 - 175, 100, 30) background:[ NSColor colorWithCalibratedRed:1 green:1 blue:1 alpha:0.5 ] ];
	[ controlView addSubView:rightButton ];
	[ rightButton setEnabled:NO ];
	[ rightButton setText:@"D" ];
	[ rightButton release ];
	
	MDLabel* jumpLabel = [ [ MDLabel alloc ] initWithFrame:MakeRect(15, resolution.height / 1.5 - 190, 0, 0) background:[ NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:1 ] ];
	[ controlView addSubView:jumpLabel ];
	[ jumpLabel setText:@"Jump:" ];
	[ jumpLabel setTextAlignment:NSLeftTextAlignment ];
	[ jumpLabel setIdentity:@"Jump Label" ];
	[ jumpLabel release ];
	
	MDLabel* jumpButton = [ [ MDButton alloc ] initWithFrame:MakeRect(60, resolution.height / 1.5 - 215, 100, 30) background:[ NSColor colorWithCalibratedRed:1 green:1 blue:1 alpha:0.5 ] ];
	[ controlView addSubView:jumpButton ];
	[ jumpButton setEnabled:NO ];
	[ jumpButton setText:@"Space" ];
	[ jumpButton release ];
	
	MDLabel* grabLabel = [ [ MDLabel alloc ] initWithFrame:MakeRect(resolution.width / 2 - 30 - 120, resolution.height / 1.5 - 30, 0, 0) background:[ NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:1 ] ];
	[ controlView addSubView:grabLabel ];
	[ grabLabel setText:@"Grab:" ];
	[ grabLabel setTextAlignment:NSRightTextAlignment ];
	[ grabLabel setIdentity:@"Grab Label" ];
	[ grabLabel release ];
	
	MDLabel* grabButton = [ [ MDButton alloc ] initWithFrame:MakeRect(resolution.width / 2 - 30 - 115, resolution.height / 1.5 - 55, 115, 30) background:[ NSColor colorWithCalibratedRed:1 green:1 blue:1 alpha:0.5 ] ];
	[ controlView addSubView:grabButton ];
	[ grabButton setEnabled:NO ];
	[ grabButton setText:@"Secondary Click" ];
	[ grabButton release ];
	
	MDLabel* shootLabel = [ [ MDLabel alloc ] initWithFrame:MakeRect(resolution.width / 2 - 30 - 120, resolution.height / 1.5 - 70, 0, 0) background:[ NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:1 ] ];
	[ controlView addSubView:shootLabel ];
	[ shootLabel setText:@"Shoot:" ];
	[ shootLabel setTextAlignment:NSRightTextAlignment ];
	[ shootLabel setIdentity:@"Shoot Label" ];
	[ shootLabel release ];
	
	MDLabel* shootButton = [ [ MDButton alloc ] initWithFrame:MakeRect(resolution.width / 2 - 30 - 115, resolution.height / 1.5 - 95, 115, 30) background:[ NSColor colorWithCalibratedRed:1 green:1 blue:1 alpha:0.5 ] ];
	[ controlView addSubView:shootButton ];
	[ shootButton setEnabled:NO ];
	[ shootButton setText:@"Primary Click" ];
	[ shootButton release ];
	
	/*MDLabel* label = [ [ MDLabel alloc ] initWithFrame:MakeRect(15, resolution.height / 1.5 - 30, 0, 0) background:[ NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:1 ] ];
	[ controlView addSubView:label ];
	[ label setTextAlignment:NSLeftTextAlignment ];
	[ label setText:@"There are no options to configure." ];
	[ label setIdentity:@"Control Label" ];
	[ label release ];*/
	
	MDButton* backButton = [ [ MDButton alloc ] initWithFrame:MakeRect(resolution.width / 8, resolution.height * .025, resolution.width / 4, resolution.height / 10) background:[ NSColor colorWithCalibratedRed:1 green:1 blue:1 alpha:0.5 ] ];
	[ controlView addSubView:backButton ];
	[ backButton setTextFont:[ NSFont systemFontOfSize:20 ] ];
	[ backButton setText:@"Back" ];
	[ backButton setIdentity:@"Back Control Button" ];
	[ backButton setTarget:[ Actions class ] ];
	[ backButton setAction:@selector(controlBack) ];
	[ backButton release ];
	
	MDImageView* control = [ [ MDImageView alloc ] initWithFrame:MakeRect(resolution.width / 8, resolution.height * 0.65, resolution.width / 4, resolution.width / 1.92 / 4) background:[ NSColor colorWithCalibratedRed:1 green:1 blue:1 alpha:1 ] ];
	[ controlView addSubView:control ];
	[ control setImage:@"Controls.png" onThread:NO ];
	[ control setIdentity:@"Control Image" ];
	[ control release ];
}

void DeallocControls()
{
	MDRemoveView(ViewForIdentity(@"Control View"));
}

void UpdateMenu()
{
	// Main
	if (menu)
	{
		if (animating[0] == 1)
		{
			MDControlView* view = ViewForIdentity(@"Main Menu View");
			MDRect frame = [ view frame ];
			frame.x = resolution.width / 8 - (MDTweenEaseInOutQuadratic(counter[0]) * resolution.width);
			[ view setFrame:frame ];
			
			counter[0] += MDElapsedTime() / 1000.0;
			if (counter[0] > 1.0)
			{
				animating[0] = 0;
				counter[0] = 0;
				[ view setVisible:NO ];
				DeallocMenu();
			}
		}
		else if (animating[0] == -1)
		{
			MDControlView* view = ViewForIdentity(@"Main Menu View");
			[ view setVisible:YES ];
			MDRect frame = [ view frame ];
			frame.x = -resolution.width / 8 * 7 + (MDTweenEaseInOutQuadratic(counter[0]) * resolution.width);
			[ view setFrame:frame ];
			
			counter[0] += MDElapsedTime() / 1000.0;
			if (counter[0] > 1.0)
			{
				animating[0] = 0;
				counter[0] = 0;
				frame.x = resolution.width / 8;
				[ view setFrame:frame ];
			}
		}
	}
	else
	{
		if (animating[0] == 1)
		{
			MDControlView* view = ViewForIdentity(@"Pause View");
			MDRect frame = [ view frame ];
			frame.x = resolution.width / 8 - (MDTweenEaseInOutQuadratic(counter[0]) * resolution.width);
			[ view setFrame:frame ];
			
			counter[0] += MDElapsedTime() / 1000.0;
			if (counter[0] > 1.0)
			{
				animating[0] = 0;
				counter[0] = 0;
				DeallocPauseMenu();
				//[ view setVisible:NO ];
			}
		}
		else if (animating[0] == -1)
		{
			MDControlView* view = ViewForIdentity(@"Pause View");
			[ view setVisible:YES ];
			MDRect frame = [ view frame ];
			frame.x = -resolution.width / 8 * 7 + (MDTweenEaseInOutQuadratic(counter[0]) * resolution.width);
			[ view setFrame:frame ];
			
			counter[0] += MDElapsedTime() / 1000.0;
			if (counter[0] > 1.0)
			{
				animating[0] = 0;
				counter[0] = 0;
				frame.x = resolution.width / 8;
				[ view setFrame:frame ];
			}
		}
		else if (animating[0] == 2)
		{
			if (!(commandFlag & COMMAND_RESUME))
			{
				commandFlag |= FADING_OUT;
				loadSame = TRUE;
				animating[0] = 0;
			}
		}
		else if (animating[0] == 3)
		{
			if (!(commandFlag & COMMAND_RESUME))
			{
				commandFlag |= FADING_OUT;
				loadedPack = -2;
				loadedLevel = 0;
				animating[0] = 0;
			}
		}
	}
	
	// Options
	if (animating[1] == 1)
	{
		MDControlView* view = ViewForIdentity(@"Options View");
		[ view setVisible:YES ];
		MDRect frame = [ view frame ];
		frame.x = resolution.width / 8 * 11 - (MDTweenEaseInOutQuadratic(counter[1]) * resolution.width);
		[ view setFrame:frame ];
		
		counter[1] += MDElapsedTime() / 1000.0;
		if (counter[1] > 1.0)
		{
			animating[1] = 0;
			counter[1] = 0;
			frame.x = resolution.width / 8 * 3;
			[ view setFrame:frame ];
		}
	}
	else if (animating[1] == -1)
	{
		MDControlView* view = ViewForIdentity(@"Options View");
		MDRect frame = [ view frame ];
		frame.x = resolution.width / 8 * 3 + (MDTweenEaseInOutQuadratic(counter[1]) * resolution.width);
		[ view setFrame:frame ];
		
		counter[1] += MDElapsedTime() / 1000.0;
		if (counter[1] > 1.0)
		{
			animating[1] = 0;
			counter[1] = 0;
			[ view setVisible:NO ];
			DeallocOptions();
		}
	}
	else if (animating[1] == 2)
	{
		MDControlView* view = ViewForIdentity(@"Options View");
		[ view setVisible:YES ];
		MDRect frame = [ view frame ];
		frame.x = resolution.width / 8 * 3 - (MDTweenEaseInOutQuadratic(counter[1]) * resolution.width);
		[ view setFrame:frame ];
		
		counter[1] += MDElapsedTime() / 1000.0;
		if (counter[1] > 1.0)
		{
			animating[1] = 0;
			counter[1] = 0;
			DeallocOptions();
		}
	}
	else if (animating[1] == -2)
	{
		MDControlView* view = ViewForIdentity(@"Options View");
		[ view setVisible:YES ];
		MDRect frame = [ view frame ];
		frame.x = resolution.width / 8 * -5 + (MDTweenEaseInOutQuadratic(counter[1]) * resolution.width);
		[ view setFrame:frame ];
		
		counter[1] += MDElapsedTime() / 1000.0;
		if (counter[1] > 1.0)
		{
			animating[1] = 0;
			counter[1] = 0;
			frame.x = resolution.width / 8 * 3;
			[ view setFrame:frame ];
		}
	}
	
	// Video
	if (animating[2] == 1)
	{
		MDControlView* view = ViewForIdentity(@"Video View");
		[ view setVisible:YES ];
		MDRect frame = [ view frame ];
		frame.x = resolution.width / 4 * 5 - (MDTweenEaseInOutQuadratic(counter[2]) * resolution.width);
		[ view setFrame:frame ];
		
		counter[2] += MDElapsedTime() / 1000.0;
		if (counter[2] > 1.0)
		{
			animating[2] = 0;
			counter[2] = 0;
			frame.x = resolution.width / 4;
			[ view setFrame:frame ];
		}
	}
	else if (animating[2] == -1)
	{
		MDControlView* view = ViewForIdentity(@"Video View");
		MDRect frame = [ view frame ];
		frame.x = resolution.width / 4 + (MDTweenEaseInOutQuadratic(counter[2]) * resolution.width);
		[ view setFrame:frame ];
		
		counter[2] += MDElapsedTime() / 1000.0;
		if (counter[2] > 1.0)
		{
			animating[2] = 0;
			counter[2] = 0;
			DeallocVideo();
		}
	}
	
	// Audio
	if (animating[3] == 1)
	{
		MDControlView* view = ViewForIdentity(@"Audio View");
		[ view setVisible:YES ];
		MDRect frame = [ view frame ];
		frame.x = resolution.width / 4 * 5 - (MDTweenEaseInOutQuadratic(counter[3]) * resolution.width);
		[ view setFrame:frame ];
		
		counter[3] += MDElapsedTime() / 1000.0;
		if (counter[3] > 1.0)
		{
			animating[3] = 0;
			counter[3] = 0;
			frame.x = resolution.width / 4;
			[ view setFrame:frame ];
		}
	}
	else if (animating[3] == -1)
	{
		MDControlView* view = ViewForIdentity(@"Audio View");
		MDRect frame = [ view frame ];
		frame.x = resolution.width / 4 + (MDTweenEaseInOutQuadratic(counter[3]) * resolution.width);
		[ view setFrame:frame ];
		
		counter[3] += MDElapsedTime() / 1000.0;
		if (counter[3] > 1.0)
		{
			animating[3] = 0;
			counter[3] = 0;
			DeallocAudio();
		}
	}
	
	// Control
	if (animating[4] == 1)
	{
		MDControlView* view = ViewForIdentity(@"Control View");
		[ view setVisible:YES ];
		MDRect frame = [ view frame ];
		frame.x = resolution.width / 4 * 5 - (MDTweenEaseInOutQuadratic(counter[4]) * resolution.width);
		[ view setFrame:frame ];
		
		counter[4] += MDElapsedTime() / 1000.0;
		if (counter[4] > 1.0)
		{
			animating[4] = 0;
			counter[4] = 0;
			frame.x = resolution.width / 4;
			[ view setFrame:frame ];
		}
	}
	else if (animating[4] == -1)
	{
		MDControlView* view = ViewForIdentity(@"Control View");
		MDRect frame = [ view frame ];
		frame.x = resolution.width / 4 + (MDTweenEaseInOutQuadratic(counter[4]) * resolution.width);
		[ view setFrame:frame ];
		
		counter[4] += MDElapsedTime() / 1000.0;
		if (counter[4] > 1.0)
		{
			animating[4] = 0;
			counter[4] = 0;
			DeallocControls();
		}
	}
	
	// Packs
	if (animating[5] == 1)
	{
		MDControlView* view = ViewForIdentity(@"Packs View");
		[ view setVisible:YES ];
		MDRect frame = [ view frame ];
		frame.x = resolution.width / 4 * 5 - (MDTweenEaseInOutQuadratic(counter[5]) * resolution.width);
		[ view setFrame:frame ];
		
		counter[5] += MDElapsedTime() / 1000.0;
		if (counter[5] > 1.0)
		{
			animating[5] = 0;
			counter[5] = 0;
			frame.x = resolution.width / 4;
			[ view setFrame:frame ];
		}
	}
	else if (animating[5] == -1)
	{
		MDControlView* view = ViewForIdentity(@"Packs View");
		MDRect frame = [ view frame ];
		frame.x = resolution.width / 4 + (MDTweenEaseInOutQuadratic(counter[5]) * resolution.width);
		[ view setFrame:frame ];
		
		counter[5] += MDElapsedTime() / 1000.0;
		if (counter[5] > 1.0)
		{
			animating[5] = 0;
			counter[5] = 0;
			DeallocPacks();
		}
	}
	else if (animating[5] == 2)
	{
		MDControlView* view = ViewForIdentity(@"Packs View");
		[ view setVisible:YES ];
		MDRect frame = [ view frame ];
		frame.x = resolution.width / 4 - (MDTweenEaseInOutQuadratic(counter[5]) * resolution.width);
		[ view setFrame:frame ];
		
		counter[5] += MDElapsedTime() / 1000.0;
		if (counter[5] > 1.0)
		{
			animating[5] = 0;
			counter[5] = 0;
			DeallocPacks();
		}
	}
	else if (animating[5] == -2)
	{
		MDControlView* view = ViewForIdentity(@"Packs View");
		[ view setVisible:YES ];
		MDRect frame = [ view frame ];
		frame.x = resolution.width / 4 * -3 + (MDTweenEaseInOutQuadratic(counter[5]) * resolution.width);
		[ view setFrame:frame ];
		
		counter[5] += MDElapsedTime() / 1000.0;
		if (counter[5] > 1.0)
		{
			animating[5] = 0;
			counter[5] = 0;
			frame.x = resolution.width / 4;
			[ view setFrame:frame ];
		}
	}
	
	// Levels
	if (animating[6] == 1)
	{
		MDControlView* view = ViewForIdentity(@"Level View");
		[ view setVisible:YES ];
		MDRect frame = [ view frame ];
		frame.x = resolution.width / 8 * 9 - (MDTweenEaseInOutQuadratic(counter[6]) * resolution.width);
		[ view setFrame:frame ];
		
		counter[6] += MDElapsedTime() / 1000.0;
		if (counter[6] > 1.0)
		{
			animating[6] = 0;
			counter[6] = 0;
			frame.x = resolution.width / 8;
			[ view setFrame:frame ];
		}
	}
	else if (animating[6] == -1)
	{
		MDControlView* view = ViewForIdentity(@"Level View");
		MDRect frame = [ view frame ];
		frame.x = resolution.width / 8 + (MDTweenEaseInOutQuadratic(counter[6]) * resolution.width);
		[ view setFrame:frame ];
		
		counter[6] += MDElapsedTime() / 1000.0;
		if (counter[6] > 1.0)
		{
			animating[6] = 0;
			counter[6] = 0;
			DeallocLevelsMenu();
		}
	}
}

// Options
void ApplyVideoOptions()
{
	unsigned int resx = 0, resy = 0;
	unsigned char antialias = 0, fullscreen = 0;
	short fps = 0;
	
	// Read
	ReadVideoOptions(&resx, &resy, &antialias, &fps, &fullscreen);
	
	// Apply
	MDSetFullScreen(fullscreen);
	if (!fullscreen)
		MDSetGLResolution(NSMakeSize(resx, resy));
	MDSetAntialias(antialias);
	MDSetFPS(fps);
}

void ReadVideoOptions(unsigned int* resx, unsigned int* resy, unsigned char* antialias, short* fps, unsigned char* fullscreen)
{
	NSString* path = [ NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0 ];
	FILE* file = fopen([ [ path stringByAppendingString:@"/video" ] UTF8String ], "r");
	
	if (!file)
	{
		WriteVideoOptions();
		ReadVideoOptions(resx, resy, antialias, fps, fullscreen);
		return;
	}
	
	fread(resx, 1, sizeof(unsigned int), file);
	fread(resy, 1, sizeof(unsigned int), file);
	fread(antialias, 1, sizeof(unsigned char), file);
	fread(fps, 1, sizeof(short), file);
	if (*fps == -1)
		*fps = 0;
	fread(fullscreen, 1, sizeof(unsigned char), file);
	
	fclose(file);
}

void WriteVideoOptions()
{
	NSSize res = MDGLResolution();
	if (res.width < 844)
		res = NSMakeSize(844, 477);
	unsigned char antialias = MDAntialias();
	if (antialias == 0)
		antialias = 16;
	short fps = MDFPS();
	unsigned char fullscreen = MDFullScreen();
	
	NSString* path = [ NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0 ];
	FILE* file = fopen([ [ path stringByAppendingString:@"/video" ] UTF8String ], "w");
	
	unsigned int resx = res.width, resy = res.height;
	fwrite(&resx, 1, sizeof(unsigned int), file);
	fwrite(&resy, 1, sizeof(unsigned int), file);
	fwrite(&antialias, 1, sizeof(unsigned char), file);
	fwrite(&fps, 1, sizeof(short), file);
	fwrite(&fullscreen, 1, sizeof(unsigned char), file);
	
	fclose(file);
}

BOOL LevelUnlocked(unsigned int levelPack, unsigned int level)
{
	NSString* path = [ NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0 ];
	FILE* file = fopen([ [ path stringByAppendingString:@"/levels" ] UTF8String ], "r");
	if (!file)
	{
		//NSLog(@"Dead");
		file = fopen([ [ path stringByAppendingString:@"/levels" ] UTF8String ], "w");
		unsigned int numZero = 0;
		fwrite(&numZero, 1, sizeof(unsigned int), file);
		fwrite(&numZero, 1, sizeof(unsigned int), file);
		fclose(file);
		return (levelPack == 0 && level < 2);
	}
	
	unsigned int maxPack = 0, maxLevel = 0;
	fread(&maxPack, 1, sizeof(unsigned int), file);
	fread(&maxLevel, 1, sizeof(unsigned int), file);
	fclose(file);
	
	//NSLog(@"%i, %i", maxPack, levelPack);
	if (maxPack > levelPack)
		return TRUE;
	else if (maxPack == levelPack)
	{
		if (maxLevel + 1 >= level)
			return TRUE;
	}
	else if (maxPack == levelPack - 1)
	{
		if (level < 2 && maxLevel == levelAmounts[maxPack])
			return TRUE;
	}
	
	return FALSE;
}

void FinishLevel(unsigned int levelPack, unsigned int level)
{
	if (LevelUnlocked(levelPack, level + 1))
		return;
	NSString* path = [ NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0 ];
	FILE* file = fopen([ [ path stringByAppendingString:@"/levels" ] UTF8String ], "w");
	
	fwrite(&levelPack, 1, sizeof(unsigned int), file);
	fwrite(&level, 1, sizeof(unsigned int), file);
	fclose(file);
}

