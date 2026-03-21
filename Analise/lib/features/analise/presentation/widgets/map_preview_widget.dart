import 'package:flutter/material.dart';

class MapPreviewWidget extends StatelessWidget {
  final double latitude;
  final double longitude;
  final VoidCallback onOpenMap;

  const MapPreviewWidget({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.onOpenMap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.green.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.map, color: Colors.green),
        ),
        title: const Text('Localização'),
        subtitle: Text('Lat: $latitude, Lng: $longitude'),
        trailing: TextButton.icon(
          onPressed: onOpenMap,
          icon: const Icon(Icons.open_in_new),
          label: const Text('Abrir no Mapa'),
        ),
      ),
    );
  }
}
