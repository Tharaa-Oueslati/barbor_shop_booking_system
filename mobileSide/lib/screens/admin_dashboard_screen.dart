import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/appointment_provider.dart';
import '../models/appointment.dart';
import '../theme/app_theme.dart';
import '../widgets/kpi_card.dart';
import '../widgets/appointment_card.dart';
import '../widgets/confirm_dialog.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  String _filterStatus = 'ALL';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppointmentProvider>().loadAllAppointments();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: RefreshIndicator(
        color: AppTheme.primaryColor,
        onRefresh: () => context.read<AppointmentProvider>().loadAllAppointments(),
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 120,
              floating: true,
              backgroundColor: AppTheme.backgroundColor,
              flexibleSpace: FlexibleSpaceBar(
                title: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dashboard',
                      style: TextStyle(
                        color: AppTheme.textColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('EEEE, MMMM d, y').format(DateTime.now()),
                      style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  child: CircleAvatar(
                    backgroundColor: AppTheme.primaryColor,
                    child: const Text(
                      'A',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // KPI Cards
            SliverToBoxAdapter(
              child: Consumer<AppointmentProvider>(
                builder: (context, provider, child) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        // Top row KPIs
                        Row(
                          children: [
                            Expanded(
                              child: KpiCard(
                                title: 'Total',
                                value: '${provider.totalAppointments}',
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: KpiCard(
                                title: 'Pending',
                                value: '${provider.pendingCount}',
                                color: AppTheme.pendingColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Bottom row KPIs
                        Row(
                          children: [
                            Expanded(
                              child: KpiCard(
                                title: 'Confirmed',
                                value: '${provider.confirmedCount}',
                                color: AppTheme.confirmedColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: KpiCard(
                                title: 'Cancelled',
                                value: '${provider.cancelledCount}',
                                color: AppTheme.cancelledColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Pending Appointments Section
            SliverToBoxAdapter(
              child: Consumer<AppointmentProvider>(
                builder: (context, provider, child) {
                  final pending = provider.pendingAppointments.take(5).toList();

                  if (pending.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'PENDING APPOINTMENTS',
                              style: TextStyle(
                                color: AppTheme.primaryColor,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.08,
                              ),
                            ),
                            if (provider.pendingCount > 5)
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _filterStatus = 'PENDING';
                                  });
                                },
                                child: Text(
                                  'View All (${provider.pendingCount})',
                                  style: TextStyle(
                                    color: AppTheme.textMuted,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...pending.map((appt) => AppointmentCard(
                          appointment: appt,
                          onConfirm: () => _showConfirmDialog(context, appt),
                        )),
                        const SizedBox(height: 24),
                      ],
                    ),
                  );
                },
              ),
            ),

            // All Appointments Section Header with Filters
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ALL APPOINTMENTS',
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.08,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Filter chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('ALL', 'All'),
                          const SizedBox(width: 8),
                          _buildFilterChip('PENDING', 'Pending'),
                          const SizedBox(width: 8),
                          _buildFilterChip('CONFIRMED', 'Confirmed'),
                          const SizedBox(width: 8),
                          _buildFilterChip('CANCELLED', 'Cancelled'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Appointments List
            Consumer<AppointmentProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(color: AppTheme.primaryColor),
                    ),
                  );
                }

                final appointments = provider.getFilteredAppointments(_filterStatus);

                if (appointments.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 64,
                            color: AppTheme.textMuted,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No appointments found',
                            style: TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final appt = appointments[index];
                        return AppointmentCard(
                          appointment: appt,
                          showConfirm: appt.status == AppointmentStatus.pending,
                          onConfirm: () => _showConfirmDialog(context, appt),
                        );
                      },
                      childCount: appointments.length,
                    ),
                  ),
                );
              },
            ),

            // Bottom padding
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _filterStatus == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _filterStatus = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : AppTheme.textMuted,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  void _showConfirmDialog(BuildContext context, Appointment appointment) {
    showDialog(
      context: context,
      builder: (context) => ConfirmDialog(
        appointment: appointment,
        onConfirm: () async {
          final provider = context.read<AppointmentProvider>();
          final success = await provider.confirmAppointment(appointment.id);
          if (success && context.mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Appointment confirmed'),
                backgroundColor: AppTheme.confirmedColor,
              ),
            );
          }
        },
      ),
    );
  }
}
