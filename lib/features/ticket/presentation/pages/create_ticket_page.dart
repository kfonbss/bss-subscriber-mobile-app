import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/form_scroll_util.dart';
import 'package:kfon_subscriber/features/profile/presentation/profile/bloc/profile_bloc.dart';
import 'package:kfon_subscriber/features/profile/presentation/profile/bloc/profile_state.dart';
import 'package:kfon_subscriber/features/home/presentation/bloc/home_bloc.dart';
import 'package:kfon_subscriber/features/home/presentation/bloc/home_state.dart';
import 'package:kfon_subscriber/core/util/preference_util.dart';
import 'package:kfon_subscriber/features/profile/presentation/components/common_radio_button.dart';
import 'package:kfon_subscriber/features/ticket/data/model/submit_ticket_req.dart';
import 'package:kfon_subscriber/features/ticket/domain/entity/subject_entity.dart';
import 'package:kfon_subscriber/features/ticket/domain/repository/ticket_repository.dart';
import 'package:kfon_subscriber/core/validator/validators.dart';
import 'package:kfon_subscriber/features/ticket/presentation/bloc/ticket_bloc.dart';
import 'package:kfon_subscriber/features/ticket/presentation/bloc/ticket_event.dart';
import 'package:kfon_subscriber/features/ticket/presentation/bloc/ticket_state.dart';
import 'package:kfon_subscriber/features/ticket/presentation/widgets/subject_picker_sheet.dart';
import 'package:kfon_subscriber/features/ticket/presentation/widgets/priority_picker_sheet.dart';
import 'package:kfon_subscriber/features/ticket/presentation/widgets/attachment_list_widget.dart';
import 'package:kfon_subscriber/features/ticket/presentation/widgets/ticket_success_bottom_sheet.dart';
import 'package:kfon_subscriber/presentation/ui_component/attachment_upload_field.dart';
import 'package:kfon_subscriber/presentation/ui_component/common_app_bar.dart';
import 'package:kfon_subscriber/presentation/ui_component/common_bottom_sheet.dart';
import 'package:kfon_subscriber/presentation/ui_component/file_preview_page.dart';
import 'package:kfon_subscriber/presentation/ui_component/primary_button.dart';
import 'package:kfon_subscriber/service_locator.dart';
import 'package:kfon_subscriber/core/util/dialog_util.dart';
import 'package:kfon_subscriber/features/ticket/presentation/pages/tickets_page.dart';

class CreateTicketPage extends StatefulWidget {
  const CreateTicketPage({super.key});

  @override
  State<CreateTicketPage> createState() => _CreateTicketPageState();
}

