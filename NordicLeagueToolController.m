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
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues ];
}

-(void)dealloc
{
	[NSEvent removeMonitor:hotkeyMonitor];
	[timer invalidate];
	[timer release];	
	[statusItem release];
	[gameName release];
	[playerCount release];
	[hotkeySuccess release];
	[hotkeyFullOrError release];
	[preferenceController release];
	
	[receivedData release];
	
	[super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	hotkeyMonitor = [NSEvent addGlobalMonitorForEventsMatchingMask:NSKeyDownMask handler:^(NSEvent* event){
		if (([event keyCode] == 49) && ([event modifierFlags] & NSControlKeyMask) && ([event modifierFlags] & NSCommandKeyMask)) {
			[self postNotification:@"HotKeyUpdate"];
		};
	}];
}

-(void)autoUpdate:(NSTimer *)timer
{
	[self postNotification:@"AutoUpdate"];
}

-(void)postNotification:(NSString *)postNotificationName
{
	
	if (postNotificationName == @"HotKeyUpdate")
	{
		if (updateInProgress == YES || bypassAutoCopy == YES)
			return;
		else
			bypassAutoCopy = YES;
		
		NSLog(@"Posting HotKeyUpdate Notification..");
	}
	else if (postNotificationName == @"AutoUpdate")
	{
		NSLog(@"Posting AutoUpdate Notification..");
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
	NSString* version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	
	[nc addObserver:self
		   selector:@selector(update:) 
			   name:@"HotKeyUpdate"
			 object:nil];
	
	[nc addObserver:self
		   selector:@selector(update:) 
			   name:@"AutoUpdate"
			 object:nil];
	
	//Create the NSStatusBar and set its length
	statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:40] retain];
	
	[self prettyIntro];
	
	[statusItem setHighlightMode:YES];
	[statusItem setToolTip:version];
	[statusItem setMenu:statusMenu];
	[statusItem setEnabled:YES];
	
	hotkeySuccess = [NSSound soundNamed:@"mmmm"];
	[hotkeySuccess setVolume:0.3];
	hotkeyFullOrError =[NSSound soundNamed:@"doh"];
	[hotkeyFullOrError setVolume:0.3];
	
	
	
	timer = [NSTimer scheduledTimerWithTimeInterval:[[NSUserDefaults standardUserDefaults] floatForKey:NLTRefreshIntervalKey]
											 target:self
										   selector:@selector(autoUpdate:)
										   userInfo:nil
											repeats:YES];
	//[self  updateTitle:@"NL":[NSColor blueColor]];
	//[self postNotification:@"AutoUpdate"];
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

-(void)update:(id)sender
{
	if (updateInProgress == YES)
	{
		NSLog(@"Another update is already in progress, aborting.");
		return;
	}
	
	updateInProgress = YES;
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
			if ([playerCount isEqualToString:@"10"])
				[hotkeyFullOrError play];
			else
				[hotkeySuccess play];
			
			bypassAutoCopy = NO;
		}
	}
	isUpdated = YES;
	[self performSelector:@selector(updateSuccess:) withObject:nil afterDelay:1.0];
}

-(void)updateSuccess:(id)sender
{
	updateInProgress = NO;
}

-(void)processError:(NSString *)error
{
	[self updateTitle:error:[NSColor redColor]];
	//[statusItem updateTitle:error];
	isUpdated = NO;
	updateInProgress = NO;
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

-(IBAction)refresh:(id)sender
{
	[self postNotification:@"AutoUpdate"];
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

/**
 * Other menuItems' actions
 * NOTE: Quit menuItem has its own function
 *       created automatically by Interface
 *       Builder.
 */

-(IBAction)copyToClipboard:(id)sender
{
	pasteBoard = [NSPasteboard generalPasteboard];
	[pasteBoard declareTypes:[NSArray arrayWithObjects:NSStringPboardType, nil] owner:nil];
	[pasteBoard setString:gameName forType:NSStringPboardType];
}

-(IBAction)toggleAutoRefresh:(id)sender
{
	
	if (autoUpdate) {
		[timer invalidate];
		autoUpdate = NO;
		[sender setState:NSOffState];
		
	}
	else {
		[self update:nil];
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		timer = [NSTimer scheduledTimerWithTimeInterval:[defaults floatForKey:NLTRefreshIntervalKey]
												 target:self
											   selector:@selector(update:)
											   userInfo:nil
												repeats:YES];
		autoUpdate = YES;
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
		[self postNotification:@"AutoUpdate"];
	}
}

- (BOOL)validateMenuItem:(NSMenuItem *)item
{
	
	NSInteger tag = [item tag];
	if (tag == copyGameNameItem && isUpdated == NO)
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
@synthesize hotkeySuccess;
@synthesize hotkeyFullOrError;
@end