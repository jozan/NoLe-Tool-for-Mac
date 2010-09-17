//
//  PreferenceController.h
//  NordicLeague Tool
//
//  Created by Johan Ruokangas on 16.9.2010.
//  All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PreferenceController : NSWindowController {
	IBOutlet id refreshTimeValue;
	IBOutlet NSSlider *refreshTimeSlider;
}

- (IBAction)sliderChangeRefreshTime:(id)sender;
- (IBAction)changeGameToBeCopied:(id)sender;
- (IBAction)restoreSettings:(id)sender;
- (IBAction)saveSettings:(id)sender;

@end
