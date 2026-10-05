import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/core/validator/validators.dart';
import 'package:kfon_subscriber/features/ticket/data/model/submit_ticket_req.dart';
import 'package:kfon_subscriber/features/ticket/presentation/widgets/tax_payer_types.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/shared/widgets/app_input_style.dart';
import 'package:kfon_subscriber/shared/widgets/attachment_upload_field.dart';

class GstPanDetailsSection extends StatefulWidget {
  const GstPanDetailsSection({super.key});

  @override
  State<GstPanDetailsSection> createState() => GstPanDetailsSectionState();
}

class GstPanDetailsSectionState extends State<GstPanDetailsSection> {
  static final _panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$');
  // 2-digit state code · 10-char PAN · entity no. · 'Z' · checksum.
  static final _gstinRegex = RegExp(
    r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z][1-9A-Z]Z[0-9A-Z]$',
  );
  static final _sacRegex = RegExp(r'^[0-9]{6}$');
  static const _maxFileBytes = 5 * 1024 * 1024;
  static const _allowedExtensions = ['pdf', 'jpg', 'jpeg', 'png'];

  final _panController = TextEditingController();

  /// GSTIN state code is fixed (not editable).
  static const _gstStateCode = '31';
  final _entityController = TextEditingController();
  final _checksumController = TextEditingController();
  final _serviceDescController = TextEditingController();
  final _sacController = TextEditingController();
  final _legalNameController = TextEditingController();
  final _tradeNameController = TextEditingController();
  final _entityFocus = FocusNode();
  final _checksumFocus = FocusNode();
  final _gstinFieldKey = GlobalKey<FormFieldState<String>>();

  String? _taxPayerType;
  PlatformFile? _gstDocFile;
  PlatformFile? _panCopyFile;

  String get _gstin =>
      '$_gstStateCode${_panController.text}'
              '${_entityController.text}Z${_checksumController.text}'
          .toUpperCase();

  /// Values for the create-ticket request. Call only after the form validated.
  GstinDetailsReq buildRequest() {
    return GstinDetailsReq(
      pan: _panController.text.trim().toUpperCase(),
      gstin: _gstin,
      serviceDescription: _serviceDescController.text.trim(),
      sac: _sacController.text.trim(),
      taxPayerType: _taxPayerType!,
      legalName: _legalNameController.text.trim(),
      tradeName: _tradeNameController.text.trim(),
      gstDocFile: _gstDocFile!,
      panCopyFile: _panCopyFile!,
    );
  }

  @override
  void initState() {
    super.initState();
    // The GSTIN's PAN part mirrors the PAN Number field.
    _panController.addListener(_onGstinPartChanged);
  }

  @override
  void dispose() {
    _panController.removeListener(_onGstinPartChanged);
    for (final c in [
      _panController,
      _entityController,
      _checksumController,
      _serviceDescController,
      _sacController,
      _legalNameController,
      _tradeNameController,
    ]) {
      c.dispose();
    }
    _entityFocus.dispose();
    _checksumFocus.dispose();
    super.dispose();
  }

  void _onGstinPartChanged() {
    setState(() {}); // repaint the read-only PAN box
    _gstinFieldKey.currentState?.didChange(_gstin);
  }

  Future<PlatformFile?> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: _allowedExtensions,
    );
    final file = result?.files.single;
    if (file == null || file.path == null) return null;
    if (file.size > _maxFileBytes) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.bssSubL10n.fileSizeMustBeLess)),
        );
      }
      return null;
    }
    return file;
  }

  // ── Styles ──────────────────────────────────────────────────────────────
  static const _labelStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColor.kTextSecondaryDark,
    height: 1.3,
    fontFamily: 'GeneralSans',
  );
  static const _radius = BorderRadius.all(Radius.circular(12));
  static TextStyle get _inputStyle => AppInputStyle.text;
  static TextStyle get _hintStyle => AppInputStyle.hint;

  InputDecoration _decoration(String? hint) =>
      AppInputStyle.decoration(hint: hint);

  Widget _label(String text, {bool required = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(required ? '$text*' : text, style: _labelStyle),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.bssSubL10n;
    final gap = SizedBox(height: 16.h);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // PAN Number
        _label(l10n.panNumberLabel, required: true),
        _CafTextField(
          controller: _panController,
          hint: l10n.enterPanNumber,
          textCapitalization: TextCapitalization.characters,
          maxLength: 10,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9]')),
            _UpperCaseFormatter(),
          ],
          validator: (v) {
            final required = Validators.validateRequired(
              v,
              fieldName: l10n.panNumberLabel,
            );
            if (required != null) return required;
            return _panRegex.hasMatch(v!.trim()) ? null : l10n.invalidPanNumber;
          },
        ),
        gap,

        // GSTIN: state code · PAN · entity no. · Z · checksum
        _label(l10n.gstinLabel, required: true),
        FormField<String>(
          key: _gstinFieldKey,
          initialValue: _gstin,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator:
              (_) => _gstinRegex.hasMatch(_gstin) ? null : l10n.invalidGstin,
          builder: (field) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  spacing: 8.w,
                  children: [
                    SizedBox(
                      width: 56.w,
                      child: _GstinStaticBox(
                        text: _gstStateCode,
                        hasError: field.hasError,
                      ),
                    ),
                    Expanded(
                      child: _GstinStaticBox(
                        text:
                            _panController.text.isEmpty
                                ? l10n.pan
                                : _panController.text,
                        isHint: _panController.text.isEmpty,
                        hasError: field.hasError,
                      ),
                    ),
                    SizedBox(
                      width: 44.w,
                      child: _GstinBox(
                        controller: _entityController,
                        focusNode: _entityFocus,
                        maxLength: 1,
                        hasError: field.hasError,
                        onChanged: (v) {
                          _onGstinPartChanged();
                          if (v.isNotEmpty) _checksumFocus.requestFocus();
                        },
                      ),
                    ),
                    SizedBox(
                      width: 44.w,
                      child: _GstinStaticBox(
                        text: 'Z',
                        hasError: field.hasError,
                      ),
                    ),
                    SizedBox(
                      width: 44.w,
                      child: _GstinBox(
                        controller: _checksumController,
                        focusNode: _checksumFocus,
                        maxLength: 1,
                        hasError: field.hasError,
                        onChanged: (_) => _onGstinPartChanged(),
                      ),
                    ),
                  ],
                ),
                if (field.hasError) _ErrorText(field.errorText!),
              ],
            );
          },
        ),
        gap,

        // Service Description
        _label(l10n.serviceDescriptionLabel, required: true),
        _CafTextField(
          controller: _serviceDescController,
          hint: l10n.enterServiceDescription,
          validator:
              (v) => Validators.validateRequired(
                v,
                fieldName: l10n.serviceDescriptionLabel,
              ),
        ),
        gap,

        // SAC Code
        _label(l10n.sacCodeLabel, required: true),
        _CafTextField(
          controller: _sacController,
          hint: l10n.enterSacCode,
          keyboardType: TextInputType.number,
          maxLength: 6,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (v) {
            final required = Validators.validateRequired(
              v,
              fieldName: l10n.sacCodeLabel,
            );
            if (required != null) return required;
            return _sacRegex.hasMatch(v!.trim()) ? null : l10n.invalidSacCode;
          },
        ),
        gap,

        // TAX-PAYER Type
        _label(l10n.taxPayerTypeLabel, required: true),
        DropdownButtonFormField<String>(
          initialValue: _taxPayerType,
          isExpanded: true,
          style: _inputStyle,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: AppColor.kIconDark,
          ),
          borderRadius: _radius,
          dropdownColor: Colors.white,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator:
              (v) => Validators.validateRequired(
                v,
                fieldName: l10n.taxPayerTypeLabel,
              ),
          decoration: _decoration(l10n.selectTaxPayerType),
          items: [
            for (final code in taxPayerTypeCodes)
              DropdownMenuItem(
                value: code,
                child: Text(taxPayerTypeLabel(l10n, code), style: _inputStyle),
              ),
          ],
          onChanged: (v) => setState(() => _taxPayerType = v),
        ),
        gap,

        // Legal Business Name (optional)
        _label(l10n.legalBusinessName),
        _CafTextField(controller: _legalNameController),
        gap,

        // Trade Name (optional)
        _label(l10n.tradeName),
        _CafTextField(controller: _tradeNameController),
        gap,

        // Documents
        _DocumentUploadField(
          label: l10n.gstinSupportingDocument,
          file: _gstDocFile,
          onPick: () async {
            final file = await _pickDocument();
            if (file != null) setState(() => _gstDocFile = file);
          },
          onRemove: () => setState(() => _gstDocFile = null),
        ),
        gap,
        _DocumentUploadField(
          label: l10n.panCardCopy,
          file: _panCopyFile,
          onPick: () async {
            final file = await _pickDocument();
            if (file != null) setState(() => _panCopyFile = file);
          },
          onRemove: () => setState(() => _panCopyFile = null),
        ),
      ],
    );
  }
}

