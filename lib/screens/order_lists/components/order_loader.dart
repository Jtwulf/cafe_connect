import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<Map<String, Map<String, List<String>>>> loadOrder() async {
  CollectionReference orders = FirebaseFirestore.instance.collection('orders');
  Map<String, Map<String, List<String>>> ordersMap = SplayTreeMap();

  QuerySnapshot querySnapshot = await orders.get();
  for (var doc in querySnapshot.docs) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    String time = data['time'];
    String coffeeType = data['coffeeType'];
    String name = data['name'];
    if (ordersMap[time] == null) {
      ordersMap[time] = {};
    }
    if (ordersMap[time]![coffeeType] == null) {
      ordersMap[time]![coffeeType] = [];
    }
    ordersMap[time]![coffeeType]!.add(name);
  }

  return ordersMap;
}