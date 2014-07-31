//
//  NoteToDetailViewController.m
//  Cycle Atlanta
//
//  Created by Felix Malfait on 7/7/14.
//
//

#import "NoteToDetailViewController.h"

@interface NoteToDetailViewController ()

@end

@implementation NoteToDetailViewController
@synthesize map;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"notesToDetail"];
    NSMutableArray *notesToDetail = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    CLLocation *noteLocation = notesToDetail[0];
    
    MKPointAnnotation *startPoint = [[MKPointAnnotation alloc] init];
    startPoint.coordinate = noteLocation.coordinate;
    startPoint.title = @"Magnet note";
    [map addAnnotation:startPoint];
    
    MKCoordinateRegion region = { noteLocation.coordinate, { 0.0078, 0.0068 } };
    [map setRegion:region animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)discard:(id)sender {
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"notesToDetail"];
    NSMutableArray *notesToDetail = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    [notesToDetail removeObjectAtIndex:0];
    NSData *data2 = [NSKeyedArchiver archivedDataWithRootObject:notesToDetail];
    [[NSUserDefaults standardUserDefaults] setObject:data2 forKey:@"notesToDetail"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    if([notesToDetail count])
    {
    
    }
    else
    {
        [self performSegueWithIdentifier:@"unwindToRecordTripViewController" sender:self];

    }
}
@end