/// Text field matching the CAF inputs.
class _CafTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? hint;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final TextCapitalization textCapitalization;

  const _CafTextField({
    required this.controller,
    this.hint,
    this.validator,
    this.keyboardType,
    this.inputFormatters,
    this.maxLength,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      textCapitalization: textCapitalization,
      textAlignVertical: TextAlignVertical.center,
      onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
      contextMenuBuilder: AppInputStyle.contextMenuBuilder,
      inputFormatters: inputFormatters,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: AppInputStyle.text,
      decoration: AppInputStyle.decoration(hint: hint),
    );
  }
}

class _UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}

// ── GSTIN boxes ───────────────────────────────────────────────────────────────
const _boxStyle = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w500,
  color: AppColor.kTextSecondaryDark,
  fontFamily: 'GeneralSans',
);

BoxDecoration _boxDecoration({required Color color, required bool hasError}) {
  return BoxDecoration(
    color: color,
    borderRadius: const BorderRadius.all(Radius.circular(12)),
    // Same 1px light-grey border as the text fields; red on error.
    border: Border.all(
      color: hasError ? Colors.red : AppColor.kinputFiledLightBorder,
      width: 1.w,
    ),
  );
}

/// Editable GSTIN segment (entity number, checksum).
class _GstinBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final int maxLength;
  final bool hasError;
  final ValueChanged<String> onChanged;

  const _GstinBox({
    required this.controller,
    this.focusNode,
    required this.maxLength,
    required this.hasError,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Same CAF field style (primary border while focused); `expands` fills
    // the 52 box so the text sits centred.
    return SizedBox(
      height: 52.h,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        maxLength: maxLength,
        expands: true,
        maxLines: null,
        textAlign: TextAlign.center,
        textAlignVertical: TextAlignVertical.center,
        onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
        style: _boxStyle,
        keyboardType: TextInputType.text,
        textCapitalization: TextCapitalization.characters,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9]')),
          _UpperCaseFormatter(),
        ],
        onChanged: onChanged,
        decoration: AppInputStyle.decoration(
          hasError: hasError,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}

/// Read-only GSTIN segment (PAN part, fixed 'Z').
class _GstinStaticBox extends StatelessWidget {
  final String text;
  final bool isHint;
  final bool hasError;

  const _GstinStaticBox({
    required this.text,
    this.isHint = false,
    required this.hasError,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52.h,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      decoration: _boxDecoration(
        color: AppColor.kSecondaryBackgroundColor,
        hasError: hasError,
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          text,
          style:
              isHint
                  ? GstPanDetailsSectionState._hintStyle
                  : _boxStyle.copyWith(letterSpacing: 1),
        ),
      ),
    );
  }
}

