import 'package:flutter/material.dart';
import 'package:dev_colorized_log/dev_colorized_log.dart';

/// Tag Demo Page - Interactive demonstration of tag-based log filtering
class TagDemoPage extends StatefulWidget {
  const TagDemoPage({super.key});

  @override
  State<TagDemoPage> createState() => _TagDemoPageState();
}

class _TagDemoPageState extends State<TagDemoPage> {
  // Available tags for selection
  final List<String> _availableTags = [
    'auth',
    'network',
    'database',
    'ui',
    'payment',
    'security',
    'analytics',
    'cache',
    'api',
    'debug',
    'test',
  ];

  // Selected tags
  final Set<String> _selectedTags = {};

  // Whether to enable tag filtering
  bool _isFilterByTags = false;

  // Log messages with their tags
  final List<Map<String, dynamic>> _logMessages = [];

  // ScrollController for auto-scrolling
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Set up Dev logging to capture logs
    Dev.enable = true;
    Dev.isLogShowDateTime = false;
    Dev.isLogFileLocation = false;

    // Generate sample logs with different tags
    _generateSampleLogs();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _generateSampleLogs() {
    _logMessages.clear();
    _logMessages.addAll([
      {
        'message': 'User login successful',
        'tag': 'auth',
        'level': DevLevel.success
      },
      {
        'message': 'Fetching user profile data',
        'tag': 'network',
        'level': DevLevel.info
      },
      {
        'message': 'Database connection established',
        'tag': 'database',
        'level': DevLevel.success
      },
      {'message': 'Rendering home screen', 'tag': 'ui', 'level': DevLevel.info},
      {
        'message': 'Payment gateway initialized',
        'tag': 'payment',
        'level': DevLevel.info
      },
      {
        'message': 'Checking user permissions',
        'tag': 'security',
        'level': DevLevel.verbose
      },
      {
        'message': 'Invalid token detected',
        'tag': 'auth',
        'level': DevLevel.error
      },
      {
        'message': 'API request timeout',
        'tag': 'network',
        'level': DevLevel.warn
      },
      {
        'message': 'Cache hit for key: user_123',
        'tag': 'cache',
        'level': DevLevel.success
      },
      {
        'message': 'Database query executed in 45ms',
        'tag': 'database',
        'level': DevLevel.verbose
      },
      {
        'message': 'Payment transaction completed',
        'tag': 'payment',
        'level': DevLevel.success
      },
      {
        'message': 'Unauthorized access attempt blocked',
        'tag': 'security',
        'level': DevLevel.fatal
      },
      {
        'message': 'User interaction event tracked',
        'tag': 'analytics',
        'level': DevLevel.info
      },
      {
        'message': 'API response: 200 OK',
        'tag': 'api',
        'level': DevLevel.success
      },
      {
        'message': 'Debug: Variable state = loading',
        'tag': 'debug',
        'level': DevLevel.verbose
      },
      {
        'message': 'Running integration tests',
        'tag': 'test',
        'level': DevLevel.info
      },
      {
        'message': 'Session token refreshed',
        'tag': 'auth',
        'level': DevLevel.info
      },
      {
        'message': 'Network connection lost',
        'tag': 'network',
        'level': DevLevel.error
      },
      {
        'message': 'UI component rendered',
        'tag': 'ui',
        'level': DevLevel.verbose
      },
      {
        'message': 'Cache expired for key: session_456',
        'tag': 'cache',
        'level': DevLevel.warn
      },
      {
        'message': 'Payment verification failed',
        'tag': 'payment',
        'level': DevLevel.error
      },
      {
        'message': 'Database backup completed',
        'tag': 'database',
        'level': DevLevel.success
      },
      {
        'message': 'Security scan: No vulnerabilities found',
        'tag': 'security',
        'level': DevLevel.success
      },
      {
        'message': 'Analytics report generated',
        'tag': 'analytics',
        'level': DevLevel.success
      },
      {
        'message': 'API rate limit exceeded',
        'tag': 'api',
        'level': DevLevel.warn
      },
      {
        'message': 'Debug: Response time = 124ms',
        'tag': 'debug',
        'level': DevLevel.verbose
      },
      {
        'message': 'All unit tests passed',
        'tag': 'test',
        'level': DevLevel.success
      },
    ]);
  }

