import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quize_app/models/category.dart';
import 'package:quize_app/models/quiz.dart';
import 'package:quize_app/utils/theme.dart';
import 'package:quize_app/views/add_quiz_screen.dart';

class ManageQuizzesPage extends StatefulWidget {
  final String? categoryId;
  const ManageQuizzesPage({super.key, this.categoryId});

  @override
  State<ManageQuizzesPage> createState() => _ManageQuizzesPageState();
}

class _ManageQuizzesPageState extends State<ManageQuizzesPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = "";
  String? _selectCategoryId;
  List<Category> _categories = [];
  Category? _initialCategory;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final querySnapshot = await _firestore.collection("categories").get();
      final categories =
          querySnapshot.docs
              .map((doc) => Category.fromMap(doc.id, doc.data()))
              .toList();

      setState(() {
        _categories = categories;

        if (widget.categoryId != null) {
          _initialCategory = _categories.firstWhere(
            (category) => category.id == widget.categoryId,
            orElse:
                () => Category(
                  id: widget.categoryId!,
                  name: "unknown",
                  description: '',
                ),
          );
          _selectCategoryId = _initialCategory!.id;
        }
      });
    } catch (e) {
      print("Error Fetching Category: $e");
    }
  }

  Stream<QuerySnapshot> _getQuizStream() {
    Query query = _firestore.collection("quizzes");

    String? filterCategoryId = _selectCategoryId ?? widget.categoryId;

    if (filterCategoryId != null) {
      query = query.where("CategoryId", isEqualTo: filterCategoryId);
    }

    return query.snapshots();
  }

  Widget _buildTitle() {
    String? categoryId = _selectCategoryId ?? widget.categoryId;

    if (categoryId == null) {
      return Text("All Quizzes", style: TextStyle(fontWeight: FontWeight.bold));
    }

    return StreamBuilder(
      stream: _firestore.collection("categories").doc(categoryId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Text(
            "Loading....",
            style: TextStyle(fontWeight: FontWeight.bold),
          );
        }

        final category = Category.fromMap(
          categoryId,
          snapshot.data!.data() as Map<String, dynamic>,
        );

        return Text(
          category.name,
          style: TextStyle(fontWeight: FontWeight.bold),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildTitle(),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddQuizScreen()),
              );
            },
            icon: Icon(Icons.add_circle_outline, color: AppTheme.primary),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                fillColor: Colors.white,
                hintText: "Search Quizzes",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),

          Padding(
            padding: EdgeInsets.all(12),
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                fillColor: Colors.white,
                hintText: "Category",
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 18,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              value: _selectCategoryId,
              items: [
                DropdownMenuItem(child: Text("All Categories"), value: null),

                // if (_initialCategory != null)
                //   DropdownMenuItem(
                //     child: Text(_initialCategory!.name),
                //     value: _initialCategory!.id,
                //   ),
                ..._categories.map(
                  (category) => DropdownMenuItem(
                    value: category.id,
                    child: Text(category.name),
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectCategoryId = value;
                });
              },
            ),
          ),

          Expanded(
            child: StreamBuilder(
              stream: _getQuizStream(),
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

                final quizzes =
                    snapshot.data!.docs
                        .map(
                          (doc) => Quiz.fromJson(
                            doc.id,
                            doc.data() as Map<String, dynamic>,
                          ),
                        )
                        .where(
                          (quiz) =>
                              _searchQuery.isEmpty ||
                              quiz.title.toLowerCase().contains(_searchQuery),
                        )
                        .toList();

                return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: quizzes.length,
                  itemBuilder: (context, index) {
                    final quiz = quizzes[index];
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
                            Icons.quiz_rounded,
                            color: AppTheme.primary,
                          ),
                        ),
                        title: Text(
                          quiz.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          children: [
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.question_answer_outlined, size: 16),
                                SizedBox(width: 4),
                                Text("${quiz.questions.length} Questions"),
                                SizedBox(width: 4),
                                Icon(Icons.timer_outlined, size: 16),
                                SizedBox(width: 4),
                                Text("${quiz.timeLimit} mins"),
                              ],
                            ),
                          ],
                        ),
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
                              (value) =>
                                  _handleQuizAction(context, value, quiz),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleQuizAction(
    BuildContext context,
    String value,
    Quiz quiz,
  ) async {
    if (value == "edit") {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => AddQuizScreen(quiz: quiz)),
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
        await _firestore.collection("quizzes").doc(quiz.id).delete();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Quiz Deleted Successfully"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
