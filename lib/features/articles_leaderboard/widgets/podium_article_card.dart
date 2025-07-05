import 'package:flutter/material.dart';
import 'package:qine_corner/core/theme/app_colors.dart';
import 'package:qine_corner/features/articles_leaderboard/models/leaderboard_article.dart';

class PodiumArticleCard extends StatelessWidget {
  final LeaderboardArticle article;
  final VoidCallback onViewDetails;
  final double scale;
  final double elevation;

  const PodiumArticleCard({
    Key? key,
    required this.article,
    required this.onViewDetails,
    this.scale = 1.0,
    this.elevation = 4.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    
    // Determine badge color based on rank
    Color badgeColor;
    IconData trophyIcon;
    
    switch (article.rank) {
      case 1:
        badgeColor = Colors.amber.shade700; // Gold
        trophyIcon = Icons.emoji_events;
        break;
      case 2:
        badgeColor = Colors.grey.shade400; // Silver
        trophyIcon = Icons.emoji_events;
        break;
      case 3:
        badgeColor = Colors.brown.shade300; // Bronze
        trophyIcon = Icons.emoji_events;
        break;
      default:
        badgeColor = Colors.blue.shade300;
        trophyIcon = Icons.star;
    }

    return Transform.scale(
      scale: scale,
      child: Card(
        elevation: elevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: article.rank == 1 
                ? Colors.amber.shade700 
                : Colors.transparent,
            width: article.rank == 1 ? 2 : 0,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: article.rank == 1 
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark 
                        ? [Colors.grey.shade900, Colors.grey.shade800]
                        : [Colors.white, Colors.grey.shade50],
                  )
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Rank badge
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: badgeColor.withOpacity(0.4),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        trophyIcon,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '#${article.rank}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Cover image
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: article.coverImage != null
                    ? Image.asset(
                        article.coverImage!,
                        height: 120 * scale,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        height: 120 * scale,
                        color: isDark ? AppColors.darkSurfaceBackground : Colors.grey.shade200,
                        child: Icon(
                          Icons.article,
                          size: 48 * scale,
                          color: isDark ? Colors.grey.shade700 : Colors.grey.shade400,
                        ),
                      ),
              ),
              
              // Content
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      article.author,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.favorite,
                          size: 16,
                          color: Colors.red.shade400,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          article.likeCount.toString(),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.comment,
                          size: 16,
                          color: primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          article.commentCount.toString(),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onViewDetails,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: const Text('View Details'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
