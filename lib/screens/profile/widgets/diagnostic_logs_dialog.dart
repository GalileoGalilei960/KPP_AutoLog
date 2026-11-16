import 'package:flutter/material.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/services/crashlytics_service.dart';
import '../../../core/theme/app_colors.dart';

/// Діалог перегляду журналів Crashlytics, Analytics та Аудієнції.
/// Дозволяє наочно продемонструвати викладачу та зафіксувати у звіті
/// збирання аналітики, інформацію про аудієнцію (хто і як залогінився)
/// й перехоплення збоїв на платформі Linux (Завдання 1 і 2).
class DiagnosticLogsDialog extends StatefulWidget {
  const DiagnosticLogsDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (context) => const DiagnosticLogsDialog(),
    );
  }

  @override
  State<DiagnosticLogsDialog> createState() => _DiagnosticLogsDialogState();
}

class _DiagnosticLogsDialogState extends State<DiagnosticLogsDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reports = CrashlyticsService.instance.reports;
    final events = AnalyticsService.instance.eventsLog;
    final audience = AnalyticsService.instance.audienceLog;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 780, maxHeight: 640),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.monitor_heart_outlined, color: AppColors.primary, size: 24),
                      SizedBox(width: 10),
                      Text(
                        'Журнали Crashlytics, Analytics та Аудиторія',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20, color: AppColors.textSecondary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.bug_report, size: 16),
                        const SizedBox(width: 6),
                        Text('Crashlytics (${reports.length})'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.analytics, size: 16),
                        const SizedBox(width: 6),
                        Text('Analytics (${events.length})'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.people_alt_outlined, size: 16),
                        const SizedBox(width: 6),
                        Text('Аудиторія (${audience.length})'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // 1. Вкладка Crashlytics
                    _buildCrashlyticsTab(reports),

                    // 2. Вкладка Analytics
                    _buildAnalyticsTab(events),

                    // 3. Вкладка Аудиторія (хто і як залогінився)
                    _buildAudienceTab(audience),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                alignment: WrapAlignment.end,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.person_add_alt_1_outlined, size: 16),
                    label: const Text('Тест аудієнції'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF2563EB),
                      side: const BorderSide(color: Color(0xFF93C5FD)),
                    ),
                    onPressed: () async {
                      final isGoogle = (audience.length % 2 == 0);
                      final num = audience.length + 1;
                      await AnalyticsService.instance.simulateTestAudienceMember(
                        email: isGoogle
                            ? 'student$num@gmail.com'
                            : 'driver$num@autoservice.ua',
                        displayName: isGoogle
                            ? 'Студент $num (Google)'
                            : 'Водій $num (Email)',
                        method: isGoogle ? 'google' : 'email_password',
                      );
                      setState(() {});
                    },
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.warning_amber_rounded, size: 16),
                    label: const Text('Non-Fatal збій'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFD97706),
                      side: const BorderSide(color: Color(0xFFFCD34D)),
                    ),
                    onPressed: () {
                      CrashlyticsService.instance.simulateTestCrash(fatal: false);
                      setState(() {});
                    },
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.dangerous_outlined, size: 16),
                    label: const Text('Fatal збій'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFB91C1C),
                      side: const BorderSide(color: Color(0xFFFCA5A5)),
                    ),
                    onPressed: () {
                      CrashlyticsService.instance.simulateTestCrash(fatal: true);
                      setState(() {});
                    },
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Закрити'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCrashlyticsTab(List<CrashReport> reports) {
    if (reports.isEmpty) {
      return const Center(
        child: Text(
          'Помилок ще не зафіксовано.\nНатисніть "Non-Fatal збій" чи "Fatal збій", щоб створити тестовий звіт.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.separated(
      itemCount: reports.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final rep = reports[reports.length - 1 - index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: rep.fatal ? const Color(0xFFFEE2E2) : const Color(0xFFFEF3C7),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: rep.fatal ? const Color(0xFFFCA5A5) : const Color(0xFFFCD34D),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: rep.fatal ? const Color(0xFFB91C1C) : const Color(0xFFD97706),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      rep.fatal ? 'FATAL' : 'NON-FATAL',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${rep.timestamp.hour.toString().padLeft(2, '0')}:${rep.timestamp.minute.toString().padLeft(2, '0')}:${rep.timestamp.second.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    rep.reason ?? 'Без опису',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                rep.error,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'monospace',
                  color: AppColors.textPrimary,
                ),
              ),
              if (rep.stackTrace != null) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  constraints: const BoxConstraints(maxHeight: 90),
                  child: SingleChildScrollView(
                    child: Text(
                      rep.stackTrace!,
                      style: const TextStyle(
                        fontSize: 11,
                        fontFamily: 'monospace',
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnalyticsTab(List<Map<String, dynamic>> events) {
    if (events.isEmpty) {
      return const Center(
        child: Text(
          'Подій аналітики поки немає.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.separated(
      itemCount: events.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final ev = events[events.length - 1 - index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.event_note, size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ev['name'].toString(),
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      ev['parameters'].toString(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                ev['timestamp'].toString().substring(11, 19),
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAudienceTab(List<AudienceRecord> audience) {
    final uniqueCount = AnalyticsService.instance.uniqueAudience.length;
    final googleCount = AnalyticsService.instance.googleLoginsCount;
    final emailCount = AnalyticsService.instance.emailPasswordLoginsCount;
    final currentUserId = AnalyticsService.instance.currentUserId;
    final userProps = AnalyticsService.instance.userProperties;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Зведена панель метрик аудиторії
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  title: 'Усього входів',
                  value: '${audience.length}',
                  icon: Icons.login_rounded,
                  color: AppColors.primary,
                  backgroundColor: AppColors.primaryLight,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricCard(
                  title: 'Унікальних користувачів',
                  value: '$uniqueCount',
                  icon: Icons.group_outlined,
                  color: const Color(0xFF0D9488),
                  backgroundColor: const Color(0xFFCCFBF1),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricCard(
                  title: 'Методи входу',
                  value: 'G: $googleCount | @: $emailCount',
                  icon: Icons.pie_chart_outline,
                  color: const Color(0xFF7C3AED),
                  backgroundColor: const Color(0xFFEDE9FE),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 2. Поточний активний користувач (Firebase User Properties)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: currentUserId != null
                  ? const Color(0xFFF0FDF4)
                  : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: currentUserId != null
                    ? const Color(0xFFBBF7D0)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: currentUserId != null
                            ? const Color(0xFF16A34A)
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      currentUserId != null
                          ? 'АКТИВНИЙ СЕАНС (Firebase User Properties)'
                          : 'СЕАНС: Гість (користувач не залогінений)',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: currentUserId != null
                            ? const Color(0xFF15803D)
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                if (currentUserId != null) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: userProps.entries.map((e) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFF86EFAC)),
                        ),
                        child: Text(
                          '${e.key}: ${e.value}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontFamily: 'monospace',
                            color: Color(0xFF166534),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 3. Заголовок списку аудиторії
          const Text(
            'Журнал автентифікації аудиторії (Хто і як залогінився)',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),

          // 4. Список записів аудиторії
          if (audience.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: const [
                  Icon(Icons.person_search_outlined, size: 36, color: AppColors.textSecondary),
                  SizedBox(height: 8),
                  Text(
                    'Дані аудиторії ще не зібрані.\nУвійдіть через Email або Google, щоб зафіксувати профіль у статистиці.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: audience.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final rec = audience[audience.length - 1 - index];
                final isGoogle = rec.method.toLowerCase().contains('google');
                final isEmail = rec.method.toLowerCase().contains('email');

                final badgeColor = isGoogle
                    ? const Color(0xFF2563EB)
                    : (isEmail ? const Color(0xFF4F46E5) : const Color(0xFF0D9488));
                final badgeBg = isGoogle
                    ? const Color(0xFFDBEAFE)
                    : (isEmail ? const Color(0xFFEEF2FF) : const Color(0xFFCCFBF1));
                final badgeLabel = isGoogle
                    ? 'Google OAuth 2.0'
                    : (isEmail ? 'Email / Пароль' : 'Збережений сеанс');

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      // Аватарка / Ініціали
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: badgeBg,
                        child: isGoogle
                            ? const Text(
                                'G',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF2563EB),
                                ),
                              )
                            : Icon(
                                isEmail ? Icons.alternate_email : Icons.account_circle,
                                size: 18,
                                color: badgeColor,
                              ),
                      ),
                      const SizedBox(width: 12),

                      // Інформація: ХТО залогінився
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  rec.displayName ?? 'Користувач',
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '(${rec.email})',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'UID: ${rec.userId}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontFamily: 'monospace',
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Інформація: ЯК і КОЛИ залогінився
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: badgeBg,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
                            ),
                            child: Text(
                              badgeLabel,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: badgeColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${rec.timestamp.hour.toString().padLeft(2, '0')}:${rec.timestamp.minute.toString().padLeft(2, '0')}:${rec.timestamp.second.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
