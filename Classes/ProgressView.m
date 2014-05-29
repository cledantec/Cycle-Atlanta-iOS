/** Cycle Atlanta, Copyright 2012, 2013 Georgia Institute of Technology
 *                                    Atlanta, GA. USA
 *
 *   @author Christopher Le Dantec <ledantec@gatech.edu>
 *   @author Anhong Guo <guoanhong@gatech.edu>
 *
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

#import "ProgressView.h"
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
#import "YLProgressBar.h"
#import "YLBackgroundView.h"

#define DEFAULT_LABEL_WIDTH		260.
#define DEFAULT_LABEL_HEIGHT	90.
#define DEFAULT_BAR_WIDTH       240.
#define DEFAULT_BAR_HEIGHT      12.

@implementation ProgressView
@synthesize background, progressBar, progressLabel, errorLabel, activityIndicator;

+ (id)progressViewInView:(UIView *)aSuperview messageString:(NSString *)message progressTypePlain:(BOOL)progressTypePlain
{
    CGRect frame    = [[UIScreen mainScreen] bounds];
    ProgressView *progressView = [[ProgressView alloc] initWithFrame:frame];
    
    progressView.background = [[YLBackgroundView alloc] initWithFrame:frame];
    [progressView addSubview:progressView.background];

    progressView.backgroundColor = [UIColor colorWithRed:((float) 0 / 255.0f)
                                                   green:((float) 0 / 255.0f)
                                                    blue:((float) 0 / 255.0f)
                                                   alpha:8.0f];
       
    
    
    
    CGRect labelFrame;
    if ([UIScreen mainScreen].scale == 2.f && [[UIScreen mainScreen] bounds].size.height == 568.0f)
    {
        labelFrame = CGRectMake(30, 159, DEFAULT_LABEL_WIDTH, DEFAULT_LABEL_HEIGHT);
    }
    else
    {
        labelFrame = CGRectMake(30, 115, DEFAULT_LABEL_WIDTH, DEFAULT_LABEL_HEIGHT);
    }
    progressView.progressLabel =[[UILabel alloc] initWithFrame:labelFrame];
    progressView.progressLabel.text = @"";
    progressView.progressLabel.textColor = [UIColor whiteColor];
    progressView.progressLabel.numberOfLines = 4;
    progressView.progressLabel.lineBreakMode = NSLineBreakByWordWrapping;
    progressView.progressLabel.backgroundColor = [UIColor clearColor];
    progressView.progressLabel.textAlignment = NSTextAlignmentCenter;
    progressView.progressLabel.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
    
    [progressView addSubview:progressView.progressLabel];
    
    CGRect barFrame;
    if ([UIScreen mainScreen].scale == 2.f && [[UIScreen mainScreen] bounds].size.height == 568.0f)
    {
        barFrame = CGRectMake(40, 269, DEFAULT_BAR_WIDTH, DEFAULT_BAR_HEIGHT);
    }
    else
    {
        barFrame = CGRectMake(40, 225, DEFAULT_BAR_WIDTH, DEFAULT_BAR_HEIGHT);
    }
    if(progressTypePlain)
        progressView.progressBar = [[UIProgressView alloc] initWithFrame:barFrame ];
    else
        progressView.progressBar = [[YLProgressBar alloc] initWithFrame:barFrame ];
    progressView.progressBar.progressViewStyle = UIProgressViewStyleBar;
    progressView.progressBar.progressTintColor = [UIColor lightGrayColor];
    progressView.progressBar.trackTintColor = [UIColor colorWithRed:0.0980f green:0.1137f blue:0.1294f alpha:1.0f];
    progressView.progressBar.hidden = TRUE;

    [progressView addSubview:progressView.progressBar];
    
    CGRect errorLabelFrame = CGRectMake(30, 275, DEFAULT_LABEL_WIDTH, DEFAULT_LABEL_HEIGHT);
    progressView.errorLabel =[[UILabel alloc] initWithFrame:errorLabelFrame];
    progressView.errorLabel.text = @"";
    progressView.errorLabel.textColor = [UIColor whiteColor];
    progressView.errorLabel.numberOfLines = 4;
    progressView.errorLabel.lineBreakMode = NSLineBreakByWordWrapping;
    progressView.errorLabel.backgroundColor = [UIColor clearColor];
    progressView.errorLabel.textAlignment = NSTextAlignmentCenter;
    progressView.errorLabel.font = [UIFont systemFontOfSize:14.0];
    
    [progressView addSubview:progressView.errorLabel];
    
    if (message==nil)
    {
        //[background removeFromSuperview];
        progressView.background.hidden = TRUE;
        if ([UIScreen mainScreen].scale == 2.f && [[UIScreen mainScreen] bounds].size.height == 568.0f)
        {
            progressView.backgroundColor =  [UIColor colorWithPatternImage:[UIImage imageNamed:@"Default-568h.png"]];
        }
        else
        {
            progressView.backgroundColor =  [UIColor colorWithPatternImage:[UIImage imageNamed:@"Default.png"]];
        }
        
        progressView.errorLabel.hidden = TRUE;
        progressView.progressBar.hidden = TRUE;
        progressView.progressLabel.hidden = TRUE;
        
        progressView.activityIndicator = [[UIActivityIndicatorView alloc]
                                           initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        CGRect activityIndicatorRect = progressView.activityIndicator.frame;
        progressView.activityIndicator.hidesWhenStopped = YES;
        activityIndicatorRect.origin.x = 0.5 * (progressView.frame.size.width - activityIndicatorRect.size.width);
        activityIndicatorRect.origin.y = 0.5 * (progressView.frame.size.height - activityIndicatorRect.size.height);
        progressView.activityIndicator.frame = activityIndicatorRect;
        
        [progressView.activityIndicator startAnimating];
        [progressView addSubview:progressView.activityIndicator];
    } else {
        progressView.progressLabel.text = message;
    }
    
    if (!progressView)
    {
        return nil;
    }

    // Set up the fade-in animation
	CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionFade];
	[[aSuperview layer] addAnimation:animation forKey:@"layerAnimation"];
        

    return progressView;
}

- (void)loadingComplete:(NSString *)completeMessage delayInterval:(NSTimeInterval)delay
{
    self.progressLabel.text=completeMessage;
    self.progressBar.hidden = TRUE;
    self.activityIndicator.hidden = TRUE;    
    [self performSelector:@selector(removeView) withObject:nil afterDelay:delay];
}

- (void)setErrorMessage:(NSString *)message
{
    self.errorLabel.text = message;
}

- (void)setVisible:(BOOL)isBarVisible messageString:(NSString *)message{
    self.background.hidden = FALSE;
    self.progressLabel.hidden = !isBarVisible;
    self.errorLabel.hidden = !isBarVisible;
    self.backgroundColor = [UIColor colorWithRed:((float) 0 / 255.0f)
                                                   green:((float) 0 / 255.0f)
                                                    blue:((float) 0 / 255.0f)
                                                   alpha:8.0f];
    self.progressLabel.text = message;
    self.progressBar.hidden = !isBarVisible;
    if(self.activityIndicator != nil)
        self.activityIndicator.hidden = isBarVisible;
}

- (void)updateProgress:(float)progressToAdd{
    [self.progressBar setProgress:self.progressBar.progress+progressToAdd animated:TRUE];
 
    if(self.progressBar.progress+progressToAdd>=1.0f){
        [self.progressBar setProgress:1.0f];
        [self performSelector:@selector(removeView) withObject:nil afterDelay:1];
        //ensures the idle timer is turned back on after the long-running migration and download.
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    dispatch_sync(dispatch_get_main_queue(), ^{
        CGFloat progress = [(NSMigrationManager *)object migrationProgress];
        [self.progressBar setProgress:progress animated:true];
    });
}

- (void)removeView
{
	UIView *aSuperview = [self superview];
	[super removeFromSuperview];
    
	CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionFade];
	[[aSuperview layer] addAnimation:animation forKey:@"layerAnimation"];
}

@end
