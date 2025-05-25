import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quize_app/models/category.dart';
import 'package:quize_app/models/question.dart';
import 'package:quize_app/models/quiz.dart';
import 'package:quize_app/utils/theme.dart';

class AddQuizScreen extends StatefulWidget {
  final Quiz? quiz;
  const AddQuizScreen({super.key, this.quiz});

  @override
  State<AddQuizScreen> createState() => _AddQuizScreenState();
}

class QuestionsFromItem {
  final TextEditingController questionController;
  final List<TextEditingController> optionsControllers;
  int correctOptionIndex;

  QuestionsFromItem({
    required this.questionController,
    required this.optionsControllers,
    required this.correctOptionIndex,
  });

  void dispose() {
    questionController.dispose();
    optionsControllers.forEach((el) {
      el.dispose();
    });
  }
}

class _AddQuizScreenState extends State<AddQuizScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _timeLimitController;
  bool _isLoading = false;
  String? _selectedCategoryId;
  List<QuestionsFromItem> _questionsItems = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.quiz!.title);
    _timeLimitController = TextEditingController(
      text: widget.quiz!.timeLimit.toString(),
    );
    _selectedCategoryId = widget.quiz!.categoryId;
    if (widget.quiz != null) {
      _questionsItems =
          widget.quiz!.questions.map((question) {
            return QuestionsFromItem(
              questionController: TextEditingController(text: question.text),
              correctOptionIndex: question.correctOptionIndex,
              optionsControllers:
                  question.options
                      .map((option) => TextEditingController(text: option))
                      .toList(),
            );
          }).toList();
    } else {
      _addQuestion();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _timeLimitController.dispose();
    for (var item in _questionsItems) {
      item.dispose();
    }
    super.dispose();
  }

  void _addQuestion() {
    setState(() {
      _questionsItems.add(
        QuestionsFromItem(
          questionController: TextEditingController(),
          optionsControllers: List.generate(4, (_) => TextEditingController()),
          correctOptionIndex: 0,
        ),
      );
    });
  }

  void _removeQuestion(int index) {
    setState(() {
      _questionsItems[index].dispose();
      _questionsItems.removeAt(index);
    });
  }

  Future<void> _saveQuiz() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please enter category"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final questions =
          _questionsItems.map((item) {
            return Question(
              text: item.questionController.text.trim(),
              options:
                  item.optionsControllers.map((option) {
                    return option.text.trim();
                  }).toList(),
              correctOptionIndex: item.correctOptionIndex,
            );
          }).toList();

      if (widget.quiz != null) {
        final updatedQuiz = widget.quiz!.copyWith(
          title: _titleController.text.trim(),
          timeLimit: int.parse(_timeLimitController.text.trim()),
          questions: questions,
        );

        await _firestore
            .collection("quizzes")
            .doc(widget.quiz?.id)
            .update(updatedQuiz.toJson());

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Quiz Updated Successfully"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        await _firestore
            .collection("quizzes")
            .add(
              Quiz(
                id: _firestore.collection("quizzes").doc().id,
                title: _titleController.text.trim(),
                categoryId: _selectedCategoryId!,
                questions: questions,
                timeLimit: int.parse(_timeLimitController.text.trim()),
                createdAt: DateTime.now(),
              ).toJson(),
            );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Quiz Added Successfully"),
            backgroundColor: AppTheme.secondary,
          ),
        );
      }

      Navigator.pop(context);
    } catch (e) {
      print("Error: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool> _onWillPop() async {
    if (_titleController.text.isNotEmpty ||
        _timeLimitController.text.isNotEmpty) {
      return await showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: Text("Discard Changes"),
                  content: Text("Are you sure you want to discard changes?"),
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
                      child: Text("Discard"),
                    ),
                  ],
                ),
          ) ??
          false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          final shouldPop = await _onWillPop();
          if (shouldPop) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.quiz != null ? "Edit Quiz" : "Add Quiz",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Quiz Details",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Create a new quiz for organizing your quizzes",
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),

                  SizedBox(height: 24),
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      labelText: "Quiz Name",
                      hintText: "Enter Quiz Name",
                      prefixIcon: Icon(Icons.title, color: AppTheme.primary),
                    ),
                    validator:
                        (value) => value!.isEmpty ? "Enter quiz title" : null,
                    textInputAction: TextInputAction.next,
                  ),

                  SizedBox(height: 24),

                  StreamBuilder(
                    stream: _firestore.collection("categories").snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator(); // or a placeholder Dropdown
                      }

                      if (!snapshot.hasData || snapshot.data == null) {
                        return const Text("No categories found"); // fallback UI
                      }

                      final categories =
                          snapshot.data!.docs
                              .map(
                                (doc) => Category.fromMap(doc.id, doc.data()),
                              )
                              .toList();

                      return DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          labelText: "Category",
                          hintText: "Category",
                          prefixIcon: Icon(
                            Icons.category_rounded,
                            color: AppTheme.primary,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 18,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        value: _selectedCategoryId,
                        items:
                            categories
                                .map(
                                  (category) => DropdownMenuItem(
                                    value: category.id,
                                    child: Text(category.name),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategoryId = value;
                          });
                        },
                        validator:
                            (val) =>
                                val == null ? "Please select a category" : null,
                      );
                    },
                  ),

                  SizedBox(height: 24),
                  TextFormField(
                    controller: _timeLimitController,
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      labelText: "Time Limit (in minutes)",
                      hintText: "Enter time limit",
                      prefixIcon: Icon(Icons.timer, color: AppTheme.primary),
                    ),
                    keyboardType: TextInputType.number,
                    validator:
                        (value) => value!.isEmpty ? "Enter time limit" : null,
                    textInputAction: TextInputAction.next,
                  ),

                  SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Questions",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          ElevatedButton.icon(
                            onPressed: _addQuestion,
                            label: Text("Add Question"),
                          ),
                        ],
                      ),

                      SizedBox(height: 16),
                      ..._questionsItems.asMap().entries.map((entity) {
                        final index = entity.key;
                        final QuestionsFromItem question = entity.value;

                        return Card(
                          margin: EdgeInsets.only(bottom: 16),
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Question ${index + 1}",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () => _removeQuestion(index),
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.redAccent,
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 16),
                                TextFormField(
                                  controller: question.questionController,
                                  decoration: InputDecoration(
                                    labelText: "Question Title",
                                    hintText: "Enter question",
                                    prefixIcon: Icon(
                                      Icons.question_answer,
                                      color: AppTheme.primary,
                                    ),
                                  ),
                                  validator:
                                      (value) =>
                                          value!.isEmpty
                                              ? "Enter question"
                                              : null,
                                  textInputAction: TextInputAction.next,
                                ),

                                SizedBox(height: 16),
                                ...question.optionsControllers
                                    .asMap()
                                    .entries
                                    .map((entity) {
                                      final optionIndex = entity.key;
                                      final controller = entity.value;
                                      return Padding(
                                        padding: EdgeInsets.only(bottom: 8),
                                        child: Row(
                                          children: [
                                            Radio<int>(
                                              value: optionIndex,
                                              groupValue:
                                                  question.correctOptionIndex,
                                              onChanged: (value) {
                                                setState(() {
                                                  question.correctOptionIndex =
                                                      value!;
                                                });
                                              },
                                            ),

                                            Expanded(
                                              child: TextFormField(
                                                controller: controller,
                                                decoration: InputDecoration(
                                                  labelText:
                                                      "Option ${optionIndex + 1}",
                                                  hintText: "Enter option",
                                                ),
                                                validator:
                                                    (value) =>
                                                        value!.isEmpty
                                                            ? "Enter option"
                                                            : null,
                                                textInputAction:
                                                    TextInputAction.next,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),

                  SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveQuiz,
                      child:
                          _isLoading
                              ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              )
                              : Text(
                                widget.quiz != null
                                    ? "Update Quiz"
                                    : "Add Quiz",
                                style: TextStyle(fontSize: 16),
                              ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
