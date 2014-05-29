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

#import <UIKit/UIKit.h>
#import "YLProgressBar.h"
#import "YLBackgroundView.h"

@interface ProgressView : UIView{
    
}

@property (nonatomic, retain) UILabel *progressLabel;
@property (nonatomic, retain) UILabel *errorLabel;
@property (nonatomic, retain) YLProgressBar *progressBar;
@property (nonatomic, retain) YLBackgroundView *background;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;

+ (id)progressViewInView:(UIView *)aSuperview messageString:(NSString *)message progressTypePlain:(BOOL)progressTypePlain;
- (void)setVisible:(BOOL)isBarVisible messageString:(NSString *)message;
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;
- (void)setErrorMessage:(NSString *)message;
- (void)updateProgress:(float)progressToAdd;
- (void)loadingComplete:(NSString *)completeMessage delayInterval:(NSTimeInterval)delay;
- (void)removeView;


@end
