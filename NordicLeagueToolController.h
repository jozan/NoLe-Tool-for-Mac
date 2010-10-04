//
//  NordicLeagueToolController.h
//  NordicLeague Tool
//
//  Created by Jozan (BNET: keepoz) on 5.8.2010.
//  All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PreferenceController;

@interface NordicLeagueToolController : NSObject {
	
	/* Our outlets which allow us to access the interface */
	IBOutlet NSMenu *statusMenu;
	NSStatusItem *statusItem;

	PreferenceController *preferenceController;
	
	NSSound *hotkeySuccess;
	NSSound *hotkeyFullOrError;	
}

NSString *gameName = @"No game name copied!";
NSString *playerCount = @"NA";
NSApplication *mySelf = nil;


NSPasteboard *pasteBoard = nil;
NSAttributedString *aString = nil;
NSMutableData *receivedData;


BOOL isUpdated = NO;
BOOL autoUpdate = YES;
BOOL autoCopy = NO;
BOOL bypassAutoCopy = NO;
NSTimer *timer = nil;

- (void)update;
- (void)processError:(NSString *)error;
- (NSAttributedString *)formatString:(NSString *)str;

- (IBAction)refresh:(id)sender;
- (IBAction)copyToClipboard:(id)sender;
- (IBAction)openAbout:(id)sender;
- (IBAction)toggleAutoRefresh:(id)sender;
- (IBAction)toggleAutoCopy:(id)sender;

// Show Preference Panel
- (IBAction)showPreferencePanel:(id)sender;

@property (retain) NSMenu *statusMenu;
@property (retain) NSStatusItem *statusItem;
@property (retain) PreferenceController *preferenceController;
@property (retain) NSSound *hotkeySuccess;
@property (retain) NSSound *hotkeyFullOrError;
@end