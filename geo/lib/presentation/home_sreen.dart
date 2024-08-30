import 'package:appgeolocalizacao/services/location_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  LatLng? _currentPosition;
  LatLng? _firstClickPosition; // Armazena a posição do primeiro clique
  LatLng? _secondClickPosition; // Armazena a posição do segundo clique
  double? _distance; // Armazena a distância entre os dois pontos
  final LocationService _locationService = LocationService();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await _locationService.getCurrentLocation();
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      print('Erro ao obter a localização: $e');
    }
  }

  void _onMapTap(TapPosition tapPosition, LatLng latlng) {
    setState(() {
      if (_firstClickPosition == null) {
        _firstClickPosition = latlng; // Armazena o primeiro ponto
        _secondClickPosition = null; // Reseta o segundo ponto
        _distance = null; // Reseta a distância
      } else if (_secondClickPosition == null) {
        _secondClickPosition = latlng; // Armazena o segundo ponto
        _calculateDistance(); // Calcula a distância entre os dois pontos
      } else {
// Se ambos os pontos estiverem definidos, reseta e começa de novo
        _firstClickPosition = latlng;
        _secondClickPosition = null;
        _distance = null;
      }
    });
  }

  void _calculateDistance() {
    if (_firstClickPosition != null && _secondClickPosition != null) {
      final distanceInMeters = Geolocator.distanceBetween(
        _firstClickPosition!.latitude,
        _firstClickPosition!.longitude,
        _secondClickPosition!.latitude,
        _secondClickPosition!.longitude,
      );

      setState(() {
        _distance = distanceInMeters;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Minha Localização no Mapa'),
      ),
      body: _currentPosition == null
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: FlutterMap(
                    options: MapOptions(
                      center: _currentPosition,
                      zoom: 15,
                      onTap: _onMapTap, // Detecta cliques no mapa
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                        subdomains: ['a', 'b', 'c'],
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _currentPosition!,
                            width: 80,
                            height: 80,
                            builder: (ctx) => Icon(
                              Icons.location_pin,
                              color: Colors.red,
                              size: 40,
                            ),
                          ),
                          if (_firstClickPosition != null)
                            Marker(
                              point: _firstClickPosition!,
                              width: 80,
                              height: 80,
                              builder: (ctx) => Icon(
                                Icons.location_pin,
                                color: Colors.red,
                                size: 40,
                              ),
                            ),
                          if (_secondClickPosition != null)
                            Marker(
                              point: _secondClickPosition!,
                              width: 80,
                              height: 80,
                              builder: (ctx) => Icon(
                                Icons.location_pin,
                                color: Colors.red,
                                size: 40,
                              ),
                            ),
                        ],
                      ),
                      if (_firstClickPosition != null &&
                          _secondClickPosition != null)
                        PolylineLayer(
                          polylines: [
                            Polyline(
                              points: [
                                _firstClickPosition!,
                                _secondClickPosition!
                              ],
                              color: Colors.red,
                              strokeWidth: 4.0,
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                if (_distance != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Distância entre os pontos: ${_distance! < 1000 ? '${_distance!.toStringAsFixed(2)} metros' : '${(_distance! / 1000).toStringAsFixed(2)} quilômetros'}',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
    );
  }
}
