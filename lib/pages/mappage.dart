
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:latlong2/latlong.dart';
import '/data/branches_data.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final PopupController _popupController = PopupController();
  late final List<Marker> _markers;

  @override
  void initState() {
    super.initState();
    _markers = branches.map((b) {
      return Marker(
        key: ValueKey(b.name),
        point: b.location,
        width: 40,
        height: 40,
        child: const Icon(Icons.location_on, color: Colors.red, size: 40),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Şube Haritası")),
      body: FlutterMap(
        options: MapOptions(
          center: LatLng(38.7223, 35.4875), // Kayseri merkez
          zoom: 13,
          minZoom: 3,
          maxZoom: 18,
          onTap: (_, __) => _popupController.hideAllPopups(),
        ),
        children: [
          
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.fr/osmfr/{z}/{x}/{y}.png",
            subdomains: const ["a", "b", "c"],
            userAgentPackageName: "com.example.app",
          ),
          PopupMarkerLayerWidget(
            options: PopupMarkerLayerOptions(
              popupController: _popupController,
              markers: _markers,
              markerTapBehavior: MarkerTapBehavior.togglePopup(),
              popupDisplayOptions: PopupDisplayOptions(
                snap: PopupSnap.markerTop,
                builder: (BuildContext context, Marker marker) {
                  final String keyName =
                      (marker.key as ValueKey).value.toString();
                  final branch = branches.firstWhere(
                    (b) => b.name == keyName,
                    orElse: () => Branch('Bilinmeyen', LatLng(0, 0)),
                  );

                  return Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            branch.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Koordinat: ${branch.location.latitude.toStringAsFixed(4)}, '
                            '${branch.location.longitude.toStringAsFixed(4)}',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.black54),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              TextButton(
                                onPressed: () =>
                                    _popupController.hideAllPopups(),
                                child: const Text('Kapat'),
                              ),
                              const SizedBox(width: 8),
                              TextButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${branch.name} seçildi'),
                                    ),
                                  );
                                },
                                child: const Text('Detay'),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
