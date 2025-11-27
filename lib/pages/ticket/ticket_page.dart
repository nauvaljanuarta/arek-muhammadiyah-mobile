import 'package:flutter/cupertino.dart';
import '../../config/theme/theme.dart';
import '../../widgets/ticket/ticket_card.dart';
import 'add_ticket_page.dart';
import '../../pages/ticket/detail_ticket_page.dart';
import '../../services/ticket_service.dart';
import '../../services/ticket_read_service.dart';
import '../../models/ticket.dart' as ticket_model;

class TicketPage extends StatefulWidget {
  final VoidCallback? onTicketOpened;

  const TicketPage({super.key, this.onTicketOpened});

  @override
  State<TicketPage> createState() => _TicketPageState();
}

class _TicketPageState extends State<TicketPage> {
  List<ticket_model.Ticket> userTickets = [];
  Set<int> readTickets = {};
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserTickets();
    _loadReadTickets();
  }

  Future<void> _loadReadTickets() async {
    final readIds = await TicketReadService.getReadTicketIds();
    setState(() {
      readTickets = readIds.toSet();
    });
  }

  Future<void> _loadUserTickets() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final tickets = await TicketService.getUserTickets();

      setState(() {
        userTickets = tickets;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load tickets: ${e.toString()}';
      });
    }
  }

  Future<void> _refreshTickets() async {
    await _loadUserTickets();
    await _loadReadTickets();
    
    widget.onTicketOpened?.call();
  }

  void _onTicketTap(ticket_model.Ticket ticket) async {
    await TicketReadService.markTicketAsRead(ticket.id);
    
    setState(() {
      readTickets.add(ticket.id);
    });

    widget.onTicketOpened?.call();

    final result = await Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => TicketDetailPage(ticket: ticket),
      ),
    );

    if (result != null) {
      _refreshTickets();
    }
  }

  bool _shouldShowBadge(ticket_model.Ticket ticket) {
    return ticket.hasUpdates && !readTickets.contains(ticket.id);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppTheme.background,
      child: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              CupertinoSliverNavigationBar(
                largeTitle: const Text(
                  'My Tickets',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: AppTheme.background.withAlpha(95),
                border: Border(
                  bottom: BorderSide(
                    color: CupertinoColors.systemGrey5,
                    width: 0.5,
                  ),
                ),
              ),

              CupertinoSliverRefreshControl(
                onRefresh: _refreshTickets,
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 8)),

              if (isLoading)
                const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CupertinoActivityIndicator(),
                    ),
                  ),
                )

              else if (errorMessage != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: CupertinoColors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: CupertinoColors.systemGrey.withOpacity(0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            CupertinoIcons.exclamationmark_triangle,
                            size: 48,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            errorMessage!,
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          CupertinoButton(
                            onPressed: _refreshTickets,
                            child: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                  ),
                )

              else if (userTickets.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: CupertinoColors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: CupertinoColors.systemGrey.withOpacity(0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Column(
                        children: [
                          Icon(
                            CupertinoIcons.doc_text,
                            size: 48,
                            color: AppTheme.textSecondary,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No Tickets Yet',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Tap the "+" button below to create a new ticket.',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final ticket = userTickets[index];
                      return TicketCard(
                        ticket: ticket,
                        onTap: () => _onTicketTap(ticket),
                        showBadge: _shouldShowBadge(ticket),
                      );
                    },
                    childCount: userTickets.length,
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),

          if (!isLoading && errorMessage == null)
            Positioned(
              bottom: 20,
              right: 20,
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.primaryDark,
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryDark.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: CupertinoButton(
                  padding: const EdgeInsets.all(16),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (_) => const AddTicketPage(),
                      ),
                    );

                    if (result == true) {
                      _refreshTickets();
                    }
                  },
                  child: const Icon(
                    CupertinoIcons.add,
                    color: CupertinoColors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}