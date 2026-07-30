class AssetModel {
  final int id;
  final String name;
  final String? assetTag;
  final String? serialNumber;
  final String? model;
  final String? brand;
  final String? type;
  final String? purchaseDate;
  final String? warrantyExpiry;
  final String status;
  final String? assignedToName;
  final String? assignedDate;

  const AssetModel({
    required this.id,
    required this.name,
    this.assetTag,
    this.serialNumber,
    this.model,
    this.brand,
    this.type,
    this.purchaseDate,
    this.warrantyExpiry,
    required this.status,
    this.assignedToName,
    this.assignedDate,
  });

  factory AssetModel.fromJson(Map<String, dynamic> json) {
    return AssetModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      assetTag: json['assetTag']?.toString(),
      serialNumber: json['serialNumber']?.toString(),
      model: json['model']?.toString(),
      brand: json['brand']?.toString(),
      type: json['type']?.toString(),
      purchaseDate: json['purchaseDate']?.toString(),
      warrantyExpiry: json['warrantyExpiry']?.toString(),
      status: json['status']?.toString() ?? 'AVAILABLE',
      assignedToName: json['assignedToName']?.toString(),
      assignedDate: json['assignedDate']?.toString(),
    );
  }
}
