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

#import "DetailViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "NoteManager.h"
#import "ImageResize.h"

@interface DetailViewController ()
static UIImage *shrinkImage(UIImage *original, CGSize size);

- (void)updateDisplay;
- (void)getMediaFromSource:(UIImagePickerControllerSourceType)sourceType;
@end

@implementation DetailViewController
@synthesize delegate;
@synthesize detailTextView;
@synthesize addPicButton;
@synthesize imageView;
@synthesize image;
@synthesize imageFrame;
@synthesize imageFrameView;
@synthesize lastChosenMediaType;
@synthesize imageData;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return self;
}

- (void)viewDidLoad
{
    //[self.detailTextView setText:@"Enter More Details Here"];
    
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.detailTextView becomeFirstResponder];
    // Do any additional setup after loading the view.
    if (![UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeCamera]) {
        addPicButton.hidden = YES;
    }
    //needed to center button title text on ios5 (attributed title does not work prior to ios6)
    addPicButton.titleLabel.textAlignment = NSTextAlignmentCenter;

    detailTextView.layer.borderWidth = 1.0;
    detailTextView.layer.borderColor = [[UIColor blackColor] CGColor];
    self.imageFrame = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"photoFrame" ofType:@"png"]];
    imageFrameView.image = imageFrame;
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updateDisplay];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

/*
-(IBAction)skip:(id)sender{
    NSLog(@"Skip");
    [detailTextView resignFirstResponder];
    [delegate didCancelNote];
    
    pickerCategory = [[NSUserDefaults standardUserDefaults] integerForKey:@"pickerCategory"];
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey: @"pickerCategory"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    details = @"";
    image = nil;
    [self performSegueWithIdentifier:@"unwindToRecordTripViewController" sender:self];
    [delegate didEnterNoteDetails:details];
    [delegate didSaveImage:nil];
    [delegate saveNote];
}
*/

-(IBAction)saveDetail:(id)sender{
    NSLog(@"Save Detail");
    [detailTextView resignFirstResponder];
    [delegate didCancelNote];
    
    pickerCategory = [[NSUserDefaults standardUserDefaults] integerForKey:@"pickerCategory"];
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey: @"pickerCategory"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    details = detailTextView.text;
    NSLog(@"Note details : %@", details);
    
    [self performSegueWithIdentifier:@"unwindToRecordTripViewController" sender:self];
    [delegate didEnterNoteDetails:details];
    [delegate didSaveImage:imageData];
    [delegate saveNote];
}

- (IBAction)shootPictureOrVideo:(id)sender {
    [self getMediaFromSource:UIImagePickerControllerSourceTypeCamera];
}

- (IBAction)selectExistingPictureOrVideo:(id)sender {
    [self getMediaFromSource:UIImagePickerControllerSourceTypePhotoLibrary];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UIImagePickerController delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info {
    //original
    UIImage *castedImage = info[UIImagePickerControllerOriginalImage];
    //save to library
    UIImageWriteToSavedPhotosAlbum(castedImage,self, nil, nil);
    imageData = [[NSData alloc] initWithData:UIImageJPEGRepresentation([ImageResize imageWithImage:castedImage scaledToSize:CGSizeMake(960, 720)], 1)];
    NSLog(@"Size of Image(bytes):%lu",(unsigned long)[imageData length]);
    self.image = [ImageResize imageWithImage:castedImage scaledToSize:CGSizeMake(290, 192)];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark  -

static UIImage *shrinkImage(UIImage *original, CGSize size) {
    CGFloat scale = [UIScreen mainScreen].scale;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(NULL, size.width * scale,
                                                 size.height * scale, 8, 0, colorSpace, kCGImageAlphaPremultipliedFirst);
    CGContextDrawImage(context,
                       CGRectMake(0, 0, size.width * scale, size.height * scale),
                       original.CGImage);
    CGImageRef shrunken = CGBitmapContextCreateImage(context);
    UIImage *final = [UIImage imageWithCGImage:shrunken];
    
    CGContextRelease(context);
    CGImageRelease(shrunken);
    CGColorSpaceRelease(colorSpace);
    return final;
}

- (void)updateDisplay {
    imageView.image = image;
    imageView.hidden = NO;
}

- (void)getMediaFromSource:(UIImagePickerControllerSourceType)sourceType {
    //NSArray *mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:sourceType];
    if ([UIImagePickerController isSourceTypeAvailable:
         sourceType]) {
        //NSArray *mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:sourceType];
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        //picker.mediaTypes = mediaTypes;
        //picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        picker.delegate = self;
        picker.sourceType = sourceType;
        [self presentViewController:picker animated:YES completion:nil];
//        [picker release];
    } else {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Error accessing media"
                              message:@"Device doesn’t support that media source."
                              delegate:nil
                              cancelButtonTitle:@"Drat!"
                              otherButtonTitles:nil];
        [alert show];
    }
}




@end
