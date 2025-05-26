import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:quize_app/models/category.dart';
import 'package:quize_app/models/quiz.dart';
import 'package:quize_app/utils/theme.dart';
import 'package:quize_app/views/user_quiz_screen.dart';

class UserCategoryScreen extends StatefulWidget {
  final Category category;
  const UserCategoryScreen({super.key, required this.category});

  @override
  State<UserCategoryScreen> createState() => _UserCategoryScreenState();
}

class _UserCategoryScreenState extends State<UserCategoryScreen> {
  List<Quiz> _quizzes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchQuizzes();
  }

  Future<void> _fetchQuizzes() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection("quizzes")
              .where('categoryId', isEqualTo: widget.category.id)
              .get();

      setState(() {
        _quizzes =
            snapshot.docs
                .map((doc) => Quiz.fromJson(doc.id, doc.data()))
                .toList();

        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error : $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          _isLoading
              ? Center(
                child: CircularProgressIndicator(color: AppTheme.primary),
              )
              : CustomScrollView(
                slivers: [
                  SliverAppBar(
                    foregroundColor: Colors.white,
                    backgroundColor: AppTheme.primary,
                    expandedHeight: 200,
                    floating: false,
                    pinned: true,
                    leading: IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      centerTitle: true,
                      title: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          widget.category.description,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ),
                      background: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.category_rounded,
                              size: 64,
                              color: Colors.white,
                            ),
                            SizedBox(height: 10),
                            Text(
                              widget.category.name,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  _quizzes.isEmpty
                      ? SliverToBoxAdapter(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(height: 80),
                              Icon(Icons.quiz_outlined, size: 64),
                              SizedBox(height: 10),
                              Text(
                                "No Quiz Available for this category",
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      )
                      : SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: _quizzes.length,
                            itemBuilder: (context, index) {
                              final quiz = _quizzes[index];
                              return _buildQuizCard(quiz, index);
                            },
                          ),
                        ),
                      ),
                ],
              ),
    );
  }

  Widget _buildQuizCard(Quiz quiz, int index) {
    return Card(
          elevation: 4,
          margin: EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserQuizScreen(quiz: quiz),
                ),
              );
            },
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withAlpha(50),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.quiz_rounded,
                      size: 32,
                      color: AppTheme.primary,
                    ),
                  ),

                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          quiz.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 35,
                    color: AppTheme.primary,
                  ),
                ],
              ),
            ),
          ),
        )
        .animate(delay: Duration(milliseconds: 100 * index))
        .slideX(begin: 0.5, end: 0, duration: Duration(milliseconds: 300))
        .fadeIn();
  }
}
