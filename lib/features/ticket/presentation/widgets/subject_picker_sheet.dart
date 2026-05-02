import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/features/ticket/domain/entity/subject_entity.dart';
import 'package:kfon_subscriber/features/ticket/presentation/bloc/ticket_bloc.dart';
import 'package:kfon_subscriber/features/ticket/presentation/bloc/ticket_state.dart';
import 'package:kfon_subscriber/features/ticket/presentation/bloc/ticket_event.dart';
import 'package:kfon_subscriber/features/ticket/presentation/widgets/common_search_field.dart';
import 'package:kfon_subscriber/shared/widgets/common_radio_button.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/shared/widgets/shimmer/list_shimmers.dart';

class SubjectPickerSheet extends StatefulWidget {
  final TicketBloc ticketBloc;
  final String? selectedSubjectId;
  final Function(SubjectEntity) onSubjectSelected;

  const SubjectPickerSheet({
    super.key,
    required this.ticketBloc,
    this.selectedSubjectId,
    required this.onSubjectSelected,
  });

  @override
  State<SubjectPickerSheet> createState() => _SubjectPickerSheetState();
}

class _SubjectPickerSheetState extends State<SubjectPickerSheet> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final l10n = context.bssSubL10n;
    final Size screenSize = MediaQuery.of(context).size;
    final double sheetHeight = (screenSize.height * 0.75).clamp(360.0, 720.0);

    return BlocBuilder<TicketBloc, TicketState>(
      bloc: widget.ticketBloc,
      builder: (context, state) {
        List<SubjectEntity> subjects = [];
        bool isLoading = false;
        String? errorMessage;

        if (state is! TicketMasterDataState) {
          isLoading = true;
        } else if (state.subjectsLoading) {
          isLoading = true;
        } else {
          subjects = state.subjects;
          errorMessage = state.subjectsError;
        }

        final filteredList = subjects
            .where(
              (subject) => subject.name.toLowerCase().contains(
                searchQuery.toLowerCase(),
              ),
            )
            .toList();

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SizedBox(
            width: double.infinity,
            height: sheetHeight,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    l10n.selectSubject,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'GeneralSans',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                      color: Color(0xFF0F1121),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (!isLoading && errorMessage == null)
                    // Search Bar - only show when not loading or in error state
                    CommonSearchField(
                      onChanged: (val) {
                        setState(() {
                          searchQuery = val;
                        });
                      },
                      hintText: 'Search Subject',
                    ),
                  if (!isLoading && errorMessage == null) const SizedBox(height: 20),
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        if (isLoading) {
                          return const ListShimmer(
                            itemCount: 4,
                            itemHeight: 50,
                            padding: EdgeInsets.symmetric(
                              vertical: 20,
                              horizontal: 8,
                            ),
                            separatorHeight: 12,
                          );
                        }

                        if (errorMessage != null) {
                          return Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Error loading subjects',
                                  style: const TextStyle(
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
                                    final master = state is TicketMasterDataState
                                        ? state
                                        : null;
                                    final categoryId =
                                        master?.selectedCategory?.id;
                                    if (categoryId == null) return;

                                    widget.ticketBloc.add(
                                      LoadSubjects(categoryId: categoryId),
                                    );
                                  },
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          );
                        }

                        if (filteredList.isEmpty && searchQuery.isNotEmpty) {
                          return const Align(
                            alignment: Alignment.topCenter,
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 32),
                              child: Text(
                                'No matching items found',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          );
                        }

                        if (subjects.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: Text('No subjects available'),
                            ),
                          );
                        }

                        // Always keep a stable sheet height; the list scrolls internally.
                        return _buildSubjectList(filteredList);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubjectList(List<SubjectEntity> filteredList) {
    return ListView.builder(
      shrinkWrap: false,
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        final subject = filteredList[index];
        final isSelected = widget.selectedSubjectId == subject.id;
        return ListTile(
          leading: CommonRadioButton(isSelected: isSelected),
          title: Text(
            subject.name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF0F1121),
              fontFamily: 'GeneralSans',
            ),
          ),
          onTap: () {
            widget.ticketBloc.add(OnSubjectSelect(subject: subject));
            widget.onSubjectSelected(subject);
            Navigator.pop(context);
          },
        );
      },
    );
  }
}
