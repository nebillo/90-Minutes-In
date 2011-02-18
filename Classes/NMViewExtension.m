
#import "NMViewExtension.h"
#import <QuartzCore/QuartzCore.h>


#pragma mark -
#pragma mark Loading View

@implementation NMLoadingView
@dynamic title;

+ (id)loadingViewWithTitle:(NSString *)title {
	NMLoadingView *view = [[[NSBundle mainBundle] loadNibNamed:@"NMViewExtension" owner:nil options:nil] objectAtIndex:0];
	view.title = title ? title : NSLocalizedString(@"Loading…", nil);
	
	return view;
}


- (void)awakeFromNib {
	[containerView.layer setCornerRadius:8.0f];
}


- (void)dealloc {
	[loadingTitle release];
	[loadingProgress release];
	[containerView release];
	[super dealloc];
}

- (NSString *)title {
	return loadingTitle.text;
}

- (void)setTitle:(NSString *)title {
	loadingTitle.text = title;
	[loadingTitle sizeToFit];
	CGRect frame = loadingTitle.frame;
	frame.origin.x = ([loadingTitle superview].frame.size.width - frame.size.width) / 2;
	loadingTitle.frame = frame;
}


@end


#pragma mark -
#pragma mark Static Image View

@implementation NMStaticImageView
@dynamic title, image;

+ (id)staticViewWithTitle:(NSString *)title bundleImage:(NSString *)imageName {
	NMStaticImageView *view = [[[NSBundle mainBundle] loadNibNamed:@"NMViewExtension" owner:nil options:nil] objectAtIndex:1];
	view.title = title;
	view.image = [UIImage imageNamed:imageName];
	return view;
}

- (void)dealloc {
	[staticTitle release];
	[staticImage release];
	[super dealloc];
}

- (NSString *)title {
	return staticTitle.text;
}

- (void)setTitle:(NSString *)title {
	staticTitle.text = title;
}

- (UIImage *)image {
	return staticImage.image;
}

- (void)setImage:(UIImage *)image {
	staticImage.image = image;
}


@end


#pragma mark -
#pragma mark View Extension

@implementation UIView (Extended)

- (void)presentLoadingViewWithTitle:(NSString *)title {
	NMLoadingView *view = [NMLoadingView loadingViewWithTitle:title];
	[self presentStaticView:view];
}

- (void)presentErrorViewWithTitle:(NSString *)title {
	//FIXME: set a valid image
	NMStaticImageView *view = [NMStaticImageView staticViewWithTitle:(title ? title : NSLocalizedString(@"Network error,\ntry again later.", nil)) 
																   bundleImage:@"window_background.png"];
	[self presentStaticView:view];
}

- (void)presentNoContentsViewWithTitle:(NSString *)title {
	//FIXME: set a valid image
	NMStaticImageView *view = [NMStaticImageView staticViewWithTitle:(title ? title : NSLocalizedString(@"No contents to display.", nil)) 
																   bundleImage:@"window_background.png"];
	[self presentStaticView:view];
}

- (void)presentStaticView:(UIView *)view {
	CGRect frame = view.frame;
	frame.size = self.frame.size;
	view.frame = frame;
	[view setTag:666];
	[self addSubview:view];
	
	self.userInteractionEnabled = NO;
}

- (void)dismissStaticView {
	if ([self isShowingStaticView]) {
		[[self viewWithTag:666] removeFromSuperview];
		self.userInteractionEnabled = YES;
	}
}

- (BOOL)isShowingStaticView {
	return [self viewWithTag:666] != nil;
}


@end

