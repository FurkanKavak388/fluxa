enum ProductType {
  discountCoupon, 
  singleUseCode,   
}

class Product {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final int price; 
  final ProductType type;
  final Map<String, dynamic>? extraData;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.type,
    this.extraData,
  });

  factory Product.fromMap(Map<String, dynamic> map, String documentId) {
    return Product(
      id: documentId,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      price: map['price'] ?? 0,
      type: ProductType.values.firstWhere(
        (e) => e.toString() == 'ProductType.${map['type']}',
        orElse: () => ProductType.discountCoupon,
      ),
      extraData: Map<String, dynamic>.from(map['extraData'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'price': price,
      'type': type.toString().split('.').last,
      'extraData': extraData ?? {},
    };
  }
}
