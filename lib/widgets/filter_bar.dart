import 'package:flutter/material.dart';

class FilterBar extends StatelessWidget {
  final List<String> categories;
  final String? selectedCategory;
  final ValueChanged<String?> onCategoryChanged;
  final Function(DateTime?, DateTime?) onDateRangeSelected;

  const FilterBar({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.onDateRangeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.green.shade50,
      child: Row(
        children: [
          // Category Filter
          Expanded(
            child: DropdownButtonFormField<String>(
              value: selectedCategory,
              hint: const Text("Category"),
              items: categories
                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                  .toList(),
              onChanged: onCategoryChanged,
            ),
          ),
          const SizedBox(width: 8),

          // Date Range Filter
          ElevatedButton.icon(
            onPressed: () async {
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                onDateRangeSelected(picked.start, picked.end);
              }
            },
            icon: const Icon(Icons.date_range),
            label: const Text("Date"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
