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
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	float refreshTime = [defaults floatForKey:NLTRefreshIntervalKey];	
	return refreshTime;
}

// NOT WORKING
- (BOOL)gameNameValue
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	return [defaults boolForKey:NLTGameNameKey];
}

- (void)windowDidLoad
{
	NSLog(@"Nib file is loaded");
	
	CGFloat interval = [self refreshTimeIntervalValue];
	
	[refreshTimeSlider setFloatValue:interval];
	[refreshTimeLabel setFloatValue:interval];

}

- (void)savePrefs
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setFloat:[refreshTimeLabel floatValue] forKey:NLTRefreshIntervalKey];
	[defaults synchronize];
}
	
- (IBAction)sliderChangeRefreshTime:(id)sender;
{	
	// Update defaults
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setFloat:[refreshTimeLabel floatValue] forKey:NLTRefreshIntervalKey];
	
	CGFloat interval = [self refreshTimeIntervalValue];
	[refreshTimeSlider setFloatValue:interval];
	[refreshTimeLabel setFloatValue:interval];

	// Floods the console!
	//NSLog(@"RefreshTimeValue changed: %i", [refreshTimeSlider intValue]);
}

- (IBAction)saveAndClose:(id)sender
{
	NSLog(@"Settings saved. At least button got pressed.");
	[self savePrefs];
	[window close];
}

- (IBAction)restoreSettings:(id)sender
{
	NSLog(@"Settings restored to default. At least button got pressed.");
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setFloat:20.0	forKey:NLTRefreshIntervalKey];
	[defaults synchronize];
	
	CGFloat interval = [self refreshTimeIntervalValue];
	[refreshTimeSlider setFloatValue:interval];
	[refreshTimeLabel setFloatValue:interval];
}

@synthesize refreshTimeLabel;
@synthesize refreshTimeSlider;
@end