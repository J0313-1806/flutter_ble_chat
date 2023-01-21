class Device {
  final String id;
  final String name;
  final String serviceId;

  bool isConnected;

  Device(
      {required this.id,
      required this.name,
      required this.serviceId,
      required this.isConnected});
}
