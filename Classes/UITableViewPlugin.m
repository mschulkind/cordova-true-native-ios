#import "UITableViewPlugin.h"

#import "EGORefreshTableHeaderView.h"
#import "UITableViewRowPlugin.h"

@interface TNUITableView : UITableView 
    <UITableViewDelegate, UITableViewDataSource,
     EGORefreshTableHeaderDelegate> {
 @private
  NSArray* entries_;
  EGORefreshTableHeaderView* pullToRefreshView_;
  NSDate* lastRefreshDate_;
  BOOL reloading_;
}

@property (nonatomic, retain) NSArray* entries;
@property (nonatomic, retain) EGORefreshTableHeaderView* pullToRefreshView;
@property (nonatomic, retain) NSDate* lastRefreshDate;

@end

@implementation TNUITableView

@synthesize entries = entries_;
@synthesize pullToRefreshView = pullToRefreshView_;
@synthesize lastRefreshDate = lastRefreshDate_;

- (id)init
{
  if ((self = [super init])) {
    self.pullToRefreshView = nil;
    reloading_ = NO;
  }
  return self;
}

- (void)dealloc
{
  self.entries = nil;
  self.pullToRefreshView = nil;
  self.lastRefreshDate = nil;
  
  [[NSNotificationCenter defaultCenter] removeObserver:self];

  [super dealloc];
}

- (void)updateSurroundingViews:(NSNotification*)notification
{
  // Call the table(Header|Footer)View setters again to work around an iOS
  // 'feature' where resizes aren't picked up automatically.
  self.tableHeaderView = self.tableHeaderView;
  self.tableFooterView = self.tableFooterView;
}

// ============================================================
// Table Data Delegate
// ============================================================

- (bool)hasSections
{
  if ([entries_ count] > 0 
      && [[entries_ objectAtIndex:0] objectForKey:@"entries"])
  {
    // Found a top-level section, so that means there should be no top-level
    // rows.
    return true;
  } else {
    // All top-level objects should be rows, if any.
    return false;
  }
}

- (NSArray*)entriesForSection:(NSInteger)sectionIndex
{
  NSDictionary* section = [entries_ objectAtIndex:sectionIndex];
  return [section objectForKey:@"entries"];
}

- (NSDictionary*)entryForIndexPath:(NSIndexPath*)indexPath
{
  int rowIndex = indexPath.row;
  int sectionIndex = [self hasSections] ? indexPath.section : -1;
  NSDictionary* rowEntry;
  if ([self hasSections]) {
    NSArray* rowEntries = [self entriesForSection:sectionIndex];
    rowEntry = [rowEntries objectAtIndex:rowIndex];
  } else {
    rowEntry = [entries_ objectAtIndex:rowIndex];
  }
  assert(rowEntry);

  return rowEntry;
}

- (UITableViewCell*)tableView:(UITableView*)tableView
        cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
  int rowIndex = indexPath.row;
  int sectionIndex = [self hasSections] ? indexPath.section : -1;
  NSDictionary* rowEntry = [self entryForIndexPath:indexPath];

  NSString* templateName = [rowEntry objectForKey:@"templateName"];
  if (!templateName) {
    templateName = @"default";
  }
  TNUITableViewRow* row =
      (TNUITableViewRow*)[tableView 
          dequeueReusableCellWithIdentifier:templateName];
  if (!row) {
    // Create the row on the JS side.
    NSDictionary* rowOptions =
        [UIComponentPlugin writeJavascript:@"createRow()"
                              forComponent:self];
    UIComponentPlugin* rowPlugin =
        [UIComponentPlugin pluginForComponentWithOptions:rowOptions];
    assert([rowPlugin class] == [UITableViewRowPlugin class]);

    // Create the row on the native side.
    row = 
        [[[TNUITableViewRow alloc] 
            initWithStyle:UITableViewCellStyleDefault
          reuseIdentifier:templateName] autorelease];
    [UIComponentPlugin registerComponent:row withOptions:rowOptions];
    [rowPlugin setupComponent:row withOptions:rowOptions];

    // Set the contentView's height since the UITableView won't get around to
    // it until after the row is returned from this function and after
    // contructRow() has run.
    CGRect newFrame = row.contentView.frame;
    // Subtract one from the height to account for the row divider line.
    newFrame.size.height = self.rowHeight - 1;
    row.contentView.frame = newFrame;

    // Construct the row.
    NSString* rowID = [rowOptions objectForKey:@"tnUIID"];
    assert(rowID);
    [UIComponentPlugin writeJavascript:
        [NSString stringWithFormat:@"constructRow(%d, %d, '%@')",
            sectionIndex, rowIndex, rowID]
        forComponent:self];
  }

  // Call the row reuse callback to load the row up with data.
  [UIComponentPlugin writeJavascript:
      [NSString 
          stringWithFormat:@"reuseRow(%d, %d, '%@')",
          sectionIndex, rowIndex,
          [UIComponentPlugin lookupIDForComponent:row]]
      forComponent:self];

  // Flush everything to make sure the row is fully drawn before returning.
  [UIComponentPlugin flushCommandQueue];

  return row;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
  if ([self hasSections]) {
    return [entries_ count];
  } else {
    return 1;
  }
}

