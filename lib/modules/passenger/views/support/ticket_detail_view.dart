import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';
import 'package:menahariya/core/widgets/buttons/primary_button.dart';
import 'package:menahariya/modules/admin/controllers/admin_support_controller.dart';
import 'package:menahariya/data/models/common/support_ticket_model.dart';

import '../../controllers/support_controller.dart';

class AdminTicketDetailView extends GetView<AdminSupportController> {
  const AdminTicketDetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final ticket = Get.arguments['ticket'] as SupportTicketModel;
    final replyController = TextEditingController();
    final isSending = false.obs;
    final selectedStatus = ticket.status.obs;

    // Load replies when view opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchTicketReplies(ticket.id);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Ticket: ${ticket.subject}'),
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        actions: [
          // Status dropdown in app bar
          Obx(() => Container(
            margin: const EdgeInsets.only(right: AppDimens.margin16),
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.padding8, vertical: AppDimens.padding4),
            decoration: BoxDecoration(
              color: _getStatusColor(selectedStatus.value, isDark).withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimens.radius20),
            ),
            child: DropdownButton<String>(
              value: selectedStatus.value,
              underline: const SizedBox(),
              icon: Icon(
                Icons.arrow_drop_down,
                color: _getStatusColor(selectedStatus.value, isDark),
              ),
              style: TextStyle(
                color: _getStatusColor(selectedStatus.value, isDark),
                fontWeight: FontWeight.w500,
              ),
              items: const [
                DropdownMenuItem(value: 'pending', child: Text('Pending')),
                DropdownMenuItem(value: 'in_progress', child: Text('In Progress')),
                DropdownMenuItem(value: 'resolved', child: Text('Resolved')),
                DropdownMenuItem(value: 'closed', child: Text('Closed')),
              ],
              onChanged: (value) {
                if (value != null) {
                  selectedStatus.value = value;
                  controller.updateTicketStatus(ticket.id, value);
                }
              },
            ),
          )),
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
                    Text(
                      ticket.name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
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
                Text(
                  ticket.email,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
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
                        'Reply to start the conversation',
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
                  final isAdminReply = reply.userRole == 'admin';
                  return _buildReplyBubble(context, reply, isAdminReply);
                },
              );
            }),
          ),
          // Reply input
          if (ticket.status != 'closed')
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
                          // Refresh replies
                          await controller.fetchTicketReplies(ticket.id);
                        }
                      },
                    ),
                  )),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReplyBubble(BuildContext context, ReplyModel reply, bool isAdminReply) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Align(
      alignment: isAdminReply ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimens.margin12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: isAdminReply ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: AppDimens.margin12,
                right: AppDimens.margin12,
                bottom: AppDimens.margin4,
              ),
              child: Text(
                isAdminReply ? 'Admin' : (reply.user?.fullName ?? 'User'),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isAdminReply
                      ? (isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen)
                      : Colors.blue,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(AppDimens.padding12),
              decoration: BoxDecoration(
                color: isAdminReply
                    ? (isDark ? AppColors.primaryGreen.withOpacity(0.2) : AppColors.primaryGreen.withOpacity(0.1))
                    : (isDark ? AppColors.grey800 : Colors.grey.shade100),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(AppDimens.radius12),
                  topRight: const Radius.circular(AppDimens.radius12),
                  bottomLeft: Radius.circular(isAdminReply ? AppDimens.radius4 : AppDimens.radius12),
                  bottomRight: Radius.circular(isAdminReply ? AppDimens.radius12 : AppDimens.radius4),
                ),
              ),
              child: Text(
                reply.message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isAdminReply
                      ? (isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen)
                      : (isDark ? Colors.white : Colors.black87),
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

  Color _getStatusColor(String status, bool isDark) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'in_progress': return Colors.blue;
      case 'resolved': return Colors.green;
      case 'closed': return isDark ? Colors.grey : Colors.grey.shade600;
      default: return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}