class _CreateTicketPageState extends State<CreateTicketPage> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _priorityController = TextEditingController();
  final TextEditingController _subscriberController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  SubjectEntity? _selectedSubject;
  final List<PlatformFile> _selectedFiles = [];
  final TicketBloc _ticketBloc = TicketBloc(
    ticketRepository: sl<TicketRepository>(),
  );
  final DialogUtil _dialogUtil = DialogUtil();
  List<SubjectEntity> subjects = [];

  String _ticketCategory = 'COMPLAINT_REGISTRATION';
  String? _selectedPriorityCode;
  // SubscriberPickerItem? _selectedSubscriber;

  @override
  void initState() {
    super.initState();
    _ticketBloc.add(LoadSubjects());
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _subjectController.dispose();
    _priorityController.dispose();
    _subscriberController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['gif', 'jpg', 'jpeg', 'png', 'pdf', 'mp4'],
        allowMultiple: true,
      );

      if (result != null) {
        // final l10n = context.bssLNPL10n; // Removed as per instruction to hardcode localization
        bool hasTooLargeFile = false;

        for (final file in result.files) {
          if (file.path != null) {
            // Check file size (5MB = 5 * 1024 * 1024 bytes)
            if (file.size > 5 * 1024 * 1024) {
              hasTooLargeFile = true;
              continue;
            }
            if (!_selectedFiles.any((f) => f.path == file.path)) {
              _selectedFiles.add(file);
            }
          }
        }

        if (hasTooLargeFile && mounted) {
          _dialogUtil.showMessage('File size must be less than 5MB', context);
        }

        if (_selectedFiles.isNotEmpty) {
          _ticketBloc.add(const OnFileSelect());
          _formKey.currentState?.validate();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking file: $e')));
      }
    }
  }

  void _viewFile(PlatformFile file) {
    if (file.path == null) return;

    final String extension = file.extension ?? file.path!.split('.').last;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => FilePreviewPage(
              file: File(file.path!),
              fileName: file.name,
              fileExtension: extension,
            ),
      ),
    );
  }

  Widget _buildRadioButton(String label, String value) {
    final bool isSelected = _ticketCategory == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _ticketCategory = value;
        });
      },
      child: Row(
        mainAxisSize: MainAxisSize.min, // Ensure it takes minimum space
        children: [
          CommonRadioButton(isSelected: isSelected),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF4C4C4C),
              fontFamily: 'GeneralSans',
            ),
          ),
        ],
      ),
    );
  }

  void _showPriorityPicker() {
    showAppModalBottomSheet(
      context: context,
      isScrollControlled: false,
      builder:
          (context) => PriorityPickerSheet(
            ticketBloc: _ticketBloc,
            selectedPriority: _selectedPriorityCode,
            onPrioritySelected: (priority) {
              setState(() {
                _selectedPriorityCode = priority.code;
                _priorityController.text = priority.name;
              });
            },
          ),
    );
  }

  /*void _showSubscriberPicker() {
    showAppModalBottomSheet(
      context: context,
      isScrollControlled: false,
      builder: (context) => SubscriberPickerSheet(
        selectedSubscriberId: _selectedSubscriber?.id,
        onSubscriberSelected: (subscriber) {
          setState(() {
            _selectedSubscriber = subscriber;
            _subscriberController.text = subscriber.name;
          });
        },
      ),
    );
  }*/

  void _showSubjectPicker() {
    showAppModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeAreaScroll: false, // Prevents full-sheet scrolling
      builder:
          (context) => SubjectPickerSheet(
            ticketBloc: _ticketBloc,
            selectedSubjectId: _selectedSubject?.id,
            onSubjectSelected: (subject) {
              setState(() {
                _selectedSubject = subject;
                _subjectController.text = subject.name;
              });
            },
          ),
    );
  }

  Future<void> _submitTicket() async {
    if (_formKey.currentState?.validate() ?? false) {
      final customerType = 'SUBSCRIBERS';
      final profileState = context.read<ProfileBloc>().state;
      final homeState = context.read<HomeBloc>().state;
      String customerName = '';
      String customerId = '';

      if (profileState is ProfileLoaded) {
        customerName = profileState.profile.name;
      }

      if (homeState is GetDataSuccess) {
        customerId = homeState.homeEntity.subscriberId;
      } else if (profileState is ProfileLoaded) {
        // Fallback to integer ID if UUID from home is not available
        customerId = profileState.profile.subscriberId.toString();
      } else {
        customerId = await PreferenceUtils.getUserId() ?? '';
      }

      _ticketBloc.add(
        OnSubmitTicket(
          params: SubmitTicketReq(
            subjectId: _selectedSubject!.id,
            ticketCategory: _ticketCategory,
            priority: _selectedPriorityCode!,
            remarks: _descriptionController.text,
            customerType: customerType,
            customerId: customerId,
            customerName: customerName,
            subjectResolve: _selectedSubject!.escalationTime,
            files: _selectedFiles.isNotEmpty ? _selectedFiles : null,
          ),
        ),
      );
    } else {
      // Small delay to allow validation state to update before finding the widget
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted && _formKey.currentContext != null) {
          FormScrollUtil.scrollToFirstError(_formKey.currentContext!);
        }
      });
    }
  }

  void _showSuccessBottomSheet(String ticketId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Stack(
            children: [
              // Semi-transparent overlay
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {}, // Prevent dismissal on tap
                  child: Container(color: Colors.black.withOpacity(0.5)),
                ),
              ),
              // Bottom sheet content
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: TicketSuccessBottomSheet(
                  ticketId: ticketId,
                  onReturnHome: () {
                    Navigator.pop(context); // Close bottom sheet
                    Navigator.pop(
                      context,
                      true,
                    ); // Return to previous page with result
                  },
                  onViewTickets: () {
                    Navigator.pop(context); // Close bottom sheet
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TicketsPage(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TicketBloc, TicketState>(
      bloc: _ticketBloc,
      listenWhen:
          (context, state) =>
              state is OnError ||
              state is SubjectLoaded ||
              state is TicketSubmitted,
      listener: (context, state) {
        if (state is OnError) {
          _dialogUtil.showMessage(state.errorMessage, context);
        } else if (state is SubjectLoaded) {
          subjects = state.subjects;
        } else if (state is TicketSubmitted) {
          _showSuccessBottomSheet(state.respoEntity.ticketId);
        }
      },
      child: CommonAppBar(
        onBackPressed: () => Navigator.pop(context),
        title: 'Create Ticket',
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 50),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Ticket Category
                        Text(
                          'Ticket Category *',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0F1121),
                            height: 1.3,
                            fontFamily: 'GeneralSans',
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildRadioButton(
                              'Complaint Registration',
                              'COMPLAINT_REGISTRATION',
                            ),
                            const SizedBox(width: 24),
                            _buildRadioButton('Request', 'REQUEST'),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Select Subject Field
                        Text(
                          'Select Subject *',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0F1121),
                            height: 1.3,
                            fontFamily: 'GeneralSans',
                          ),
                        ),
                        const SizedBox(height: 12),
                        BlocBuilder<TicketBloc, TicketState>(
                          bloc: _ticketBloc,
                          buildWhen:
                              (previous, current) => current is SubjectSelected,
                          builder: (context, state) {
                            return TextFormField(
                              controller: _subjectController,
                              readOnly: true,
                              onTap: _showSubjectPicker,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              validator:
                                  (v) => Validators.validateRequired(
                                    v,
                                    fieldName: 'Select subject',
                                  ),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF0F1121),
                                fontFamily: 'GeneralSans',
                              ),
                              decoration: InputDecoration(
                                hintText: 'Select subject',
                                hintStyle: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFFA5A5A5),
                                  fontFamily: 'GeneralSans',
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                suffixIcon: const Icon(
                                  Icons.keyboard_arrow_down,
                                  color: Color(0xFF292D32),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Colors.red,
                                    width: 1,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        if (_selectedSubject != null) ...[
                          const SizedBox(height: 16),
                          // Resolved In Container
                          Container(
                            height: 52,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: CustomPaint(
                              painter: DashedBorderPainter(
                                color: AppColor.kPrimaryColor,
                                strokeWidth: 1.0,
                                dashWidth: 4.0,
                                dashSpace: 4.0,
                                borderRadius: 12.0,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    _selectedSubject?.escalationTime ?? '',
                                    style: const TextStyle(
                                      color: AppColor.kPrimaryColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'GeneralSans',
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),

                        // Select Priority Field
                        // Select Priority Field
                        Text(
                          'Select Priority *',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0F1121),
                            height: 1.3,
                            fontFamily: 'GeneralSans',
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _priorityController,
                          readOnly: true,
                          onTap: _showPriorityPicker,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator:
                              (v) => Validators.validateRequired(
                                v,
                                fieldName: 'Priority',
                              ),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF0F1121),
                            fontFamily: 'GeneralSans',
                          ),
                          decoration: InputDecoration(
                            hintText: 'Select Priority',
                            hintStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFFA5A5A5),
                              fontFamily: 'GeneralSans',
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            suffixIcon: const Icon(
                              Icons.keyboard_arrow_down,
                              color: Color(0xFF292D32),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Colors.red,
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        /*
                        // Select Subscriber Field
                        Text(
                          'Select Subscriber*', // Hardcoded localization
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0F1121),
                            height: 1.3,
                            fontFamily: 'GeneralSans',
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _subscriberController,
                          readOnly: true,
                          onTap: _showSubscriberPicker,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (v) => Validators.validateRequired(
                            v,
                            fieldName: 'Select Subscriber', // Hardcoded localization
                          ),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF0F1121),
                            fontFamily: 'GeneralSans',
                          ),
                          decoration: InputDecoration(
                            hintText: 'Select Subscriber', // Hardcoded localization
                            hintStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFFA5A5A5),
                              fontFamily: 'GeneralSans',
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            suffixIcon: const Icon(
                              Icons.keyboard_arrow_down,
                              color: Color(0xFF292D32),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Colors.red,
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
*/

                        // Remarks Field
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Remarks',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0F1121),
                                height: 1.3,
                                fontFamily: 'GeneralSans',
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: TextFormField(
                                controller: _descriptionController,
                                maxLines: 5,
                                minLines: 5,
                                textAlignVertical: TextAlignVertical.top,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                validator:
                                    (v) =>
                                        Validators.validateRequired(
                                          v,
                                          fieldName: 'Remarks',
                                        ) ??
                                        Validators.validateMinLength(
                                          v,
                                          10,
                                          fieldName: 'Remarks',
                                        ),
                                decoration: InputDecoration(
                                  hintText: 'Remarks',
                                  hintStyle: const TextStyle(
                                    color: Color(0xFF67697A),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    height: 1.6,
                                    fontFamily: 'GeneralSans',
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Colors.red,
                                      width: 1,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 15,
                                  ),
                                ),
                                style: const TextStyle(
                                  color: Color(0xFF262629),
                                  fontSize: 14,
                                  height: 1.6,
                                  fontFamily: 'GeneralSans',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Upload Attachment Field
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FormField<List<PlatformFile>>(
                              validator: (value) {
                                if (_selectedFiles.isEmpty) {
                                  return 'Please attach at least one document';
                                }
                                return null;
                              },
                              builder: (state) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AttachmentUploadField(
                                      label: 'Attachments *',
                                      onTap: _pickFile,
                                    ),
                                    if (state.hasError)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 8,
                                          left: 12,
                                        ),
                                        child: Text(
                                          state.errorText!,
                                          style: const TextStyle(
                                            color: Color(0xFFBA1A1A),
                                            fontSize: 12,
                                            fontFamily: 'GeneralSans',
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                            // Attached File List
                            const SizedBox(height: 12),
                            BlocBuilder<TicketBloc, TicketState>(
                              bloc: _ticketBloc,
                              buildWhen:
                                  (context, state) => state is FileSelected,
                              builder: (context, state) {
                                return AttachmentListWidget(
                                  selectedFiles: _selectedFiles,
                                  onViewFile: _viewFile,
                                  onDeleteFile: (file) {
                                    setState(() {
                                      _selectedFiles.remove(file);
                                      _ticketBloc.add(const OnFileSelect());
                                      _formKey.currentState?.validate();
                                    });
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // File Format Instructions
                        Text(
                          '*Please upload files in the following format :\nGIF, JPG, JPEG, PNG, PDF, MP4. The maximum allowed file\nsize is 5MB.',
                          style: const TextStyle(
                            color: Color(0xFF67697A),
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            height: 1.67,
                            fontFamily: 'GeneralSans',
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),

              // Submit Button (Fixed at bottom)
              Container(
                padding: const EdgeInsets.all(20),
                child: BlocBuilder<TicketBloc, TicketState>(
                  bloc: _ticketBloc,
                  buildWhen:
                      (previous, current) =>
                          current is TicketSubmitting ||
                          current is TicketSubmitted ||
                          current is OnError,
                  builder: (context, state) {
                    return PrimaryButton(
                      isLoading: state is TicketSubmitting,
                      label: 'Submit',
                      borderRadius: 10,
                      height: 52,
                      onClicked: _submitTicket,
                      textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                        fontFamily: 'GeneralSans',
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
