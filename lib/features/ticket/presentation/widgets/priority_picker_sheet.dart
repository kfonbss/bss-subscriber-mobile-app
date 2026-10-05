import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/features/ticket/domain/entity/priority_entity.dart';
import 'package:kfon_subscriber/features/ticket/presentation/bloc/ticket_bloc.dart';
import 'package:kfon_subscriber/features/ticket/presentation/bloc/ticket_event.dart';
import 'package:kfon_subscriber/features/ticket/presentation/bloc/ticket_state.dart';
import 'package:kfon_subscriber/shared/widgets/shimmer/list_shimmers.dart';
import 'package:kfon_subscriber/shared/widgets/common_radio_button.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';

class PriorityPickerSheet extends StatefulWidget {
  final String? selectedPriority;
  final Function(PriorityEntity) onPrioritySelected;
  final TicketBloc ticketBloc;

  const PriorityPickerSheet({
    super.key,
    this.selectedPriority,
    required this.onPrioritySelected,
    required this.ticketBloc,
  });

  @override
  State<PriorityPickerSheet> createState() => _PriorityPickerSheetState();
}

class _PriorityPickerSheetState extends State<PriorityPickerSheet> {
  @override
  void initState() {
    super.initState();
    // Load priorities if not already loaded
    widget.ticketBloc.add(const LoadPriorities());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TicketBloc, TicketState>(
      bloc: widget.ticketBloc,
      builder: (context, state) {
        List<PriorityEntity> priorities = [];
        bool isLoading = false;
        String? errorMessage;

        if (state is! TicketMasterDataState) {
          isLoading = true;
        } else if (state.prioritiesLoading) {
          isLoading = true;
        } else {
          priorities = state.priorities;
          errorMessage = state.prioritiesError;
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                context.bssSubL10n.selectPriorityKey,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'GeneralSans',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                  color: AppColor.kTextSecondaryDark,
                ),
              ),
              SizedBox(height: 30.h),
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
                        context.bssSubL10n.errorLoadingPriorities,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColor.kUrgentRed,
                          fontFamily: 'GeneralSans',
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        errorMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColor.kTextFiledPlaceholderColor,
                          fontFamily: 'GeneralSans',
                        ),
                      ),
                      SizedBox(height: 16.h),
                      ElevatedButton(
                        onPressed: () {
                          widget.ticketBloc.add(const LoadPriorities());
                        },
                        child: Text(context.bssSubL10n.retry),
                      ),
                    ],
                  ),
                )
              else if (priorities.isEmpty)
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text(context.bssSubL10n.noPrioritiesAvailable),
                )
              else
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 400),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: priorities.length,
                    itemBuilder: (context, index) {
                      final priority = priorities[index];
                      final isSelected =
                          widget.selectedPriority == priority.code;
                      return ListTile(
                        leading: CommonRadioButton(isSelected: isSelected),
                        title: Text(
                          priority.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppColor.kTextSecondaryDark,
                            fontFamily: 'GeneralSans',
                          ),
                        ),
                        onTap: () {
                          widget.onPrioritySelected(priority);
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
