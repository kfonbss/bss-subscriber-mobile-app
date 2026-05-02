import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/helper/bottom_sheet_helper.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/shared/widgets/primary_button.dart';
import 'package:kfon_subscriber/shared/widgets/secondary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

class TicketFilterValue {
  final String? priority;
  final String? status;
  final DateTime? createdDateFrom;
  final DateTime? createdDateTo;
  final String? type;

  const TicketFilterValue({
    this.priority,
    this.status,
    this.createdDateFrom,
    this.createdDateTo,
    this.type,
  });
}

class TicketFilterBottomSheet extends StatefulWidget {
  final TicketFilterValue initialValue;
  final ValueChanged<TicketFilterValue> onApply;

  const TicketFilterBottomSheet({
    super.key,
    required this.initialValue,
    required this.onApply,
  });

  static Future<void> show(
    BuildContext context, {
    required TicketFilterValue initialValue,
    required ValueChanged<TicketFilterValue> onApply,
  }) async {
    await BottomSheetHelper.show<void>(
      context: context,
      title: context.bssSubL10n.filter,
      child: TicketFilterBottomSheet(
        initialValue: initialValue,
        onApply: onApply,
      ),
    );
  }

  @override
  State<TicketFilterBottomSheet> createState() =>
      _TicketFilterBottomSheetState();
}

class _TicketFilterBottomSheetState extends State<TicketFilterBottomSheet> {
  static const List<String> _priorities = ['INSTANT', 'HIGH', 'MEDIUM', 'LOW'];
  static const List<String> _statuses = [
    'OPEN',
    'PROGRESS',
    'CLOSED',
    'RETURNED',
    'REOPEN',
  ];

