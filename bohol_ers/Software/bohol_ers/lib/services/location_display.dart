import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

class LocationDisplay extends StatefulWidget {
  const LocationDisplay({super.key});

  @override
  LocationDisplayState createState() => LocationDisplayState();
}

class LocationDisplayState extends State<LocationDisplay> {
  late MapController mapController;
  GeoPoint? userLocation; // Store the user's location

  @override
  void initState() {
    super.initState();
    mapController = MapController.customLayer(
      initPosition: GeoPoint(
        latitude: 47.4358055,
        longitude: 8.4737324,
      ),
      customTile: CustomTile(
        sourceName: "opentopomap_cycle", // Cycling-specific source name
        tileExtension: ".png",
        minZoomLevel: 2,
        maxZoomLevel: 19,
        urlsServers: [
          TileURLs(
            url: "https://tile.opentopomap.org/", // Corrected tile URL
            subdomains: [],
          )
        ],
        tileSize: 256,
      ),
    );
  }

  /// Fetches the user's current location and updates the map
  Future<void> getUserLocation() async {
    try {
      final location = await mapController.myLocation(); // Fetch the user's location
      setState(() {
        userLocation = location;
      });
      // Center the map on the user's location
      mapController.changeLocation(userLocation!);
        } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to fetch location: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Current Location'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Info button pressed")),
              );
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: OSMFlutter(
              controller: mapController,
              osmOption: OSMOption(
                userTrackingOption: UserTrackingOption(
                  enableTracking: true,
                ),
                zoomOption: ZoomOption(
                  initZoom: 16,
                  minZoomLevel: 3,
                  maxZoomLevel: 19,
                  stepZoom: 1.0,
                ),
                userLocationMarker: UserLocationMaker(
                  personMarker: MarkerIcon(
                    icon: Icon(
                      Icons.person_pin_circle,
                      color: Color.fromARGB(255, 1, 55, 252),
                      size: 60,
                    ),
                  ),
                  directionArrowMarker: MarkerIcon(
                    icon: Icon(Icons.arrow_drop_down, size: 48),
                  ),
                ),
                roadConfiguration: RoadOption(
                  roadColor: Colors.yellowAccent,
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await getUserLocation(); // Fetch and center on the user's location
        },
        backgroundColor: Colors.blue,
        tooltip: 'Go to My Location',
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
