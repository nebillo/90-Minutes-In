
#import <UIKit/UIKit.h>


@interface UIView (Extended)

- (void)presentLoadingViewWithTitle:(NSString *)titleOrNil;
- (void)presentErrorViewWithTitle:(NSString *)titleOrNil;
- (void)presentNoContentsViewWithTitle:(NSString *)titleOrNil;
- (void)presentStaticView:(UIView *)view;
- (void)dismissStaticView;
- (BOOL)isShowingStaticView;

@end


@interface NMLoadingView : UIView
{
	IBOutlet UILabel *loadingTitle;
	IBOutlet UIActivityIndicatorView *loadingProgress;
	IBOutlet UIView *containerView;
}
@property (nonatomic, copy) NSString *title;

+ (id)loadingViewWithTitle:(NSString *)title;

@end


@interface NMStaticImageView : UIView
{
	IBOutlet UILabel *staticTitle;
	IBOutlet UIImageView *staticImage;
}
@property (nonatomic, copy) NSString *title;
@property (nonatomic, retain) UIImage *image;

+ (id)staticViewWithTitle:(NSString *)title bundleImage:(NSString *)imageName;

@end

