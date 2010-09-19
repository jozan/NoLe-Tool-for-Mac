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

OSStatus myHotKeyHandler(EventHandlerCallRef nextHandler, EventRef anEvent, void *userData);

-(void)awakeFromNib
{
	EventHotKeyRef	myHotKeyRef;
	EventHotKeyID	myHotKeyID;
	EventTypeSpec	eventType;
	eventType.eventClass=kEventClassKeyboard;
	eventType.eventKind=kEventHotKeyPressed;
	InstallApplicationEventHandler(&myHotKeyHandler,1,&eventType,NULL,NULL);
	
	myHotKeyID.signature='up';
	myHotKeyID.id=1;

	// Get version number
	NSString* version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];

	// Register hotkey ctrl+option+space
	RegisterEventHotKey(49, controlKey+optionKey, myHotKeyID, GetApplicationEventTarget(), 0, &myHotKeyRef);
	
	//Create the NSStatusBar and set its length
	statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength] retain];
	
	
	NSAttributedString *atitle = [[NSAttributedString alloc]
								  initWithString:@" 0" attributes:
								  [NSDictionary dictionaryWithObjectsAndKeys:
								   [NSFont menuBarFontOfSize:0], NSFontAttributeName,
								   [NSColor grayColor], NSForegroundColorAttributeName,
								   nil]];
	
	[statusItem setAttributedTitle:atitle];
	[atitle release];
	
	[statusItem setHighlightMode:YES];
	[statusItem setToolTip:version];
	[statusItem setMenu:statusMenu];
	[statusItem setEnabled:YES];
	
	mySelf = self;
	
	hotkeySuccess = [NSSound soundNamed:@"mmmm"];
	hotkeyFullOrError =[NSSound soundNamed:@"doh"];
	
	[self update];
	
	timer = [NSTimer scheduledTimerWithTimeInterval:20.0
											 target:self
										   selector:@selector(update)
										   userInfo:nil
											repeats: YES];
	

}

-(void)dealloc
{   
	[statusItem release];
	//[gameName release];
	//[playerCount release];
	//[aString release];
	[mySelf release];
	[hotkeySuccess release];
	[hotkeyFullOrError release];
	[receivedData release];
	
	[super dealloc];
}

-(void)update
{
	// Introduce variables
	
	/**
	 * This should work as well using:
	 * NSString *urlContent = [NSString stringWithContentsOfURL:url];
	 *
	 * However, better error handling is NEEDED!
	 */
	
	
	// Mark statusbar as updating
	NSAttributedString *atitle = [[NSAttributedString alloc]
								  initWithString:@"U!" attributes:
								  [NSDictionary dictionaryWithObjectsAndKeys:
								   [NSFont menuBarFontOfSize:0], NSFontAttributeName,
								   [NSColor grayColor], NSForegroundColorAttributeName,
								   nil]];
	
	[statusItem setAttributedTitle:atitle];
	[atitle release];
	
	// Create the request.
	NSURLRequest *theRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.nordicleague.eu/api/games/s"]
											  cachePolicy:NSURLRequestReloadIgnoringCacheData
										  timeoutInterval:5.0];
	
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
		return;
	
	NSLog(data);
	
	NSArray *resultArray = [data componentsSeparatedByString:@"|"];
	
	if ([resultArray count] != 3)
	{
		[self processError:@"-"];
		return;
	}
	/* Quick fix for gameName problem. It's root are in data where game name is from. */
	NSString *dirtyGameName = [[NSString alloc]initWithString:[resultArray objectAtIndex:0]];
	NSString *cleanGameName = [dirtyGameName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	[dirtyGameName release];
	
	//gameName = [[NSString alloc] initWithString:[resultArray objectAtIndex:0]];
	gameName = [[NSString alloc] initWithString:cleanGameName];
	playerCount = [resultArray objectAtIndex:1];
	//playerCount = @"4";
	
	
	NSLog(@"Game name: %@", gameName);
	NSLog(@"Player count: %@", playerCount);
	
	
	// Display player count on status bar	
	NSAttributedString *atitle = [self formatString:playerCount];
	
	[statusItem setAttributedTitle:atitle];
	
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
}

-(void)processError:(NSString *)error
{
	[statusItem setTitle:error];
	isUpdated = NO;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Append the new data to receivedData.
    [receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // do something with the data
    // receivedData is declared as a method instance elsewhere
	
    // NSLog(@"Succeeded! Received %d bytes of data",[receivedData length]);
	
	[self processData:[[NSString alloc] initWithData:receivedData encoding:NSASCIIStringEncoding]];
	
    // release the connection, and the data object
    [connection release];
	[receivedData release];
}
		 
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	// This method is called when the server has determined that it
	// has enough information to create the NSURLResponse.

	// It can be called multiple times, for example in the case of
	// redirect, so each time we reset the data.

	[receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	[connection release];
    [receivedData release];

    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSErrorFailingURLStringKey]);
	
	[self processError:@"E4"];
}

-(IBAction)refresh:(id)sender
{
	[self update];
}