- (NSInteger)tableView:(UITableView*)tableView
    numberOfRowsInSection:(NSInteger)section
{
  if ([self hasSections]) {
    NSArray* rowEntries = [self entriesForSection:section];
    return [rowEntries count];
  } else {
    return [entries_ count];
  }
} 
- (NSString*)tableView:(UITableView*)tableView 
    titleForHeaderInSection:(NSInteger)section
{
  if ([self hasSections]) {
    return [[entries_ objectAtIndex:section] objectForKey:@"title"];
  } else {
    return nil;
  }
}

- (UITableViewCellEditingStyle)tableView:(UITableView*)tableView 
           editingStyleForRowAtIndexPath:(NSIndexPath*)indexPath
{
  NSDictionary* rowEntry = [self entryForIndexPath:indexPath];
  NSString* editingStyle = [rowEntry objectForKey:@"editingStyle"];
  if (editingStyle) {
    if ([editingStyle isEqual:@"none"]) {
      return UITableViewCellEditingStyleNone;
    } else if ([editingStyle isEqual:@"delete"]) {
      return UITableViewCellEditingStyleDelete;
    } else if ([editingStyle isEqual:@"insert"]) {
      return UITableViewCellEditingStyleInsert;
    } else {
      assert(false);
    }
  } else {
    return UITableViewCellEditingStyleNone;
  }
}

- (void)tableView:(UITableView*)tableView 
    commitEditingStyle:(UITableViewCellEditingStyle)editingStyle 
    forRowAtIndexPath:(NSIndexPath*)indexPath
{
  NSString* eventName;
  if (editingStyle == UITableViewCellEditingStyleInsert) {
    eventName = @"insert";
  } else if (editingStyle == UITableViewCellEditingStyleDelete) {
    eventName = @"delete";
  } else {
    assert(false);
  }

  NSMutableDictionary* eventData = 
      [NSMutableDictionary 
          dictionaryWithObject:[NSNumber numberWithInt:indexPath.row] 
                        forKey:@"rowIndex"];
  if ([self hasSections]) {
    [eventData setObject:[NSNumber numberWithInt:indexPath.section]
                  forKey:@"sectionIndex"];
  }

  [[UIComponentPlugin class] 
      fireEvent:eventName withData:eventData forComponent:tableView];
}

