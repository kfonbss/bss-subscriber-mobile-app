import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/features/profile/presentation/components/common_radio_button.dart';
import 'package:kfon_subscriber/features/ticket/presentation/bloc/ticket_bloc.dart';
import 'package:kfon_subscriber/features/ticket/presentation/bloc/ticket_event.dart';
import 'package:kfon_subscriber/features/ticket/presentation/bloc/ticket_state.dart';
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
            child: const Text(
              'Add Note',
              style: TextStyle(
                fontFamily: 'GeneralSans',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColor.kTextSecondaryDark,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Visibility Selection
          const Text(
            'Visibility Permission',
            style: TextStyle(
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
                  children:
                      visibilities.map((option) {
                        final isSelected =
                            _selectedVisibilityCode == option.code;
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
                          color: Color(0xFFE53935),
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
                        child: const Text('Retry'),
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
          const Text(
            'Note',
            style: TextStyle(
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
              hintText: 'Enter your note here...',
              hintStyle: const TextStyle(
                color: AppColor.kTextSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                fontFamily: 'GeneralSans',
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColor.kPrimaryColor),
              ),
              errorText:
                  _noteController.text.isNotEmpty &&
                          _noteController.text.trim().length < 10
                      ? 'Remarks must be at least 10 characters'
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
            label: 'Save Note',
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
