//
//  NordicLeagueToolController.m
//  NordicLeague Tool
//
//  Created by Jozan (BNET: keepoz) on 5.8.2010.
//  All rights reserved.
//

#import "NordicLeagueToolController.h"
#import "PreferenceController.h"
#import <Carbon/Carbon.h>


#define copyGameNameItem 5300

@implementation NordicLeagueToolController

+(void)initialize
{
	// Create a dictionary
	NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
	
	// Put default values in the dictionary
	[defaultValues setObject:[NSNumber numberWithFloat:20.0] forKey:NLTRefreshIntervalKey];
	[defaultValues setObject:[NSNumber numberWithBool:YES] forKey:NLTGameNameKey];
	
	// Register the dictionary of defaults
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
}

-(void)dealloc
{
	[NSEvent removeMonitor:hotkeyMonitor];
	[timer invalidate];
	[timer release];	
	[statusItem release];
	[gameName release];
	[playerCount release];
	[preferenceController release];
	[receivedData release];
	
	[super dealloc];
}

-(void)applicationWillFinishLaunching:(NSNotification *)aNotification {
	
	//[[SUUpdater sharedUpdater] setAutomaticallyChecksForUpdates:NO];
	// need to make some better handling here. This is just to force it to check for updates at start.
	//[[SUUpdater sharedUpdater] setUpdateCheckInterval:20.0];
	//[[SUUpdater sharedUpdater] setAutomaticallyChecksForUpdates:YES];
	//[[SUUpdater sharedUpdater] resetUpdateCycle];
}

-(void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	hotkeyMonitor = [NSEvent addGlobalMonitorForEventsMatchingMask:NSKeyDownMask handler:^(NSEvent* event){
		if (([event keyCode] == 49) && ([event modifierFlags] & NSControlKeyMask) && ([event modifierFlags] & NSCommandKeyMask)) {
			[self postNotification:@"HotKeyRefresh"];
		};
	}];
	
	// Only enable autoupates again if user has choosen it. do some check?
	
	//[[SUUpdater sharedUpdater] setAutomaticallyChecksForUpdates:YES];
}

-(void)autoRefresh:(NSTimer *)timer
{
	[self postNotification:@"AutoRefresh"];
}

-(void)postNotification:(NSString *)postNotificationName
{
	
	if (postNotificationName == @"HotKeyRefresh")
	{
		if (refreshInProgress == YES || bypassAutoCopy == YES)
			return;
		else
			bypassAutoCopy = YES;
		
		//NSLog(@"Posting HotKeyRefresh Notification..");
	}
	else if (postNotificationName == @"AutoRefresh")
	{
		//NSLog(@"Posting AutoRefresh Notification..");
	}
	else if (postNotificationName == @"ManualRefresh")
	{
		//NSLog(@"Manual Refresh...");
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:postNotificationName object: nil];
}

-(void)fancyInit:(id)sender
{
	[self updateTitle:(NSString*)sender:[NSColor colorWithDeviceRed:0 green:0 blue:0.9 alpha:1]];
}
-(void)prettyIntro
{
	NSString* version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
	[self updateTitle:@" ":[NSColor darkGrayColor]];
	[self performSelector:@selector(fancyInit:) withObject:@"  N" afterDelay:0.3];
	[self performSelector:@selector(fancyInit:) withObject:@" No" afterDelay:0.6];
	[self performSelector:@selector(fancyInit:) withObject:@"NoL" afterDelay:0.9];
	[self performSelector:@selector(fancyInit:) withObject:@"oLe" afterDelay:1.2];
	[self performSelector:@selector(fancyInit:) withObject:@"Le " afterDelay:1.5];
	[self performSelector:@selector(fancyInit:) withObject:@"e  " afterDelay:1.8];
	[self performSelector:@selector(fancyInit:) withObject:@"   " afterDelay:2.1];
	[self performSelector:@selector(fancyInit:) withObject:version afterDelay:2.4];
	
}