// ============================================================
// Pull to Refresh
// ============================================================

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
  reloading_ = YES;
  [UITableViewPlugin fireEvent:@"refresh" withData:nil forComponent:self];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:
    (EGORefreshTableHeaderView*)view
{
	return reloading_;
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:
    (EGORefreshTableHeaderView*)view
{
  return self.lastRefreshDate;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{	
	[pullToRefreshView_ egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate
{
	[pullToRefreshView_ egoRefreshScrollViewDidEndDragging:scrollView];
}

- (void)refreshDone:(BOOL)success
{
  reloading_ = NO;

  if (success) {
    self.lastRefreshDate = [NSDate date];
  }

  [pullToRefreshView_ egoRefreshScrollViewDataSourceDidFinishedLoading:self];
}

@end

@implementation UITableViewPlugin

+ (Class)uiKitSubclass 
{
  return [TNUITableView class];
}

- (id)initComponent:(TNUITableView*)tableView withOptions:(NSDictionary*)options
{
  UITableViewStyle style;
  NSString* styleString = [options objectForKey:@"style"];
  assert(styleString);
  if ([styleString isEqual:@"plain"]) {
    style = UITableViewStylePlain;
  } else if ([styleString isEqual:@"grouped"]) {
    style = UITableViewStyleGrouped;
  } else {
    // Unknown style.
    assert(false);
  }

  return (id)[tableView initWithFrame:CGRectZero style:style];
}

- (void)setupComponent:(TNUITableView*)tableView 
           withOptions:(NSDictionary*)options
{
  [super setupComponent:tableView withOptions:options];

  tableView.delegate = tableView;
  tableView.dataSource = tableView;
  tableView.allowsSelection = NO;

  [self setProperties:
      [NSArray arrayWithObjects:@"rowHeight", @"entries", @"pullToRefresh", 
          @"headerView", @"footerView", @"scrollEnabled", @"editing", nil]
      forComponent:tableView
       fromOptions:options];
}

- (id)getProperty:(NSString*)name
     forComponent:(TNUITableView*)tableView
{
  if ([name isEqual:@"contentHeight"]) {
    return [NSNumber numberWithFloat:[tableView contentSize].height];
  } else if ([name isEqual:@"contentWidth"]) {
    return [NSNumber numberWithFloat:[tableView contentSize].width];
  } else {
    return [super getProperty:name forComponent:tableView];
  }
}

- (void)setSurroundingView:(TNUITableView*)tableView
                 viewNamed:(NSString*)name
         toViewWithOptions:(id)options
{
  SEL getter = 
      NSSelectorFromString(
          [NSString stringWithFormat:@"table%@View", name]);
  SEL setter = 
      NSSelectorFromString(
          [NSString stringWithFormat:@"setTable%@View:", name]);

  // If there's already a view, we need to remove our old
  // observer.
  if ([tableView performSelector:getter]) {
    [[NSNotificationCenter defaultCenter] 
        removeObserver:tableView
                  name:kTNUIViewResizeNotification
                object:[tableView performSelector:getter]];
  }

  if ([options class] != [NSNull class]) {
    [tableView performSelector:setter 
                    withObject:[[self class] componentWithOptions:options]];

    // Watch for tableHeaderView resizes.
    [[NSNotificationCenter defaultCenter]
        addObserver:tableView
           selector:@selector(updateSurroundingViews:)
               name:kTNUIViewResizeNotification
             object:[tableView performSelector:getter]];
  } else {
    [tableView performSelector:setter withObject:nil];
  }
}

- (void)setProperty:(NSString*)name 
          withValue:(id)value
       forComponent:(TNUITableView*)tableView
{
  if ([name isEqual:@"entries"]) {
    assert([value isKindOfClass:[NSArray class]]);
    tableView.entries = value;
    [tableView reloadData];
  } else if ([name isEqual:@"editing"]) {
    tableView.editing = [value boolValue];
  } else if ([name isEqual:@"scrollsToTop"]) {
    tableView.scrollsToTop = [value boolValue];
  } else if ([name isEqual:@"scrollEnabled"]) {
    tableView.scrollEnabled = [value boolValue];
  } else if ([name isEqual:@"rowHeight"]) {
    // The '+ 1' here is to account for the 1 pixel height difference between
    // the cell and the contentView presumably due to the cell border.
    tableView.rowHeight = [value intValue] + 1;
  } else if ([name isEqual:@"headerView"]) {
    [self setSurroundingView:tableView 
                   viewNamed:@"Header" 
           toViewWithOptions:value];
  } else if ([name isEqual:@"footerView"]) {
    [self setSurroundingView:tableView 
                   viewNamed:@"Footer" 
           toViewWithOptions:value];
  } else if ([name isEqual:@"pullToRefresh"]) {
    if ([value boolValue]) {
      tableView.pullToRefreshView = 
          [[[EGORefreshTableHeaderView alloc]
              initWithFrame:CGRectZero
             arrowImageName:@"grayArrow" 
                  textColor:[UIColor grayColor]] autorelease];
      tableView.pullToRefreshView.delegate = tableView;

      tableView.lastRefreshDate = [NSDate date];
      [tableView.pullToRefreshView refreshLastUpdatedDate];

      [tableView addSubview:tableView.pullToRefreshView];
    } else {
      if (tableView.pullToRefreshView) {
        [tableView.pullToRefreshView removeFromSuperview];
        tableView.pullToRefreshView = nil;
      }
    }
  } else {
    [super setProperty:name withValue:value forComponent:tableView];
  }
}

- (void)refreshDone:(NSMutableArray*)arguments
           withDict:(NSMutableDictionary*)options
{
  NSString* tableViewID = [options objectForKey:@"tableViewID"];
  assert(tableViewID);

  NSNumber* success = [options objectForKey:@"success"];
  assert(success);
  [[[self class] lookupComponentWithID:tableViewID] 
      refreshDone:[success boolValue]];
}

- (void)refreshRow:(NSMutableArray*)arguments
          withDict:(NSMutableDictionary*)options
{
  NSNumber* sectionIndexNumber = [options objectForKey:@"sectionIndex"];
  assert(sectionIndexNumber);
  NSNumber* rowIndexNumber = [options objectForKey:@"rowIndex"];
  assert(rowIndexNumber && [rowIndexNumber class] != [NSNull class]);

  // Default to section 0 if no section given.
  NSUInteger sectionIndex;
  if ([sectionIndexNumber class] == [NSNull class]) {
    sectionIndex = 0;
  } else {
    sectionIndex = [sectionIndexNumber intValue];
  }

  // Fire off the reload command.
  NSString* tableViewID = [options objectForKey:@"tableViewID"];
  assert(tableViewID);
  TNUITableView* tableView = [[self class] lookupComponentWithID:tableViewID];
  NSArray* indexPathArray = 
      [NSArray arrayWithObject:
          [NSIndexPath indexPathForRow:[rowIndexNumber intValue]
                             inSection:sectionIndex]];
  [tableView reloadRowsAtIndexPaths:indexPathArray
                   withRowAnimation:UITableViewRowAnimationNone];
}

@end
