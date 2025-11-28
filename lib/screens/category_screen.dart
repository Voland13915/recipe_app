// category_screen
import 'package:flutter/material.dart';
import 'package:nutrition_app/screens/screens.dart';  // Изменён путь
import 'package:nutrition_app/utils/utils.dart';  // Изменён путь
import 'package:nutrition_app/widgets/widgets.dart';  // Изменён путь
import 'package:nutrition_app/custom_theme.dart';  // Изменён путь

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: GridView.builder(
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: 3 / 4,
            ),
            itemBuilder: (context, index) {
              final category = items[index];
              return InkWell(
                borderRadius: BorderRadius.circular(16.0),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RecipesScreen(),
                    settings: RouteSettings(arguments: category.category),
                  ),
                ),
                child: Material(
                  elevation: 3.0,
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.0),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ReusableNetworkImage(
                        imageUrl: category.image,
                        height: double.infinity,
                        width: double.infinity,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.05),
                              Colors.black.withOpacity(0.6),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 12.0,
                        right: 12.0,
                        bottom: 12.0,
                        child: Text(
                          category.category,
                          style: Theme.of(context)
                              .textTheme
                              .headlineLarge!
                              .copyWith(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
