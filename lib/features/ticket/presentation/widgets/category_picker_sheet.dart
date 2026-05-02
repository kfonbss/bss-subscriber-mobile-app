import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/features/ticket/domain/entity/ticket_category_entity.dart';
import 'package:kfon_subscriber/features/ticket/presentation/bloc/ticket_bloc.dart';
import 'package:kfon_subscriber/features/ticket/presentation/bloc/ticket_event.dart';
import 'package:kfon_subscriber/features/ticket/presentation/bloc/ticket_state.dart';
import 'package:kfon_subscriber/shared/widgets/common_radio_button.dart';
import 'package:kfon_subscriber/shared/widgets/shimmer/list_shimmers.dart';

class CategoryPickerSheet extends StatefulWidget {
  final String? selectedCategoryId;
  final Function(TicketCategoryEntity) onCategorySelected;
  final TicketBloc ticketBloc;

  const CategoryPickerSheet({
    super.key,
    this.selectedCategoryId,
    required this.onCategorySelected,
    required this.ticketBloc,
  });

  @override
  State<CategoryPickerSheet> createState() => _CategoryPickerSheetState();
}

class _CategoryPickerSheetState extends State<CategoryPickerSheet> {
  @override
  void initState() {
    super.initState();
    widget.ticketBloc.add(const LoadCategories());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TicketBloc, TicketState>(
      bloc: widget.ticketBloc,
      builder: (context, state) {
        List<TicketCategoryEntity> categories = [];
        bool isLoading = false;
        String? errorMessage;

        if (state is! TicketMasterDataState) {
          isLoading = true;
        } else if (state.categoriesLoading) {
          isLoading = true;
        } else {
          categories = state.categories;
          errorMessage = state.categoriesError;
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Select Category',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'GeneralSans',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                  color: Color(0xFF0F1121),
                ),
              ),
              const SizedBox(height: 30),
              if (isLoading)
                const ListShimmer(
                  itemCount: 4,
                  itemHeight: 50,
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 8),
                  separatorHeight: 12,
                )
              else if (errorMessage != null)
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Error loading categories',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFE53935),
                          fontFamily: 'GeneralSans',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        errorMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF67697A),
                          fontFamily: 'GeneralSans',
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          widget.ticketBloc.add(const LoadCategories());
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              else if (categories.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text('No categories available'),
                )
              else
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 400),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final isSelected =
                          widget.selectedCategoryId == category.id;
                      return ListTile(
                        leading: CommonRadioButton(isSelected: isSelected),
                        title: Text(
                          category.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF0F1121),
                            fontFamily: 'GeneralSans',
                          ),
                        ),
                        onTap: () {
                          widget.onCategorySelected(category);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