  late String? _selectedPriority;
  late String? _selectedStatus;
  late DateTime? _createdDateFrom;
  late DateTime? _createdDateTo;
  late String? _selectedType;
  final TextEditingController _priorityController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedPriority = widget.initialValue.priority;
    _selectedStatus = widget.initialValue.status;
    _createdDateFrom = widget.initialValue.createdDateFrom;
    _createdDateTo = widget.initialValue.createdDateTo;
    _selectedType = widget.initialValue.type;
  }

  @override
  void dispose() {
    _priorityController.dispose();
    _statusController.dispose();
    super.dispose();
  }

  String _dateLabel(DateTime? value) {
    if (value == null) return 'Select date';
    return DateFormat('dd MMM yyyy').format(value);
  }

  Future<void> _pickFromDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _createdDateFrom ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: _createdDateTo ?? DateTime.now(),
    );
    if (picked == null) return;
    setState(() {
      _createdDateFrom = picked;
      if (_createdDateTo != null && _createdDateTo!.isBefore(picked)) {
        _createdDateTo = picked;
      }
    });
  }

  Future<void> _pickToDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _createdDateTo ?? _createdDateFrom ?? DateTime.now(),
      firstDate: _createdDateFrom ?? DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked == null) return;
    setState(() => _createdDateTo = picked);
  }

  void _onApply() {
    widget.onApply(
      TicketFilterValue(
        priority: _selectedPriority,
        status: _selectedStatus,
        createdDateFrom: _createdDateFrom,
        createdDateTo: _createdDateTo,
        type: _selectedType,
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _dropdownField<String?>(
          label: 'Priority',
          value: _selectedPriority,
          items: [null, ..._priorities],
          itemLabel: (value) => value ?? context.bssSubL10n.all,
          controller: _priorityController,
          onChanged: (value) => setState(() => _selectedPriority = value),
        ),
        const SizedBox(height: 12),
        _dropdownField<String?>(
          label: 'Status',
          value: _selectedStatus,
          items: [null, ..._statuses],
          itemLabel: (value) => value ?? context.bssSubL10n.all,
          controller: _statusController,
          onChanged: (value) => setState(() => _selectedStatus = value),
        ),
        const SizedBox(height: 12),
        _dateField(
          label: 'Created Date From',
          value: _dateLabel(_createdDateFrom),
          onTap: _pickFromDate,
          onClear:
              _createdDateFrom == null
                  ? null
                  : () => setState(() => _createdDateFrom = null),
        ),
        const SizedBox(height: 12),
        _dateField(
          label: 'Created Date To',
          value: _dateLabel(_createdDateTo),
          onTap: _pickToDate,
          onClear:
              _createdDateTo == null
                  ? null
                  : () => setState(() => _createdDateTo = null),
        ),

        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: SecondaryButton(
                label: context.bssSubL10n.cancel,
                borderRadius: 10,
                backgroundColor: Colors.transparent,
                onClicked: () => Navigator.of(context).pop(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PrimaryButton(
                label: context.bssSubL10n.search,
                borderRadius: 10,
                isLoading: false,
                onClicked: _onApply,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _fieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontFamily: 'GeneralSans',
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColor.kTextSecondaryDark,
      ),
    );
  }

  Widget _dateField({
    required String label,
    required String value,
    required VoidCallback onTap,
    VoidCallback? onClear,
  }) {
    final isPlaceholder = value == 'Select date';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(label),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColor.kinputFiledLightBorder),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontFamily: 'GeneralSans',
                      fontSize: 14,
                      color:
                          isPlaceholder
                              ? AppColor.kTextFiledPlaceholderColor
                              : AppColor.kTextSecondaryDark,
                    ),
                  ),
                ),
                if (onClear != null && !isPlaceholder)
                  GestureDetector(
                    onTap: onClear,
                    behavior: HitTestBehavior.opaque,
                    child: const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: AppColor.kTextSecondary,
                      ),
                    ),
                  )
                else
                  SvgPicture.asset(
                    'assets/icons/calendar.svg',
                    width: 20,
                    height: 20,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF9CA3AF),
                      BlendMode.srcIn,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _dropdownField<T>({
    required String label,
    required T value,
    required List<T> items,
    required String Function(T) itemLabel,
    required TextEditingController controller,
    required ValueChanged<T?> onChanged,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final newText = value == null ? context.bssSubL10n.all : itemLabel(value);
      if (controller.text != newText) {
        controller.text = newText;
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(label),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColor.kinputFiledLightBorder),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final fieldWidth = constraints.maxWidth;
              return DropdownMenu<T>(
                controller: controller,
                initialSelection: value,
                width: fieldWidth,
                menuHeight: 220,
                textStyle: const TextStyle(
                  fontFamily: 'GeneralSans',
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                inputDecorationTheme: const InputDecorationTheme(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  isDense: true,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  constraints: BoxConstraints.tightFor(height: 48),
                ),
                menuStyle: MenuStyle(
                  alignment: Alignment.bottomLeft,
                  backgroundColor: WidgetStateProperty.all(Colors.white),
                  fixedSize: WidgetStateProperty.all(Size(fieldWidth, 220)),
                ),
                trailingIcon: Icon(
                  Icons.keyboard_arrow_down,
                  size: 24,
                  color: Colors.black.withOpacity(0.54),
                ),
                dropdownMenuEntries:
                    items
                        .map(
                          (entry) => DropdownMenuEntry<T>(
                            value: entry,
                            label: itemLabel(entry),
                          ),
                        )
                        .toList(),
                onSelected: (selected) {
                  controller.text =
                      selected == null
                          ? context.bssSubL10n.all
                          : itemLabel(selected);
                  onChanged(selected);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _typeRadioSection<T>({
    required String label,
    required T groupValue,
    required List<T> items,
    required String Function(T) itemLabel,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.kinputFiledLightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fieldLabel(label),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children:
                items
                    .map(
                      (item) => _radioItem<T>(
                        itemLabel(item),
                        item,
                        groupValue,
                        onChanged,
                      ),
                    )
                    .toList(),
          ),
        ],
      ),
    );
  }

  Widget _radioItem<T>(
    String label,
    T value,
    T groupValue,
    ValueChanged<T?> onChanged,
  ) {
    return InkWell(
      onTap: () => onChanged(value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: Radio<T>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
              activeColor: AppColor.kSecondaryColor,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'GeneralSans',
              fontSize: 14,
              color: AppColor.kTextSecondaryDark,
            ),
          ),
        ],
      ),
    );
  }
}
