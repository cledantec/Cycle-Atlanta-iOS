/** Cycle Atlanta, Copyright 2012, 2013 Georgia Institute of Technology
 *                                    Atlanta, GA. USA
 *
 *   @author Christopher Le Dantec <ledantec@gatech.edu>
 *   @author Anhong Guo <guoanhong@gatech.edu>
 *
 *   Cycle Atlanta is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation, either version 3 of the License, or
 *   (at your option) any later version.
 *
 *   Cycle Atlanta is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with Cycle Atlanta.  If not, see <http://www.gnu.org/licenses/>.
 */

#import "FetchUser.h"
#import "FetchTripData.h"
#import "constants.h"
#import "CycleAtlantaAppDelegate.h"
#import "PersonalInfoViewController.h"
#import "Coord.h"
#import "Trip.h"

#define kEpsilonAccuracy		100.0
#define kEpsilonTimeInterval	10.0
#define kEpsilonSpeed			30.0

@class TripManager;

@implementation FetchTripData

@synthesize managedObjectContext, receivedData, urlRequest, tripDict, downloadingProgressView, tripDownloadCount, tripsToLoad;

- (id)init{
    self.managedObjectContext = [(CycleAtlantaAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    return self;
}

- (id)initWithTripCountAndProgessView:(int) tripCount progressView:(ProgressView*) progressView{
    self.downloadingProgressView = progressView;
    self.tripDownloadCount = tripCount;
    return [self init];
}

- (void)saveTrip:(NSDictionary *)coordsDict{
    UIBackgroundTaskIdentifier taskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^(void) {
        // TODO: add better code for clean up if app times out
        // option: do nothing, user can just hit download again and the rest will come. partially download trips will not be restored
    }];
	NSError *error;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormat setTimeZone:[NSTimeZone timeZoneWithName:@"PST"]]; 
    
    CLLocationDistance distance = 0;
    Coord *prev = nil;
    
    //Add the trip
    Trip * newTrip = (Trip *)[NSEntityDescription insertNewObjectForEntityForName:@"Trip"
                                                            inManagedObjectContext:self.managedObjectContext] ;
    [newTrip setPurpose:tripDict[@"purpose"]];
    [newTrip setStart:[dateFormat dateFromString:tripDict[@"start"]]];
    [newTrip setUploaded:[dateFormat dateFromString:tripDict[@"stop"]]];
    [newTrip setSaved:[NSDate date]];
    [newTrip setNotes:tripDict[@"notes"]];
    [newTrip setDistance:0];
    
    if (![self.managedObjectContext save:&error]) {
        // Handle the error.
        NSLog(@"TripManager addCoord error %@, %@", error, [error localizedDescription]);
    }
    //Add the coords
    Coord *newCoord = nil;
    Coord *firstCoord = nil;
    BOOL isFirstCoord = true;
    for(NSDictionary *coord in coordsDict){
        newCoord = (Coord *)[NSEntityDescription insertNewObjectForEntityForName:@"Coord" inManagedObjectContext:self.managedObjectContext];
        [newCoord setAltitude:@([coord[@"altitude"] doubleValue])];
        [newCoord setLatitude:@([coord[@"latitude"] doubleValue])];
        [newCoord setLongitude:@([coord[@"longitude"] doubleValue])];
        [newCoord setRecorded:[dateFormat dateFromString:coord[@"recorded"]]];
        [newCoord setSpeed:@([coord[@"altitude"] doubleValue])];
        [newCoord setHAccuracy:@([coord[@"h_accuracy"] doubleValue])];
        [newCoord setVAccuracy:@([coord[@"v_accuracy"] doubleValue])];
        
        [newTrip addCoordsObject:newCoord];
        
        if(prev){
            distance	+= [self distanceFrom:prev to:newCoord realTime:YES];
        }
        prev = newCoord;
        
        if(isFirstCoord){
            firstCoord = newCoord;
            isFirstCoord = false;
        }
    }
    // update duration
    NSTimeInterval duration = [newCoord.recorded timeIntervalSinceDate:firstCoord.recorded];
    //NSLog(@"duration = %.0fs", duration);
    [newTrip setDuration:@(duration)];
    [newTrip setDistance:@(distance)];
    
	if (![self.managedObjectContext save:&error]) {
		// Handle the error.
		NSLog(@"TripManager addCoord error %@, %@", error, [error localizedDescription]);
	}
    
    if (taskId != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:taskId];
    }
}

