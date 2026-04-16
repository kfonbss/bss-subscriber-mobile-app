import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/dialog_util.dart';
import 'package:kfon_subscriber/core/util/form_scroll_util.dart';
import 'package:kfon_subscriber/core/util/preference_util.dart';
import 'package:kfon_subscriber/core/validator/validators.dart';
import 'package:kfon_subscriber/features/home/presentation/bloc/home_bloc.dart';
import 'package:kfon_subscriber/features/home/presentation/bloc/home_state.dart';
import 'package:kfon_subscriber/features/profile/presentation/components/common_radio_button.dart';
import 'package:kfon_subscriber/features/profile/presentation/profile/bloc/profile_bloc.dart';
import 'package:kfon_subscriber/features/profile/presentation/profile/bloc/profile_state.dart';
import 'package:kfon_subscriber/features/ticket/data/model/submit_ticket_req.dart';
import 'package:kfon_subscriber/features/ticket/domain/entity/subject_entity.dart';
import 'package:kfon_subscriber/features/ticket/domain/repository/ticket_repository.dart';
import 'package:kfon_subscriber/features/ticket/presentation/bloc/ticket_bloc.dart';
import 'package:kfon_subscriber/features/ticket/presentation/bloc/ticket_event.dart';
import 'package:kfon_subscriber/features/ticket/presentation/bloc/ticket_state.dart';
import 'package:kfon_subscriber/features/ticket/presentation/pages/tickets_page.dart';
import 'package:kfon_subscriber/features/ticket/presentation/widgets/attachment_list_widget.dart';
import 'package:kfon_subscriber/features/ticket/presentation/widgets/priority_picker_sheet.dart';
import 'package:kfon_subscriber/features/ticket/presentation/widgets/subject_picker_sheet.dart';
import 'package:kfon_subscriber/features/ticket/presentation/widgets/ticket_success_bottom_sheet.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/presentation/ui_component/attachment_upload_field.dart';
import 'package:kfon_subscriber/presentation/ui_component/common_app_bar.dart';
import 'package:kfon_subscriber/presentation/ui_component/common_bottom_sheet.dart';
import 'package:kfon_subscriber/presentation/ui_component/file_preview_page.dart';
import 'package:kfon_subscriber/presentation/ui_component/primary_button.dart';
import 'package:kfon_subscriber/service_locator.dart';

class CreateTicketPage extends StatefulWidget {
  const CreateTicketPage({super.key});

  @override
  State<CreateTicketPage> createState() => _CreateTicketPageState();
}

