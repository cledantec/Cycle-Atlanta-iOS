//
//  NoteToDetailViewController.h
//  Cycle Atlanta
//
//  Created by Felix Malfait on 7/7/14.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Note.h"


@class NoteManager;
@interface NoteToDetailViewController : UIViewController {
    NoteManager *noteManager;
    IBOutlet MKMapView *map;
}
@property (strong, nonatomic) IBOutlet MKMapView *map;
- (IBAction)discard:(id)sender;

@end
