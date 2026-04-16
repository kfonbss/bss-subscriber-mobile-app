import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/features/profile/presentation/components/common_radio_button.dart';
import 'package:kfon_subscriber/features/ticket/domain/entity/subject_entity.dart';
import 'package:kfon_subscriber/features/ticket/presentation/bloc/ticket_bloc.dart';
import 'package:kfon_subscriber/features/ticket/presentation/bloc/ticket_event.dart';
import 'package:kfon_subscriber/features/ticket/presentation/bloc/ticket_state.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
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
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    widget.ticketBloc.add(const LoadSubjects());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.bssSubL10n;

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

        final filteredList = subjects
            .where(
              (subject) => subject.name.toLowerCase().contains(
                _searchQuery.toLowerCase(),
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
                Text(
                  l10n.selectSubject,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'GeneralSans',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                    color: AppColor.kTextSecondaryDark,
                  ),
                ),
                const SizedBox(height: 20),
                if (!isLoading && errorMessage == null)
                  CommonSearchField(
                    onChanged: (query) {
                      setState(() {
                        _searchQuery = query;
                      });
                    },
                    hintText: l10n.selectSubjectHint,
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
                          l10n.errorLoadingSubjects,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColor.kUrgentRed,
                            fontFamily: 'GeneralSans',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          errorMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColor.kSlateGrey,
                            fontFamily: 'GeneralSans',
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            widget.ticketBloc.add(const LoadSubjects());
                          },
                          child: Text(l10n.retry),
                        ),
                      ],
                    ),
                  )
                else if (filteredList.isEmpty && _searchQuery.isNotEmpty)
                  SizedBox(
                    height: (subjects.length * 56.0).clamp(0.0, 400.0),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Text(
                          l10n.noMatchingItemsFound,
                          style: const TextStyle(color: AppColor.kMediumGrey),
                        ),
                      ),
                    ),
                  )
                else if (subjects.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(l10n.noSubjectsAvailable),
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
              color: AppColor.kTextSecondaryDark,
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
