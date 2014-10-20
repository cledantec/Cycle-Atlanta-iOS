/** Cycle Atlanta, Copyright 2012, 2013 Georgia Institute of Technology
 *                                    Atlanta, GA. USA
 *
 *   @author Christopher Le Dantec <ledantec@gatech.edu>
 *   @author Anhong Guo <guoanhong@gatech.edu>
 *
 *   Updated/Modified for Atlanta's app deployment. Based on the
 *   CycleTracks codebase for SFCTA.
 *
 ** CycleTracks, Copyright 2009,2010 San Francisco County Transportation Authority
 *                                    San Francisco, CA, USA
 *
 *   @author Matt Paul <mattpaul@mopimp.com>
 *
 *   This file is part of CycleTracks.
 *
 *   CycleTracks is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation, either version 3 of the License, or
 *   (at your option) any later version.
 *
 *   CycleTracks is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with CycleTracks.  If not, see <http://www.gnu.org/licenses/>.
 */

//
//  PersonalInfoViewController.m
//  CycleTracks
//
//  Copyright 2009-2010 SFCTA. All rights reserved.
//  Written by Matt Paul <mattpaul@mopimp.com> on 9/23/09.
//	For more information on the project, 
//	e-mail Billy Charlton at the SFCTA <billy.charlton@sfcta.org>


#import "PersonalInfoViewController.h"
#import "User.h"
#import "constants.h"
#import "ProgressView.h"
#import "CycleAtlantaAppDelegate.h"
#import "ALToastView.h"

#define kMaxCyclingFreq 3

@implementation PersonalInfoViewController

@synthesize delegate, managedObjectContext, user;
@synthesize age, email, gender, ethnicity, income, homeZIP, workZIP, schoolZIP;
@synthesize cyclingFreq, riderType, riderHistory, magnetometerSwitch;
@synthesize ageSelectedRow, genderSelectedRow, ethnicitySelectedRow, incomeSelectedRow, cyclingFreqSelectedRow, riderTypeSelectedRow, riderHistorySelectedRow, selectedItem;
@synthesize fetchUser;


- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
    }
    return self;
}


- (id)init
{
	NSLog(@"INIT");
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
    }
    return self;
}


- (id)initWithManagedObjectContext:(NSManagedObjectContext*)context
{
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
		NSLog(@"PersonalInfoViewController::initWithManagedObjectContext");
		self.managedObjectContext = context;
    }
    return self;
}

- (UITextField*)initiateTextFieldAlpha
{
	CGRect frame = CGRectMake( 152, 7, 138, 29 );
	UITextField *textField = [[UITextField alloc] initWithFrame:frame];
	textField.borderStyle = UITextBorderStyleRoundedRect;
	textField.textAlignment = NSTextAlignmentRight;
	textField.placeholder = @"Choose one";
	textField.delegate = self;
	return textField;
}

- (UITextField*)initiateTextFieldBeta
{
	CGRect frame = CGRectMake( 152, 7, 138, 29 );
	UITextField *textField = [[UITextField alloc] initWithFrame:frame];
	textField.borderStyle = UITextBorderStyleRoundedRect;
	textField.textAlignment = NSTextAlignmentRight;
	textField.placeholder = @"Choose one";
	textField.delegate = self;
	return textField;
}


- (UITextField*)initiateTextFieldEmail
{
	CGRect frame = CGRectMake( 152, 7, 138, 29 );
	UITextField *textField = [[UITextField alloc] initWithFrame:frame];
	textField.autocapitalizationType = UITextAutocapitalizationTypeNone,
	textField.borderStyle = UITextBorderStyleRoundedRect;
	textField.textAlignment = NSTextAlignmentRight;
	textField.placeholder = @"name@domain";
	textField.keyboardType = UIKeyboardTypeEmailAddress;
	textField.returnKeyType = UIReturnKeyDone;
	textField.delegate = self;
	return textField;
}


