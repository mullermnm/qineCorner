import 'package:flutter/material.dart';
import '../../../core/models/note.dart';
import 'package:timeago/timeago.dart' as timeago;

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final bool isListView;

  const NoteCard({
    Key? key,
    required this.note,
    required this.onTap,
    this.isListView = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: isListView ? _buildListView(context) : _buildGridView(context),
        ),
      ),
    );
  }

  Widget _buildGridView(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                note.bookTitle,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Colors.grey[600],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (note.isImportant)
              Icon(Icons.star, color: Colors.amber, size: 20),
          ],
        ),
        SizedBox(height: 8),
        Expanded(
          child: Text(
            note.noteText,
            style: Theme.of(context).textTheme.bodyMedium,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
            SizedBox(width: 4),
            Expanded(
              child: Text(
                timeago.format(note.updatedAt ?? note.createdAt),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
        if (note.tags.isNotEmpty) ...[
          SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: note.tags.map((tag) => 
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Chip(
                    label: Text(
                      tag,
                      style: TextStyle(fontSize: 12),
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ).toList(),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildListView(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      note.bookTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  if (note.isImportant)
                    Icon(Icons.star, color: Colors.amber),
                ],
              ),
              SizedBox(height: 8),
              Text(
                note.noteText,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 4),
                  Text(
                    timeago.format(note.updatedAt ?? note.createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              if (note.tags.isNotEmpty) ...[
                SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: note.tags.map((tag) => 
                    Chip(
                      label: Text(
                        tag,
                        style: TextStyle(fontSize: 12),
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                  ).toList(),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
