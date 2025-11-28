class Pharmacy {
  final int id;
  final String pharmacyName;
  final String address;
  final String phoneNumber;
  final String? email;
  final String? description;

  Pharmacy({
    required this.id,
    required this.pharmacyName,
    required this.address,
    required this.phoneNumber,
    this.email,
    this.description,
  });

  factory Pharmacy.fromJson(Map<String, dynamic> json) {
    return Pharmacy(
      id: json['id'] as int,
      pharmacyName: json['pharmacyName'] as String,
      address: json['address'] as String,
      phoneNumber: json['phoneNumber'] as String,
      email: json['email'] as String?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pharmacyName': pharmacyName,
      'address': address,
      'phoneNumber': phoneNumber,
      'email': email,
      'description': description,
    };
  }
}