- (UITextField*)initiateTextFieldNumeric
{
	CGRect frame = CGRectMake( 152, 7, 138, 29 );
	UITextField *textField = [[UITextField alloc] initWithFrame:frame];
	textField.borderStyle = UITextBorderStyleRoundedRect;
	textField.textAlignment = NSTextAlignmentRight;
	textField.placeholder = @"12345";
	textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
	textField.returnKeyType = UIReturnKeyDone;
	textField.delegate = self;
	return textField;
}

- (UISwitch*) initiateSwitch
{
    UISwitch* switchButton = [[UISwitch alloc] initWithFrame:CGRectMake(225.0, 0.0, 80.0, 45.0)];
    switchButton.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"magnetometerIsOn"];
    [switchButton addTarget:self action:@selector(saveSwitch:) forControlEvents:UIControlEventValueChanged];
    return switchButton;
    
}



- (User *)createUser
{
	// Create and configure a new instance of the User entity
	User *noob = (User *)[NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:managedObjectContext];
	
	NSError *error;
	if (![managedObjectContext save:&error]) {
		// Handle the error.
		NSLog(@"createUser error %@, %@", error, [error localizedDescription]);
	}
	
	return noob;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    CycleAtlantaAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    // [self setManagedObjectContext: [[[UIApplication sharedApplication] delegate] managedObjectContext]];
    
    genderArray = [[NSArray alloc]initWithObjects: @" ", @"Female",@"Male", nil];
    
    ageArray = [[NSArray alloc]initWithObjects: @" ", @"Less than 18", @"18-24", @"25-34", @"35-44", @"45-54", @"55-64", @"65+", nil];
    
    ethnicityArray = [[NSArray alloc]initWithObjects: @" ", @"White", @"African American", @"Asian", @"Native American", @"Pacific Islander", @"Multi-racial", @"Hispanic / Mexican / Latino", @"Other", nil];
    
    incomeArray = [[NSArray alloc]initWithObjects: @" ", @"Less than $20,000", @"$20,000 to $39,999", @"$40,000 to $59,999", @"$60,000 to $74,999", @"$75,000 to $99,999", @"$100,000 or greater", nil];
    
    cyclingFreqArray = [[NSArray alloc]initWithObjects: @" ", @"Less than once a month", @"Several times per month", @"Several times per week", @"Daily", nil];
    
    riderTypeArray = [[NSArray alloc]initWithObjects: @" ", @"Strong & fearless", @"Enthused & confident", @"Comfortable, but cautious", @"Interested, but concerned", nil];
    
    riderHistoryArray = [[NSArray alloc]initWithObjects: @" ", @"Since childhood", @"Several years", @"One year or less", @"Just trying it out / just started", nil];

    CGRect pickerFrame = CGRectMake(0, 40, 0, 0);
    pickerView = [[UIPickerView alloc] initWithFrame:pickerFrame];
    pickerView.showsSelectionIndicator = YES;
    pickerView.dataSource = self;
    pickerView.delegate = self;
    pickerView.backgroundColor=[UIColor whiteColor];
    
	// initialize text fields
	self.age		= [self initiateTextFieldAlpha];
	self.email		= [self initiateTextFieldEmail];
	self.gender		= [self initiateTextFieldAlpha];
    self.ethnicity  = [self initiateTextFieldAlpha];
    self.income     = [self initiateTextFieldAlpha];
	self.homeZIP	= [self initiateTextFieldNumeric];
	self.workZIP	= [self initiateTextFieldNumeric];
	self.schoolZIP	= [self initiateTextFieldNumeric];
    self.cyclingFreq = [self initiateTextFieldBeta];
    self.riderType  =  [self initiateTextFieldBeta];
    self.riderHistory =[self initiateTextFieldBeta];
    self.magnetometerSwitch = [self initiateSwitch];
    
    actionView=[[UIView alloc]init];
    int actionViewSize=260;
    actionView.frame = CGRectMake(0, [[UIScreen mainScreen]bounds].size.height-actionViewSize, [[UIScreen mainScreen]bounds].size.width, actionViewSize);
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    
    
    //Initial Save button state is disabled. will be enabled if a change has been made to any of the fields.
	_saveButton.enabled = NO;
    
    fetchUser = [[FetchUser alloc] init];

}
- (void)viewWillAppear:(BOOL)animated{
	NSFetchRequest		*request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];
	
	NSError *error;
	NSInteger count = [managedObjectContext countForFetchRequest:request error:&error];
	NSLog(@"saved user count  = %ld", (long) count);
	if ( count == 0 )
	{
		// create an empty User entity
		[self setUser:[self createUser]];
	}
	
	NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
	if (mutableFetchResults == nil) {
		// Handle the error.
		NSLog(@"no saved user");
		if ( error != nil )
			NSLog(@"PersonalInfo viewDidLoad fetch error %@, %@", error, [error localizedDescription]);
	}
	
	[self setUser:mutableFetchResults[0]];
	if ( user != nil )
	{
		// initialize text fields indexes to saved personal info
		age.text            = ageArray[[user.age integerValue]];
        ageSelectedRow      = [user.age integerValue];
		email.text          = user.email;
		gender.text         = genderArray[[user.gender integerValue]];;
        genderSelectedRow   = [user.gender integerValue];
        ethnicity.text      = ethnicityArray[[user.ethnicity integerValue]];
        ethnicitySelectedRow= [user.ethnicity integerValue];
        income.text         = incomeArray[[user.income integerValue]];
        incomeSelectedRow   = [user.income integerValue];
		
        homeZIP.text        = user.homeZIP;
		workZIP.text        = user.workZIP;
		schoolZIP.text      = user.schoolZIP;
        
        cyclingFreq.text        = cyclingFreqArray[[user.cyclingFreq integerValue]];
        cyclingFreqSelectedRow  = [user.cyclingFreq integerValue];
        riderType.text          = riderTypeArray[[user.rider_type integerValue]];
        riderTypeSelectedRow    = [user.rider_type integerValue];
        riderHistory.text       = riderHistoryArray[[user.rider_history integerValue]];
        riderHistorySelectedRow = [user.rider_history integerValue];
				
	}
	else
		NSLog(@"init FAIL");
    

    self.tableView.dataSource = self;
    [self.tableView reloadData];
    [super viewWillAppear:animated];
}


