class BencanaList {
  String name;
  String location;
  String description;
  String createdAt;
  String updatedAt;
  String nameReporter;
  String phoneNumber;
  String? id;
  bool isSynced; // Tambahkan isSynced sebagai flag sinkronisasi
  bool isDeleted; // Tambahkan isSynced sebagai flag soft delete

  BencanaList({
    required this.name,
    required this.location,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.nameReporter,
    required this.phoneNumber,
    this.id,
    this.isSynced = false, // atur default false
    this.isDeleted = false, // atur default false
  });
}
