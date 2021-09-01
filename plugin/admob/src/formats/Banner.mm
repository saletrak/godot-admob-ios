//
//  Banner.mm
//  Banner
//
//  Created by Gustavo Maciel on 24/01/21.
//


#import "Banner.h"
@implementation Banner

- (void)dealloc {
    bannerView.delegate = nil;
}

- (instancetype)init{
    if ((self = [super init])) {
        initialized = true;
        loaded = false;
        rootController = (ViewController *)((AppDelegate *)[[UIApplication sharedApplication] delegate]).window.rootViewController;
    }
    return self;
}

- (float) get_banner_width{
    if (bannerView != Nil){
        NSLog(@"bannerView.bounds.size.width = %f", bannerView.bounds.size.width);
        return bannerView.bounds.size.width;
    }
    NSLog(@"width not found");

    return 0;
}
- (float) get_banner_height{
    if (bannerView != Nil){
        NSLog(@"bannerView.bounds.size.height = %f", bannerView.bounds.size.height);
        return bannerView.bounds.size.height;
    }
    return 0;
}

- (float) get_banner_width_in_pixels{
    if (bannerView != Nil){
        NSLog(@"bannerView.bounds.size.width_pixels = %f", bannerView.bounds.size.width * [UIScreen mainScreen].scale);
        return bannerView.bounds.size.width * [UIScreen mainScreen].scale;
    }
    return 0;
}
- (float) get_banner_height_in_pixels{
    if (bannerView != Nil){
        NSLog(@"bannerView.bounds.size.height_pixels = %f", bannerView.bounds.size.height * [UIScreen mainScreen].scale);
        return bannerView.bounds.size.height * [UIScreen mainScreen].scale;
    }
    return 0;
}


- (void) load_banner:(NSString*)ad_unit_id :(int)position :(NSString*)size : (bool) show_instantly {
    NSLog(@"Calling load_banner");
        
    if (!initialized || (!ad_unit_id.length)) {
        return;
    }
    else{
        NSLog(@"banner will load with the banner id %@", ad_unit_id);
    }
    
    positionBanner = position;
    NSLog(@"banner position = %i", positionBanner);
    
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;

    if (bannerView != nil) {
        [self destroy_banner];
    }

    
    if ([size isEqualToString:@"BANNER"]) {
        bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
        NSLog(@"Banner will be created");
    } else if ([size isEqualToString:@"LARGE_BANNER"]) {
        bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeLargeBanner];
        NSLog(@"Large banner will be created");
    } else if ([size isEqualToString:@"MEDIUM_RECTANGLE"]) {
        bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeMediumRectangle];
        NSLog(@"Medium banner will be created");
    } else if ([size isEqualToString:@"FULL_BANNER"]) {
        bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeFullBanner];
        NSLog(@"Full banner will be created");
    } else if ([size isEqualToString:@"LEADERBOARD"]) {
        bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeLeaderboard];
        NSLog(@"Leaderboard will be banner created");
    } else if ([size isEqualToString:@"ADAPTIVE"]) {
        CGRect frame = rootController.view.frame;
        // Here safe area is taken into account, hence the view frame is used after
        // the view has been laid out.
        if (@available(iOS 11.0, *)) {
              frame = UIEdgeInsetsInsetRect(rootController.view.frame, rootController.view.safeAreaInsets);
        }
        CGFloat viewWidth = frame.size.width;
        bannerView.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth);
        NSLog(@"Adaptive banner will be created");
    }
    else { //smart banner
        if (orientation == 0 || orientation == UIInterfaceOrientationPortrait) { //portrait
            bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait];
            NSLog(@"Smart portait banner will be created");
        }
        else { //landscape
            bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerLandscape];
            NSLog(@"Smart landscape banner will be created");
        }
    }
    
    if (show_instantly){
        [self show_banner];
    }
    else{
        [self hide_banner];
    }
    
    bannerView.adUnitID = ad_unit_id;

    bannerView.delegate = self;
    bannerView.rootViewController = rootController;
    
    GADRequest *request = [GADRequest request];
    [bannerView loadRequest:request];

    
    
}

- (void)addBannerViewToView {
    bannerView.translatesAutoresizingMaskIntoConstraints = NO;
    [rootController.view addSubview:bannerView];
    //CENTER ON MIDDLE OF SCREEM
    [rootController.view addConstraint:
        [NSLayoutConstraint constraintWithItem:bannerView
                                     attribute:NSLayoutAttributeCenterX
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:rootController.view
                                     attribute:NSLayoutAttributeCenterX
                                    multiplier:1
                                      constant:0]];

    if (positionBanner == 0)//BOTTOM
    {
        [rootController.view addConstraint:
            [NSLayoutConstraint constraintWithItem:bannerView
                                        attribute:NSLayoutAttributeBottom
                                        relatedBy:NSLayoutRelationEqual
                                            toItem:rootController.view.safeAreaLayoutGuide
                                        attribute:NSLayoutAttributeBottom
                                        multiplier:1
                                        constant:0]];
    }
    else if(positionBanner == 1)//TOP
    {
        [rootController.view addConstraint:
            [NSLayoutConstraint constraintWithItem:bannerView
                                        attribute:NSLayoutAttributeTop
                                        relatedBy:NSLayoutRelationEqual
                                            toItem:rootController.view.safeAreaLayoutGuide
                                        attribute:NSLayoutAttributeTop
                                        multiplier:1
                                        constant:0]];
    }
}


- (void)destroy_banner
{
    if (!initialized)
        return;
    
    if (bannerView != nil)
    {
        [bannerView setHidden:YES];
        [bannerView removeFromSuperview];
        bannerView = nil;
        AdMob::get_singleton()->emit_signal("banner_destroyed");

        loaded = false;
    }
}


- (void)show_banner
{
    if (!initialized)
        return;
    
    if (bannerView != nil)
    {
        [bannerView setHidden:NO];
    }
}

- (void)hide_banner
{
    if (!initialized)
        return;
    
    if (bannerView != nil)
    {
        [bannerView setHidden:YES];
    }
}


- (bool) get_is_banner_loaded{
    return loaded;
}

//LISTENERS

- (void)bannerViewDidReceiveAd:(GADBannerView *)bannerView {
    NSLog(@"bannerViewDidReceiveAd");
    [self addBannerViewToView];
    AdMob::get_singleton()->emit_signal("banner_loaded");
    loaded = true;
}

- (void)bannerView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(NSError *)error {
    NSLog(@"bannerView:didFailToReceiveAdWithError: %@", [error localizedDescription]);
    AdMob::get_singleton()->emit_signal("banner_failed_to_load", (int) error.code);

}

- (void)bannerViewDidRecordImpression:(GADBannerView *)bannerView {
  NSLog(@"bannerViewDidRecordImpression");
    AdMob::get_singleton()->emit_signal("banner_recorded_impression");
}

- (void)bannerViewWillPresentScreen:(GADBannerView *)bannerView {
    AdMob::get_singleton()->emit_signal("banner_clicked");
}

- (void)bannerViewWillDismissScreen:(GADBannerView *)bannerView {
    NSLog(@"bannerViewWillDismissScreen");
    AdMob::get_singleton()->emit_signal("banner_closed");
}

- (void)bannerViewDidDismissScreen:(GADBannerView *)bannerView {
    NSLog(@"bannerViewDidDismissScreen");
    AdMob::get_singleton()->emit_signal("banner_opened");
}

@end