#pragma mark UITextFieldDelegate methods

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if(currentTextField == email || currentTextField == workZIP || currentTextField == homeZIP || currentTextField == schoolZIP || textField != email || textField != workZIP || textField != homeZIP || textField != schoolZIP){
        NSLog(@"currentTextField: text2");
        [currentTextField resignFirstResponder];
        [textField resignFirstResponder];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)myTextField{
    

    currentTextField = myTextField;
   
    
    if(myTextField == gender || myTextField == age || myTextField == ethnicity || myTextField == income || myTextField == cyclingFreq || myTextField == riderType || myTextField == riderHistory){
        
        
         [myTextField setInputView:actionView];
        //[myTextField resignFirstResponder];
        
      //  actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil]; //as we want to display a subview we won't be using the default buttons but rather we're need to create a toolbar to display the buttons on
                
      //  [actionSheet addSubview:pickerView];
        [actionView addSubview:pickerView];
        
        doneToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        doneToolbar.barStyle = UIBarStyleDefault;
        [doneToolbar sizeToFit];
        
        NSMutableArray *barItems = [[NSMutableArray alloc] init];
        
        UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
        [barItems addObject:flexSpace];
        
        UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)];
        [barItems addObject:cancelBtn];
        
        UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed:)];
        [barItems addObject:doneBtn];
        
        [doneToolbar setItems:barItems animated:YES];
        
       // [actionSheet addSubview:doneToolbar];
        
        [actionView addSubview:doneToolbar];
        
        selectedItem = 0;
        if(myTextField == gender){
            selectedItem = [user.gender integerValue];
        }else if (myTextField == age){
            selectedItem = [user.age integerValue];
        }else if (myTextField == ethnicity){
            selectedItem = [user.ethnicity integerValue];
        }else if (myTextField == income){
            selectedItem = [user.income integerValue];
        }else if (myTextField == cyclingFreq){
            selectedItem = [user.cyclingFreq integerValue];
        }else if (myTextField == riderType){
            selectedItem = [user.rider_type integerValue];
        }else if (myTextField == riderHistory){
            selectedItem = [user.rider_history integerValue];
        }
        
        [pickerView selectRow:selectedItem inComponent:0 animated:NO];
        
        [pickerView reloadAllComponents];
        
        [actionView addSubview:pickerView];

    }
}

