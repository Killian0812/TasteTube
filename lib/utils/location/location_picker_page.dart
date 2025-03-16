import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:place_picker_google/place_picker_google.dart';
import 'package:taste_tube/common/loading.dart';
import 'package:taste_tube/common/size.dart';
import 'package:taste_tube/utils/location/location.util.dart';

class LocationPickerPage extends StatefulWidget {
  const LocationPickerPage({super.key});

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  GoogleMapController? mapController;
  LatLng? initialLocaltion;
  String? error;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialLocation();
  }

  Future<void> _loadInitialLocation() async {
    try {
      final position = await locateCurrentPosition();
      setState(() {
        initialLocaltion = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    } finally {
      loading = false;
    }
  }

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (context) {
          if (loading) {
            return const Center(child: CommonLoadingIndicator.regular);
          } else if (error != null) {
            return Center(child: Text("Error: $error"));
          } else {
            return PlacePicker(
              key: GlobalKey(debugLabel: "Maps"),
              mapsBaseUrl: kIsWeb
                  ? "https://cors-anywhere.herokuapp.com/https://maps.googleapis.com/maps/api/"
                  : "https://maps.googleapis.com/maps/api/",
              usePinPointingSearch: true,
              apiKey: "AIzaSyCaKLtA7loFFSm0aEzsg1gY_BOP5xeUn74",
              onPlacePicked: (LocationResult result) {
                if (Navigator.canPop(context)) {
                  Navigator.of(context).pop(result);
                }
              },
              myLocationFABConfig: MyLocationFABConfig(
                heroTag: "Maps",
                tooltip: "Locate me",
                mini: true,
                left: 10,
                right: CommonSize.screenSize.width - 60,
              ),
              enableNearbyPlaces: false,
              showSearchInput: true,
              initialLocation: initialLocaltion,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              onMapCreated: (controller) {
                mapController = controller;
              },
              searchInputConfig: const SearchInputConfig(
                padding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                autofocus: false,
                textDirection: TextDirection.ltr,
              ),
              searchInputDecorationConfig: const SearchInputDecorationConfig(
                hintText: "Search for a location ...",
              ),
              autocompletePlacesSearchRadius: 150,
            );
          }
        },
      ),
    );
  }
}
