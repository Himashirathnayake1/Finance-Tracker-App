import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../widgets/custom_text_field.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final amountController = TextEditingController();
  final descriptionController = TextEditingController();
  final dateController = TextEditingController();

  String? selectedCategory;
  String? selectedType;
  DateTime? selectedDate;

  bool _saving = false;

  final categories = ["Food", "Travel", "Salary", "Shopping", "Bills", "Other"];
  final types = ["Income", "Expense"];

  @override
  void dispose() {
    amountController.dispose();
    descriptionController.dispose();
    dateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 600),
            child: child!,
          ),
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        dateController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(
      context,
      listen: false,
    );

    return Scaffold(
      appBar: AppBar(title: const Text("Add Transaction"), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Amount
                CustomTextField(
                  controller: amountController,
                  label: "Amount",
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  icon: Icons.attach_money,
                ),

                // Category
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  items:
                      categories
                          .map(
                            (cat) =>
                                DropdownMenuItem(value: cat, child: Text(cat)),
                          )
                          .toList(),
                  decoration: InputDecoration(
                    labelText: "Category",
                    labelStyle: Theme.of(context).textTheme.labelLarge,
                    prefixIcon: const Icon(Icons.category),
                  ),
                  onChanged: (v) => setState(() => selectedCategory = v),
                  validator: (v) => v == null ? "Category is required" : null,
                ),

                // Date
                InkWell(
                  onTap: _pickDate,
                  child: IgnorePointer(
                    child: CustomTextField(
                      controller: dateController,
                      label: "Date",
                      icon: Icons.date_range,
                    ),
                  ),
                ),

                // Type
                DropdownButtonFormField<String>(
                  value: selectedType,
                  items:
                      types
                          .map(
                            (t) => DropdownMenuItem(value: t, child: Text(t)),
                          )
                          .toList(),
                  decoration: InputDecoration(
                    labelText: "Type",
                    labelStyle: Theme.of(context).textTheme.labelLarge,
                    prefixIcon: Icon(Icons.swap_vert),
                   
                  ),
                  onChanged: (v) => setState(() => selectedType = v),
                  validator: (v) => v == null ? "Type is required" : null,

                  
                ),

                // Description
                CustomTextField(
                  controller: descriptionController,
                  label: "Description (optional)",
                  icon: Icons.note,
                ),

                const SizedBox(height: 20),
                // Save button
                _saving
                    ? const Center(
                      child: CircularProgressIndicator(color: Colors.green),
                    )
                    : ElevatedButton(
                      onPressed: () async {
                        // Manual validation for CustomTextField
                        if (amountController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: const Text("Amount is required"),
                              backgroundColor: Colors.green[400],),
                          );
                          return;
                        }
                        if (double.tryParse(amountController.text.trim()) ==
                            null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                             SnackBar(
                              content: Text("Enter a valid number"),
                               backgroundColor: Colors.green[400],
                            ),
                          );
                          return;
                        }
                        if (_formKey.currentState!.validate() == false) return;
                        if (selectedDate == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Date is required"),
                              backgroundColor: Colors.green[400],
                            ),
                            
                          );
                          return;
                        }

                        setState(() => _saving = true);

                        final amount = double.parse(
                          amountController.text.trim(),
                        );
                        final error = await transactionProvider.addTransaction(
                          amount: amount,
                          category: selectedCategory!,
                          date: selectedDate!,
                          type: selectedType!,
                          description: descriptionController.text.trim(),
                        );

                        setState(() => _saving = false);

                        if (error != null) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(error)));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Transaction added successfully"),
                              backgroundColor: Colors.green[400],
                            ),
                          );
                          Navigator.pop(context);
                        }
                      },
                      child: const Text("Save Transaction"),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