// the user pressed the "Save" button, so dismiss the keyboard
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	NSLog(@"textFieldShouldReturn");
	[textField resignFirstResponder];
	return YES;
}


// save the new value for this textField
- (void)textFieldDidEndEditing:(UITextField *)textField
{
	NSLog(@"textFieldDidEndEditing");
	
	// save value
	if ( user != nil )
	{		
		if ( textField == email )
		{
            //enable save button if value has been changed.
            if (email.text != user.email){
                _saveButton.enabled = YES;
            }
			NSLog(@"saving email: %@", email.text);
			[user setEmail:email.text];
		}		
		if ( textField == homeZIP )
		{
            if (homeZIP.text != user.homeZIP){
                _saveButton.enabled = YES;
            }
			NSLog(@"saving homeZIP: %@", homeZIP.text);
			[user setHomeZIP:homeZIP.text];
		}
		if ( textField == schoolZIP )
		{
            if (schoolZIP.text != user.schoolZIP){
                _saveButton.enabled = YES;
            }
			NSLog(@"saving schoolZIP: %@", schoolZIP.text);
			[user setSchoolZIP:schoolZIP.text];
		}
		if ( textField == workZIP )
		{
            if (workZIP.text != user.workZIP){
                _saveButton.enabled = YES;
            }
			NSLog(@"saving workZIP: %@", workZIP.text);
			[user setWorkZIP:workZIP.text];
		}
       
		
		NSError *error;
		if (![managedObjectContext save:&error]) {
			NSLog(@"PersonalInfo save textField error %@, %@", error, [error localizedDescription]);
		}
	}
    [textField resignFirstResponder];
}

- (IBAction)save:(id)sender {

    [email resignFirstResponder];
    [homeZIP resignFirstResponder];
    [workZIP resignFirstResponder];
    [schoolZIP resignFirstResponder];
    
    NSLog(@"Saving User Data");
	if ( user != nil )
	{
		[user setAge:@(ageSelectedRow)];
        NSLog(@"saved age index: %@ and text: %@", user.age, age.text);

		[user setEmail:email.text];
        NSLog(@"saved email: %@", user.email);

		[user setGender:@(genderSelectedRow)];
		NSLog(@"saved gender index: %@ and text: %@", user.gender, gender.text);
        
        [user setEthnicity:@(ethnicitySelectedRow)];
        NSLog(@"saved ethnicity index: %@ and text: %@", user.ethnicity, ethnicity.text);
        
        [user setIncome:@(incomeSelectedRow)];
        NSLog(@"saved income index: %@ and text: %@", user.income, income.text);
        
		[user setHomeZIP:homeZIP.text];
        NSLog(@"saved homeZIP: %@", homeZIP.text);

		[user setSchoolZIP:schoolZIP.text];
        NSLog(@"saved schoolZIP: %@", schoolZIP.text);

		[user setWorkZIP:workZIP.text];
        NSLog(@"saved workZIP: %@", workZIP.text);
                
        [user setCyclingFreq:@(cyclingFreqSelectedRow)];
        NSLog(@"saved cycle freq index: %@ and text: %@", user.cyclingFreq, cyclingFreq.text);
        
        [user setRider_type:@(riderTypeSelectedRow)];
        NSLog(@"saved rider type index: %@ and text: %@", user.rider_type, riderType.text);
        
        [user setRider_history:@(riderHistorySelectedRow)];
        NSLog(@"saved rider history index: %@ and text: %@", user.rider_history, riderHistory.text);
		

		NSError *error;
		if (![managedObjectContext save:&error]) {
			// Handle the error.
			NSLog(@"PersonalInfo save cycling freq error %@, %@", error, [error localizedDescription]);
		}
	}
	else
		NSLog(@"ERROR can't save personal info for nil user");
	
	// update UI
	
	[delegate setSaved:YES];
	_saveButton.enabled = NO;
	[self.navigationController popViewControllerAnimated:YES];
    [ALToastView toastInView:self.view withText:@"Saved!"];
}

