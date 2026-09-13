import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';

class PlacesScreen extends StatefulWidget {
  const PlacesScreen({super.key});

  @override
  State<PlacesScreen> createState() => _PlacesScreenState();
}

class _PlacesScreenState extends State<PlacesScreen> {
  // Must match android/app/src/main/AndroidManifest.xml.
  // After changing this value, run: flutter clean && flutter pub get && flutter run -d emulator-5554
  static const String googleApiKey = 'AIzaSyCIKyyHA9b__PaSVsgxw3Qp6Ikkfp5hVCE';
  static const LatLng fallbackLatLng = LatLng(33.6844, 73.0479);
  static const String fallbackAddress = 'Islamabad, Pakistan';

  final searchController = TextEditingController();

  GoogleMapController? mapController;

  LatLng selectedLatLng = fallbackLatLng;
  String selectedAddress = fallbackAddress;
  bool isLoadingLocation = true;

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  @override
  void dispose() {
    searchController.dispose();
    mapController?.dispose();
    super.dispose();
  }

  Future<void> getCurrentLocation() async {
    try {
      searchController.text = selectedAddress;

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        Get.snackbar('Location', 'Please enable location services');
        await setFallbackLocation();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        Get.snackbar('Location', 'Location permission denied');
        await setFallbackLocation();
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final currentLatLng = LatLng(position.latitude, position.longitude);
      final address =
          await getAddressFromLatLng(currentLatLng) ?? fallbackAddress;

      updateSelectedLocation(currentLatLng, address);
      moveCameraTo(currentLatLng, zoom: 15);
    } catch (error) {
      await setFallbackLocation();
    } finally {
      if (mounted) {
        setState(() {
          isLoadingLocation = false;
        });
      }
    }
  }

  Future<void> setFallbackLocation() async {
    final address =
        await getAddressFromLatLng(fallbackLatLng) ?? fallbackAddress;
    updateSelectedLocation(fallbackLatLng, address);
    moveCameraTo(fallbackLatLng, zoom: 13);
  }

  Future<String?> getAddressFromLatLng(LatLng latLng) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );

      if (placemarks.isEmpty) {
        return null;
      }

      final place = placemarks.first;
      final parts =
          [
                place.name,
                place.street,
                place.subLocality,
                place.locality,
                place.administrativeArea,
                place.country,
              ]
              .where((part) => part != null && part.trim().isNotEmpty)
              .map((part) => part!.trim())
              .toSet()
              .toList();

      if (parts.isEmpty) {
        return null;
      }

      return parts.join(', ');
    } catch (_) {
      return null;
    }
  }

  String getCoordinateText(LatLng latLng) {
    return '${latLng.latitude.toStringAsFixed(6)}, ${latLng.longitude.toStringAsFixed(6)}';
  }

  void updateSelectedLocation(LatLng latLng, String address) {
    if (!mounted) {
      return;
    }

    setState(() {
      selectedLatLng = latLng;
      selectedAddress = address;
      searchController.text = address;
    });
  }

  void moveCameraTo(LatLng position, {double zoom = 15}) {
    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: position, zoom: zoom),
      ),
    );
  }

  Future<void> selectMapLocation(LatLng latLng) async {
    if (!mounted) {
      return;
    }

    setState(() {
      isLoadingLocation = true;
    });

    try {
      updateSelectedLocation(latLng, getCoordinateText(latLng));
      moveCameraTo(latLng);

      final address = await getAddressFromLatLng(latLng);
      if (address == null || address.isEmpty) {
        return;
      }

      updateSelectedLocation(latLng, address);
    } finally {
      if (mounted) {
        setState(() {
          isLoadingLocation = false;
        });
      }
    }
  }

  void selectPlace(Prediction prediction) {
    final lat = double.tryParse(prediction.lat ?? '');
    final lng = double.tryParse(prediction.lng ?? '');

    final address = prediction.description ?? '';

    if (lat != null && lng != null) {
      final position = LatLng(lat, lng);
      updateSelectedLocation(position, address);
      moveCameraTo(position);
    } else if (address.isNotEmpty) {
      updateSelectedLocation(selectedLatLng, address);
    }
  }

  void submitLocation() {
    if (selectedAddress.isEmpty) {
      Get.snackbar('Error', 'Please select a location');
      return;
    }

    Get.back(result: selectedAddress);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Location')),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: selectedLatLng,
              zoom: 13,
            ),
            onMapCreated: (controller) {
              mapController = controller;

              controller.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(target: selectedLatLng, zoom: 15),
                ),
              );
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: true,
            padding: const EdgeInsets.only(top: 96, bottom: 112, right: 16),
            markers: {
              Marker(
                markerId: const MarkerId('selected_location'),
                position: selectedLatLng,
              ),
            },
            onTap: selectMapLocation,
          ),

          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Column(
              children: [
                Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(12),
                  child: GooglePlaceAutoCompleteTextField(
                    textEditingController: searchController,
                    googleAPIKey: googleApiKey,
                    debounceTime: 600,
                    isLatLngRequired: true,
                    inputDecoration: InputDecoration(
                      hintText: 'Search location',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          searchController.clear();
                          selectedAddress = '';
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    itemClick: (Prediction prediction) {
                      selectPlace(prediction);
                    },
                    getPlaceDetailWithLatLng: (Prediction prediction) {
                      selectPlace(prediction);
                    },
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: submitLocation,
                  child: const Text('Select This Location'),
                ),
              ),
            ),
          ),

          if (isLoadingLocation)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
