import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/features/profile/presentation/components/common_radio_button.dart';
import 'package:kfon_subscriber/l10n/bss_sub_localizations.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/presentation/ui_component/common_search_field.dart';

class SubscriberPickerItem {
  final String id;
  final String name;
  final String subscriberId;

  const SubscriberPickerItem({
    required this.id,
    required this.name,
    required this.subscriberId,
  });
}

class SubscriberPickerSheet extends StatefulWidget {
  final String? selectedSubscriberId;
  final Function(SubscriberPickerItem) onSubscriberSelected;

  const SubscriberPickerSheet({
    super.key,
    this.selectedSubscriberId,
    required this.onSubscriberSelected,
  });

  @override
  State<SubscriberPickerSheet> createState() => _SubscriberPickerSheetState();
}

class _SubscriberPickerSheetState extends State<SubscriberPickerSheet> {
  String _searchQuery = '';

  // TODO: Replace with actual subscriber data from API
  final List<SubscriberPickerItem> _subscribers = const [
    SubscriberPickerItem(id: '1', name: 'John Doe', subscriberId: 'SUB001'),
    SubscriberPickerItem(id: '2', name: 'Jane Smith', subscriberId: 'SUB002'),
    SubscriberPickerItem(
      id: '3',
      name: 'Robert Johnson',
      subscriberId: 'SUB003',
    ),
    SubscriberPickerItem(id: '4', name: 'Emily Davis', subscriberId: 'SUB004'),
    SubscriberPickerItem(
      id: '5',
      name: 'Michael Brown',
      subscriberId: 'SUB005',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.bssSubL10n;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            l10n.selectSubscriber,
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
          CommonSearchField(
            onChanged: (val) {
              setState(() {
                _searchQuery = val;
              });
            },
            hintText: l10n.searchSubscriber,
          ),
          const SizedBox(height: 20),
          SizedBox(height: 400, child: _buildSubscriberList(l10n)),
        ],
      ),
    );
  }

  Widget _buildSubscriberList(BssSubLocalizations l10n) {
    final filteredList = _subscribers
        .where(
          (subscriber) =>
              subscriber.name.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              subscriber.subscriberId.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ),
        )
        .toList();

    if (filteredList.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(l10n.noSubscribersAvailable),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: false,
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        final subscriber = filteredList[index];
        final isSelected = widget.selectedSubscriberId == subscriber.id;
        return ListTile(
          leading: CommonRadioButton(isSelected: isSelected),
          title: Text(
            subscriber.name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColor.kTextSecondaryDark,
              fontFamily: 'GeneralSans',
            ),
          ),
          subtitle: Text(
            subscriber.subscriberId,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColor.kSlateGrey,
              fontFamily: 'GeneralSans',
            ),
          ),
          onTap: () {
            widget.onSubscriberSelected(subscriber);
            Navigator.pop(context);
          },
        );
      },
    );
  }
}
