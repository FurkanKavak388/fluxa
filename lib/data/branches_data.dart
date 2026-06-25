import 'package:latlong2/latlong.dart';

class Branch {
  final String name;
  final LatLng location;
  const Branch(this.name, this.location);
}

const List<Branch> branches = [
  Branch("Kayseri Merkez Şube", LatLng(38.7223, 35.4875)),
  Branch("Kayseri Talas Şube", LatLng(38.7450, 35.5310)),
  Branch("Kayseri Melikgazi Şube", LatLng(38.7200, 35.5000)),
  Branch("Kayseri Kocasinan Şube", LatLng(38.7050, 35.4700)),
  Branch("Kayseri Erkilet Şube", LatLng(38.7320, 35.5200)),
];
