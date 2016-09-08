// Menu.h

#import <Cocoa/Cocoa.h>

void InitBlack();
void ResizeBlack();
void DeallocBlack();

void InitPauseMenu();
void ResizePauseMenu();
void DeallocPauseMenu();
void ExitPause();

void InitMenu();
void ShowMenu();
void HideMenu();
void ResizeMenu();
void DeallocMenu();

void InitPacks();
void UpdatePacks();
void DeallocPacks();

void InitLevelsMenu();
void DeallocLevelsMenu();

void Init();

void InitOptions();
void DeallocOptions();

void InitVideo();
void DeallocVideo();
void InitAudio();
void DeallocAudio();
void InitControls();
void DeallocControls();

void UpdateMenu();
void MenuDraw();

// Save
void ApplyVideoOptions();
void ReadVideoOptions(unsigned int* resx, unsigned int* resy, unsigned char* antialias, short* fps, unsigned char* fullscreen);
void WriteVideoOptions();
BOOL LevelUnlocked(unsigned int levelPack, unsigned int level);
void FinishLevel(unsigned int levelPack, unsigned int level);
