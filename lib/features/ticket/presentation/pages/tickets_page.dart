import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/features/ticket/domain/entity/ticket_entity.dart';
import 'package:kfon_subscriber/features/ticket/domain/params/get_tickets_list_params.dart';
import 'package:kfon_subscriber/features/ticket/domain/repository/ticket_repository.dart';
import 'package:kfon_subscriber/features/ticket/presentation/bloc/ticket_bloc.dart';
import 'package:kfon_subscriber/features/ticket/presentation/bloc/ticket_event.dart';
import 'package:kfon_subscriber/features/ticket/presentation/bloc/ticket_state.dart';
import 'package:kfon_subscriber/features/ticket/presentation/widgets/common_search_field.dart';

import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/features/ticket/presentation/pages/ticket_detail_page.dart';
import 'package:kfon_subscriber/features/ticket/presentation/pages/ticket_models.dart';
import 'package:kfon_subscriber/features/ticket/presentation/widgets/ticket_filter_bottom_sheet.dart';
import 'package:kfon_subscriber/shared/widgets/common_app_bar.dart';
import 'package:kfon_subscriber/service_locator.dart';
import 'package:kfon_subscriber/core/util/dialog_util.dart';
import 'dart:async';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kfon_subscriber/shared/widgets/no_data_found.dart';
import 'package:kfon_subscriber/shared/widgets/shimmer/list_shimmers.dart';
import 'package:kfon_subscriber/core/constant/app_assets.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';

class TicketsPage extends StatefulWidget {
  const TicketsPage({super.key});

  @override
  State<TicketsPage> createState() => _TicketsPageState();
}

class _TicketsPageState extends State<TicketsPage> {
  final TicketBloc _ticketBloc = TicketBloc(
    ticketRepository: sl<TicketRepository>(),
  );
  final DialogUtil _dialogUtil = DialogUtil();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;
  String? _selectedPriority;
  String? _selectedStatus;
  DateTime? _createdDateFrom;
  DateTime? _createdDateTo;
  String? _selectedType;

