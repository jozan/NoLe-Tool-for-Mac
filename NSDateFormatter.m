//
//  NSDateFormatter.m
//  NordicLeague Tool
//
//  Created by Johan Ruokangas on 12.8.2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
/*
#import "NSDateFormatter.h"


@implementation NSDateFormatter (Extras)

	/**
	 * Helper functions
	 */
/*
	- (NSString *)dateDiff:(NSDate *)inputDate {
		
		NSDate *now = [NSDate date];
		double time = [now timeIntervalSinceDate:inputDate];
		time *= -1;
		if(time < 1) {
			return @"less than a second ago";
		} else if (time < 60) {
			return @"less than a minute ago";
		} else if (time < 3600) {
			int diff = round(time / 60);
			if (diff == 1) {
				return [NSString stringWithFormat:@"1 minute ago", diff];
			}
			return [NSString stringWithFormat:@"%d minutes ago", diff];
		} else if (time < 86400) {
			int diff = round(time / 60 / 60);
			if (diff == 1) {
				return [NSString stringWithFormat:@"1 hour ago", diff];
			}
			return [NSString stringWithFormat:@"%d hours ago", diff];
		} else if (time < 604800) {
			int diff = round(time / 60 / 60 / 24);
			if (diff == 1) {
				return [NSString stringWithFormat:@"yesterday", diff];
			}
			else if (diff == 7) { 
				return [NSString stringWithFormat:@"last week", diff];
			}
			return[NSString stringWithFormat:@"%d days ago", diff];
		} else {
			int diff = round(time / 60 / 60 / 24 / 7);
			if (diff == 1) {
				return [NSString stringWithFormat:@"last week", diff];
			}
			return [NSString stringWithFormat:@"%d weeks ago", diff];
		}   
	}

	- (NSString*)dateToString:(NSDate *)inputDate {

		//Create the dateformatter object
		NSDateFormatter* formatter = [[[NSDateFormatter alloc] autorelease] init];
		
		// Set required date format
		[formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss VVVV"];
	
		NSString* strDate = [formatter stringFromDate:inputDate];
	
		return strDate;

		
		[formatter release];
		
	}

	// FROM http://stackoverflow.com/questions/902950/iphone-convert-date-string-to-a-relative-time-stamp
	+ (NSString *)dateDifferenceStringFromString:(NSString *)dateString
									  withFormat:(NSString *)dateFormat
	{
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
		[dateFormatter setDateFormat:dateFormat];
		NSDate *date = [dateFormatter dateFromString:dateString];
		[dateFormatter release];
		NSDate *now = [NSDate date];
		double time = [date timeIntervalSinceDate:now];
		time *= -1;
		if(time < 1) {
			return dateString;
		} else if (time < 60) {
			return @"less than a minute ago";
		} else if (time < 3600) {
			int diff = round(time / 60);
			if (diff == 1) {
				return [NSString stringWithFormat:@"1 minute ago", diff];
			}
			return [NSString stringWithFormat:@"%d minutes ago", diff];
		} else if (time < 86400) {
			int diff = round(time / 60 / 60);
			if (diff == 1) {
				return [NSString stringWithFormat:@"1 hour ago", diff];
			}
			return [NSString stringWithFormat:@"%d hours ago", diff];
		} else if (time < 604800) {
			int diff = round(time / 60 / 60 / 24);
			if (diff == 1) {
				return [NSString stringWithFormat:@"yesterday", diff];
			}
			else if (diff == 7) { 
				return [NSString stringWithFormat:@"last week", diff];
			}
			return[NSString stringWithFormat:@"%d days ago", diff];
		} else {
			int diff = round(time / 60 / 60 / 24 / 7);
			if (diff == 1) {
				return [NSString stringWithFormat:@"last week", diff];
			}
			return [NSString stringWithFormat:@"%d weeks ago", diff];
		}   
	}

@end
*/