-(void)awakeFromNib
{
	[[SUUpdater sharedUpdater] setDelegate:self];
	[[SUUpdater sharedUpdater] checkForUpdatesInBackground];
	
	[self performSelector:@selector(refreshSuccess:) withObject:nil afterDelay:1.0];
	
	NSString* version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	
	[nc addObserver:self
		   selector:@selector(refresh:) 
			   name:@"HotKeyRefresh"
			 object:nil];
	
	[nc addObserver:self
		   selector:@selector(refresh:) 
			   name:@"AutoRefresh"
			 object:nil];
	
	[nc addObserver:self
		   selector:@selector(refresh:)
			   name:@"ManualRefresh"
			 object:nil];
	
	//Create the NSStatusBar and set its length
	statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:40] retain];
	
	[self prettyIntro];
	
	[statusItem setHighlightMode:YES];
	[statusItem setToolTip:version];
	[statusItem setMenu:statusMenu];
	[statusItem setEnabled:YES];
	
	timer = [NSTimer scheduledTimerWithTimeInterval:[[NSUserDefaults standardUserDefaults] floatForKey:NLTRefreshIntervalKey]
											 target:self
										   selector:@selector(autoRefresh:)
										   userInfo:nil
											repeats:YES];
	//[self  updateTitle:@"NL":[NSColor blueColor]];
	//[self postNotification:@"AutoRefresh"];
	
}

-(void)updateTitle:(NSString *)string:(NSColor *)color
{
	[statusItem setAttributedTitle:[[NSAttributedString alloc]
									initWithString:string attributes:
									[NSDictionary dictionaryWithObjectsAndKeys:
									 [NSFont menuBarFontOfSize:0], NSFontAttributeName,
									 color, NSForegroundColorAttributeName,
									 nil]]];
}

-(void)refresh:(id)sender
{
	if (refreshInProgress == YES)
	{
		NSLog(@"Another refresh is already in progress, aborting.");
		return;
	}
	
	refreshInProgress = YES;
	[self updateTitle:@"U!":[NSColor grayColor]];
	
	// Create the request.
	NSURLRequest *theRequest;
	
	BOOL TrackNormalGames = [[NSUserDefaults standardUserDefaults] boolForKey:NLTGameNameKey];
	if (TrackNormalGames)
		theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.nordicleague.eu/api/games/s"]
									  cachePolicy:NSURLRequestReloadIgnoringCacheData
								  timeoutInterval:3.0];
	else
		theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.nordicleague.eu/api/games/q"]
									  cachePolicy:NSURLRequestReloadIgnoringCacheData
								  timeoutInterval:3.0];
	
	// create the connection with the request and start loading the data
	NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	
	if (theConnection) {
		// Create the NSMutableData to hold the received data.
		receivedData = [[NSMutableData data] retain];
	} else {
		// Inform the user that the connection failed.
		NSLog(@"Connection error. This should never happend, it's handled by connection:didFailWithError.");
		[self processError:@"EC"];
	}
	
}