  void _updateTagSelection() {
    setState(() {
      // Update Dev.tags and Dev.isFilterByTags based on selection and switch state
      Dev.isFilterByTags = _isFilterByTags;
      if (_selectedTags.isEmpty) {
        Dev.tags = null; // Clear tags when no tags selected
      } else {
        Dev.tags = Set.from(_selectedTags);
      }
    });
  }

  List<Map<String, dynamic>> get _filteredLogs {
    // When filtering is disabled, show all logs
    if (!_isFilterByTags) {
      return _logMessages;
    }
    // When filtering is enabled but no tags selected, show all logs
    if (_selectedTags.isEmpty) {
      return _logMessages;
    }
    // When filtering is enabled and tags are selected, filter by tags
    return _logMessages
        .where((log) => _selectedTags.contains(log['tag']))
        .toList();
  }

  Color _getLevelColor(DevLevel level) {
    switch (level) {
      case DevLevel.verbose:
        return Colors.grey;
      case DevLevel.normal:
        return Colors.blue;
      case DevLevel.info:
        return Colors.cyan;
      case DevLevel.success:
        return Colors.green;
      case DevLevel.warn:
        return Colors.orange;
      case DevLevel.error:
        return Colors.red;
      case DevLevel.fatal:
        return Colors.purple;
    }
  }

  String _getLevelEmoji(DevLevel level) {
    switch (level) {
      case DevLevel.verbose:
        return '🔍';
      case DevLevel.normal:
        return '🔖';
      case DevLevel.info:
        return '📬';
      case DevLevel.success:
        return '🎉';
      case DevLevel.warn:
        return '🚧';
      case DevLevel.error:
        return '❌';
      case DevLevel.fatal:
        return '💣';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tag Filtering Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Tag selection area
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border(
                bottom: BorderSide(color: Colors.grey[300]!, width: 1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Filter enable/disable switch
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Enable Tag Filtering:',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    Switch(
                      value: _isFilterByTags,
                      onChanged: (value) {
                        setState(() {
                          _isFilterByTags = value;
                          _updateTagSelection();
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _isFilterByTags
                      ? '✓ Filtering enabled - only selected tags shown'
                      : '✗ Filtering disabled - all logs shown with tag info',
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        _isFilterByTags ? Colors.green[700] : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Select Tags:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    if (_selectedTags.isNotEmpty)
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _selectedTags.clear();
                            _updateTagSelection();
                          });
                        },
                        icon: const Icon(Icons.clear, size: 16),
                        label: const Text('Clear All'),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  !_isFilterByTags
                      ? 'No filtering - showing all ${_logMessages.length} logs (${_selectedTags.length} tags selected for reference)'
                      : _selectedTags.isEmpty
                          ? 'No tags selected - showing all ${_logMessages.length} logs'
                          : 'Showing ${_filteredLogs.length} of ${_logMessages.length} logs',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: _availableTags.map((tag) {
                    final isSelected = _selectedTags.contains(tag);
                    final logCount =
                        _logMessages.where((log) => log['tag'] == tag).length;
                    return FilterChip(
                      label: Text('$tag ($logCount)'),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedTags.add(tag);
                          } else {
                            _selectedTags.remove(tag);
                          }
                          _updateTagSelection();
                        });
                      },
                      selectedColor: Colors.blue[100],
                      checkmarkColor: Colors.blue[800],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // Log display area
          Expanded(
            child: _filteredLogs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.filter_list_off,
                            size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No logs match the selected tags',
                          style:
                              TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedTags.clear();
                              _updateTagSelection();
                            });
                          },
                          child: const Text('Clear filters to see all logs'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(8.0),
                    itemCount: _filteredLogs.length,
                    itemBuilder: (context, index) {
                      final log = _filteredLogs[index];
                      final level = log['level'] as DevLevel;
                      final tag = log['tag'] as String;
                      final message = log['message'] as String;

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 4.0, horizontal: 8.0),
                        child: ListTile(
                          dense: true,
                          leading: Text(
                            _getLevelEmoji(level),
                            style: const TextStyle(fontSize: 20),
                          ),
                          title: Text(
                            message,
                            style: TextStyle(
                              color: _getLevelColor(level),
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Text(
                            'Tag: $tag | Level: ${level.name}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getLevelColor(level).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _getLevelColor(level).withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                fontSize: 10,
                                color: _getLevelColor(level),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          setState(() {
            _generateSampleLogs();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sample logs regenerated!'),
              duration: Duration(seconds: 1),
            ),
          );
        },
        icon: const Icon(Icons.refresh),
        label: const Text('Refresh Logs'),
      ),
    );
  }
}
