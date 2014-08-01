//
//  NoteToDetailViewController.m
//  Cycle Atlanta
//
//  Created by Felix Malfait on 7/7/14.
//
//

#import "NoteToDetailViewController.h"
#import "NoteManager.h"
#import "PickerViewController.h"



@interface NoteToDetailViewController ()

@end

@implementation NoteToDetailViewController
@synthesize map, noteManager, recordTripVC;;


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
    [self updateDisplay];
}

- (void) updateDisplay
{
    
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"notesToDetail"];
    NSMutableArray *notesToDetail = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    // Map
    CLLocation *noteLocation = notesToDetail[0];
    
    MKPointAnnotation *startPoint = [[MKPointAnnotation alloc] init];
    startPoint.coordinate = noteLocation.coordinate;
    startPoint.title = @"Magnet note";
    [map addAnnotation:startPoint];
    
    MKCoordinateRegion region = { noteLocation.coordinate, { 0.0078, 0.0068 } };
    [map setRegion:region animated:YES];
    
    // NavBar
    if([notesToDetail count] > 1)
    {
        [navBar setTitle:[NSString stringWithFormat:@"%lu Notes to detail", (unsigned long)[notesToDetail count]]];
    }
    else
    {
        [navBar setTitle:@"1 Note to detail"];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




- (IBAction)discard:(id)sender {
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"notesToDetail"];
    NSMutableArray *notesToDetail = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    [notesToDetail removeObjectAtIndex:0];
    NSData *data2 = [NSKeyedArchiver archivedDataWithRootObject:notesToDetail];
    [[NSUserDefaults standardUserDefaults] setObject:data2 forKey:@"notesToDetail"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    if([notesToDetail count])
    {
        [self updateDisplay];
    }
    else
    {
        [self performSegueWithIdentifier:@"unwindToRecordTripViewController" sender:self];

    }
}

- (IBAction)detail:(id)sender {
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"notesToDetail"];
    NSMutableArray *notesToDetail = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    [noteManager addLocation:notesToDetail[0]];
    
    [[NSUserDefaults standardUserDefaults] setInteger:3 forKey: @"pickerCategory"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainWindow"
                                                         bundle: nil];
    PickerViewController *pickerViewController = [[storyboard instantiateViewControllerWithIdentifier:@"Picker"] initWithNibName:@"Picker" bundle:nil];
    [pickerViewController setDelegate:recordTripVC];
    [self presentViewController:pickerViewController animated:YES completion:nil];
    
    [notesToDetail removeObjectAtIndex:0];
    NSData *data2 = [NSKeyedArchiver archivedDataWithRootObject:notesToDetail];
    [[NSUserDefaults standardUserDefaults] setObject:data2 forKey:@"notesToDetail"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end
