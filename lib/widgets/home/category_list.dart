import 'package:flutter/cupertino.dart';
import '../../../config/theme/theme.dart';
import '../../../services/category_service.dart';
import '../../../models/category.dart';
import '../../../pages/article/article_page.dart';


class CategoriesList extends StatelessWidget {
  const CategoriesList({super.key});

  IconData _getCategoryIcon(String iconName) {
    switch (iconName) {
      case 'book':
        return CupertinoIcons.book_fill;
      case 'heart':
        return CupertinoIcons.heart_fill;
      case 'chart':
        return CupertinoIcons.chart_bar_fill;
      case 'mosque':
        return CupertinoIcons.star_fill;
      default:
        return CupertinoIcons.circle_fill;
    }
  }

  void _onCategoryPressed(BuildContext context, Category category) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => ArticlePage(
          
          categoryId: category.id, 
          categoryName: category.name, 
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Category>>(
      future: CategoryService.getCategories(page: 1, limit: 10, activeOnly: true),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 100,
            child: Center(child: CupertinoActivityIndicator()),
          );
        } else if (snapshot.hasError) {
          return SizedBox(
            height: 100,
            child: const Center(child: Text('Connection Server error')),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox(
            height: 100,
            child: Center(child: Text('No categories')),
          );
        }

        final categories = snapshot.data!;

        return SizedBox(
          height: 100,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return Container(
                width: 80,
                margin: const EdgeInsets.only(right: 16),
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => _onCategoryPressed(context, category),
                  child: Column(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: CupertinoColors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: CupertinoColors.systemGrey.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Color(int.parse('0xFF${category.color.substring(1)}'))
                                  .withOpacity(0.15),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Icon(
                              _getCategoryIcon(category.icon.toLowerCase()),
                              color: Color(int.parse('0xFF${category.color.substring(1)}')),
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        category.name,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}