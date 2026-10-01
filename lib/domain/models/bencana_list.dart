class BencanaList {
  String name;
  String location;
  String description;
  String createdAt;
  String updatedAt;
  String nameReporter;
  String phoneNumber;
  String? id; //Dari string menjadi id dan berikan operator ?


  BencanaList (
    {
      required this.name,
      required this.location,
      required this.description,
      required this.createdAt,
      required this.updatedAt,
      required this.nameReporter,
      required this.phoneNumber,
      this.id, //Hapus required, karena id akan dibuat oleh database otomatis
    }
  );
}

