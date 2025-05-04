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

    final categories = await _firestore.collection('categories').get();

    final categoryData = await Future.wait(
      categories.docs.map((category) async {
        final quizCount =
            await _firestore
                .collection('quizzes')
                .where('categoryId', isEqualTo: category.id)
                .count()
                .get();
        return {'name': category.data()['name'], 'quizzes': quizCount.count};
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
                  color: AppTheme.primary,
                ),
                child: Icon(icon, size: 32, color: AppTheme.primary),
              ),
              SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
