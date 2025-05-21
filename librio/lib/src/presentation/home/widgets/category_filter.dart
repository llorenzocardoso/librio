import 'package:flutter/material.dart';

class CategoryFilter extends StatelessWidget {
  final List<String> categories;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const CategoryFilter({
    Key? key,
    required this.categories,
    required this.selectedIndex,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = index == selectedIndex;
          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: FilterChip(
              label: Text(cat),
              labelStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.blue : Colors.grey,
              ),
              selected: isSelected,
              selectedColor: Colors.transparent,
              backgroundColor: Colors.transparent,
              side: BorderSide.none,
              shape: const StadiumBorder(),
              showCheckmark: false,
              onSelected: (selected) => onSelected(index),
            ),
          );
        },
      ),
    );
  }
}
