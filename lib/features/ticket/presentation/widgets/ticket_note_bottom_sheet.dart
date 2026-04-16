import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/features/profile/presentation/components/common_radio_button.dart';
import 'package:kfon_subscriber/features/ticket/presentation/bloc/ticket_bloc.dart';
import 'package:kfon_subscriber/features/ticket/presentation/bloc/ticket_event.dart';
import 'package:kfon_subscriber/features/ticket/presentation/bloc/ticket_state.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/presentation/ui_component/primary_button.dart';

class TicketNoteBottomSheet extends StatefulWidget {
  final Function(String note, String visibility) onSave;
  final TicketBloc ticketBloc;

  const TicketNoteBottomSheet({
    super.key,
    required this.onSave,
    required this.ticketBloc,
  });

  @override
  State<TicketNoteBottomSheet> createState() => _TicketNoteBottomSheetState();
}

class _TicketNoteBottomSheetState extends State<TicketNoteBottomSheet> {
  final TextEditingController _noteController = TextEditingController();
  String? _selectedVisibilityCode;

  @override
  void initState() {
    super.initState();
    _noteController.addListener(() {
      setState(() {});
    });
    widget.ticketBloc.add(const LoadVisibilityPermissions());
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.bssSubL10n;

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Center(
            child: Text(
              l10n.addNote,
              style: const TextStyle(
                fontFamily: 'GeneralSans',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColor.kTextSecondaryDark,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Visibility Selection
          Text(
            l10n.visibilityPermission,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColor.kTextSecondaryDark,
              fontFamily: 'GeneralSans',
            ),
          ),
          const SizedBox(height: 12),
          BlocBuilder<TicketBloc, TicketState>(
            bloc: widget.ticketBloc,
            builder: (context, state) {
              if (state is VisibilityLoading) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Center(
                    child: SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                );
              } else if (state is VisibilityLoaded) {
                final visibilities = state.visibilities;
                if (visibilities.isNotEmpty &&
                    _selectedVisibilityCode == null) {
                  _selectedVisibilityCode = visibilities.first.code;
                }
                return Row(
                  children: visibilities.map((option) {
                    final isSelected = _selectedVisibilityCode == option.code;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedVisibilityCode = option.code;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 24),
                        color: Colors.transparent,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CommonRadioButton(isSelected: isSelected),
                            const SizedBox(width: 8),
                            Text(
                              option.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: AppColor.kTextSecondary,
                                fontFamily: 'GeneralSans',
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              } else if (state is OnError) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        state.errorMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColor.kUrgentRed,
                          fontFamily: 'GeneralSans',
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          widget.ticketBloc.add(
                            const LoadVisibilityPermissions(),
                          );
                        },
                        child: Text(l10n.retry),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          const SizedBox(height: 24),

          // Note Input
          Text(
            l10n.note,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColor.kTextSecondaryDark,
              fontFamily: 'GeneralSans',
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _noteController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: l10n.enterYourNoteHere,
              hintStyle: const TextStyle(
                color: AppColor.kTextSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                fontFamily: 'GeneralSans',
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColor.kShimmerBase),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColor.kShimmerBase),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColor.kPrimaryColor),
              ),
              errorText:
              _noteController.text.isNotEmpty &&
                  _noteController.text.trim().length < 10
                  ? l10n.remarksMustBeAtLeast10Characters
                  : null,
              contentPadding: const EdgeInsets.all(16),
            ),
            style: const TextStyle(
              fontSize: 14,
              color: AppColor.kTextSecondaryDark,
              fontFamily: 'GeneralSans',
            ),
          ),
          const SizedBox(height: 24),

          // Submit Button
          PrimaryButton(
            label: l10n.saveNote,
            isLoading: false,
            borderRadius: 12,
            onClicked:
            _noteController.text.trim().length < 10 ||
                _selectedVisibilityCode == null
                ? null
                : () {
              widget.onSave(
                _noteController.text.trim(),
                _selectedVisibilityCode!,
              );
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