-(void)processData:(NSString*)data
{
	if ([data length] < 1)
	{
		[self processError:@"NG"];
		return;
	}
	
	NSArray *resultArray = [data componentsSeparatedByString:@"|"];
	
	if ([resultArray count] != 3)
	{
		[self processError:@"PD2"];
		return;
	}
	
	gameName = [[[NSString alloc]	initWithString:[resultArray objectAtIndex:0]]
									stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	playerCount = [resultArray objectAtIndex:1];

	// Display player count on status bar
	[self generateAttributedTitle];
	
	if (autoCopy || bypassAutoCopy)
	{
		// Automatically copy game name to clipboard
		pasteBoard = [NSPasteboard generalPasteboard];
		[pasteBoard declareTypes:[NSArray arrayWithObjects:NSStringPboardType, nil] owner:nil];
		[pasteBoard setString:gameName forType:NSStringPboardType];
		
		if (bypassAutoCopy)
		{
			NSSpeechSynthesizer *speechSynth = [[NSSpeechSynthesizer alloc] initWithVoice:nil];
			[speechSynth setVolume:0.2];
			
			if ([playerCount isEqualToString:@"10"])
			{
				[speechSynth startSpeakingString:@"Full house"];
				//[hotkeyFullOrError play];
			}
			else if ([playerCount isEqualToString:@"1"])
			{
				[speechSynth startSpeakingString:@"1 player"];
			}
			else
			{	
				NSString *speakPlayers = [NSString stringWithFormat:@"%@ players", playerCount]; 
				[speechSynth startSpeakingString:speakPlayers];
				//[hotkeySuccess play];
			}
			
			bypassAutoCopy = NO;
			
			[speechSynth release];
		}
	}
	isRefreshed = YES;
	[self performSelector:@selector(refreshSuccess:) withObject:nil afterDelay:1.0];
}

-(void)refreshSuccess:(id)sender
{
	refreshInProgress = NO;
}

-(void)processError:(NSString *)error
{
	[self updateTitle:error:[NSColor redColor]];
	//[statusItem updateTitle:error];
	isRefreshed = NO;
	refreshInProgress = NO;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	if (receivedData != nil)
		[receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Append the new data to receivedData.
	if (receivedData != nil)
		[receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	[self processData:[[NSString alloc] initWithData:receivedData encoding:NSASCIIStringEncoding]];
	
    // release the connection, and the data object
    [connection release];
	[receivedData release];
	receivedData = nil;
}
		 
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	[connection release];
    [receivedData release];
	receivedData = nil;

    NSLog(@"Connection failed! Error - %@ %@",	[error localizedDescription],
												[[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
	
	[self processError:@"E4"];
}

-(void)generateAttributedTitle
{
	float players = [playerCount intValue];
	
	if (players > 10)
		[self updateTitle:@"E3":[NSColor redColor]];
	else
	{
		float r = -0.2f + (players/10.0f) + ((players/20.0f)*2.0f);
		//float g = 1.0f - players/10.0;
		float g = 0.76f - players/28.0f;
		float b = 0.15f - players/40.0f;
		[self updateTitle:playerCount:[NSColor colorWithDeviceRed:r green:g blue:b alpha:15.0]];
	}
		
}


- (void)updater:(SUUpdater *)updater didFindValidUpdate:(SUAppcastItem *)update {
	NSSpeechSynthesizer *speechSynth = [[NSSpeechSynthesizer alloc] initWithVoice:nil];
	[speechSynth setVolume:0.2];
	[speechSynth startSpeakingString:@"New update available!"];
	[speechSynth release];
	//NSLog(@"Found update!");
}

-(void)updaterDidNotFindUpdate:(SUUpdater *)update {
	NSSpeechSynthesizer *speechSynth = [[NSSpeechSynthesizer alloc] initWithVoice:nil];
	[speechSynth setVolume:0.2];
	[speechSynth startSpeakingString:@"No updates found,"];
	[speechSynth release];
	//NSLog(@"No new updates!");
}

/**
 * MenuItem Actions
 * NOTE: Quit menuItem has its own function
 *       created automatically by Interface
 *       Builder.
 */

-(IBAction)refreshAction:(id)sender
{
	[self postNotification:@"ManualRefresh"];
}

-(IBAction)copyToClipboard:(id)sender
{
	pasteBoard = [NSPasteboard generalPasteboard];
	[pasteBoard declareTypes:[NSArray arrayWithObjects:NSStringPboardType, nil] owner:nil];
	[pasteBoard setString:gameName forType:NSStringPboardType];
}

-(IBAction)toggleAutoRefresh:(id)sender
{
	
	if (autoRefresh) {
		[timer invalidate];
		autoRefresh = NO;
		[sender setState:NSOffState];
		
	}
	else {
		[timer invalidate];
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		timer = [NSTimer scheduledTimerWithTimeInterval:[defaults floatForKey:NLTRefreshIntervalKey]
												 target:self
											   selector:@selector(refresh:)
											   userInfo:nil
												repeats:YES];
		
		autoRefresh = YES;
		[sender setState:NSOnState];
	}
	
}

-(IBAction)toggleAutoCopy:(id)sender
{
	
	if (autoCopy) {
		autoCopy = NO;
		[sender setState:NSOffState];
	}
	else {
		autoCopy = YES;
		[sender setState:NSOnState];
		[self postNotification:@"ManualRefresh"];
	}
}

- (BOOL)validateMenuItem:(NSMenuItem *)item
{
	
	NSInteger tag = [item tag];
	if (tag == copyGameNameItem && isRefreshed == NO)
		return NO;
	else
		return YES;
	
}

/**
 * Menu items that brings up window
 * openAbout: opens About Panel
 * showPreferencePanel: opens Preference Panel
 */

- (IBAction)openAbout:(id)sender
{
	[NSApp activateIgnoringOtherApps:YES];
	//[NSApp orderFrontStandardAboutPanel:YES];
	
	[NSApp orderFrontStandardAboutPanel:(id)sender];
}

- (IBAction)showPreferencePanel:(id)sender
{
	// Is preferenceController nil?
	if ( ! preferenceController) {
		preferenceController = [[PreferenceController alloc] init];
	}
	
	NSLog(@"Showing %@", preferenceController);
	
	[NSApp activateIgnoringOtherApps:YES];
	[preferenceController showWindow:self];
	
}

- (IBAction)hidePreferencePanel:(id)sender
{
	// Is preferenceController nil?
	if ( preferenceController) {
		[NSApp activateIgnoringOtherApps:NO];
		[preferenceController close];
		NSLog(@"Hiding %@", preferenceController);
	}
	
}

@synthesize statusMenu;
@synthesize statusItem;
@synthesize preferenceController;
//@synthesize hotkeySuccess;
//@synthesize hotkeyFullOrError;
@end