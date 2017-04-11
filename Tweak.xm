#define PreferencesChangedNotification "me.chewitt.tabcount.settingschanged"
#define PreferencesFilePath [NSString stringWithFormat:@"/var/mobile/Library/Preferences/me.chewitt.tabcount.plist"]

#import "Substrate.h"
#import "Headers.h"

static NSDictionary* preferences;
static int longPressAction;
static BOOL ayeris;
static BOOL enabled;

static void updatePrefs() {
    preferences = [[NSDictionary alloc] initWithContentsOfFile:PreferencesFilePath];
    longPressAction = [[preferences objectForKey:@"LongPressAction"] intValue];
    ayeris = [[preferences objectForKey:@"ayeris"] boolValue];
    enabled = ! [[preferences objectForKey:@"enabled"] boolValue];
}

static int numberOfTabs = 1;
static UILabel* countLabel;
static UILongPressGestureRecognizer* longPress;
static BOOL newTabCreated;

%group STC

%hook TabController

-(void)_auditTabCount {
    %orig;
    numberOfTabs = self.tabDocuments.count;
    if (countLabel) {
        countLabel.text = [NSString stringWithFormat:@"%i", numberOfTabs];
    }
}

-(int) maximumTabDocumentCount {
    return 999;
}

%end

%hook BrowserToolbar

-(void)layoutSubviews {
    %orig;
    [self setupButton];
}

-(void) setItems:(id)arg1 animated:(BOOL)arg2 {
    %orig;
    [self setupButton];
}

-(void) setTintColor:(id)arg1 {
    %orig;
    if (countLabel) {
        countLabel.textColor = self.tintColor;
    }
}

%new

-(void)setupButton {
    UIBarButtonItem* button = nil;
    for (UIBarButtonItem* b in self.items) {
        if ([NSStringFromSelector(b.action) isEqualToString:@"showTabsFromButtonBar"]) {
            button = b;
        }
    }

    if (! button) {
        return;
    }

    UIView* v = button.view;

    CGFloat originY;
    CGFloat originX = 1;
    CGFloat width = 16;
    if (v.frame.size.height == 44) {
        if (ayeris) {
            originY = 15;
            originX = 5.5;
            width = 13;
        }
        else {
            originY = 15.5;
        }
    }
    else {
        originY = 8;
        if (ayeris) {
            width = 13;
            originX = 5.5;
        }
    }

    if (! countLabel) {
        countLabel = [[UILabel alloc] init];
        countLabel.text = [NSString stringWithFormat:@"%i", numberOfTabs];
        countLabel.textColor = self.tintColor;
        countLabel.textAlignment = NSTextAlignmentCenter;
        countLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        countLabel.adjustsFontSizeToFitWidth = YES;
        countLabel.numberOfLines = 1;
    }
    countLabel.frame = CGRectMake(originX, originY, width, 18);

    if (! [countLabel isDescendantOfView:v]) {
        [v addSubview:countLabel];
    }

    if (! longPress) {
        if (longPressAction == 0) {
            longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(closeAllTabsButActive)];
        }
        else {
            longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(openNewTab)];
        }
        longPress.minimumPressDuration = 0.75;
    }

    if (! [longPress.view isEqual:v]) {
        [v addGestureRecognizer:longPress];
    }

    countLabel.hidden = [[%c(BrowserController) sharedBrowserController] privateBrowsingEnabled];
}

%new

-(void)openNewTab {
    if (! newTabCreated) {
        [[[%c(BrowserController) sharedBrowserController] tabController] _createAndSwitchToNewBlankTabDocumentOpeningCaptiveLandingPageIfNecessary];
        newTabCreated = YES;
    }
    if (longPress.state == UIGestureRecognizerStateEnded || longPress.state == UIGestureRecognizerStateCancelled || longPress.state == UIGestureRecognizerStateFailed) {
        newTabCreated = NO;
    }
}

%new

-(void)closeAllTabsButActive {
    NSMutableArray* tabsToClose = [NSMutableArray array];
    TabController* currentController = [[%c(BrowserController) sharedBrowserController] tabController];
    for (id d in currentController.tabDocuments) {
        if (d != currentController.activeTabDocument) {
            [tabsToClose addObject:d];
        }
    }
    for (id d in tabsToClose) {
        [currentController closeTabDocument:d animated:NO];
    }
}

%end

%end

%ctor {
    updatePrefs();
    if (enabled) {
        %init(STC);
    }
}