- (void)saveSwitch:(id)sender
{
    BOOL state = [sender isOn];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:state forKey:@"magnetometerIsOn"];
    [userDefaults synchronize];
}



//- (void)viewWillAppear:(BOOL)animated {
//    [super viewWillAppear:animated];
//    [self.view setNeedsDisplay];
//    [self.tableView reloadData];
//    [self.tableView reloadInputViews];
//}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}


#pragma mark Table view methods


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 8;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
        case 0:
			return nil;
			break;
		case 1:
			return @"Tell us about yourself";
			break;
		case 2:
			return @"Your typical commute";
			break;
		case 3:
			return @"How often do you cycle?";
			break;
        case 4:
			return @"What kind of rider are you?";
			break;
        case 5:
			return @"How long have you been a cyclist?";
			break;
        case 6:
			return @"Missing trips you saved in an earlier version ? ";
			break;
        case 7:
			return @"Use magnet detection to add notes ? ";
			break;
	}
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([self tableView:tableView titleForHeaderInSection:section] != nil) {
        return 50;
    }
    else {
        // If no section header title, no section header needed
        return 0;
    }
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	switch ( section )
	{
        case 0:
            return 1;
            break;
		case 1:
			return 5;
			break;
		case 2:
			return 3;
			break;
		case 3:
			return 1;
			break;
        case 4:
			return 1;
			break;
        case 5:
			return 1;
			break;
        case 6:
			return 1;
			break;
        case 7:
			return 1;
            break;
		default:
			return 0;
	}
    return 0;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    // Set up the cell...
	UITableViewCell *cell = nil;
	
	// outer switch statement identifies section
	switch ([indexPath indexAtPosition:0])
	{
        case 0:
		{
			static NSString *CellIdentifier = @"CellInstruction";
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
			}
            
			// inner switch statement identifies row
			switch ([indexPath indexAtPosition:1])
			{
				case 0:
					cell.textLabel.text = @"Getting started with Cycle Atlanta";
					break;
			}
			
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
			break;

		case 1:
		{
			static NSString *CellIdentifier = @"CellPersonalInfo";
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
			}

			// inner switch statement identifies row
			switch ([indexPath indexAtPosition:1])
			{
				case 0:
					cell.textLabel.text = @"Age";
					[cell.contentView addSubview:age];
					break;
				case 1:
					cell.textLabel.text = @"Email";
					[cell.contentView addSubview:email];
					break;
				case 2:
					cell.textLabel.text = @"Gender";
					[cell.contentView addSubview:gender];
					break;
                case 3:
					cell.textLabel.text = @"Ethnicity";
					[cell.contentView addSubview:ethnicity];
					break;
                case 4:
					cell.textLabel.text = @"Home Income";
					[cell.contentView addSubview:income];
					break;
			}
			
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
			break;
	
		case 2:
		{
			static NSString *CellIdentifier = @"CellZip";
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
			}

			switch ([indexPath indexAtPosition:1])
			{
				case 0:
					cell.textLabel.text = @"Home ZIP";
					[cell.contentView addSubview:homeZIP];
					break;
				case 1:
					cell.textLabel.text = @"Work ZIP";
					[cell.contentView addSubview:workZIP];
					break;
				case 2:
					cell.textLabel.text = @"School ZIP";
					[cell.contentView addSubview:schoolZIP];
					break;
			}
			
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
			break;
            
        case 3:
		{
			static NSString *CellIdentifier = @"CellFrequecy";
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
			}
            
			// inner switch statement identifies row
			switch ([indexPath indexAtPosition:1])
			{
				case 0:
                    cell.textLabel.text = @"Cycle Frequency";
					[cell.contentView addSubview:cyclingFreq];
					break;
            }
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
			break;
            
        case 4:
		{
			static NSString *CellIdentifier = @"CellType";
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
			}
            
			// inner switch statement identifies row
			switch ([indexPath indexAtPosition:1])
			{
				case 0:
                    cell.textLabel.text = @"Rider Type";
					[cell.contentView addSubview:riderType];
					break;
            }
			
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
			break;
            
        case 5:
		{
			static NSString *CellIdentifier = @"CellHistory";
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
			}
            
			// inner switch statement identifies row
			switch ([indexPath indexAtPosition:1])
			{
				case 0:
                    cell.textLabel.text = @"Rider History";
                    [cell.contentView addSubview:riderHistory];
					break;
			}
			
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
            break;
        case 6:
		{
			static NSString *CellIdentifier = @"CellDownload";
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
			}
            
			// inner switch statement identifies row
			switch ([indexPath indexAtPosition:1])
			{
				case 0:
					cell.textLabel.text = @"Download Previously Saved Trips";
					break;
			}
			
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
			break;
        case 7:
		{
			static NSString *CellIdentifier = @"CellMagnetometer";
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
			}
            
			// inner switch statement identifies row
			switch ([indexPath indexAtPosition:1])
			{
				case 0:
					cell.textLabel.text = @"Magnetometer";
                    [cell.contentView addSubview:magnetometerSwitch];
					break;
			}
			
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
			break;
	}
	
	// debug
	//NSLog(@"%@", [cell subviews]);
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:NO];

    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];

	// outer switch statement identifies section
    NSURL *url = [NSURL URLWithString:kInstructionsURL];
    NSURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
	switch ([indexPath indexAtPosition:0])
	{
		case 0:
		{
			// inner switch statement identifies row
			switch ([indexPath indexAtPosition:1])
			{
				case 0:
                    [[UIApplication sharedApplication] openURL:[request URL]];
					break;
				case 1:
					break;
			}
			break;
		}
			
		case 1:
		{
			switch ([indexPath indexAtPosition:1])
			{
				case 0:
					break;
				case 1:
					break;
			}
			break;
		}
            
        case 2:
		{
			switch ([indexPath indexAtPosition:1])
			{
				case 0:
					break;
				case 1:
					break;
			}
			break;
		}
            
        case 3:
		{
			switch ([indexPath indexAtPosition:1])
			{
				case 0:
					break;
				case 1:
					break;
			}
			break;
		}
            
        case 4:
		{
			switch ([indexPath indexAtPosition:1])
			{
				case 0:
					break;
				case 1:
					break;
			}
			break;
		}
        case 5:
		{
			switch ([indexPath indexAtPosition:1])
			{
				case 0:
					break;
				case 1:
					break;
			}
			break;
		}
                    
        case 6:
		{
			// inner switch statement identifies row
			switch ([indexPath indexAtPosition:1])
			{
				case 0:                                                        
                    [fetchUser fetchUserAndTrip:self.parentViewController];
                    //reload data didn't seem to refresh the view. this does
                    //[self viewWillAppear:false];
					break;
				case 1:
					break;
			}
			break;
		}
	}
}


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    if(currentTextField == gender){
        return [genderArray count];
    }
    else if(currentTextField == age){
        return [ageArray count];
    }
    else if(currentTextField == ethnicity){
        return [ethnicityArray count];
    }
    else if(currentTextField == income){
        return [incomeArray count];
    }
    else if(currentTextField == cyclingFreq){
        return [cyclingFreqArray count];
    }
    else if(currentTextField == riderType){
        return [riderTypeArray count];
    }
    else if(currentTextField == riderHistory){
        return [riderHistoryArray count];
    }
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if(currentTextField == gender){
        return genderArray[row];
    }
    else if(currentTextField == age){
        return ageArray[row];
    }
    else if(currentTextField == ethnicity){
        return ethnicityArray[row];
    }
    else if(currentTextField == income){
        return incomeArray[row];
    }
    else if(currentTextField == cyclingFreq){
        return cyclingFreqArray[row];
    }
    else if(currentTextField == riderType){
        return riderTypeArray[row];
    }
    else if(currentTextField == riderHistory){
        return riderHistoryArray[row];
    }
    return nil;
}