- (CLLocationDistance)calculateTripDistance:(Trip*)trip
{
	NSLog(@"calculateTripDistance for trip started %@ having %lu coords", trip.start, (unsigned long)[trip.coords count]);
	
	CLLocationDistance newDist = 0.;
    	
	// filter coords by hAccuracy
	NSPredicate *filterByAccuracy	= [NSPredicate predicateWithFormat:@"hAccuracy < 100.0"];
	NSArray		*filteredCoords		= [[trip.coords allObjects] filteredArrayUsingPredicate:filterByAccuracy];
	NSLog(@"count of filtered coords = %lu", (unsigned long)[filteredCoords count]);
	
	if ( [filteredCoords count] )
	{
		// sort filtered coords by recorded date
		NSSortDescriptor *sortByDate	= [[NSSortDescriptor alloc] initWithKey:@"recorded" ascending:YES];
		NSArray		*sortDescriptors	= @[sortByDate];
		NSArray		*sortedCoords		= [filteredCoords sortedArrayUsingDescriptors:sortDescriptors];
		
		for (int i=1; i < [sortedCoords count]; i++)
		{
			Coord *prev	 = sortedCoords[(i - 1)];
			Coord *next	 = sortedCoords[i];
			newDist	+= [self distanceFrom:prev to:next realTime:NO];
		}
	}
	
	return newDist;
}

- (CLLocationDistance)distanceFrom:(Coord*)prev to:(Coord*)next realTime:(BOOL)realTime
{
	CLLocation *prevLoc = [[CLLocation alloc] initWithLatitude:[prev.latitude doubleValue]
                                                      longitude:[prev.longitude doubleValue]];
	CLLocation *nextLoc = [[CLLocation alloc] initWithLatitude:[next.latitude doubleValue]
                                                      longitude:[next.longitude doubleValue]];
	
	CLLocationDistance	deltaDist	= [nextLoc distanceFromLocation:prevLoc];
	NSTimeInterval		deltaTime	= [next.recorded timeIntervalSinceDate:prev.recorded];
	CLLocationDistance	newDist		= 0.;
	
	// sanity check accuracy
	if ( [prev.hAccuracy doubleValue] < kEpsilonAccuracy &&
        [next.hAccuracy doubleValue] < kEpsilonAccuracy )
	{
		// sanity check time interval
		if ( !realTime || deltaTime < kEpsilonTimeInterval )
		{
			// sanity check speed
			if ( !realTime || (deltaDist / deltaTime < kEpsilonSpeed) )
			{
				// consider distance delta as valid
				newDist += deltaDist;				
			}
		}
	}
	
	return newDist;
}

- (void)fetchWithTrips:(NSMutableArray*) trips
{
    [self.downloadingProgressView updateProgress:1.0f/[[NSNumber numberWithInt:tripDownloadCount] floatValue] ];
    self.tripsToLoad = trips;
    NSDictionary* trip = [self.tripsToLoad lastObject];
    [self.tripsToLoad removeLastObject];
    
    if(trip)
    {
        [self fetchTripData:trip];
    }    
}


