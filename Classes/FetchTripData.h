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

#import <Foundation/Foundation.h>
#import "ActivityIndicatorDelegate.h"
#import "ProgressView.h"
#import "Trip.h"
#import "User.h"

@class User;
@class Trip;

@interface FetchTripData: NSObject
{
    NSMutableURLRequest *urlRequest;
    NSManagedObjectContext *managedObjectContext;
	NSMutableData *receivedData;
    NSDictionary *tripDict;
}

@property (nonatomic, retain) NSDictionary *tripDict;
@property (nonatomic, retain) NSMutableURLRequest *urlRequest;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSMutableData *receivedData;
@property (nonatomic, retain) ProgressView *downloadingProgressView;
@property (nonatomic) int *tripDownloadCount;
@property (nonatomic, retain) NSMutableArray *tripsToLoad;

- (void)fetchTripData:(NSDictionary*) tripToLoad;
- (id)initWithTripCountAndProgessView:(int) tripCount progressView:(ProgressView*) progressView;
- (void)fetchWithTrips:(NSMutableArray*) trips;

@end
