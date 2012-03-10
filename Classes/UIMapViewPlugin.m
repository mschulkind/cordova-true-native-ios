#import "UIMapViewPlugin.h"

@interface TNUIMapView : MKMapView <MKMapViewDelegate> {
 @private
}
@end

@implementation TNUIMapView

- (void)addPinWithOptions:(NSDictionary*)options
{
  NSNumber* longitude = [options objectForKey:@"longitude"];
  NSNumber* latitude = [options objectForKey:@"latitude"];
  assert(longitude && latitude);

  CLLocationCoordinate2D point;
  point.latitude = [latitude doubleValue];
  point.longitude = [longitude doubleValue];

  MKPointAnnotation* annotation =
      [[[MKPointAnnotation alloc] init] autorelease];
  annotation.coordinate = point;
  [self addAnnotation:annotation];
}

- (void)mapView:(MKMapView*)mapView 
      didAddAnnotationViews:(NSArray *)views
{
  // Disable all annotation interaction until we have proper support.
  for (MKAnnotationView* view in views) {
    view.enabled = NO;
  }
}

@end

@implementation UIMapViewPlugin

+ (Class)uiKitSubclass
{
  return [TNUIMapView class];
}

- (void)setupComponent:(TNUIMapView*)mapView withOptions:(NSDictionary*)options
{
  [super setupComponent:mapView withOptions:options];

  mapView.delegate = mapView;

  // Start the span very small so that if we move the center, it will actually
  // get moved instead of being readjusted to fit the entire large default
  // span.
  MKCoordinateRegion newRegion;
  newRegion.center.longitude = 0;
  newRegion.center.latitude = 0;
  newRegion.span.longitudeDelta = 1e-10;
  newRegion.span.latitudeDelta = 1e-10;
  mapView.region = newRegion;

  [self setProperties:
    [NSArray arrayWithObjects:@"region", @"scrollEnabled", @"zoomEnabled", 
      @"center", @"span", nil]
    forComponent:mapView
    fromOptions:options];

  NSArray* pins = [options objectForKey:@"pins"];
  if (pins) {
    for (NSDictionary* pinOptions in pins) {
      [mapView addPinWithOptions:pinOptions];
    }
  }
}

- (id)getProperty:(NSString*)name
     forComponent:(TNUIMapView*)mapView
{
  if (false) {
  } else {
    return [super getProperty:name forComponent:mapView];
  }
}

- (void)setProperty:(NSString*)name 
          withValue:(id)value
       forComponent:(TNUIMapView*)mapView
{
  if ([name isEqual:@"center"]) {
    NSNumber* latitude = [value objectForKey:@"latitude"];
    NSNumber* longitude = [value objectForKey:@"longitude"];
    assert(longitude && latitude);

    CLLocationCoordinate2D newCenter = mapView.centerCoordinate;
    newCenter.longitude = [longitude doubleValue];
    newCenter.latitude = [latitude doubleValue];
    mapView.centerCoordinate = newCenter;
  } else if ([name isEqual:@"span"]) {
    NSNumber* latitude = [value objectForKey:@"latitude"];
    NSNumber* longitude = [value objectForKey:@"longitude"];
    assert(longitude && latitude);

    MKCoordinateRegion newRegion = mapView.region;
    newRegion.span.longitudeDelta = [longitude doubleValue];
    newRegion.span.latitudeDelta = [latitude doubleValue];
    mapView.region = newRegion;
  } else if ([name isEqual:@"scrollEnabled"]) {
    mapView.scrollEnabled = [value boolValue];
  } else if ([name isEqual:@"zoomEnabled"]) {
    mapView.zoomEnabled = [value boolValue];
  } else {
    [super setProperty:name 
             withValue:value 
          forComponent:mapView];
  }
}

- (void)addPin:(NSMutableArray*)arguments
      withDict:(NSMutableDictionary*)options
{
  NSString* mapViewID = [options objectForKey:@"mapViewID"];
  TNUIMapView* mapView = [[self class] lookupComponentWithID:mapViewID];
  assert(mapView);

  NSDictionary* pinOptions = [options objectForKey:@"pinOptions"];
  assert(pinOptions);
  [mapView addPinWithOptions:pinOptions];
}

@end
