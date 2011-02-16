//
//  NordicLeagueToolController.h
//  NordicLeague Tool
//
//  Created by Jozan (BNET: keepoz) on 5.8.2010.
//  All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AppKit/AppKit.h>
#import <Sparkle/Sparkle.h>

@class PreferenceController;


@interface NordicLeagueToolController : NSObject {
	/* Our outlets which allow us to access the interface */
	IBOutlet NSMenu *statusMenu;
	NSStatusItem *statusItem;
	PreferenceController *preferenceController;	
}

- (void)refresh:(id)sender;
- (void)refreshSuccess:(id)sender;
- (void)postNotification:(NSString *)postNotificationName;
- (void)autoRefresh:(NSTimer *)timer;
- (void)processError:(NSString *)error;
- (void)updateTitle:(NSString *)string:(NSColor *)color;
- (void)generateAttributedTitle;
- (void)fancyInit:(id)sender;
- (void)prettyIntro;

// Sent when a valid update is found by the update driver.
- (void)updater:(SUUpdater *)updater didFindValidUpdate:(SUAppcastItem *)update;

// Sent when a valid update is not found.
- (void)updaterDidNotFindUpdate:(SUUpdater *)update;

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

@end

NSString *gameName = @"No game name copied!";
NSString *playerCount = @"NA";
NSPasteboard *pasteBoard = nil;
NSMutableData *receivedData;
NSTimer *timer = nil;
BOOL refreshInProgress = NO;
BOOL isRefreshed = NO;
BOOL autoRefresh = YES;
BOOL autoCopy = NO;
BOOL bypassAutoCopy = NO;
id hotkeyMonitor;