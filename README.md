# Doorstep - An Android Application that keeps you home

Amidst alarming COVID-19 situation and ever an increasing lockdown in India, I realised people around me are risking their safety against a global pandemic because they wanted to buy groceries and medical supplies for their households. While well-known applications like *zomato* are providing options for home delivery of groceries, they have failed in reaching out to small grocery shop owners like the ones in my neighbourhood. Change starts at home, is the one thing that's always at the back of my head and so I fashioned an application called *Doorstep* which connects local shop owners to people around them.<br>
One thing that has to be kept in mind while building an application like this is that **not every grocery/medical shop delivers goods**. So in case of the ones that don't, I've constructed a mechanism that generates *pickup-times* for customers, keeping each one of them **atleast 10 minutes apart** to avoid crowding at the shop. That's how this application avoids **social intimacy** (It's got a nice ring to it!).<br>

## Screenshots
### Customer sign In
<p align="center">
  <img width="200" height="400" src="Pictures/1.jpeg">&nbsp;&nbsp;<img src="Pictures/2.jpeg" width="200" height="400">&nbsp;&nbsp;<img src="Pictures/3.jpeg" width="200" height="400">&nbsp;&nbsp;<img src="Pictures/4.jpeg" width="200" height="400">
</p>

### Shop owner sign In
<p align="center">
<img src="Pictures/5.jpeg" width="200" height="400">&nbsp;&nbsp;&nbsp;&nbsp;<img src="Pictures/6.jpeg" width="200" height="400">&nbsp;&nbsp;&nbsp;&nbsp;<img src="Pictures/7.jpeg" width="200" height="400">
</p>

Let's dive into the technicalities now!
## Google Maps Integration
To use google maps in a flutter application, there are couple of steps that one should perform before coding anything in his application. <br>
I've used [*google_maps_flutter*](https://pub.dev/packages/google_maps_flutter) plugin to integrate maps in my application. After adding *google_maps_flutter* dependency in the pubspec.yaml file of your application, follow the following steps:
<ul> 
  <li>Get an API key at [Maps Platform](https://cloud.google.com/maps-platform/)</li>
  <li>Enable Google Map SDK for each platform
    <ul>
      <li>Go to https://console.cloud.google.com/</li>
      <li>Choose the project that you want to enable Google Maps on</li>
      <li>Select the navigation menu and then select "Google Maps"</li>
      <li>Select "APIs" under the Google Maps menu</li>
      <li>To enable Google Maps for Android, select "Maps SDK for Android" in the "Additional APIs" section, then select "ENABLE"</li>
      <li>To enable Google Maps for iOS, select "Maps SDK for iOS" in the "Additional APIs" section, then select "ENABLE"</li>
      <li>Make sure the APIs you enabled are under the "Enabled APIs" section</li>
    </ul>
  </li>
</ul>
**Note:** You can find detailed steps [here](https://developers.google.com/maps/gmp-get-started).

### Android
Specify your API key in the application manifest ```android/app/src/main/AndroidManifest.xml``` :
```
<manifest ...
  <application ...
    <meta-data android:name="com.google.android.geo.API_KEY"
               android:value="YOUR KEY HERE"/>
```
### iOS
Specify your API key in the application delegate ```ios/Runner/AppDelegate.m``` :
```
#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
#import "GoogleMaps/GoogleMaps.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GMSServices provideAPIKey:@"YOUR KEY HERE"];
  [GeneratedPluginRegistrant registerWithRegistry:self];
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}
@end
```
Or in your swift code, specify your API key in the application delegate ```ios/Runner/AppDelegate.swift``` :
```
import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("YOUR KEY HERE")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```
Opt-in to the embedded views preview by adding a boolean property to the app's ```Info.plist``` file with the key ```io.flutter.embedded_views_preview``` and the value ```YES```.

## Customer Screen Map
*GoogleMap* widget is used to display map on the screen. The map view can be controlled with the *GoogleMapController* that is passed to the GoogleMap's onMapCreated callback.
```dart
        GoogleMap(
          myLocationEnabled: true,
          compassEnabled: true,
          mapType: MapType.normal,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
          initialCameraPosition: _currLocCameraPostition,
          markers: _markers,
        ),
```
```initialCameraPosition``` is the current location of the user and ```_markers``` is a set of markers on the map which hold the latitude-longitude information of shops in a radius of 3 km from the current location of the user which is fetched from the *Firestore database* using the following function:
```dart
  Future fetchShops() async {
    _shops = List();
    await Firestore.instance.collection('users').getDocuments().then((snap) {
      if (snap.documents.length > 0) {
        snap.documents.forEach((doc) {
          if (doc['typeOfShop'] != 'None') {
            print('**********' + doc['name'].toString());
            var lat = double.parse(doc['latitude']);
            var lng = double.parse(doc['longitude']);
            var loc = LatLng(lat, lng);
            var distance =
                geodesy.distanceBetweenTwoGeoPoints(currLatLng, loc) / 1000;
            print("********DISTANCE*****" + distance.toString());
            if (distance <= 3 && distance > 0) {
              _shops.add(ShopData(
                address: doc['address'],
                latitude: double.parse(doc['latitude']),
                longitude: double.parse(doc['longitude']),
                delivery: doc['homeDelivery'],
                typeOfShop: doc['typeOfShop'],
                userId: doc.documentID,
              ));
            }
          }
        });
      }
    });
    print('************' + _shops.length.toString() + '*********');
    notifyListeners();
  }
```
