import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../domain/entities/news_article.dart';

class NewsArticleCard extends StatelessWidget {
  final NewsArticle article;

  const NewsArticleCard({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (article.urlToImage.isNotEmpty) buildImage(context),
          buildContent(context),
        ],
      ),
    );
  }

  Widget buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Source
          Text(
            article.sourceName,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 8),

          // Title
          Text(
            article.title,
            style: Theme.of(context).textTheme.titleMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),

          // Description
          if (article.description.isNotEmpty)
            Text(
              article.description,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          const SizedBox(height: 8),

          // Author
          if (article.author.isNotEmpty) buildAuthor(context),
        ],
      ),
    );
  }

  Row buildAuthor(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.person, size: 14),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            article.author,
            style: Theme.of(context).textTheme.labelSmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget buildImage(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: CachedNetworkImage(
        imageUrl: article.urlToImage,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (context, url) => Shimmer.fromColors(
          baseColor: theme.primaryColor,
          highlightColor: theme.colorScheme.secondary,
          child: Container(
            height: 200,
            width: double.infinity,
            color: theme.primaryColor,
          ),
        ),
        errorWidget: (context, url, error) => Container(
          height: 200,
          color: theme.primaryColor,
          child: const Icon(Icons.broken_image, size: 64),
        ),
      ),
    );
  }
}