class _CreateTicketPageState extends State<CreateTicketPage> {
  // Shared across all three TextFormFields — avoids allocating 6 new
  // InputBorder objects on every build() call.
  static const _inputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(12)),
    borderSide: BorderSide.none,
  );
  static const _errorBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(12)),
    borderSide: BorderSide(color: AppColor.kFailedRed, width: 1),
  );

  // Subject escalation time container decoration.
  static const _escalationBoxDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(12)),
  );

  // 0.5 × 255 = 127.5 → 128 = 0x80
  static const _backdropColor = Color(0x80000000);
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

  String _ticketCategory = 'COMPLAINT_REGISTRATION';
  String? _selectedPriorityCode;

  @override
  void initState() {
    super.initState();
    _ticketBloc.add(const LoadSubjects());
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _subjectController.dispose();
    _priorityController.dispose();
    _subscriberController.dispose();
    _ticketBloc.close();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final l10n = context.bssSubL10n;
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['gif', 'jpg', 'jpeg', 'png', 'pdf', 'mp4'],
        allowMultiple: true,
      );

      if (result != null) {
        bool hasTooLargeFile = false;

        for (final file in result.files) {
          if (file.path != null) {
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
          _dialogUtil.showMessage(l10n.fileSizeMustBeLessThan5MB, context);
        }

        if (_selectedFiles.isNotEmpty) {
          _ticketBloc.add(const OnFileSelect());
          _formKey.currentState?.validate();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorPickingFile(e.toString()))),
        );
      }
    }
  }

  void _viewFile(PlatformFile file) {
    if (file.path == null) return;
    final String extension = file.extension ?? file.path!.split('.').last;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FilePreviewPage(
          file: File(file.path!),
          fileName: file.name,
          fileExtension: extension,
        ),
      ),
    );
  }

  Widget _buildRadioButton(String label, String value) {
    final isSelected = _ticketCategory == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _ticketCategory = value;
        });
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CommonRadioButton(isSelected: isSelected),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColor.kTextFiledLabelColor,
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
      builder: (context) => PriorityPickerSheet(
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

  void _showSubjectPicker() {
    showAppModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeAreaScroll: false,
      builder: (context) => SubjectPickerSheet(
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
      if (_selectedSubject == null || _selectedPriorityCode == null) return;
      final customerType = 'SUBSCRIBERS';
      final profileState = context.read<ProfileBloc>().state;
      final homeBloc = context.read<HomeBloc>();
      String customerName = '';
      String customerId = '';

      if (profileState is ProfileLoaded) {
        customerName = profileState.profile.name;
      }

      final homeState = homeBloc.state;
      if (homeState is GetDataSuccess) {
        customerId = homeState.homeEntity.subscriberId;
      } else if (profileState is ProfileLoaded) {
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
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () {},
              child: const ColoredBox(color: _backdropColor),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: TicketSuccessBottomSheet(
              ticketId: ticketId,
              onReturnHome: () {
                Navigator.pop(context);
                Navigator.pop(context, true);
              },
              onViewTickets: () {
                Navigator.pop(context);
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
    final l10n = context.bssSubL10n;

    return BlocListener<TicketBloc, TicketState>(
      bloc: _ticketBloc,
      listenWhen: (previous, current) =>
          current is OnError ||
          current is TicketSubmitted,
      listener: (context, state) {
        if (state is OnError) {
          _dialogUtil.showMessage(state.errorMessage, context);
        } else if (state is TicketSubmitted) {
          _showSuccessBottomSheet(state.respoEntity.ticketId);
        }
      },
      child: CommonAppBar(
        onBackPressed: () => Navigator.pop(context),
        title: l10n.createTicket,
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
                          l10n.ticketCategoryLabel,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColor.kTextSecondaryDark,
                            height: 1.3,
                            fontFamily: 'GeneralSans',
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildRadioButton(
                              l10n.complaintRegistration,
                              'COMPLAINT_REGISTRATION',
                            ),
                            const SizedBox(width: 24),
                            _buildRadioButton(l10n.request, 'REQUEST'),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Select Subject Field
                        Text(
                          l10n.selectSubjectLabel,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColor.kTextSecondaryDark,
                            height: 1.3,
                            fontFamily: 'GeneralSans',
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _subjectController,
                          readOnly: true,
                          onTap: _showSubjectPicker,
                          autovalidateMode:
                          AutovalidateMode.onUserInteraction,
                          validator: (v) => Validators.validateRequired(
                            v,
                            fieldName: l10n.selectSubjectHintText,
                          ),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppColor.kTextSecondaryDark,
                            fontFamily: 'GeneralSans',
                          ),
                          decoration: InputDecoration(
                            hintText: l10n.selectSubjectHintText,
                            hintStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: AppColor.kMediumGrey,
                              fontFamily: 'GeneralSans',
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            suffixIcon: const Icon(
                              Icons.keyboard_arrow_down,
                              color: AppColor.kNearBlack,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            border: _inputBorder,
                            errorBorder: _errorBorder,
                          ),
                        ),
                        if (_selectedSubject != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            height: 52,
                            width: double.infinity,
                            decoration: _escalationBoxDecoration,
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
                        Text(
                          l10n.selectPriorityLabel,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColor.kTextSecondaryDark,
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
                          validator: (v) => Validators.validateRequired(
                            v,
                            fieldName: l10n.selectPriorityHintText,
                          ),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppColor.kTextSecondaryDark,
                            fontFamily: 'GeneralSans',
                          ),
                          decoration: InputDecoration(
                            hintText: l10n.selectPriorityHintText,
                            hintStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: AppColor.kMediumGrey,
                              fontFamily: 'GeneralSans',
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            suffixIcon: const Icon(
                              Icons.keyboard_arrow_down,
                              color: AppColor.kNearBlack,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            border: _inputBorder,
                            errorBorder: _errorBorder,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Remarks Field
                        Text(
                          l10n.remarks,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColor.kTextSecondaryDark,
                            height: 1.3,
                            fontFamily: 'GeneralSans',
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 5,
                          minLines: 5,
                          textAlignVertical: TextAlignVertical.top,
                          autovalidateMode:
                          AutovalidateMode.onUserInteraction,
                          validator: (v) =>
                          Validators.validateRequired(
                            v,
                            fieldName: l10n.remarks,
                          ) ??
                              Validators.validateMinLength(
                                v,
                                10,
                                fieldName: l10n.remarks,
                              ),
                          decoration: InputDecoration(
                            hintText: l10n.remarksHint,
                            hintStyle: const TextStyle(
                              color: AppColor.kSlateGrey,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              height: 1.6,
                              fontFamily: 'GeneralSans',
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: _inputBorder,
                            errorBorder: _errorBorder,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 15,
                            ),
                          ),
                          style: const TextStyle(
                            color: AppColor.kNearBlack,
                            fontSize: 14,
                            height: 1.6,
                            fontFamily: 'GeneralSans',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Upload Attachment Field
                        FormField<List<PlatformFile>>(
                          validator: (value) {
                            if (_selectedFiles.isEmpty) {
                              return l10n.pleaseAttachAtLeastOneDocument;
                            }
                            return null;
                          },
                          builder: (state) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AttachmentUploadField(
                                  label: l10n.attachmentsLabel,
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
                                        color: AppColor.kFailedRed,
                                        fontSize: 12,
                                        fontFamily: 'GeneralSans',
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        BlocBuilder<TicketBloc, TicketState>(
                          bloc: _ticketBloc,
                          buildWhen: (_, current) =>
                              current is FileSelected,
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
                        const SizedBox(height: 12),

                        // File Format Instructions
                        Text(
                          l10n.fileFormatInstructions,
                          style: const TextStyle(
                            color: AppColor.kSlateGrey,
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

              // Submit Button — Padding is lighter than Container when there
              // is no decoration; avoids an unnecessary RenderObject layer.
              Padding(
                padding: const EdgeInsets.all(20),
                child: BlocBuilder<TicketBloc, TicketState>(
                  bloc: _ticketBloc,
                  buildWhen: (previous, current) =>
                  current is TicketSubmitting ||
                      current is TicketSubmitted ||
                      current is OnError,
                  builder: (context, state) {
                    return PrimaryButton(
                      isLoading: state is TicketSubmitting,
                      label: l10n.submit,
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
