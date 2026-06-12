import 'dart:io';

import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/preference_util.dart';
import 'package:kfon_subscriber/features/ticket/data/model/submit_ticket_req.dart';
import 'package:kfon_subscriber/features/ticket/domain/entity/subject_entity.dart';
import 'package:kfon_subscriber/features/ticket/domain/entity/ticket_category_entity.dart';
import 'package:kfon_subscriber/features/ticket/domain/repository/ticket_repository.dart';
import 'package:kfon_subscriber/core/validator/validators.dart';
import 'package:kfon_subscriber/features/ticket/presentation/bloc/ticket_bloc.dart';
import 'package:kfon_subscriber/features/ticket/presentation/bloc/ticket_event.dart';
import 'package:kfon_subscriber/features/ticket/presentation/bloc/ticket_state.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/shared/widgets/attachment_upload_field.dart';
import 'package:kfon_subscriber/shared/widgets/common_app_bar.dart';
import 'package:kfon_subscriber/shared/widgets/common_bottom_sheet.dart';
import 'package:kfon_subscriber/shared/widgets/common_radio_button.dart';
import 'package:kfon_subscriber/shared/widgets/file_preview_page.dart';
import 'package:kfon_subscriber/core/util/form_scroll_util.dart';
import 'package:kfon_subscriber/features/ticket/presentation/widgets/subject_picker_sheet.dart';
import 'package:kfon_subscriber/features/ticket/presentation/widgets/priority_picker_sheet.dart';
import 'package:kfon_subscriber/features/ticket/presentation/widgets/attachment_list_widget.dart';
import 'package:kfon_subscriber/features/ticket/presentation/widgets/ticket_success_bottom_sheet.dart';
import 'package:kfon_subscriber/shared/widgets/primary_button.dart';
import 'package:kfon_subscriber/service_locator.dart';
import 'package:kfon_subscriber/core/util/dialog_util.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/shared/widgets/shimmer/shimmer_base.dart';

class CreateTicketPage extends StatefulWidget {
  const CreateTicketPage({super.key});

  @override
  State<CreateTicketPage> createState() => _CreateTicketPageState();
}

const int _kTicketRemarksMaxLength = 500;