- (void)doneButtonPressed:(id)sender{
    
    NSInteger selectedRow;
    selectedRow = [pickerView selectedRowInComponent:0];
    if(currentTextField == gender){
        //enable save button if value has been changed.
        if (selectedRow != [user.gender integerValue]){
            _saveButton.enabled = YES;
        }
        genderSelectedRow = selectedRow;
        NSString *genderSelect = genderArray[selectedRow];
        gender.text = genderSelect;
    }
    if(currentTextField == age){
        //enable save button if value has been changed.
        if (selectedRow != [user.age integerValue]){
            _saveButton.enabled = YES;
        }

        ageSelectedRow = selectedRow;
        NSString *ageSelect = ageArray[selectedRow];
        age.text = ageSelect;
    }
    if(currentTextField == ethnicity){
        //enable save button if value has been changed.
        if (selectedRow != [user.ethnicity integerValue]){
            _saveButton.enabled = YES;
        }

        ethnicitySelectedRow = selectedRow;
        NSString *ethnicitySelect = ethnicityArray[selectedRow];
        ethnicity.text = ethnicitySelect;
    }
    if(currentTextField == income){
        //enable save button if value has been changed.
        if (selectedRow != [user.income integerValue]){
            _saveButton.enabled = YES;
        }

        incomeSelectedRow = selectedRow;
        NSString *incomeSelect = incomeArray[selectedRow];
        income.text = incomeSelect;
    }
    if(currentTextField == cyclingFreq){
        //enable save button if value has been changed.
        if (selectedRow != [user.cyclingFreq integerValue]){
            _saveButton.enabled = YES;
        }

        cyclingFreqSelectedRow = selectedRow;
        NSString *cyclingFreqSelect = cyclingFreqArray[selectedRow];
        cyclingFreq.text = cyclingFreqSelect;
    }
    if(currentTextField == riderType){
        //enable save button if value has been changed.
        if (selectedRow != [user.rider_type integerValue]){
            _saveButton.enabled = YES;
        }

        riderTypeSelectedRow = selectedRow;
        NSString *riderTypeSelect = riderTypeArray[selectedRow];
        riderType.text = riderTypeSelect;
    }
    if(currentTextField == riderHistory){
        //enable save button if value has been changed.
        if (selectedRow != [user.rider_history integerValue]){
            _saveButton.enabled = YES;
        }

        riderHistorySelectedRow = selectedRow;
        NSString *riderHistorySelect = riderHistoryArray[selectedRow];
        riderHistory.text = riderHistorySelect;
    }
  
    
     // Signal that the editing has been done and dismiss the input view
    [self.view endEditing:YES];
}

- (void)cancelButtonPressed:(id)sender{
  
  // Signal that the editing has been done and dismiss the input view
    [self.view endEditing:YES];
}

- (void)dealloc {
    self.ageSelectedRow = nil;
    self.genderSelectedRow = nil;
    self.ethnicitySelectedRow = nil;
    self.incomeSelectedRow = nil;
    self.cyclingFreqSelectedRow = nil;
    self.riderTypeSelectedRow = nil;
    self.riderHistorySelectedRow = nil;
    self.selectedItem = nil;
    
    

}

@end

