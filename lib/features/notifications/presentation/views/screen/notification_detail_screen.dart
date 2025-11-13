import 'package:flutter/material.dart';

import '../../../../../app/domain/entities/push_notification.dart';

class NotificationDetailScreen extends StatelessWidget {
  final PushNotification notification;
  final String formattedDate;

  const NotificationDetailScreen({
    super.key,
    required this.notification,
    required this.formattedDate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: buildBody(),
    );
  }

  PreferredSizeWidget buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      title: Text(
        'Notification',
        style: TextStyle(color: Theme.of(context).colorScheme.secondary),
      ),
      iconTheme: IconThemeData(
        color: Theme.of(context).colorScheme.secondary,
      ),
    );
  }

  Widget buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildTimestamp(),
          const SizedBox(height: 16),
          buildTitle(),
          const SizedBox(height: 16),
          Divider(color: Colors.grey[300]),
          const SizedBox(height: 16),
          buildBodyText(),
          const SizedBox(height: 24),
          if (notification.imageUrl != null) ...[
            buildImageSection(),
            const SizedBox(height: 24),
          ],
          if (notification.data != null && notification.data!.isNotEmpty)
            buildAdditionalDataSection(),
        ],
      ),
    );
  }

  Widget buildTimestamp() {
    return Text(
      formattedDate,
      style: TextStyle(
        fontSize: 12,
        color: Colors.grey[600],
      ),
    );
  }

  Widget buildTitle() {
    return Text(
      notification.title,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget buildBodyText() {
    return Text(
      notification.body,
      style: const TextStyle(
        fontSize: 16,
        height: 1.5,
      ),
    );
  }

  Widget buildImageSection() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        notification.imageUrl!,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 200,
            color: Colors.grey[200],
            child: const Center(
              child: Icon(
                Icons.broken_image,
                size: 48,
                color: Colors.grey,
              ),
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: 200,
            color: Colors.grey[200],
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      ),
    );
  }

  Widget buildAdditionalDataSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional Data',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: notification.data!.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                    ),
                    children: [
                      TextSpan(
                        text: '${entry.key}: ',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: entry.value.toString(),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