- (void)fetchTripData:(NSDictionary*) tripToLoad
{
    self.tripDict = tripToLoad;
    
    NSMutableString *postBody = [NSMutableString string];
    self.urlRequest = [[NSMutableURLRequest alloc] init] ;
    [urlRequest setURL:[NSURL URLWithString:kFetchURL] ];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    NSDictionary *postDict = @{@"t": @"get_coords_by_trip", @"q": (self.tripDict)[@"id"]};
    NSString *sep = @"";
    for(NSString * key in postDict) {
        [postBody appendString:[NSString stringWithFormat:@"%@%@=%@",
                                sep,
                                key,
                                postDict[key]]];
        sep = @"&";
    }
    NSLog(@"POST Data: %@", postBody);
    [urlRequest setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[[postBody dataUsingEncoding:NSUTF8StringEncoding] length]] forHTTPHeaderField:@"Content-Length"];
    [urlRequest setHTTPBody:[postBody dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    
    if ( theConnection )
    {
        receivedData=[NSMutableData data];
    }
    else
    {
        // inform the user that the download could not be made
        NSLog(@"Download failed!");
    }    
}

#pragma mark NSURLConnection delegate methods


- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten
 totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
//	NSLog(@"%d bytesWritten, %d totalBytesWritten, %d totalBytesExpectedToWrite",
//		  bytesWritten, totalBytesWritten, totalBytesExpectedToWrite );
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	// this method is called when the server has determined that it
    // has enough information to create the NSURLResponse
	// NSLog(@"didReceiveResponse: %@", response);
	
	NSHTTPURLResponse *httpResponse = nil;
	if ( [response isKindOfClass:[NSHTTPURLResponse class]] &&
		( httpResponse = (NSHTTPURLResponse*)response ) )
	{
		BOOL success = NO;
		NSString *title   = nil;
		NSString *message = nil;
		switch ( [httpResponse statusCode] )
		{
			case 200:
			case 201:
				success = YES;
				title	= kSuccessFetchTitle;
				message = @"Coords downloaded";//kFetchSuccess;
				break;
			case 500:
			default:
				title = @"Internal Server Error";
				message = kServerError;
		}
		
		NSLog(@"%@: %@", title, message);
        
        // DEBUG
        //NSLog(@"+++++++DEBUG didReceiveResponse %@: %@", [response URL],[(NSHTTPURLResponse*)response allHeaderFields]);
        
        if ( success )
		{
            //NSLog(@"Coord Download Success.");
            
            //[uploadingView loadingComplete:kSuccessTitle delayInterval:.7];
		} else {
            //not sure if this is needed here.
        }
	}
    // receivedData is declared as a method instance elsewhere
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // append the new data to the receivedData
	[receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // release the connection, and the data object
	
    // receivedData is declared as a method instance elsewhere
    
    [self.downloadingProgressView setErrorMessage:kFetchError];
    [self.downloadingProgressView updateProgress:1.0f/[[NSNumber numberWithInt:self.tripDownloadCount] floatValue] ];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];

    // inform the user
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [error userInfo][NSURLErrorFailingURLStringErrorKey]);
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    //NSString *dataString = [[[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding] autorelease];
    NSLog(@"+++++++DEBUG: Received %lu bytes of data for trip %@", (unsigned long)[receivedData length], tripDict[@"id"]);
    NSError *error;
    NSString *jsonString = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
    NSDictionary *coordsDict = [NSJSONSerialization JSONObjectWithData: [jsonString dataUsingEncoding:NSUTF8StringEncoding]
                                                         options: NSJSONReadingMutableContainers
                                                           error: &error];    
    [self saveTrip:coordsDict];
    
    //Debugging received data
//    NSData *JsonDataCoords = [[NSData alloc] initWithData:[NSJSONSerialization dataWithJSONObject:JSON options:0 error:&error]];
//    NSLog(@"%@", [[[NSString alloc] initWithData:JsonDataCoords encoding:NSUTF8StringEncoding] autorelease] );

    // release the connection, and the data object
    //get the next trip from the array.
    [self fetchWithTrips:self.tripsToLoad];
}

@end
