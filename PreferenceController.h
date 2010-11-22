//
//  PreferenceController.h
//  NordicLeague Tool
//
//  Created by Johan Ruokangas on 16.9.2010.
//  All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString * const NLTRefreshIntervalKey;
extern NSString * const NLTGameNameKey;

@interface PreferenceController : NSWindowController {
	IBOutlet id refreshTimeLabel;
	IBOutlet NSSlider *refreshTimeSlider;
	IBOutlet NSMatrix *matrix;
	
}

- (BOOL)gameNameValue;
- (float)refreshTimeIntervalValue;
- (void)savePrefs;
- (BOOL)getSelectedTagFromMatrix;
- (void)resetMatrix:(BOOL)qualification;

- (IBAction)sliderChangeRefreshTime:(id)sender;
- (IBAction)matrixChangeGameToBeCopied:(id)sender;
- (IBAction)restoreSettings:(id)sender;
- (IBAction)saveAndClose:(id)sender;


@property (retain) id refreshTimeLabel;
@property (retain) NSSlider *refreshTimeSlider;
@property (retain) NSMatrix *matrix;
@end
