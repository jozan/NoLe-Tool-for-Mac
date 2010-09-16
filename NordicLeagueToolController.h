//
//  NordicLeagueToolController.h
//  NordicLeague Tool
//
//  Created by Jozan (BNET: keepoz) on 5.8.2010.
//  All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ASIHTTPRequest;
@class PreferenceController;

@interface NordicLeagueToolController : NSObject {
	
	/* Our outlets which allow us to access the interface */
	IBOutlet NSMenu *statusMenu;

	NSStatusItem *statusItem;
	
	PreferenceController *preferenceController;
	
}

NSString *gameName = @"No game name copied!";
NSString *playerCount = @"NA";
NSApplication *mySelf;
NSSound *hotkeySuccess;
NSSound *hotkeyFullOrError;

NSPasteboard *pasteBoard;
NSAttributedString *aString;


BOOL isUpdated = NO;
BOOL autoUpdate = YES;
BOOL autoCopy = NO;
BOOL bypassAutoCopy = NO;
NSTimer *timer;

- (IBAction)refresh:(id)sender;
- (IBAction)copyToClipboard:(id)sender;
- (IBAction)openAbout:(id)sender;
- (IBAction)toggleAutoRefresh:(id)sender;
- (IBAction)toggleAutoCopy:(id)sender;

// Show Preference Panel
- (IBAction)showPreferencePanel:(id)sender;

@end