@interface BrowserController : NSObject
+(id)sharedBrowserController;
-(id)tabController;
-(BOOL)privateBrowsingEnabled;
@end

@interface TabController : NSObject {}
@property(readonly, assign, nonatomic) NSArray* tabDocuments;
@property(retain, nonatomic) id activeTabDocument;
-(void)closeTabDocument:(id)document animated:(BOOL)animated;
-(BOOL)_createAndSwitchToNewBlankTabDocumentOpeningCaptiveLandingPageIfNecessary;
-(BOOL)_createAndSwitchToNewBlankTabDocumentOpeningCaptiveLandingPageIfNecessary;
@end

@interface BrowserToolbar : UIToolbar {}
-(void)closeAllTabsIncludingActive:(BOOL)a;
@property(readonly, assign, nonatomic) NSArray* defaultItems;
-(void)setupButton;
@end

@interface UIBarButtonItem (c)
-(id)view;
@end
