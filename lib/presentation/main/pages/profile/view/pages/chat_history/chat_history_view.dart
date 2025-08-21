import 'package:ai_movie_suggestion/domain/model/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ChatHistoryView extends StatefulWidget {
  final List<ChatHistoryModel> chatHistory;
  const ChatHistoryView({super.key, required this.chatHistory});

  @override
  State<ChatHistoryView> createState() => _ChatHistoryViewState();
}

class _ChatHistoryViewState extends State<ChatHistoryView> {
  final ScrollController _scrollController = ScrollController();
  late List<ChatHistoryModel> _sortedHistory;

  @override
  void initState() {
    super.initState();
    _sortedHistory = List.from(widget.chatHistory);
    _sortHistoryByDate();
  }

  void _sortHistoryByDate() {
    _sortedHistory.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  String _getMessageText(ChatHistoryModel chat) {
    if (chat.role == 'user') {
      return chat.message as String;
    } else {
      // For bot messages, check if it's a movie recommendation or regular text
      if (chat.message is Map<String, dynamic>) {
        final movieData = chat.message as Map<String, dynamic>;
        final title = movieData['title'] as String? ?? '';
        final overview = movieData['overview'] as String? ?? '';
        return '$title $overview';
      } else if (chat.message is String) {
        return chat.message as String;
      }
      return '';
    }
  }

  void _clearHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A3E),
        title: const Text(
          'Clear Chat History',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to clear all chat history? This action cannot be undone.',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _sortedHistory.clear();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Chat history cleared'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _copyMessage(String message) {
    Clipboard.setData(ClipboardData(text: message));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Message copied to clipboard'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 7) {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Chat History',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          if (_sortedHistory.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all, color: Colors.white),
              onPressed: _clearHistory,
              tooltip: 'Clear history',
            ),
        ],
      ),
      body: _sortedHistory.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: _sortedHistory.length,
              itemBuilder: (context, index) {
                final chat = _sortedHistory[index];
                final isUser = chat.role == 'user';
                return _buildChatItem(chat, isUser);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(
              Icons.chat_bubble_outline,
              size: 50,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Chat History',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Start a conversation to see your chat history here.',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChatItem(ChatHistoryModel chat, bool isUser) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            // Bot avatar
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple.shade300, Colors.blue.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.smart_toy,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
          ],

          Expanded(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // Message bubble
                Container(
                  padding: const EdgeInsets.all(16),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  decoration: BoxDecoration(
                    color: isUser
                        ? Colors.blue.withOpacity(0.8)
                        : Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isUser
                          ? Colors.blue.withOpacity(0.3)
                          : Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: isUser
                      ? Text(
                          chat.message as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        )
                      : _buildBotMessage(chat.message),
                ),

                const SizedBox(height: 4),

                // Timestamp and actions
                Row(
                  mainAxisAlignment:
                      isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                  children: [
                    Text(
                      _formatTimestamp(chat.timestamp),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _copyMessage(_getMessageText(chat)),
                      child: const Icon(
                        Icons.copy,
                        color: Colors.grey,
                        size: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (isUser) ...[
            const SizedBox(width: 12),
            // User avatar
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 18,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBotMessage(dynamic message) {
    if (message is Map<String, dynamic>) {
      return _buildMovieResponse(message);
    } else if (message is String) {
      return Text(
        message,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      );
    } else {
      return const Text(
        'Invalid message format',
        style: TextStyle(
          color: Colors.red,
          fontSize: 16,
        ),
      );
    }
  }

  Widget _buildMovieResponse(Map<String, dynamic> movieData) {
    final title = movieData['title'] as String? ?? 'Unknown Title';
    final overview = movieData['overview'] as String? ?? '';
    final posterPath = movieData['poster_path'] as String?;
    final releaseDate = movieData['release_date'] as String?;
    final voteAverage = (movieData['vote_average'] as num?)?.toDouble() ?? 0.0;
    final genres = movieData['genres'] as List<dynamic>? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 60,
              height: 90,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.withOpacity(0.3),
              ),
              child: posterPath != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        'https://image.tmdb.org/t/p/w200$posterPath',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.movie,
                            color: Colors.white,
                            size: 30,
                          );
                        },
                      ),
                    )
                  : const Icon(
                      Icons.movie,
                      color: Colors.white,
                      size: 30,
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (releaseDate != null && releaseDate.isNotEmpty)
                    Text(
                      releaseDate,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.orange,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        voteAverage.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        if (overview.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            overview,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        if (genres.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: genres.take(3).map<Widget>((genre) {
              final genreName = genre is Map<String, dynamic>
                  ? (genre['name'] as String? ?? '')
                  : genre.toString();
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  genreName,
                  style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 10,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}