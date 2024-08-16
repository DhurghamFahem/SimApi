import 'package:flutter/material.dart';
import 'package:sim_api/models/sim_api_http_method.dart';
import 'package:sim_api/sim_api.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'SimApi Test'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _apiClient = SimApi<String>();
  List<ItemResponse> _data = [];
  final _newItemController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _seedData();
    _fetchData();
  }

  void _seedData() {
    _apiClient.registerRoute('/items');
    _apiClient.registerRoute(
      '/items',
      method: SimApiHttpMethod.patch,
      haveRouteParameters: true,
    );
    _apiClient.registerRoute(
      '/items',
      method: SimApiHttpMethod.delete,
      haveRouteParameters: true,
    );
    _apiClient.seedData('/items', {
      '1': ItemResponse(id: '1', name: 'Item 1').toJson(),
      '2': ItemResponse(id: '2', name: 'Item 2').toJson(),
      '3': ItemResponse(id: '3', name: 'Item 3').toJson(),
    });
  }

  Future<void> _fetchData() async {
    final response = await _apiClient.get(Uri.parse('items'));
    if (response.statusCode == 200) {
      setState(() {
        _data = (response.body as List)
            .map((e) => ItemResponse.fromJson(e))
            .toList();
      });
    }
  }

  void _createItem() async {
    final newItem = ItemRequest(name: _newItemController.text);
    await _apiClient.post(Uri.parse('items'), body: newItem.toJson());
    _newItemController.clear();
    _fetchData();
  }

  void _updateItem(String id) async {
    final updatedItem = ItemRequest(name: _newItemController.text);
    await _apiClient.patch(Uri.parse('items/$id'), body: updatedItem.toJson());
    _newItemController.clear();
    _fetchData();
  }

  void _deleteItem(String id) async {
    await _apiClient.delete(Uri.parse('items/$id'));
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SimApi Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _newItemController,
              decoration: const InputDecoration(
                labelText: 'New Item Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _createItem,
              child: const Text('Create Item'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _data.length,
                itemBuilder: (context, index) {
                  final item = _data[index];
                  final id = item.id;
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    elevation: 4,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16.0),
                      title: Text(
                        item.name,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _updateItem(id),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteItem(id),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ItemRequest {
  final String name;

  ItemRequest({required this.name});

  Map<String, dynamic> toJson() {
    return {'name': name};
  }
}

class ItemResponse {
  final String id;
  final String name;

  ItemResponse({required this.id, required this.name});

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }

  factory ItemResponse.fromJson(Map<String, dynamic> json) {
    return ItemResponse(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }
}
