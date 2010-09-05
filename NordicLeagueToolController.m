//
//  NordicLeagueToolController.m
//  NordicLeague Tool
//
//  Created by Jozan (BNET: keepoz) on 5.8.2010.
//  Copyright 2010 Jozan. All rights reserved.
//

#import "NordicLeagueToolController.h"
#define copyGameNameItem 5300
//#define infoMenuItemTag 5010


@implementation NordicLeagueToolController

-(void)awakeFromNib
{
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
	[statusItem setToolTip:@"NordicLeague Tool v0.1"];
	[statusItem setMenu:statusMenu];
	[statusItem setEnabled:YES];
}

-(void)dealloc
{   
	[statusItem release];
	//[gameName release];
	//[playerCount release];
	//˘[aString release];
	
	[super dealloc];
}

 
-(IBAction)refresh:(id)sender{
	
	// Introduce variables
	//NSURL *url;
	//NSString *urlString = @"http://jozan.fi/dota/get/gamename/display/simple";
	
	NSURL *url = [NSURL URLWithString:@"http://jozan.fi/dota/get/gamename/display/simple"];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
	[request setDelegate:self];
	[request startAsynchronous];
	
	
	NSAttributedString *atitle = [[NSAttributedString alloc]
								  initWithString:@"U!" attributes:
								  [NSDictionary dictionaryWithObjectsAndKeys:
								   [NSFont menuBarFontOfSize:0], NSFontAttributeName,
								   [NSColor grayColor], NSForegroundColorAttributeName,
								   nil]];
	
	[statusItem setAttributedTitle:atitle];
	[atitle release];
	
}

- (NSAttributedString *)formatString:(NSString *)str {
	
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
	
- (void)requestFinished:(ASIHTTPRequest *)request
{
	// Fetch text data to NSString
	NSString *responseString = [request responseString];
	
	NSArray *resultArray = [responseString componentsSeparatedByString:@"|"];
	
	gameName = [[NSString alloc] initWithString:[resultArray objectAtIndex:0]];
	playerCount = [resultArray objectAtIndex:1];
	//playerCount = @"4";
	
	
	NSLog(@"Game name: %@", gameName);
	NSLog(@"Player count: %@", playerCount);

	
	// Display player count on status bar	
	NSAttributedString *atitle = [self formatString:playerCount];
	
	[statusItem setAttributedTitle:atitle];
	[statusItem setToolTip:@"NordicLeague Tool v0.1"];
	
	// Automatically copy game name to clipboard
	pasteBoard = [NSPasteboard generalPasteboard];
	[pasteBoard declareTypes:[NSArray arrayWithObjects:NSStringPboardType, nil] owner:nil];
	[pasteBoard setString:gameName forType:NSStringPboardType];
	
	isUpdated = YES;
	
	
	//currentDate = [[[NSDate alloc] date] init];
	//[currentDate release];
	
	//NSDate *currentDate = [NSDate date];
	//lastRefreshedTimestamp = [[NSDateFormatter alloc] dateToString:currentDate];
	
	//NSLog(@"Date: %@",lastRefreshedTimestamp);
	
	
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
	//NSError *error = [request error];
	[statusItem setTitle:@"E4"];
	//[statusItem setToolTip:error];
	
	isUpdated = NO;
}

/**
 * Other menuItems' actions
 * NOTE: Quit menuItem has its own function
 *       created automatically by Interface
 *       Builder.
 */

-(IBAction)copyToClipboard:(id)sender{
	
	NSString *copyGameName = [[NSMutableString alloc] initWithString:gameName];
	[copyGameName release];
	
	NSLog(copyGameName);
	
	// Copy game name (copyGameName) to clipbaord
	pasteBoard = [NSPasteboard generalPasteboard];
	[pasteBoard declareTypes:[NSArray arrayWithObjects:NSStringPboardType, nil] owner:nil];
	[pasteBoard setString:copyGameName forType:NSStringPboardType];
	
	NSLog(copyGameName);
}

-(IBAction)openAbout:(id)sender{
	[NSApp activateIgnoringOtherApps:YES];
	[NSApp orderFrontStandardAboutPanel:nil];
}


- (BOOL)validateMenuItem:(NSMenuItem *)item {
	
	NSInteger tag = [item tag];
	//NSObject *lastRefreshedMenuItem = [statusMenu itemWithTag:infoMenuItemTag];
	
	//NSLog(@"%i",infoMenuItemTag);
	//NSLog(lastRefreshedMenuItem);
	
	//yyyy-MM-dd HH:mm:ss VVVV
	
	if (tag == copyGameNameItem && isUpdated == NO)
	{
		//NSLog(@"Do I repeat myself here?");
		return NO;
		
	}
	/*
	else if (tag == infoMenuItemTag && isUpdated == YES)
	{
		relativeTimeStamp = [NSDateFormatter dateDifferenceStringFromString:lastRefreshedTimestamp
																 withFormat:@"yyyy-MM-dd HH:mm:ss VVVV"];
		//[lastRefreshedTimestamp release];
		
		[lastRefreshedMenuItem setTitle:relativeTimeStamp];
		//[lastRefreshedMenuItem setTitle:@"Last refreshed: ---"];
		
		//NSLog(@"Why do I repeat myself?");
		
		return YES;
		
	}*/
	else
	{
		return YES;
	}
	
}

@end