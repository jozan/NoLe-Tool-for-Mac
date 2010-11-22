//
//  PreferenceController.m
//  NordicLeague Tool
//
//  Created by Jozan (BNET: keepoz) on 16.9.2010.
//  All rights reserved.
//

#import "PreferenceController.h"

NSString * const NLTRefreshIntervalKey = @"RefreshTimeInterval";
NSString * const NLTGameNameKey = @"GameNameToCopy";

@implementation PreferenceController

- (id)init
{
	if ( ! [super initWithWindowNibName:@"Preferences"])
		return nil;
	
	return self;
}

- (float)refreshTimeIntervalValue
{
	return [[NSUserDefaults standardUserDefaults] floatForKey:NLTRefreshIntervalKey];
}

- (BOOL)gameNameValue
{
	return [[NSUserDefaults standardUserDefaults] boolForKey:NLTGameNameKey];
}

- (void)windowDidLoad
{
	NSLog(@"Nib file is loaded");
	
	CGFloat interval = [self refreshTimeIntervalValue];
	
	[refreshTimeSlider setFloatValue:interval];
	[refreshTimeLabel setFloatValue:interval];
	
	[matrix deselectAllCells];
	BOOL state = [self gameNameValue];
	
	if (state == TRUE)
		[matrix setSelectionFrom:0 to:0 anchor:0 highlight:YES];
	else
		[matrix setSelectionFrom:1 to:1 anchor:1 highlight:YES];

}
	
- (IBAction)sliderChangeRefreshTime:(id)sender
{	
	// Update defaults
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setFloat:[refreshTimeLabel floatValue] forKey:NLTRefreshIntervalKey];
	[defaults synchronize];
	
	CGFloat interval = [self refreshTimeIntervalValue];
	[refreshTimeSlider setFloatValue:interval];
	[refreshTimeLabel setFloatValue:interval];

	// Floods the console!
	//NSLog(@"RefreshTimeValue changed: %i", [refreshTimeSlider intValue]);
}

- (IBAction)matrixChangeGameToBeCopied:(id)sender
{
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	switch ([[sender selectedCell] tag]) {
		case 0:
			[defaults setBool:FALSE forKey:NLTGameNameKey];
			break;
		case 1:
		default:
			[defaults setBool:TRUE forKey:NLTGameNameKey];
	}
	
	[defaults synchronize];
}

- (BOOL)getSelectedTagFromMatrix
{
	switch ([[matrix selectedCell] tag]) {
		case 0:
			NSLog(@"Got tag 0");
			return FALSE;
		case 1:
		default:
			NSLog(@"Got tag 1 or default");
			return TRUE;
	}
}

- (void)resetMatrix:(BOOL)NormalGame
{
	[matrix deselectAllCells];
	
	if (NormalGame)
		[matrix setSelectionFrom:0 to:0 anchor:0 highlight:YES];
	else
		[matrix setSelectionFrom:1 to:1 anchor:1 highlight:YES];	
}

- (IBAction)saveAndClose:(id)sender
{
	NSLog(@"Settings saved.");
	[self saveSettingsToUserDefaults];
	[self close];
	
}

- (void)saveSettingsToUserDefaults
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setFloat:[refreshTimeLabel floatValue] forKey:NLTRefreshIntervalKey];
	[defaults setBool:[self getSelectedTagFromMatrix] forKey:NLTGameNameKey];
	[defaults synchronize];
}

- (IBAction)restoreSettings:(id)sender
{
	NSLog(@"Settings restored to default.");
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setFloat:20.0	forKey:NLTRefreshIntervalKey];
	[defaults setBool:TRUE forKey:NLTGameNameKey];
	[defaults synchronize];
	
	CGFloat interval = [self refreshTimeIntervalValue];
	[refreshTimeSlider setFloatValue:interval];
	[refreshTimeLabel setFloatValue:interval];
	[self resetMatrix:TRUE];
	
}

@synthesize refreshTimeLabel;
@synthesize refreshTimeSlider;
@synthesize matrix;
@end