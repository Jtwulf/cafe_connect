// import 'package:cafe_connect/screens/order_screen/order_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';
import '../components/order_loader.dart';
import 'edit_order_page.dart';
// import 'order_lists/components/order_loader.dart';

class OrderListPage extends StatefulWidget {
  const OrderListPage({Key? key}) : super(key: key);

  @override
  _OrderListPageState createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> {
  Future<Map<String, Map<String, List<Map<String, dynamic>>>>>? _orderFuture;

  final Map<String, String> coffeeImages = {
    'コーヒー':
        'https://images.unsplash.com/photo-1634913564795-7825a3266590?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1740&q=80',
    'カフェオレ':
        'https://images.unsplash.com/photo-1484244619813-7dd17c80db4c?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1170&q=80',
    'ちょいふわ\nカフェオレ':
        'https://images.unsplash.com/photo-1666600638856-dc0fb01c01bc?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1740&q=80',
    'ふわふわ\nカフェオレ':
        'https://images.unsplash.com/photo-1585494156145-1c60a4fe952b?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=774&q=80',
    'アイスコーヒー\n（水出し）':
        'https://images.unsplash.com/photo-1499961024600-ad094db305cc?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1740&q=80',
    'アイスコーヒー\n(急冷式)':
        'https://images.unsplash.com/photo-1517959105821-eaf2591984ca?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1746&q=80',
    'アイス\nカフェオレ':
        'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1738&q=80',
    'アイス\nカフェオレ\n（ミルク多め）':
        'https://images.unsplash.com/photo-1553909489-ec2175ef3f52?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=930&q=80',
    'ソイラテ':
        'https://images.unsplash.com/photo-1608651057580-4a50b2fc2281?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=774&q=80',
    'アイスソイラテ':
        'https://images.unsplash.com/photo-1471691118458-a88597b4c1f5?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1740&q=80',
    '緑茶':
        'https://images.unsplash.com/photo-1627435601361-ec25f5b1d0e5?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1170&q=80',
    '緑茶（アイス）':
        'https://images.unsplash.com/photo-1455621481073-d5bc1c40e3cb?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1324&q=80',
  };

  @override
  void initState() {
    super.initState();
    _orderFuture = loadOrder();
  }

  Future<void> _refreshOrder() async {
    setState(() {
      _orderFuture = loadOrder();
    });
  }

  // 削除処理を行うメソッド
  Future<void> _deleteOrder(String name, String coffeeType, String time) async {
    CollectionReference orders =
        FirebaseFirestore.instance.collection('orders');
    QuerySnapshot querySnapshot = await orders.get();
    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      if (data['name'] == name &&
          data['coffeeType'] == coffeeType &&
          data['time'] == time) {
        doc.reference.delete();
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshOrder,
        child:
            FutureBuilder<Map<String, Map<String, List<Map<String, dynamic>>>>>(
          future: _orderFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              print(snapshot.error);
              return Center(child: Text('エラーが発生しました: ${snapshot.error}'));
            } else {
              Map<String, Map<String, List<Map<String, dynamic>>>> orders =
                  snapshot.data!;
              Map<String, Map<String, List<Map<String, dynamic>>>> ordersMap =
                  orders;
              return ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  String time = orders.keys.elementAt(index);
                  int totalOrdersAtThisTime = orders[time]!
                      .values
                      .fold(0, (prev, curr) => prev + curr.length);
                  return ExpansionTile(
                    collapsedIconColor: Colors.brown[800],
                    iconColor: Colors.brown[800],
                    title: Text(
                      '$time     $totalOrdersAtThisTime名',
                      style: TextStyle(
                        color: Colors.brown[800],
                        fontSize: 24,
                      ),
                    ),
                    children: orders[time]!.entries.map((entry) {
                      String coffeeType = entry.key;
                      List<Map<String, dynamic>> ordersList = entry.value;
                      return Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0,
                                  vertical: 4.0,
                                ),
                                child: Text(
                                  '$coffeeType     ${ordersList.length}名',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.brown[800],
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ],
                          ),
                          ...ordersList.map((order) {
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              elevation: 10,
                              margin: const EdgeInsets.symmetric(
                                vertical: 8.0,
                                horizontal: 16.0,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width: 80,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        image: DecorationImage(
                                          image: NetworkImage(
                                              coffeeImages[coffeeType] ?? ''),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 16.0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${order['name']}',
                                              style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.brown[700],
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  order['isIce'] ? '氷あり' : '',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.blue[300],
                                                  ),
                                                ),
                                                Text(
                                                  order['small'] ? '少なめ' : '',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.orange,
                                                  ),
                                                ),
                                                Text(
                                                  order['isSugar'] ? '砂糖' : '',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.red,
                                                  ),
                                                ),
                                                Text(
                                                  order['caramel']
                                                      ? 'キャラメル'
                                                      : '',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.purple,
                                                  ),
                                                ),
                                                Text(
                                                  order['isCondecensedMilk']
                                                      ? '練乳'
                                                      : '',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.blue,
                                                  ),
                                                ),
                                                Text(
                                                  order['isPickupOn4thFloor']
                                                      ? '4階受取'
                                                      : '',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.green,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.green[400],
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                        ),
                                        child: IconButton(
                                          icon: Icon(
                                            Icons.edit,
                                            color: Colors.white,
                                          ),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    EditOrderPage(
                                                  name: order['name'],
                                                  initialCoffeeType: coffeeType,
                                                  initialTime: time,
                                                  initialIsIce: order['isIce'],
                                                  initialIsSugar:
                                                      order['isSugar'],
                                                  initialCaramel:
                                                      order['caramel'],
                                                  initialIsCondecensedMilk:
                                                      order[
                                                          'isCondecensedMilk'],
                                                  initialSmall: order['small'],
                                                  initialIsPickupOn4thFloor:
                                                      order[
                                                          'isPickupOn4thFloor'],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.red[400],
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                        ),
                                        child: IconButton(
                                          icon: Icon(
                                            Icons.delete,
                                            color: Colors.white,
                                          ),
                                          onPressed: () async {
                                            // 確認ダイアログを表示
                                            final bool? result =
                                                await showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  title: Text("確認"),
                                                  content: Text(
                                                      "${order['name']}さんの注文を削除してもよろしいですか？"), // 注文者の名前を含む文言に変更
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.of(context)
                                                              .pop(false),
                                                      child: Text("キャンセル"),
                                                    ),
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.of(context)
                                                              .pop(true),
                                                      child: Text("削除"),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );

                                            // ユーザーが「削除」を選択した場合
                                            if (result == true) {
                                              await _deleteOrder(order['name'],
                                                  coffeeType, time);
                                              setState(() {
                                                ordersMap[time]![coffeeType]!
                                                    .remove(order);
                                                if (ordersMap[time]![
                                                        coffeeType]!
                                                    .isEmpty) {
                                                  ordersMap[time]!
                                                      .remove(coffeeType);
                                                  if (ordersMap[time]!
                                                      .isEmpty) {
                                                    ordersMap.remove(time);
                                                  }
                                                }
                                              });
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      );
                    }).toList(),
                  );
                },
              );
            }
          },
        ),
      ),

      // floatingActionButton: Padding(
      //   padding: const EdgeInsets.symmetric(horizontal: 20.0),
      //   child: Row(
      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //     children: [
      //       Padding(
      //         padding: const EdgeInsets.only(left: 20.0),
      //         child: FloatingActionButton(
      //           onPressed: () async {
      //             const url =
      //                 'https://calico-crowd-6dc.notion.site/93cb15b68f2443f3a7608d68b5afb83a?pvs=4';
      //             if (await canLaunch(url)) {
      //               await launch(url);
      //             } else {
      //               throw 'Could not launch $url';
      //             }
      //           },
      //           backgroundColor: Colors.brown[500],
      //           heroTag: null,
      //           child: Icon(Icons.mail),
      //         ),
      //       ),
      //       FloatingActionButton(
      //         onPressed: () {
      //           Navigator.popUntil(context, (route) => route.isFirst);
      //         },
      //         child: Icon(Icons.home),
      //         backgroundColor: Colors.brown[500],
      //         tooltip: 'ホームに戻る',
      //       )
      //     ],
      //   ),
      // ),
    );
  }
}