import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quize_app/utils/theme.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> _fetchStatistics() async {
    final categoryCount =
        await _firestore.collection('categories').count().get();
    final quizCount = await _firestore.collection('quizzes').count().get();
    final latestQuizzes =
        await _firestore
            .collection('quizzes')
            .orderBy('createdAt', descending: true)
            .limit(5)
            .get();

    final categories = await _firestore.collection('categories').limit(5).get();

    final categoryData = await Future.wait(
      categories.docs.map((category) async {
        final quizCount =
            await _firestore
                .collection('quizzes')
                .where('categoryId', isEqualTo: category.id)
                .count()
                .get();
        return {'name': category.data()['name'], 'count': quizCount.count};
      }),
    );

    return {
      'categoryCount': categoryCount.count,
      'quizCount': quizCount.count,
      'latestQuizzes': latestQuizzes.docs,
      'categoryData': categoryData,
    };
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildStateCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: color.withAlpha(50),
              ),
              child: Icon(icon, size: 25, color: color),
            ),
            SizedBox(height: 16),
            Text(
              value,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(title, style: TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppTheme.primary.withAlpha(50),
                ),
                child: Icon(icon, size: 32, color: AppTheme.primary),
              ),
              SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Admin Dashboard",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: FutureBuilder(
        future: _fetchStatistics(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            );
          }

          if (snapshot.hasError) {
            return Center(child: Text("Has Error"));
          }

          final Map<String, dynamic> stats = snapshot.data!;
          final List<dynamic> categoryData = stats['categoryData'];
          final List<QueryDocumentSnapshot> latestQuizzes =
              stats['latestQuizzes'];

          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome Admin",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Here's Your Quiz application overview",
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStateCard(
                          "Total Categories",
                          stats['categoryCount'].toString(),
                          Icons.category,
                          AppTheme.primary,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: _buildStateCard(
                          "Total Quizzes",
                          stats['quizCount'].toString(),
                          Icons.quiz_rounded,
                          AppTheme.secondary,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 24),

                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.pie_chart_rounded,
                                size: 24,
                                color: AppTheme.primary,
                              ),

                              SizedBox(width: 12),

                              Text(
                                "Category Statistics",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: categoryData.length,
                            itemBuilder: (context, index) {
                              return CategoryDetailsCard(
                                categoryData: categoryData,
                                index: index,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 20),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.history_rounded,
                                size: 24,
                                color: AppTheme.primary,
                              ),

                              SizedBox(width: 12),

                              Text(
                                "Recent Activity",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: latestQuizzes.length,
                            itemBuilder: (context, index) {
                              return HistoryDetailsCard(
                                data: latestQuizzes,
                                index: index,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.speed_rounded,
                                size: 24,
                                color: AppTheme.primary,
                              ),

                              SizedBox(width: 12),

                              Text(
                                "Quiz Actions",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.9,
                            crossAxisSpacing: 16,
                            children: [
                              _buildDashboardCard(
                                context,
                                "Quizzes",
                                Icons.quiz_rounded,
                                () {},
                              ),
                              _buildDashboardCard(
                                context,
                                "Categories",
                                Icons.category_rounded,
                                () {},
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class CategoryDetailsCard extends StatelessWidget {
  final List categoryData;
  final int index;

  const CategoryDetailsCard({
    super.key,
    required this.categoryData,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final category = categoryData[index];
    final totalQuizzes = categoryData.fold(
      0,
      (sum, item) => sum + (item['count'] as int),
    );

    final percentage =
        totalQuizzes > 0
            ? (category['count'] as int) / totalQuizzes * 100
            : 0.0;
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category['name'] as String,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                Text(
                  "${category['count']} ${(category['count'] as int) == 1 ? 'quiz' : 'quizzes'}",
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: AppTheme.primary.withAlpha(50),
            ),
            child: Text(
              '${percentage.toStringAsFixed(1)}%',
              style: TextStyle(fontSize: 12, color: AppTheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class HistoryDetailsCard extends StatelessWidget {
  final List data;
  final int index;

  const HistoryDetailsCard({
    super.key,
    required this.data,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final quiz = data[index].data();

    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: AppTheme.primary.withAlpha(50),
            ),
            child: Icon(Icons.quiz_rounded, color: AppTheme.primary, size: 20),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quiz['title'] as String,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  "Created on ${quiz['createdAt'].toString()}",
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
