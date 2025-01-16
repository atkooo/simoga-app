import 'package:flutter/material.dart';
import '../../../../core/widgets/search_field.dart';
import '../../../../model/food_nutrition.dart';
import '../../../../core/widgets/csv_parser.dart';
import 'food_details_dialog_search.dart';


class SearchFoodWidget extends StatefulWidget {
  final String childId;

  const SearchFoodWidget({super.key, required this.childId});

  @override
  _SearchFoodWidgetState createState() => _SearchFoodWidgetState();
}

class _SearchFoodWidgetState extends State<SearchFoodWidget> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  List<FoodNutrition> _allFoodItems = [];
  List<FoodNutrition> _filteredFoodItems = [];
  List<FoodNutrition> _displayedFoodItems = [];
  int _currentMax = 5;
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_filterFoodItems);
    _scrollController.addListener(_scrollListener);
  }

  Future<void> _loadData() async {
    CsvParser parser = CsvParser();
    List<FoodNutrition> foods =
        await parser.loadCsvData('assets/data_food/nutrition.csv');

    setState(() {
      _allFoodItems = foods;
      _filteredFoodItems = foods;
      _displayedFoodItems = _filteredFoodItems.take(_currentMax).toList();
    });
  }

  void _filterFoodItems() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredFoodItems = _allFoodItems
          .where((item) => item.name.toLowerCase().contains(query))
          .toList();
      _displayedFoodItems = _filteredFoodItems.take(_currentMax).toList();
    });
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoadingMore) {
      _loadMoreData();
    }
  }

  void _loadMoreData() {
    if (_displayedFoodItems.length < _filteredFoodItems.length) {
      setState(() {
        _isLoadingMore = true;
      });

      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _currentMax += 5;
          _displayedFoodItems = _filteredFoodItems.take(_currentMax).toList();
          _isLoadingMore = false;
        });
      });
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterFoodItems);
    _scrollController.removeListener(_scrollListener);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _showFoodDetailsDialog(
      BuildContext context, FoodNutrition nutrition) async {
    final result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return FoodDetailsDialog(
          nutrition: nutrition,
          weightController: _weightController,
          quantityController: _quantityController,
          initialShowChildChecklist: false,
          initialChildCheckList: {},
          childId: widget.childId, // Pass childId
        );
      },
    );

    if (result != null) {
      setState(() {
        // Update state based on result if needed
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SearchField(controller: _searchController),
            const SizedBox(height: 16),
            Text('Search Results',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount:
                    _displayedFoodItems.length + (_isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _displayedFoodItems.length) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  int idx = _allFoodItems.indexOf(_displayedFoodItems[index]);
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    elevation: 4,
                    shadowColor: Colors.grey.withOpacity(0.2),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      leading: CircleAvatar(
                        backgroundImage:
                            NetworkImage(_displayedFoodItems[index].image),
                        backgroundColor:
                            Colors.primaries[idx % Colors.primaries.length],
                      ),
                      title: Text(
                        _displayedFoodItems[index].name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                          'Kalori: ${_displayedFoodItems[index].calories} kkal'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        _showFoodDetailsDialog(
                            context, _displayedFoodItems[index]);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
