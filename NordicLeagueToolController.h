//
//  NordicLeagueToolController.h
//  NordicLeague Tool
//
//  Created by Johan Ruokangas on 5.8.2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ASIHTTPRequest;

@interface NordicLeagueToolController : NSObject {

	/* Our outlets which allow us to access the interface */
	IBOutlet NSMenu *statusMenu;

	NSStatusItem *statusItem;

}

NSString *gameName = @"No game name copied!";
NSString *playerCount = @"NA";

NSPasteboard *pasteBoard;
NSAttributedString *aString;

//NSDate *currentDate;
//NSString *lastRefreshedTimestamp;
//NSString *relativeTimeStamp;
//NSString *timestampString;


BOOL isUpdated = NO;

-(IBAction)refresh:(id)sender;
-(IBAction)copyToClipboard:(id)sender;
-(IBAction)openAbout:(id)sender;

//@property (retain, nonatomic) ASIHTTPRequest *bigFetchRequest;

@end
/*
@interface NSDateFormatter (Extras)

	- (NSString *)dateDiff:(NSDate *)inputDate;

	- (NSString*)dateToString:(NSDate *)inputDate;

	+ (NSString *)dateDifferenceStringFromString:(NSString *)dateString
									  withFormat:(NSString *)dateFormat;

@end
*/