import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quize_app/models/category.dart';
import 'package:quize_app/utils/theme.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  List<Category> _allCategories = [];
  List<Category> _filterCategories = [];

  List<String> _categoryFilter = ['All'];
  String _selectedFilter = "All";

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    final _snapshot = await _firestore.collection("categories").get();

    setState(() {
      _allCategories =
          _snapshot.docs
              .map((doc) => Category.fromMap(doc.id, doc.data()))
              .toList();

      _categoryFilter =
          ['All'] + _allCategories.map((category) => category.name).toList();

      _filterCategories = _allCategories;
    });
  }

  void _filterCategory(String query, {String? categoryFilter}) {
    setState(() {
      _filterCategories =
          _allCategories.where((category) {
            final matchesSearch =
                category.name.toLowerCase().contains(query.toLowerCase()) ||
                category.description.toLowerCase().contains(
                  query.toLowerCase(),
                );

            final matchCategory =
                categoryFilter == null ||
                categoryFilter == "All" ||
                category.name.toLowerCase().contains(query.toLowerCase());

            return matchCategory && matchesSearch;
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 225,
            pinned: true,
            floating: true,
            centerTitle: true,
            backgroundColor: AppTheme.primary,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            title: Text(
              "Smart Quiz",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: SafeArea(
                child: Column(
                  children: [
                    SizedBox(height: kToolbarHeight + 16),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Welcome, Learner!",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Let's Test your knowledge today!",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 16),

                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _searchController,
                              onChanged: (value) => _filterCategory(value),
                              decoration: InputDecoration(
                                hintText: "Search categories...",
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: AppTheme.primary,
                                ),
                                suffixIcon:
                                    _searchController.text.isNotEmpty
                                        ? IconButton(
                                          onPressed: () {
                                            _searchController.clear();
                                            _filterCategory('');
                                          },
                                          icon: Icon(Icons.clear),
                                          color: AppTheme.primary,
                                        )
                                        : null,
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              collapseMode: CollapseMode.pin,
            ),
          ),

          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.all(16),
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _categoryFilter.length,
                itemBuilder: (context, index) {
                  final filter = _categoryFilter[index];
                  return Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                        filter,
                        style: TextStyle(
                          color:
                              _selectedFilter == filter
                                  ? Colors.white
                                  : Colors.black,
                        ),
                      ),
                      selected: _selectedFilter == filter,
                      selectedColor: AppTheme.primary,
                      backgroundColor: Colors.white,
                      onSelected: (bool selected) {
                        setState(() {
                          _selectedFilter = filter;
                          _filterCategory(
                            _searchController.text,
                            categoryFilter: filter,
                          );
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ),

          SliverPadding(
            padding: EdgeInsets.all(16),
            sliver:
                _filterCategories.isEmpty
                    ? SliverToBoxAdapter(
                      child: Center(
                        child: Text(
                          "No Categories found",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                    : SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) =>
                            _buildCategoryCard(_filterCategories[index], index),
                        childCount: _filterCategories.length,
                      ),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.8,
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(Category category, int index) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {},
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withAlpha(50),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.quiz, size: 48, color: AppTheme.primary),
              ),

              SizedBox(height: 16),
              Text(
                category.name,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
