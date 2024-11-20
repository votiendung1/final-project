import 'package:flutter/material.dart';
import 'package:food_delivery_app/models/restaurant.dart';
import 'package:food_delivery_app/pages/food_page.dart';
import 'package:provider/provider.dart';
import 'package:food_delivery_app/models/food.dart';

class SearchPage extends StatelessWidget {
  final String query;

  const SearchPage({Key? key, required this.query}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final restaurant = Provider.of<Restaurant>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Search Results')),
      body: FutureBuilder<List<Food>>(
        future: restaurant.searchFoods(query),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No results found.'));
          } else {
            final results = snapshot.data!;
            return ListView.builder(
              itemCount: results.length,
              itemBuilder: (context, index) {
                final food = results[index];
                return ListTile(
                  leading: Image.network(food.imagePath, width: 50),
                  title: Text(food.name),
                  subtitle: Text('${food.price.toString()} \$'),
                  onTap: () {
                    // Xử lý sự kiện khi chọn món
                    Navigator.push(context, MaterialPageRoute(builder: (context) => FoodPage(food: food)));
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
