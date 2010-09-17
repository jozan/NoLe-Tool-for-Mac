//
//  PreferenceController.m
//  NordicLeague Tool
//
//  Created by Jozan (BNET: keepoz) on 16.9.2010.
//  All rights reserved.
//

#import "PreferenceController.h"


@implementation PreferenceController

- (id)init
{
	if ( ! [super initWithWindowNibName:@"Preferences"])
		return nil;
	
	return self;
}

- (void)windowDidLoad
{
	NSLog(@"Nib file is loaded");

}
	
- (IBAction)sliderChangeRefreshTime:(id)sender;
{
	// Changes the number next to slider.
	[refreshTimeValue setIntValue:[refreshTimeSlider intValue]];
	
	// Floods the console!
	//NSLog(@"RefreshTimeValue changed: %i", [refreshTimeSlider intValue]);
}

- (IBAction)saveSettings:(id)sender
{
	NSLog(@"Settings saved. At least button got pressed.");
}

- (IBAction)restoreSettings:(id)sender
{
	NSLog(@"Settings restored to default. At least button got pressed.");
}

@end