class _CreateTicketPageState extends State<CreateTicketPage> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _priorityController = TextEditingController();
  final TextEditingController _subscriberController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<FormFieldState<String>> _remarksFormFieldKey =
      GlobalKey<FormFieldState<String>>();
  SubjectEntity? _selectedSubject;
  final List<PlatformFile> _selectedFiles = [];
  final TicketBloc _ticketBloc = TicketBloc(
    ticketRepository: sl<TicketRepository>(),
  );
  final DialogUtil _dialogUtil = DialogUtil();
  TicketCategoryEntity? _selectedCategory;
  String? _selectedPriorityCode;

  /// Toggle category UI style without removing the old implementation.
  /// When `true`: dropdown field + bottom sheet (radio inside).
  /// When `false`: inline radio selection (old UI).
  bool useCategoryDropdown = true;

  // SubscriberPickerItem? _selectedSubscriber;

  bool _isAllowedCategory(TicketCategoryEntity category) {
    String normalize(String value) =>
        value.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

    final normalizedName = normalize(category.name);
    final normalizedLocalName = normalize(category.nameInLocal);
    final normalizedCode = normalize(category.code);

    bool isComplaintRegistration(String value) =>
        value.contains('complaintregistration') ||
        (value.contains('complaint') && value.contains('registration')) ||
        value == 'complaint' ||
        value.contains('complaint');
    bool isRequest(String value) =>
        value == 'request' || value.contains('request');

    return isComplaintRegistration(normalizedName) ||
        isComplaintRegistration(normalizedLocalName) ||
        isComplaintRegistration(normalizedCode) ||
        isRequest(normalizedName) ||
        isRequest(normalizedLocalName) ||
        isRequest(normalizedCode);
  }

  String _categoryLabel(TicketCategoryEntity category) {
    final name = category.name.trim();
    final localName = category.nameInLocal.trim();
    if (name.isNotEmpty) return name;
    if (localName.isNotEmpty) return localName;
    return '-';
  }

  @override
  void initState() {
    super.initState();
    // Determine customer type code based on user role
    final customerTypeCode = 'SUBSCRIBERS';
    _ticketBloc.add(LoadCustomerTypeId(code: customerTypeCode));
    _ticketBloc.add(const LoadCategories());
    _descriptionController.addListener(_syncRemarksFormField);
  }

  void _syncRemarksFormField() {
    _remarksFormFieldKey.currentState?.didChange(_descriptionController.text);
  }

  @override
  void dispose() {
    _descriptionController.removeListener(_syncRemarksFormField);
    _descriptionController.dispose();
    _subjectController.dispose();
    _categoryController.dispose();
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
        final l10n = context.bssSubL10n;
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
          _dialogUtil.showMessage(l10n.fileSizeMustBeLess, context);
        }

        if (_selectedFiles.isNotEmpty) {
          _ticketBloc.add(const OnFileSelect());
          _formKey.currentState?.validate();
        }
      }
    } catch (e) {
      if (mounted) {
        final l10n = context.bssSubL10n;
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
        builder:
            (context) => FilePreviewPage(
              file: File(file.path!),
              fileName: file.name,
              fileExtension: extension,
            ),
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
    if (_selectedCategory == null) {
      _dialogUtil.showMessage(
        '${context.bssSubL10n.selectCategory} first.',
        context,
      );
      return;
    }

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
      // Get the resolved customerTypeId UUID from master state
      final masterState = _ticketBloc.state;
      final customerTypeId =
          masterState is TicketMasterDataState
              ? masterState.customerTypeId
              : null;

      if (customerTypeId == null) {
        _dialogUtil.showMessage(
          'Customer type could not be resolved. Please try again.',
          context,
        );
        return;
      }
      //
      final customerId = await PreferenceUtils.getUserId() ?? '';
      final customerName = await PreferenceUtils.getUserName() ?? '';

      _ticketBloc.add(
        OnSubmitTicket(
          params: SubmitTicketReq(
            subjectId: _selectedSubject!.id,
            ticketCategory: _selectedCategory!.id,
            // priority: _selectedPriorityCode!,
            remarks: _descriptionController.text,
            customerType: customerTypeId,
            // ← resolved UUID
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
                  child: Container(color: Colors.black.withValues(alpha: 0.5)),
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
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.bssSubL10n;
    return MultiBlocListener(
      listeners: [
        BlocListener<TicketBloc, TicketState>(
          bloc: _ticketBloc,
          listenWhen:
              (context, state) => state is OnError || state is TicketSubmitted,
          listener: (context, state) {
            if (state is OnError) {
              _dialogUtil.showMessage(state.errorMessage, context);
            } else if (state is TicketSubmitted) {
              _showSuccessBottomSheet(state.respoEntity.ticketId);
            }
          },
        ),
        BlocListener<TicketBloc, TicketState>(
          bloc: _ticketBloc,
          listenWhen: (previous, current) => current is TicketMasterDataState,
          listener: (context, state) {
            if (state is! TicketMasterDataState) return;
            if (_selectedCategory != null) return;

            final allowedCategories =
                useCategoryDropdown
                    ? state.categories.toList(growable: false)
                    : state.categories
                        .where(_isAllowedCategory)
                        .toList(growable: false);

            if (allowedCategories.isEmpty) return;

            // Default selection: prevents "subjects not available"
            // because issue-types API needs `categoryId`.
            final defaultCategory = allowedCategories.first;
            setState(() {
              _selectedCategory = defaultCategory;
              _categoryController.text = _categoryLabel(defaultCategory);
              _selectedSubject = null;
              _subjectController.clear();
            });
            _ticketBloc.add(OnCategorySelect(category: defaultCategory));
          },
        ),
      ],
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
                          '${l10n.ticketCategory}*',
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
                              (previous, current) =>
                                  current is TicketMasterDataState,
                          builder: (context, state) {
                            final masterData =
                                state is TicketMasterDataState
                                    ? state
                                    : const TicketMasterDataState();
                            final categories =
                                useCategoryDropdown
                                    ? masterData.categories.toList()
                                    : masterData.categories
                                        .where(_isAllowedCategory)
                                        .toList();
                            return FormField<TicketCategoryEntity>(
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              validator:
                                  (value) => Validators.validateRequired(
                                    _selectedCategory?.id,
                                    fieldName: l10n.ticketCategory,
                                  ),
                              builder: (fieldState) {
                                final showCategoryShimmer =
                                    masterData.categoriesLoading &&
                                    categories.isEmpty;

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (showCategoryShimmer)
                                      (useCategoryDropdown
                                          ? const _CategoryDropdownSkeleton()
                                          : const Row(
                                            children: [
                                              Expanded(
                                                child: _CategoryRadioSkeleton(),
                                              ),
                                              SizedBox(width: 24),
                                              Expanded(
                                                child: _CategoryRadioSkeleton(),
                                              ),
                                            ],
                                          ))
                                    else if (useCategoryDropdown)
                                      InkWell(
                                        onTap: () {
                                          if (categories.isEmpty) {
                                            _dialogUtil.showMessage(
                                              l10n.noDataFound,
                                              context,
                                            );
                                            return;
                                          }
                                          showAppModalBottomSheet<void>(
                                            context: context,
                                            isScrollControlled: true,
                                            useSafeAreaScroll: true,
                                            builder: (ctx) {
                                              return Container(
                                                width: double.infinity,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 20,
                                                    ),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      l10n.selectCategory,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: const TextStyle(
                                                        fontFamily:
                                                            'GeneralSans',
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        height: 1.4,
                                                        color: Color(
                                                          0xFF0F1121,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 30),
                                                    ConstrainedBox(
                                                      constraints:
                                                          const BoxConstraints(
                                                            maxHeight: 400,
                                                          ),
                                                      child: ListView.builder(
                                                        shrinkWrap: true,
                                                        itemCount:
                                                            categories.length,
                                                        itemBuilder: (
                                                          context,
                                                          index,
                                                        ) {
                                                          final category =
                                                              categories[index];
                                                          final isSelected =
                                                              _selectedCategory
                                                                  ?.id ==
                                                              category.id;
                                                          return ListTile(
                                                            leading:
                                                                CommonRadioButton(
                                                                  isSelected:
                                                                      isSelected,
                                                                ),
                                                            title: Text(
                                                              _categoryLabel(
                                                                category,
                                                              ),
                                                              style: const TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                color: Color(
                                                                  0xFF0F1121,
                                                                ),
                                                                fontFamily:
                                                                    'GeneralSans',
                                                              ),
                                                            ),
                                                            onTap: () {
                                                              setState(() {
                                                                _selectedCategory =
                                                                    category;
                                                                _categoryController
                                                                        .text =
                                                                    _categoryLabel(
                                                                      category,
                                                                    );
                                                                _selectedSubject =
                                                                    null;
                                                                _subjectController
                                                                    .clear();
                                                              });
                                                              fieldState
                                                                  .didChange(
                                                                    category,
                                                                  );
                                                              _ticketBloc.add(
                                                                OnCategorySelect(
                                                                  category:
                                                                      category,
                                                                ),
                                                              );
                                                              Navigator.pop(
                                                                ctx,
                                                              );
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
                                        },
                                        child: TextFormField(
                                          controller: _categoryController,
                                          readOnly: true,
                                          enabled: false,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            color: Color(0xFF0F1121),
                                            fontFamily: 'GeneralSans',
                                          ),
                                          decoration: InputDecoration(
                                            hintText: l10n.selectCategory,
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
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 14,
                                                ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide.none,
                                            ),
                                            disabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide.none,
                                            ),
                                          ),
                                        ),
                                      )
                                    else
                                      Wrap(
                                        spacing: 28,
                                        runSpacing: 12,
                                        children:
                                            categories
                                                .map(
                                                  (category) => InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        _selectedCategory =
                                                            category;
                                                        _categoryController
                                                                .text =
                                                            _categoryLabel(
                                                              category,
                                                            );
                                                        _selectedSubject = null;
                                                        _subjectController
                                                            .clear();
                                                      });
                                                      fieldState.didChange(
                                                        category,
                                                      );
                                                      _ticketBloc.add(
                                                        OnCategorySelect(
                                                          category: category,
                                                        ),
                                                      );
                                                    },
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        SizedBox(
                                                          width: 20,
                                                          height: 20,
                                                          child: Radio<
                                                            TicketCategoryEntity
                                                          >(
                                                            value: category,
                                                            groupValue:
                                                                _selectedCategory,
                                                            onChanged: (value) {
                                                              if (value ==
                                                                  null) {
                                                                return;
                                                              }
                                                              setState(() {
                                                                _selectedCategory =
                                                                    value;
                                                                _categoryController
                                                                        .text =
                                                                    _categoryLabel(
                                                                      value,
                                                                    );
                                                                _selectedSubject =
                                                                    null;
                                                                _subjectController
                                                                    .clear();
                                                              });
                                                              fieldState
                                                                  .didChange(
                                                                    value,
                                                                  );
                                                              _ticketBloc.add(
                                                                OnCategorySelect(
                                                                  category:
                                                                      value,
                                                                ),
                                                              );
                                                            },
                                                            activeColor:
                                                                AppColor
                                                                    .kSecondaryColor,
                                                            fillColor: WidgetStateProperty.resolveWith(
                                                              (states) =>
                                                                  states.contains(
                                                                        WidgetState
                                                                            .selected,
                                                                      )
                                                                      ? AppColor
                                                                          .kSecondaryColor
                                                                      : const Color(
                                                                        0xFF77787F,
                                                                      ),
                                                            ),
                                                            materialTapTargetSize:
                                                                MaterialTapTargetSize
                                                                    .shrinkWrap,
                                                            visualDensity:
                                                                VisualDensity
                                                                    .compact,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 10,
                                                        ),
                                                        Text(
                                                          _categoryLabel(
                                                            category,
                                                          ),
                                                          style: const TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            height: 1.6,
                                                            color: Color(
                                                              0xFF43444A,
                                                            ),
                                                            fontFamily:
                                                                'GeneralSans',
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                )
                                                .toList(),
                                      ),
                                    if (fieldState.hasError)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 8,
                                          left: 12,
                                        ),
                                        child: Text(
                                          fieldState.errorText!,
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
                            );
                          },
                        ),
                        const SizedBox(height: 24),

                        // Select Subject Field
                        Text(
                          '${l10n.selectSubjectKey}*',
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
                          buildWhen: (previous, current) {
                            if (current is! TicketMasterDataState) {
                              return false;
                            }
                            if (previous is! TicketMasterDataState) {
                              return true;
                            }
                            return previous.selectedSubject !=
                                current.selectedSubject;
                          },
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
                                    fieldName: l10n.selectSubject,
                                  ),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF0F1121),
                                fontFamily: 'GeneralSans',
                              ),
                              decoration: InputDecoration(
                                hintText: l10n.selectSubject,
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
                        if (_selectedSubject != null &&
                            _selectedSubject!.name.toLowerCase() !=
                                'others') ...[
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
                                color: AppColor.kSecondaryColor,
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
                                      color: AppColor.kSecondaryColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      height: 1.6,
                                      fontFamily: 'GeneralSans',
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                        // const SizedBox(height: 24),
                        //
                        // // Select Priority Field
                        // // Select Priority Field
                        // Text(
                        //   '${l10n.selectPriorityKey}*',
                        //   style: const TextStyle(
                        //     fontSize: 14,
                        //     fontWeight: FontWeight.w600,
                        //     color: Color(0xFF0F1121),
                        //     height: 1.3,
                        //     fontFamily: 'GeneralSans',
                        //   ),
                        // ),
                        // const SizedBox(height: 12),
                        // TextFormField(
                        //   controller: _priorityController,
                        //   readOnly: true,
                        //   onTap: _showPriorityPicker,
                        //   autovalidateMode: AutovalidateMode.onUserInteraction,
                        //   validator:
                        //       (v) => Validators.validateRequired(
                        //         v,
                        //         fieldName: l10n.priority,
                        //       ),
                        //   style: const TextStyle(
                        //     fontSize: 14,
                        //     fontWeight: FontWeight.w400,
                        //     color: Color(0xFF0F1121),
                        //     fontFamily: 'GeneralSans',
                        //   ),
                        //   decoration: InputDecoration(
                        //     hintText: l10n.selectPriorityKey,
                        //     hintStyle: const TextStyle(
                        //       fontSize: 14,
                        //       fontWeight: FontWeight.w400,
                        //       color: Color(0xFFA5A5A5),
                        //       fontFamily: 'GeneralSans',
                        //     ),
                        //     filled: true,
                        //     fillColor: Colors.white,
                        //     suffixIcon: const Icon(
                        //       Icons.keyboard_arrow_down,
                        //       color: Color(0xFF292D32),
                        //     ),
                        //     contentPadding: const EdgeInsets.symmetric(
                        //       horizontal: 16,
                        //       vertical: 14,
                        //     ),
                        //     border: OutlineInputBorder(
                        //       borderRadius: BorderRadius.circular(12),
                        //       borderSide: BorderSide.none,
                        //     ),
                        //     errorBorder: OutlineInputBorder(
                        //       borderRadius: BorderRadius.circular(12),
                        //       borderSide: const BorderSide(
                        //         color: Colors.red,
                        //         width: 1,
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        const SizedBox(height: 24),

                        /*
                        // Select Subscriber Field
                        Text(
                          '${l10n.selectSubscriber}*',
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
                            fieldName: l10n.selectSubscriber,
                          ),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF0F1121),
                            fontFamily: 'GeneralSans',
                          ),
                          decoration: InputDecoration(
                            hintText: l10n.selectSubscriber,
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

                        // Remarks Field (error text below field — same pattern as attachments)
                        FormField<String>(
                          key: _remarksFormFieldKey,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          initialValue: _descriptionController.text,
                          validator: (_) {
                            final v = _descriptionController.text;
                            if (_selectedSubject != null &&
                                _selectedSubject!.name.toLowerCase() ==
                                    'others') {
                              return Validators.validateRequired(
                                v,
                                fieldName: l10n.remarks,
                              );
                            }
                            if (v.trim().isEmpty) {
                              return null;
                            }
                            return Validators.validateMaxLength(
                              v,
                              _kTicketRemarksMaxLength,
                              fieldName: l10n.remarks,
                            );
                          },
                          builder: (fieldState) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.remarks,
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
                                    border:
                                        fieldState.hasError
                                            ? Border.all(
                                              color: const Color(0xFFBA1A1A),
                                              width: 1,
                                            )
                                            : null,
                                  ),
                                  child: TextField(
                                    controller: _descriptionController,
                                    maxLines: 5,
                                    minLines: 5,
                                    maxLength: _kTicketRemarksMaxLength,
                                    textAlignVertical: TextAlignVertical.top,
                                    onChanged:
                                        (_) => fieldState.didChange(
                                          _descriptionController.text,
                                        ),
                                    decoration: InputDecoration(
                                      hintText: l10n.remarks,
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
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 15,
                                          ),
                                      counterText: '',
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
                                if (fieldState.hasError)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: 8,
                                      left: 12,
                                    ),
                                    child: Text(
                                      fieldState.errorText!,
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
                        const SizedBox(height: 24),

                        // Upload Attachment Field
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FormField<List<PlatformFile>>(
                              builder: (state) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AttachmentUploadField(
                                      label: l10n.attachments,
                                      onTap: _pickFile,
                                      isMandatory: true,
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
                              buildWhen: (previous, current) {
                                if (current is! TicketMasterDataState) {
                                  return false;
                                }
                                if (previous is! TicketMasterDataState) {
                                  return true;
                                }
                                return previous.fileUiEpoch !=
                                    current.fileUiEpoch;
                              },
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
                          l10n.ticketFileInstructions,
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

class _CategoryRadioSkeleton extends StatelessWidget {
  const _CategoryRadioSkeleton();

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 16,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryDropdownSkeleton extends StatelessWidget {
  const _CategoryDropdownSkeleton();

  @override
  Widget build(BuildContext context) {
    // Reuse existing skeleton to avoid dead code + keep style consistent.
    return const Row(children: [Expanded(child: _CategoryRadioSkeleton())]);
  }
}
