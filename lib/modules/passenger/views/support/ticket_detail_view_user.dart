import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';
import 'package:menahariya/modules/passenger/controllers/support_controller.dart';
import 'package:menahariya/data/models/common/support_ticket_model.dart';

class TicketDetailViewUser extends GetView<SupportController> {
  const TicketDetailViewUser({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final ticket = Get.arguments['ticket'] as SupportTicketModel;
    final replyController = TextEditingController();
    final isSending = false.obs;

    // Load replies when view opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchTicketReplies(ticket.id);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          ticket.subject.length > 30
              ? '${ticket.subject.substring(0, 30)}...'
              : ticket.subject,
        ),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
        actions: [
          // Status badge in app bar
          Container(
            margin: const EdgeInsets.only(right: AppDimens.margin16),
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.padding12,
              vertical: AppDimens.padding6,
            ),
            decoration: BoxDecoration(
              color: ticket.statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimens.radius20),
            ),
            child: Text(
              ticket.statusDisplay,
              style: theme.textTheme.bodySmall?.copyWith(
                color: ticket.statusColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Original ticket message
          Container(
            padding: const EdgeInsets.all(AppDimens.padding16),
            margin: const EdgeInsets.all(AppDimens.padding16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.grey800 : AppColors.grey50,
              borderRadius: BorderRadius.circular(AppDimens.radius12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.person_rounded,
                      size: 16,
                      color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                    ),
                    const SizedBox(width: AppDimens.margin8),
                    Expanded(
                      child: Text(
                        ticket.name,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      _formatDate(ticket.createdAt),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.margin12),
                Text(
                  ticket.message,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: AppDimens.margin8),
                Row(
                  children: [
                    Icon(
                      Icons.email_rounded,
                      size: 14,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                    const SizedBox(width: AppDimens.margin4),
                    Expanded(
                      child: Text(
                        ticket.email,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Replies list
          Expanded(
            child: Obx(() {
              if (controller.isLoadingReplies && controller.replies.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.replies.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 48,
                        color: isDark ? AppColors.grey600 : AppColors.grey400,
                      ),
                      const SizedBox(height: AppDimens.margin16),
                      Text(
                        'No replies yet',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: AppDimens.margin16),
                      Text(
                        'Type your reply below',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? AppColors.textHintDark : AppColors.textHintLight,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: AppDimens.padding16),
                itemCount: controller.replies.length,
                itemBuilder: (context, index) {
                  final reply = controller.replies[index];
                  final isUserReply = reply.userRole != 'admin';
                  return _buildReplyBubble(context, reply, isUserReply);
                },
              );
            }),
          ),
          // Reply input (only if ticket is not closed/resolved)
          if (ticket.status != 'closed' && ticket.status != 'resolved')
            Container(
              padding: const EdgeInsets.all(AppDimens.padding12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.grey800 : Colors.white,
                border: Border(
                  top: BorderSide(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: replyController,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: 'Type your reply...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppDimens.radius24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: isDark ? AppColors.grey700 : AppColors.grey100,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppDimens.padding16,
                          vertical: AppDimens.padding12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimens.margin8),
                  Obx(() => CircleAvatar(
                    backgroundColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                    child: IconButton(
                      icon: isSending.value
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Icon(Icons.send_rounded, color: Colors.white),
                      onPressed: isSending.value
                          ? null
                          : () async {
                        if (replyController.text.trim().isEmpty) {
                          Get.snackbar('Error', 'Please enter a message');
                          return;
                        }
                        isSending.value = true;
                        final success = await controller.addReply(
                          ticket.id,
                          replyController.text.trim(),
                        );
                        isSending.value = false;
                        if (success) {
                          replyController.clear();
                          await controller.fetchTicketReplies(ticket.id);
                          await controller.fetchMyTickets();
                        }
                      },
                    ),
                  )),
                ],
              ),
            ),
          if (ticket.status == 'resolved' || ticket.status == 'closed')
            Container(
              padding: const EdgeInsets.all(AppDimens.padding16),
              color: isDark ? AppColors.grey800 : Colors.grey.shade100,
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: ticket.status == 'resolved' ? Colors.green : Colors.grey,
                      size: 32,
                    ),
                    const SizedBox(height: AppDimens.margin8),
                    Text(
                      ticket.status == 'resolved'
                          ? 'This ticket has been resolved'
                          : 'This ticket is closed',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReplyBubble(BuildContext context, ReplyModel reply, bool isUserReply) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Align(
      alignment: isUserReply ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimens.margin12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: isUserReply ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: AppDimens.margin12,
                right: AppDimens.margin12,
                bottom: AppDimens.margin4,
              ),
              child: Text(
                isUserReply ? 'You' : (reply.user?.fullName ?? 'Admin'),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isUserReply
                      ? Colors.blue
                      : (isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(AppDimens.padding12),
              decoration: BoxDecoration(
                color: isUserReply
                    ? Colors.blue
                    : (isDark ? AppColors.primaryGreen.withOpacity(0.2) : AppColors.primaryGreen.withOpacity(0.1)),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(AppDimens.radius12),
                  topRight: const Radius.circular(AppDimens.radius12),
                  bottomLeft: Radius.circular(isUserReply ? AppDimens.radius12 : AppDimens.radius4),
                  bottomRight: Radius.circular(isUserReply ? AppDimens.radius4 : AppDimens.radius12),
                ),
              ),
              child: Text(
                reply.message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isUserReply ? Colors.white : (isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: AppDimens.margin12,
                right: AppDimens.margin12,
                top: AppDimens.margin4,
              ),
              child: Text(
                DateFormat('hh:mm a, MMM dd').format(reply.createdAt),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  color: isDark ? AppColors.textHintDark : AppColors.textHintLight,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}