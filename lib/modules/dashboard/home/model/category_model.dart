
import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  final String catId;
  final String name;

  CategoryModel({required this.catId, required this.name});

  // Factory constructor to create a Category from a Firestore document
  factory CategoryModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return CategoryModel(
      catId: data['catId'] ?? '',
      name: data['name'] ?? '',
    );
  }

  // Method to convert Category to a Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'catId': catId,
      'name': name,
    };
  }
}