class _ErrorText extends StatelessWidget {
  final String text;
  const _ErrorText(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 12),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColor.kAttachmentErrorRed,
          fontSize: 12,
          fontFamily: 'GeneralSans',
        ),
      ),
    );
  }
}

// ── Document upload ───────────────────────────────────────────────────────────
/// Dashed [AttachmentUploadField] (same as the ticket Attachments field), with
/// the chosen file shown underneath and the accepted-formats hint.
class _DocumentUploadField extends StatelessWidget {
  final String label;
  final PlatformFile? file;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  const _DocumentUploadField({
    required this.label,
    required this.file,
    required this.onPick,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.bssSubL10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AttachmentUploadField(
          label: label,
          isMandatory: true,
          onTap: onPick,
          value: file?.name,
          validator: (v) => Validators.validateRequired(v, fieldName: label),
        ),
        if (file != null) ...[
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.only(left: 12.w),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.description_outlined,
                  size: 18.w,
                  color: AppColor.kPrimaryColor,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    file!.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColor.kTextSecondaryDark,
                      fontFamily: 'GeneralSans',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    size: 18,
                    color: AppColor.kMediumGrey,
                  ),
                  onPressed: onRemove,
                ),
              ],
            ),
          ),
        ],
        SizedBox(height: 8.h),
        Text(
          l10n.acceptedDocFormatsInfo,
          style: const TextStyle(
            fontSize: 12,
            color: AppColor.kLabelGrey,
            fontFamily: 'GeneralSans',
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
