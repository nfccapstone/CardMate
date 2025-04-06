class CardModel {
  String id;
  String name;
  String company;
  String position;
  String department;
  String? profileUrl;

  CardModel({
    required this.id,
    required this.name,
    required this.company,
    required this.position,
    required this.department,
    this.profileUrl,
  });

  factory CardModel.fromMap(Map<String, dynamic> map, String id) {
    return CardModel(
        name: map['name'],
        position: map['position'],
        department: map['department'],
        company: map['company'],
        id: id,
        profileUrl: map['profileUrl']);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'position': position,
      'department': department,
      'company': company,
      'id': id,
      'profileUrl': profileUrl,
    };
  }
}