- (NSAttributedString *)formatString:(NSString *)str
{
	
	NSString *formattedString;
	NSAttributedString *aString;
	
	if (gameName.length > 27)
	{
		formattedString = [NSString stringWithFormat:@"NA"];
		aString = [[NSAttributedString alloc] initWithString:formattedString attributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSFont menuBarFontOfSize:0], NSFontAttributeName,[NSColor grayColor], NSForegroundColorAttributeName,nil]];
	}
	
	if (str.length == 1)
	{
		
		formattedString = [NSString stringWithFormat:@" %@", str];
		
		if ([str isEqualToString:@"0"] || [str isEqualToString:@"1"] || [str isEqualToString:@"2"] || [str isEqualToString:@"3"] || [str isEqualToString:@"4"] || [str isEqualToString:@"5"] || [str isEqualToString:@"6"])
		{
			aString = [[NSAttributedString alloc] initWithString:formattedString attributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSFont menuBarFontOfSize:0], NSFontAttributeName,[NSColor colorWithDeviceRed:0.0 green:0.6 blue:0.0 alpha:1.0], NSForegroundColorAttributeName,nil]];
		}
		else if ([str isEqualToString:@"7"] || [str isEqualToString:@"8"])
		{
			aString = [[NSAttributedString alloc] initWithString:formattedString attributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSFont menuBarFontOfSize:0], NSFontAttributeName,[NSColor colorWithDeviceRed:0.8 green:0.5 blue:0.0 alpha:1.0], NSForegroundColorAttributeName,nil]];
		}
		else if ([str isEqualToString:@"9"])
		{
			aString = [[NSAttributedString alloc] initWithString:formattedString attributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSFont menuBarFontOfSize:0], NSFontAttributeName,[NSColor colorWithDeviceRed:0.8 green:0.37 blue:0.0 alpha:1.0], NSForegroundColorAttributeName,nil]];
		}
		else
		{
			NSLog(@"formatted: \"%@\"", formattedString);
			formattedString = [NSString stringWithFormat:@"E%@", str];
			aString = [[NSAttributedString alloc] initWithString:formattedString attributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSFont menuBarFontOfSize:0], NSFontAttributeName,[NSColor redColor], NSForegroundColorAttributeName,nil]];
		}
		
		//return [NSString stringWithFormat:@" %@", str];
	}
	else if (str.length == 2)
	{
		//formattedString = [NSString stringWithFormat:@"%@", str];
		aString = [[NSAttributedString alloc] initWithString:str attributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSFont menuBarFontOfSize:0], NSFontAttributeName,[NSColor redColor], NSForegroundColorAttributeName,nil]];
	}
	
	else
	{
		aString = [[NSAttributedString alloc] initWithString:@"E3" attributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSFont menuBarFontOfSize:0], NSFontAttributeName,[NSColor redColor], NSForegroundColorAttributeName,nil]];
	}
	
	//aString = [[NSAttributedString alloc] initWithString:formattedString attributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSFont menuBarFontOfSize:0], NSFontAttributeName,[NSColor greenColor], NSForegroundColorAttributeName,nil]];
	
	//[aString release];
	return aString;
}

/**
 * Other menuItems' actions
 * NOTE: Quit menuItem has its own function
 *       created automatically by Interface
 *       Builder.
 */

-(IBAction)copyToClipboard:(id)sender
{
	
	NSString *copyGameName = [[NSMutableString alloc] initWithString:gameName];
	[copyGameName release];
	
	NSLog(copyGameName);
	
	// Copy game name (copyGameName) to clipbaord
	pasteBoard = [NSPasteboard generalPasteboard];
	[pasteBoard declareTypes:[NSArray arrayWithObjects:NSStringPboardType, nil] owner:nil];
	[pasteBoard setString:copyGameName forType:NSStringPboardType];
	
	NSLog(copyGameName);
}

-(IBAction)toggleAutoRefresh:(id)sender
{
	
	if (autoUpdate) {
		[timer invalidate];
		autoUpdate = NO;
		[sender setState:NSOffState];
		
	}
	else {
		[self update];
		timer = [NSTimer scheduledTimerWithTimeInterval:20.0
												 target:self
											   selector:@selector(update)
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

OSStatus myHotKeyHandler(EventHandlerCallRef nextHandler, EventRef anEvent, void *userData)
{
	// hotkey request to update and copy gamename.
	
	bypassAutoCopy = YES;
	[mySelf update];

    return noErr;
	
}

/**
 * Menu items that brings up window
 * openAbout: opens About Panel
 * showPreferencePanel: opens Preference Panel
 */

- (IBAction)openAbout:(id)sender
{
	[NSApp activateIgnoringOtherApps:YES];
	[NSApp orderFrontStandardAboutPanel:nil];
}

- (IBAction)showPreferencePanel:(id)sender
{
	// Is preferenceController nil?
	if ( ! preferenceController) {
		preferenceController = [[PreferenceController alloc] init];
	}
	
	NSLog(@"Showing %@", preferenceController);

	[preferenceController showWindow:self];
}

@end