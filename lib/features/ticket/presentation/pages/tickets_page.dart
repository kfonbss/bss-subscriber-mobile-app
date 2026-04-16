import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/dialog_util.dart';
import 'package:kfon_subscriber/features/ticket/data/model/ticket_models.dart';
import 'package:kfon_subscriber/features/ticket/domain/entity/ticket_entity.dart';
import 'package:kfon_subscriber/features/ticket/domain/params/get_tickets_list_params.dart';
import 'package:kfon_subscriber/features/ticket/domain/repository/ticket_repository.dart';
import 'package:kfon_subscriber/features/ticket/presentation/bloc/ticket_bloc.dart';
import 'package:kfon_subscriber/features/ticket/presentation/bloc/ticket_event.dart';
import 'package:kfon_subscriber/features/ticket/presentation/bloc/ticket_state.dart';
import 'package:kfon_subscriber/features/ticket/presentation/pages/ticket_detail_page.dart';
import 'package:kfon_subscriber/l10n/bss_sub_localizations.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/presentation/ui_component/common_app_bar.dart';
import 'package:kfon_subscriber/presentation/ui_component/common_search_field.dart';
import 'package:kfon_subscriber/presentation/ui_component/shimmer/list_shimmers.dart';
import 'package:kfon_subscriber/service_locator.dart';

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
  Timer? _debounce;

  List<TicketEntity>? _lastMappedEntities;
  List<TicketItem> _cachedTicketItems = [];

  GetTicketsListParams _buildParams() {
    return GetTicketsListParams(
      page: 0,
      size: 10,
      search: _searchController.text.trim().isNotEmpty
          ? _searchController.text.trim()
          : null,
    );
  }

  @override
  void initState() {
    super.initState();
    _ticketBloc.add(LoadTickets(params: _buildParams()));
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _searchController.dispose();
    _ticketBloc.close();
    super.dispose();
  }

  void _onScroll() {
    if (_isNearBottom) {
      final currentState = _ticketBloc.state;
      if (currentState is TicketsLoaded &&
          !currentState.isLoadingMore &&
          !currentState.data.pageInfo.isLast) {
        final nextPage = currentState.data.pageInfo.pageNumber + 1;
        _ticketBloc.add(
          LoadMoreTickets(params: _buildParams().copyWith(page: nextPage)),
        );
      }
    }
  }

  bool get _isNearBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll - 200);
  }

  TicketItem _ticketEntityToItem(TicketEntity entity, BssSubLocalizations l10n) {
    return TicketItem(
      uuid: entity.uuid,
      title: entity.subject?.name ?? '',
      ticketId: entity.ticketId != null
          ? l10n.ticketIdFormat(entity.ticketId.toString())
          : l10n.ticketIdEmpty,
      status: TicketStatus.fromString(entity.status),
      priority: TicketPriority.fromString(entity.priority),
      resolutionTime: entity.subjectResolve ?? '',
      attachments: entity.attachments,
    );
  }

  List<TicketItem> _mapToItems(List<TicketEntity> entities, BssSubLocalizations l10n) {
    if (identical(entities, _lastMappedEntities)) return _cachedTicketItems;
    _lastMappedEntities = entities;
    _cachedTicketItems = entities.map((e) => _ticketEntityToItem(e, l10n)).toList();
    return _cachedTicketItems;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.bssSubL10n;

    // CommonAppBar, SafeArea, GestureDetector and the search bar are all
    // structurally static — they do not depend on BLoC state and must not
    // be rebuilt every time a ticket loads or paginates.  Only the list
    // section (Expanded child) is wrapped in BlocListener + BlocBuilder.
    return CommonAppBar(
      onBackPressed: () => Navigator.pop(context),
      title: l10n.myTickets,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          behavior: HitTestBehavior.opaque,
          child: Column(
            children: [
              // ── Search bar — never rebuilds with BLoC state ──────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: CommonSearchField(
                  controller: _searchController,
                  hintText: l10n.searchTickets,
                  onChanged: (value) {
                    if (_debounce?.isActive ?? false) _debounce!.cancel();
                    _debounce = Timer(
                      const Duration(milliseconds: 500),
                      () {
                        _ticketBloc.add(LoadTickets(params: _buildParams()));
                      },
                    );
                  },
                ),
              ),

              // ── Only the list section rebuilds ───────────────────────────
              Expanded(
                child: BlocListener<TicketBloc, TicketState>(
                  bloc: _ticketBloc,
                  listenWhen: (previous, current) {
                    if (current is OnError) return true;
                    if (current is TicketsLoaded && current.paginationError != null) {
                      final prevError = previous is TicketsLoaded ? previous.paginationError : null;
                      return current.paginationError != prevError;
                    }
                    return false;
                  },
                  listener: (context, state) {
                    if (state is OnError) {
                      _dialogUtil.showMessage(state.errorMessage, context);
                    } else if (state is TicketsLoaded && state.paginationError != null) {
                      _dialogUtil.showMessage(state.paginationError!, context);
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
                        tickets = _mapToItems(ticketEntities, l10n);
                        isLoadingMore = state.isLoadingMore;
                      } else if (state is TicketsRefreshing) {
                        ticketEntities = state.currentData.tickets;
                        tickets = _mapToItems(ticketEntities, l10n);
                      } else if (state is OnError && state.previousData != null) {
                        ticketEntities = state.previousData!.tickets;
                        tickets = _mapToItems(ticketEntities, l10n);
                      }

                      if (state is TicketsLoading) {
                        return const Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: ListShimmer(itemCount: 8, itemHeight: 140),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: () async {
                          _ticketBloc.add(RefreshTickets(params: _buildParams()));
                        },
                        child: tickets.isEmpty
                            ? SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                child: SizedBox(
                                  height: MediaQuery.sizeOf(context).height * 0.6,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          'assets/images/filler.png',
                                          width: 232,
                                          height: 166,
                                          fit: BoxFit.contain,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          l10n.noTickets,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                            color: AppColor.kTextSecondaryDark,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : ListView.separated(
                                controller: _scrollController,
                                padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
                                physics: const AlwaysScrollableScrollPhysics(),
                                itemCount: tickets.length + (isLoadingMore ? 1 : 0),
                                separatorBuilder: (context, index) {
                                  if (index == tickets.length - 1 && isLoadingMore) {
                                    return const SizedBox.shrink();
                                  }
                                  return const SizedBox(height: 16);
                                },
                                itemBuilder: (context, index) {
                                  if (index == tickets.length) {
                                    return const Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Center(
                                        child: ListShimmer(itemCount: 1, itemHeight: 140),
                                      ),
                                    );
                                  }
                                  return GestureDetector(
                                    onTap: () async {
                                      final result = await Navigator.push<bool>(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => TicketDetailPage(
                                            ticket: ticketEntities[index],
                                          ),
                                        ),
                                      );
                                      if (result == true) {
                                        _ticketBloc.add(RefreshTickets(params: _buildParams()));
                                      }
                                    },
                                    child: _TicketCard(ticket: tickets[index]),
                                  );
                                },
                              ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  final TicketItem ticket;

  const _TicketCard({required this.ticket});

  // ── Static decorations ────────────────────────────────────────────────────
  static const _cardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(16)),
    boxShadow: [
      BoxShadow(
        color: Color(0x08000000), // black @ 3% opacity
        blurRadius: 10,
        offset: Offset(0, 4),
      ),
    ],
  );

  static const _iconContainerDecoration = BoxDecoration(
    shape: BoxShape.circle,
    color: AppColor.kSecondaryBackgroundColor,
  );

  static const _titleStyle = TextStyle(
    color: AppColor.kTextSecondaryDark,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    fontFamily: 'GeneralSans',
    height: 1.30,
  );

  static const _subtitleStyle = TextStyle(
    color: AppColor.kTextSecondaryDark,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    fontFamily: 'GeneralSans',
    height: 1.30,
  );

  static const _ticketIdStyle = TextStyle(
    color: AppColor.kMediumGrey,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    fontFamily: 'GeneralSans',
    height: 1.30,
  );

  static const _priorityLabelStyle = TextStyle(
    color: AppColor.kMediumGrey,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    fontFamily: 'GeneralSans',
    height: 1.30,
  );

  // ── Helpers ───────────────────────────────────────────────────────────────
  Color _priorityColor() {
    switch (ticket.priority) {
      case TicketPriority.instant: return AppColor.kUrgentRed;
      case TicketPriority.high:    return AppColor.kPriorityHigh;
      case TicketPriority.medium:  return AppColor.kPriorityMedium;
      case TicketPriority.low:     return AppColor.kPriorityLow;
    }
  }

  String _priorityText(BssSubLocalizations l10n) {
    switch (ticket.priority) {
      case TicketPriority.instant: return l10n.priorityInstant;
      case TicketPriority.high:    return l10n.priorityHigh;
      case TicketPriority.medium:  return l10n.priorityMedium;
      case TicketPriority.low:     return l10n.priorityLow;
    }
  }

  Color _statusColor() {
    switch (ticket.status) {
      case TicketStatus.open:     return AppColor.kTicketOpenBlue;
      case TicketStatus.progress: return AppColor.kTicketProgressOrange;
      case TicketStatus.closed:   return AppColor.kTicketClosedGreen;
      case TicketStatus.resolved: return AppColor.kPrimaryColor;
    }
  }

  String _statusText(BssSubLocalizations l10n) {
    switch (ticket.status) {
      case TicketStatus.open:     return l10n.statusOpen;
      case TicketStatus.progress: return l10n.statusProgress;
      case TicketStatus.closed:   return l10n.statusClosed;
      case TicketStatus.resolved: return l10n.statusResolved;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.bssSubL10n;
    final priorityColor = _priorityColor();
    final statusColor = _statusColor();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration,
      child: Column(
        children: [
          // Top Section
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: _iconContainerDecoration,
                child: Center(
                  child: SvgPicture.asset(
                    'assets/icons/ticket.svg',
                    width: 20,
                    height: 20,
                    colorFilter: const ColorFilter.mode(
                      AppColor.kPrimaryColor,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ticket.title, style: _titleStyle),
                    const SizedBox(height: 4),
                    Text(ticket.resolutionTime, style: _subtitleStyle),
                    const SizedBox(height: 2),
                    Text(ticket.ticketId, style: _ticketIdStyle),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColor.kSecondaryBackgroundColor),
          const SizedBox(height: 16),

          // Bottom Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Priority
              Row(
                children: [
                  Text(l10n.priorityLabel, style: _priorityLabelStyle),
                  const SizedBox(width: 8),
                  Container(
                    height: 24,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                    decoration: ShapeDecoration(
                      color: priorityColor.withValues(alpha: 0.1),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(width: 1, color: priorityColor),
                        borderRadius: BorderRadius.circular(35),
                      ),
                      shadows: const [
                        BoxShadow(
                          color: AppColor.kCardShadowDark,
                          blurRadius: 3.80,
                          offset: Offset(0, 4),
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
                          width: 6,
                          height: 6,
                          decoration: ShapeDecoration(
                            color: priorityColor,
                            shape: const OvalBorder(),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _priorityText(l10n),
                          style: TextStyle(
                            color: priorityColor,
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
                height: 28,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: ShapeDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(width: 1, color: statusColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  shadows: const [
                    BoxShadow(
                      color: AppColor.kCardShadowDark,
                      blurRadius: 3.80,
                      offset: Offset(0, 4),
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
                      _statusText(l10n),
                      style: TextStyle(
                        color: statusColor,
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
