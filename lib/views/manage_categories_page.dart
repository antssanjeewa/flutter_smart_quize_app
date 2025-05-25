import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quize_app/models/category.dart';
import 'package:quize_app/utils/theme.dart';
import 'package:quize_app/views/add_category_screen.dart';
import 'package:quize_app/views/manage_quizzes_page.dart';

class ManageCategoriesPage extends StatelessWidget {
  ManageCategoriesPage({super.key});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Manage Categories",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddCategoryScreen()),
              );
            },
            icon: Icon(Icons.add_circle_outline, color: AppTheme.primary),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('categories').orderBy('name').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error : ${snapshot.error}"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No Data"));
          }

          final categories =
              snapshot.data!.docs
                  .map(
                    (doc) => Category.fromMap(
                      doc.id,
                      doc.data() as Map<String, dynamic>,
                    ),
                  )
                  .toList();

          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return Card(
                margin: EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  leading: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withAlpha(50),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.category_outlined,
                      color: AppTheme.primary,
                    ),
                  ),
                  title: Text(
                    category.name,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Text(category.description),
                  trailing: PopupMenuButton(
                    itemBuilder:
                        (context) => [
                          PopupMenuItem(
                            value: "edit",
                            child: ListTile(
                              leading: Icon(Icons.edit),
                              dense: true,
                              title: Text("Edit"),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          PopupMenuItem(
                            value: "delete",
                            child: ListTile(
                              leading: Icon(
                                Icons.delete,
                                color: Colors.redAccent,
                              ),
                              dense: true,
                              title: Text("Delete"),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                    onSelected:
                        (value) => _handleQuizAction(context, value, category),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                ManageQuizzesPage(categoryId: category.id),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _handleQuizAction(
    BuildContext context,
    String value,
    Category category,
  ) async {
    if (value == "edit") {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AddCategoryScreen(category: category),
        ),
      );
    } else if (value == "delete") {
      final confirm = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text("Delete Quiz"),
              content: Text("Are you sure you want to delete this quiz?"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  child: Text(
                    "Delete",
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ),
              ],
            ),
      );
      if (confirm == true) {
        await _firestore.collection("categories").doc(category.id).delete();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Category Deleted Successfully"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
