import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/features/profile/presentation/components/common_radio_button.dart';
import 'package:kfon_subscriber/features/ticket/domain/entity/subject_entity.dart';
import 'package:kfon_subscriber/features/ticket/presentation/bloc/ticket_bloc.dart';
import 'package:kfon_subscriber/features/ticket/presentation/bloc/ticket_event.dart';
import 'package:kfon_subscriber/features/ticket/presentation/bloc/ticket_state.dart';
import 'package:kfon_subscriber/presentation/ui_component/common_search_field.dart';
import 'package:kfon_subscriber/presentation/ui_component/shimmer/list_shimmers.dart';

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
  void initState() {
    super.initState();
    // Load subjects if not already loaded
    widget.ticketBloc.add(const LoadSubjects());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TicketBloc, TicketState>(
      bloc: widget.ticketBloc,
      builder: (context, state) {
        List<SubjectEntity> subjects = [];
        bool isLoading = false;
        String? errorMessage;

        if (state is SubjectLoading) {
          isLoading = true;
        } else if (state is SubjectLoaded) {
          subjects = state.subjects;
        } else if (state is OnError) {
          errorMessage = state.errorMessage;
        }

        final filteredList =
            subjects
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
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Select subject',
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
                    onChanged: (query) {
                      setState(() {
                        searchQuery = query;
                      });
                    },
                    hintText: 'Select Subject',
                  ),
                if (!isLoading && errorMessage == null)
                  const SizedBox(height: 20),
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
                            widget.ticketBloc.add(const LoadSubjects());
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                else if (filteredList.isEmpty && searchQuery.isNotEmpty)
                  SizedBox(
                    height: (subjects.length * 56.0).clamp(0.0, 400.0),
                    child: const Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Text(
                          'No matching items found',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  )
                else if (subjects.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text('No subjects available'),
                  )
                else
                  SizedBox(
                    height: (subjects.length * 56.0).clamp(0.0, 400.0),
                    child: _buildSubjectList(subjects, filteredList),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubjectList(
    List<SubjectEntity> subjects,
    List<SubjectEntity> filteredList,
  ) {
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
