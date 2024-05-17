import 'dart:convert';
import 'package:flutter/material.dart';
import 'items.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final String serverUrl = 'http://10.0.2.2:58006';

  final nameController = TextEditingController();

  Future<List<Item>> fetchItems() async {
    final response = await http.get(Uri.parse('$serverUrl/api/v1/items'));

    if (response.statusCode == 200) {
      final List<dynamic> itemList = jsonDecode(response.body);
      final List<Item> items = itemList.map((item) {
        return Item.fromJson(item);
      }).toList();
      return items;
    } else {
      throw Exception("Failed to fetch items");
    }
  }

  Future<Item> addItem(String name) async {
    final response = await http.post(Uri.parse('$serverUrl/api/v1/items'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'name': name}));

    if (response.statusCode == 201) {
      final dynamic json = jsonDecode(response.body);
      final Item item = Item.fromJson(json);
      return item;
    } else {
      throw Exception('Failed to add item');
    }
  }

  Future<void> updateItem(int id, String name) async {
    final response = await http.put(Uri.parse('$serverUrl/api/v1/items/$id'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'name': name}));

    if (response.statusCode != 200) {
      throw Exception("Failed to update item");
    }
  }

  Future<void> deleteItem(int id) async {
    final response =
    await http.delete(Uri.parse('$serverUrl/api/v1/items/$id'));

    if (response.statusCode != 200) {
      throw Exception("Failed to delete item");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: const Text('NodeJs with Flutter'),
        ),
        body: Column(
          children: [
            FutureBuilder(
                future: fetchItems(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                        shrinkWrap: true,
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final item = snapshot.data![index];
                          return Card(
                            elevation: 5,
                            child: ListTile(
                              title: Text(item.name),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () async {
                                      await deleteItem(item.id);
                                      setState(() {});
                                    },
                                    icon: const Icon(Icons.delete, color: Colors.amber,),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit,color: Colors.red, ),
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: const Text('Edit Item'),
                                              content: TextFormField(
                                                controller: nameController,
                                                decoration: const InputDecoration(
                                                  labelText: 'Item name',
                                                ),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    updateItem(item.id,
                                                        nameController.text);
                                                    setState(() {
                                                      nameController.clear();
                                                    });
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text('Edit'),
                                                ),
                                              ],
                                            );
                                          });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        });
                  } else if (snapshot.hasError) {
                    return Center(child: Text(snapshot.error.toString()));
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                })
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Add Item'),
                    content: TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Item name',
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          addItem(nameController.text);
                          setState(() {
                            nameController.clear();
                          });
                          Navigator.pop(context);
                        },
                        child: const Text('Add'),
                      ),
                    ],
                  );
                });
          },
          tooltip: 'Add Item',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}