  GetTicketsListParams _buildParams() {
    final q = _searchController.text.trim();
    return GetTicketsListParams(
      page: 0,
      size: 10,
      search: q.isEmpty ? null : q,
      priority: _selectedPriority,
      status: _selectedStatus,
      createdDateFrom:
          _createdDateFrom == null
              ? null
              : DateFormat('yyyy-MM-dd').format(_createdDateFrom!),
      createdDateTo:
          _createdDateTo == null
              ? null
              : DateFormat('yyyy-MM-dd').format(_createdDateTo!),
      type: _selectedType,
    );
  }

  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      _ticketBloc.add(LoadTickets(params: _buildParams()));
    });
  }

  @override
  void initState() {
    super.initState();
    _ticketBloc.add(LoadTickets(params: _buildParams()));
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _searchController.dispose();
    _ticketBloc.close();
    super.dispose();
  }

  void _onScroll() {
    if (_isNearBottom) {
      _ticketBloc.add(const LoadMoreTickets());
    }
  }

  bool get _isNearBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll - 200);
  }

  TicketStatus _mapStatusToEnum(String status) {
    final lowerStatus = status.toLowerCase();
    if (lowerStatus == 'open') {
      return TicketStatus.open;
    } else if (lowerStatus == 'progress' || lowerStatus == 'in progress') {
      return TicketStatus.progress;
    } else if (lowerStatus == 'closed') {
      return TicketStatus.closed;
    } else if (lowerStatus == 'resolved') {
      return TicketStatus.resolved;
    } else {
      return TicketStatus.closed; // Default
    }
  }

  TicketPriority _mapPriorityToEnum(String priority) {
    final lowerPriority = priority.toLowerCase();
    if (lowerPriority == 'instant') {
      return TicketPriority.instant;
    } else if (lowerPriority == 'high') {
      return TicketPriority.high;
    } else if (lowerPriority == 'medium') {
      return TicketPriority.medium;
    } else if (lowerPriority == 'low') {
      return TicketPriority.low;
    } else {
      return TicketPriority.medium;
    }
  }

  TicketItem _ticketEntityToItem(TicketEntity entity) {
    return TicketItem(
      uuid: entity.uuid,
      title: entity.subject?.name ?? '',
      ticketId:
          entity.ticketId != null
              ? context.bssSubL10n.ticketIdFormat('${entity.ticketId}')
              : context.bssSubL10n.ticketIdEmpty,
      status: _mapStatusToEnum(entity.status),
      priority: _mapPriorityToEnum(entity.priority),
      resolutionTime: entity.subjectResolve ?? '',
      attachments: entity.attachments,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.bssSubL10n;

    return BlocListener<TicketBloc, TicketState>(
      bloc: _ticketBloc,
      listenWhen: (previous, current) => current is OnError,
      listener: (context, state) {
        if (state is OnError) {
          _dialogUtil.showCustomSnackbar(
            content: state.errorMessage,
            context: context,
            isError: true,
          );
        }
      },
      child: BlocBuilder<TicketBloc, TicketState>(
        bloc: _ticketBloc,
        builder: (context, state) {
          List<TicketItem> tickets = [];
          List<TicketEntity> ticketEntities = [];
          bool isLoadingMore = false;

          if (state is TicketsLoaded) {
            ticketEntities = state.data.tickets;
            tickets = ticketEntities.map(_ticketEntityToItem).toList();
            isLoadingMore = state.isLoadingMore;
          } else if (state is TicketsRefreshing) {
            ticketEntities = state.currentData.tickets;
            tickets = ticketEntities.map(_ticketEntityToItem).toList();
          } else if (state is TicketsLoading && state.previousData != null) {
            ticketEntities = state.previousData!.tickets;
            tickets = ticketEntities.map(_ticketEntityToItem).toList();
          } else if (state is OnError && state.previousData != null) {
            ticketEntities = state.previousData!.tickets;
            tickets = ticketEntities.map(_ticketEntityToItem).toList();
          }

          return CommonAppBar(
            onBackPressed: () => Navigator.pop(context),
            title: l10n.myTickets,
            body: SafeArea(
              child: Stack(
                children: [
                  Column(
                    children: [
                      // Search Bar
                      Padding(
                        padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
                        child: CommonSearchField(
                          controller: _searchController,
                          hintText: context.bssSubL10n.searchTickets,
                          filterIconColor: AppColor.kPrimaryColor,
                          onChanged: (_) => _onSearchChanged(),
                          onFilterPressed: () {
                            TicketFilterBottomSheet.show(
                              context,
                              initialValue: TicketFilterValue(
                                priority: _selectedPriority,
                                status: _selectedStatus,
                                createdDateFrom: _createdDateFrom,
                                createdDateTo: _createdDateTo,
                                type: _selectedType,
                              ),
                              onApply: (value) {
                                setState(() {
                                  _selectedPriority = value.priority;
                                  _selectedStatus = value.status;
                                  _createdDateFrom = value.createdDateFrom;
                                  _createdDateTo = value.createdDateTo;
                                  _selectedType = value.type;
                                });
                                _ticketBloc.add(
                                  LoadTickets(params: _buildParams()),
                                );
                              },
                            );
                          },
                        ),
                      ),

                      // Ticket List
                      Expanded(
                        child:
                            state is TicketsLoading && tickets.isEmpty
                                ? SingleChildScrollView(
                                  child: const Padding(
                                    padding: EdgeInsets.only(top: 10),
                                    child: ListShimmer(
                                      itemCount: 8,
                                      itemHeight: 140,
                                    ),
                                  ),
                                )
                                : RefreshIndicator(
                                  onRefresh: () async {
                                    _ticketBloc.add(
                                      RefreshTickets(params: _buildParams()),
                                    );
                                    await Future.delayed(
                                      const Duration(milliseconds: 500),
                                    );
                                  },
                                  child:
                                      tickets.isEmpty &&
                                              state is! TicketsLoading
                                          ? NoDataFound(
                                            errorMessage: l10n.noTickets,
                                          )
                                          : ListView.separated(
                                            controller: _scrollController,
                                            padding: const EdgeInsets.fromLTRB(
                                              20,
                                              0,
                                              20,
                                              80,
                                            ),
                                            physics:
                                                const AlwaysScrollableScrollPhysics(),
                                            itemCount:
                                                tickets.length +
                                                (isLoadingMore ? 1 : 0),
                                            separatorBuilder: (context, index) {
                                              if (index == tickets.length - 1 &&
                                                  isLoadingMore) {
                                                return const SizedBox.shrink();
                                              }
                                              return SizedBox(height: 12.h);
                                            },
                                            itemBuilder: (context, index) {
                                              if (index == tickets.length) {
                                                return const Padding(
                                                  padding: EdgeInsets.all(16.0),
                                                  child: Center(
                                                    child: ListShimmer(
                                                      itemCount: 1,
                                                      itemHeight: 140,
                                                    ),
                                                  ),
                                                );
                                              }
                                              return GestureDetector(
                                                onTap: () async {
                                                  final result = await Navigator.push<
                                                    bool
                                                  >(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder:
                                                          (
                                                            context,
                                                          ) => TicketDetailPage(
                                                            ticket:
                                                                ticketEntities[index],
                                                          ),
                                                    ),
                                                  );
                                                  if (result == true) {
                                                    _ticketBloc.add(
                                                      RefreshTickets(
                                                        params: _buildParams(),
                                                      ),
                                                    );
                                                  }
                                                },
                                                child: _TicketCard(
                                                  ticket: tickets[index],
                                                ),
                                              );
                                            },
                                          ),
                                ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  final TicketItem ticket;

  const _TicketCard({required this.ticket});

  // Priority Colors
  Color _getPriorityColor() {
    switch (ticket.priority) {
      case TicketPriority.instant:
        return AppColor.kUrgentRed; // Red
      case TicketPriority.high:
        return AppColor.kPriorityHigh; // Orange
      case TicketPriority.medium:
        return AppColor.kPriorityMedium; // Yellow/Amber
      case TicketPriority.low:
        return AppColor.kPriorityLow; // Green
    }
  }

  String _getPriorityText(BuildContext context) {
    switch (ticket.priority) {
      case TicketPriority.instant:
        return context.bssSubL10n.priorityInstant;
      case TicketPriority.high:
        return context.bssSubL10n.priorityHigh;
      case TicketPriority.medium:
        return context.bssSubL10n.priorityMedium;
      case TicketPriority.low:
        return context.bssSubL10n.priorityLow;
    }
  }

  // Status Colors (Outlined)
  Color _getStatusColor() {
    switch (ticket.status) {
      case TicketStatus.open:
        return AppColor.kTicketOpenBlue; // Teal/Blue
      case TicketStatus.progress:
        return AppColor.kTicketProgressOrange; // Orange
      case TicketStatus.closed:
        return AppColor.kTicketClosedGreen; // Green
      case TicketStatus.resolved:
        return AppColor.kPrimaryColor; // Primary Color
    }
  }

  String _getStatusText(BuildContext context) {
    final l10n = context.bssSubL10n;
    switch (ticket.status) {
      case TicketStatus.open:
        return l10n.open;
      case TicketStatus.progress:
        return l10n.progress;
      case TicketStatus.closed:
        return l10n.closed;
      case TicketStatus.resolved:
        return l10n.statusResolved;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Design: white, radius 12, 16 blur black @ 6%, no offset; 15 side /
    // 16 vertical padding.
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 16.h),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(12)),
        boxShadow: [BoxShadow(color: AppColor.kCardShadow, blurRadius: 16)],
      ),
      child: Column(
        children: [
          // Top Section
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon — Design: 38 circle, 20 icon.
              Container(
                width: 38.w,
                height: 38.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColor.kIconBackground,
                ),
                child: Center(
                  child: SvgPicture.asset(
                    AppAssets.ticket,
                    width: 20.w,
                    height: 20.w,
                    colorFilter: ColorFilter.mode(
                      AppColor.kPrimaryColor,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              // Design: text starts 69 from the card edge (15 + 38 + 16).
              SizedBox(width: 16.w),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ticket.title,
                      style: TextStyle(
                        color: AppColor.kTextSecondaryDark,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'GeneralSans',
                        height: 1.30,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      ticket.resolutionTime,
                      style: TextStyle(
                        color: AppColor.kTextSecondaryDark,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'GeneralSans',
                        height: 1.30,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      ticket.ticketId,
                      style: TextStyle(
                        color: AppColor.kHintGrey,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'GeneralSans',
                        height: 1.30,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Design: 15 above the divider, 12 below.
          SizedBox(height: 15.h),
          Divider(height: 1, color: AppColor.kSecondaryBackgroundColor),
          SizedBox(height: 12.h),

          // Bottom Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Priority
              Row(
                children: [
                  Text(
                    context.bssSubL10n.priority,
                    // Design: 10 w400 #707070, 5 before the badge.
                    style: TextStyle(
                      color: AppColor.kLabelGrey,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'GeneralSans',
                      height: 1.30,
                    ),
                  ),
                  SizedBox(width: 5.w),
                  Container(
                    height: 24.h,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 2,
                    ),
                    decoration: ShapeDecoration(
                      color: _getPriorityColor().withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(width: 1, color: _getPriorityColor()),
                        borderRadius: BorderRadius.circular(35),
                      ),
                      shadows: [
                        BoxShadow(
                          color: AppColor.kCardShadowDark,
                          blurRadius: 3.80,
                          offset: const Offset(0, 4),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 6.w,
                          height: 6.w,
                          decoration: ShapeDecoration(
                            color: _getPriorityColor(),
                            shape: const OvalBorder(),
                          ),
                        ),
                        SizedBox(width: 5.w),
                        Text(
                          _getPriorityText(context),
                          style: TextStyle(
                            color: _getPriorityColor(),
                            fontSize: 12,
                            fontFamily: 'GeneralSans',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Status
              Container(
                height: 28.h,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: ShapeDecoration(
                  color: _getStatusColor().withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(width: 1, color: _getStatusColor()),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  shadows: [
                    BoxShadow(
                      color: AppColor.kCardShadowDark,
                      blurRadius: 3.80,
                      offset: const Offset(0, 4),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      _getStatusText(context),
                      style: TextStyle(
                        color: _getStatusColor(),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'GeneralSans',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
