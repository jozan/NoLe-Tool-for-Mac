//
//  NordicLeagueToolController.h
//  NordicLeague Tool
//
//  Created by Jozan (BNET: keepoz) on 5.8.2010.
//  All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AppKit/AppKit.h>

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


NSPasteboard *pasteBoard = nil;
//NSAttributedString *aString = nil;
NSMutableData *receivedData;

BOOL refreshInProgress = NO;
BOOL isRefreshed = NO;
BOOL autoRefresh = YES;
BOOL autoCopy = NO;
BOOL bypassAutoCopy = NO;
NSTimer *timer = nil;
id hotkeyMonitor;

- (void)refresh:(id)sender;
- (void)refreshSuccess:(id)sender;
- (void)postNotification:(NSString *)postNotificationName;
- (void)autoRefresh:(NSTimer *)timer;
- (void)processError:(NSString *)error;
- (void)updateTitle:(NSString *)string:(NSColor *)color;
- (void)generateAttributedTitle;
- (void)fancyInit:(id)sender;
- (void)prettyIntro;

- (IBAction)refreshAction:(id)sender;
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