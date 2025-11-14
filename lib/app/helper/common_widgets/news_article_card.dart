import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../domain/entities/news_article.dart';

class NewsArticleCard extends StatelessWidget {
  final NewsArticle article;
  final VoidCallback onTap;

  const NewsArticleCard({super.key, required this.article, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: "News card",
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Stack(children: [buildContent(context), buildOpenLinkIcon(context)]),
        ),
      ),
    );
  }

  Widget buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [if (article.urlToImage.isNotEmpty) buildImage(context), buildArticleText(context)],
    );
  }

  Widget buildOpenLinkIcon(BuildContext context) {
    return Positioned(
      top: 8,
      right: 8,
      child: Semantics(
        label: "Open article in browser",
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.open_in_new, size: 20, color: Theme.of(context).primaryColor),
        ),
      ),
    );
  }

  Widget buildArticleText(BuildContext context) {
    return Semantics(
      label: "Article content",
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Source
            buildSource(context),
            const SizedBox(height: 8),

            // Title
            Semantics(
              label: "Article title",
              child: Text(
                article.title,
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(height: 8),

            // Description (only if present)
            if (article.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Semantics(
                label: "Article description",
                child: Text(
                  article.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget buildSource(BuildContext context) {
    return Semantics(
      label: "Article source: ${article.sourceName}${article.author.isNotEmpty ? ', by ${article.author}' : ''}",
      child: Row(
        children: [
          Text(
            article.sourceName,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: Theme.of(context).primaryColor),
          ),
          const SizedBox(width: 8),
          if (article.author.isNotEmpty) ...[
            Icon(Icons.person, size: 14, color: Theme.of(context).primaryColor),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                article.author,
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: Theme.of(context).primaryColor),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget buildImage(BuildContext context) {
    return Semantics(
      label: "Article image",
      image: true,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        child: CachedNetworkImage(
          imageUrl: article.urlToImage,
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
          placeholder: (context, url) => Shimmer.fromColors(
            baseColor: Theme.of(context).primaryColor,
            highlightColor: Theme.of(context).colorScheme.secondary,
            child: Container(
              height: 200,
              width: double.infinity,
              color: Theme.of(context).primaryColor,
            ),
          ),
          errorWidget: (context, url, error) => Container(
            height: 200,
            color: Theme.of(context).primaryColor,
            child: Icon(Icons.broken_image, size: 64, color: Theme.of(context).colorScheme.secondary),
          ),
        ),
      ),
    );
  }
}
