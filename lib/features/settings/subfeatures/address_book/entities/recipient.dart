class Recipient {
  Recipient({
    required this.id,
    required this.name,
    this.address,
    this.mns,
  });

  int id;
  String name;
  String? address;
  String? mns;
}
