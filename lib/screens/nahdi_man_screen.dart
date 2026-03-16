import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../providers/app_providers.dart';

// Providers for Nahdi Man Screen
final selectedMethodProvider = StateProvider<String>((ref) => 'GET');
final isLoadingProviderNM = StateProvider<bool>((ref) => false);
final statusCodeProvider = StateProvider<int?>((ref) => null);
final requestDurationProvider = StateProvider<Duration?>((ref) => null);
final responseSizeProvider = StateProvider<int?>((ref) => null);
final searchQueryProvider = StateProvider<String>((ref) => '');

class NahdiManScreen extends ConsumerStatefulWidget {
  final String? initialCurl;
  final String? initialMethod;
  final String? initialUrl;
  final String? initialBody;
  /// When true, shows an "Update to Firebase" button that builds cURL from current state and calls [onUpdateToFirebase].
  final bool showUpdateToFirebaseButton;
  /// Callback when user taps "Update to Firebase". Receives the current request as a cURL string.
  final Future<void> Function(String curl)? onUpdateToFirebase;

  const NahdiManScreen({
    super.key,
    this.initialCurl,
    this.initialMethod,
    this.initialUrl,
    this.initialBody,
    this.showUpdateToFirebaseButton = false,
    this.onUpdateToFirebase,
  });

  @override
  ConsumerState<NahdiManScreen> createState() => _NahdiManScreenState();
}

class _NahdiManScreenState extends ConsumerState<NahdiManScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _tokenController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  final TextEditingController _responseController = TextEditingController();
  
  final List<MapEntry<String, String>> _headers = [];
  final List<MapEntry<String, String>> _queryParams = [];
  
  // CORS proxy is automatically enabled on web, disabled on other platforms
  bool get _useCorsProxy => kIsWeb;
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  final List<String> _httpMethods = ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'HEAD', 'OPTIONS'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Initialize with provided values
    if (widget.initialCurl != null && widget.initialCurl!.isNotEmpty) {
      // Parse curl command silently (no toast when navigating from View)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _parseCurl(widget.initialCurl!, showSuccessToast: false);
      });
        } else {
          // Set initial values directly - delay provider modification
          Future(() {
            if (mounted) {
              if (widget.initialMethod != null) {
                ref.read(selectedMethodProvider.notifier).state = widget.initialMethod!;
              }
              if (widget.initialUrl != null) {
                _urlController.text = widget.initialUrl!;
              }
              if (widget.initialBody != null) {
                _bodyController.text = widget.initialBody!;
              }
            }
          });
        }
    
    // Add listener to auto-detect and parse cURL commands
    _urlController.addListener(_onUrlChanged);
  }
  
  bool _isParsingCurl = false;
  
  void _onUrlChanged() {
    // Don't trigger if we're currently parsing (to avoid infinite loop)
    if (_isParsingCurl) return;
    
    final text = _urlController.text.trim();
    // Check if the text looks like a cURL command
    if (text.toLowerCase().startsWith('curl') || 
        (text.contains('curl') && (text.contains('-X') || text.contains('-H') || text.contains('http')))) {
      // Small delay to ensure the paste is complete
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted && _urlController.text.trim() == text && !_isParsingCurl) {
          _parseCurl(text);
        }
      });
    }
  }

  @override
  void dispose() {
    _urlController.removeListener(_onUrlChanged);
    _urlController.dispose();
    _tokenController.dispose();
    _bodyController.dispose();
    _responseController.dispose();
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _addHeader() {
    setState(() {
      _headers.add(const MapEntry('', ''));
    });
  }

  void _removeHeader(int index) {
    setState(() {
      _headers.removeAt(index);
    });
  }

  void _updateHeader(int index, String key, String value) {
    setState(() {
      _headers[index] = MapEntry(key, value);
    });
  }

  void _addQueryParam() {
    setState(() {
      _queryParams.add(const MapEntry('', ''));
    });
  }

  void _removeQueryParam(int index) {
    setState(() {
      _queryParams.removeAt(index);
    });
  }

  void _updateQueryParam(int index, String key, String value) {
    setState(() {
      _queryParams[index] = MapEntry(key, value);
    });
  }

  Future<void> _sendRequest() async {
    if (_urlController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Center(child: Text('Please enter a URL', style: TextStyle(color: Colors.white)))),
      );
      return;
    }

    ref.read(isLoadingProviderNM.notifier).state = true;
    _responseController.clear();
    ref.read(statusCodeProvider.notifier).state = null;
    ref.read(requestDurationProvider.notifier).state = null;
    ref.read(responseSizeProvider.notifier).state = null;
    
    // Track request start time
    final startTime = DateTime.now();

    try {
      // Build headers
      final headers = <String, String>{
        'Accept': 'application/json',
      };
      
      // Add tokens - use login tokens if toggle is enabled, otherwise use manual token
      // Strip any leading "Bearer " to avoid "Bearer Bearer xxx" (causes malformed token error)
      String? _stripBearer(String? t) => t != null && t.isNotEmpty
          ? (t.trim().toLowerCase().startsWith('bearer ')
              ? t.trim().substring(7).trim()
              : t.trim())
          : null;

      final useLoginToken = ref.read(useLoginTokenProvider);
      final loginAccessToken = _stripBearer(ref.read(loginAccessTokenProvider));
      final loginIdToken = _stripBearer(ref.read(loginIdTokenProvider));

      // Set Authorization header with access_token
      if (useLoginToken && loginAccessToken != null && loginAccessToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $loginAccessToken';
      } else if (_tokenController.text.trim().isNotEmpty) {
        final manualToken = _stripBearer(_tokenController.text.trim());
        if (manualToken != null && manualToken.isNotEmpty) {
          headers['Authorization'] = 'Bearer $manualToken';
        }
      }

      // Set X-ID-Token header with id_token if available
      if (useLoginToken && loginIdToken != null && loginIdToken.isNotEmpty) {
        headers['X-ID-Token'] = 'Bearer $loginIdToken';
      }
      
      // Add custom headers (but don't allow Authorization or X-ID-Token to be overridden if using login tokens)
      for (final header in _headers) {
        if (header.key.trim().isNotEmpty && header.value.trim().isNotEmpty) {
          final headerKey = header.key.trim().toLowerCase();
          // Skip Authorization and X-ID-Token headers if we're using login tokens (to prevent override)
          if (useLoginToken && 
              ((loginAccessToken != null && loginAccessToken.isNotEmpty && headerKey == 'authorization') ||
               (loginIdToken != null && loginIdToken.isNotEmpty && headerKey == 'x-id-token'))) {
            continue; // Skip this header to preserve the login tokens
          }
          headers[header.key.trim()] = header.value.trim();
        }
      }

      // Build query parameters
      final queryParams = <String, String>{};
      for (final param in _queryParams) {
        if (param.key.trim().isNotEmpty && param.value.trim().isNotEmpty) {
          queryParams[param.key.trim()] = param.value.trim();
        }
      }

      // Prepare body
      String? bodyString;
      final selectedMethod = ref.read(selectedMethodProvider);
      if (_bodyController.text.trim().isNotEmpty && 
          ['POST', 'PUT', 'PATCH'].contains(selectedMethod)) {
        bodyString = _bodyController.text.trim();
        if (!headers.containsKey('Content-Type')) {
          headers['Content-Type'] = 'application/json';
        }
      }

      // Handle CORS proxy if enabled
      String requestUrl = _urlController.text.trim();
      
      // Build full URL with query parameters if not using proxy
      if (!_useCorsProxy && queryParams.isNotEmpty) {
        final uri = Uri.parse(requestUrl);
        final updatedUri = uri.replace(queryParameters: {
          ...uri.queryParameters,
          ...queryParams,
        });
        requestUrl = updatedUri.toString();
      }
      
      // Only use CORS proxy on web platform (desktop/mobile don't have CORS restrictions)
      bool shouldUseProxy = _useCorsProxy && kIsWeb;
      
      String? originalUrl;
      if (shouldUseProxy) {
        // When using proxy, include query params in the original URL
        if (queryParams.isNotEmpty) {
          final uri = Uri.parse(requestUrl);
          final updatedUri = uri.replace(queryParameters: {
            ...uri.queryParameters,
            ...queryParams,
          });
          requestUrl = updatedUri.toString();
        }
        
        originalUrl = requestUrl; // Save original URL for fallback
        final encodedUrl = Uri.encodeComponent(requestUrl);
        
        if (selectedMethod == 'GET') {
          // Try multiple proxy services for GET requests
          requestUrl = 'https://api.allorigins.win/raw?url=$encodedUrl';
        } else {
          // For POST/PUT/PATCH/DELETE: corsproxy forwards method+body; cors.lol often returns 405
          requestUrl = 'https://corsproxy-8uo5.onrender.com/?url=$encodedUrl';
        }
        
        // Debug: Log that we're using proxy
        if (kDebugMode) {
          print('Using CORS proxy: $requestUrl');
        }
      }

      // Send request using http package with multiple fallback attempts
      http.Response? response;
      final uri = Uri.parse(requestUrl);
      
      List<String> proxyAttempts = [];
      if (shouldUseProxy && originalUrl != null) {
        final encodedUrl = Uri.encodeComponent(originalUrl);
        if (selectedMethod == 'GET') {
          // Proxies that work in production (corsproxy.io blocks non-localhost)
          proxyAttempts = [
            'https://api.allorigins.win/raw?url=$encodedUrl',
            'https://api.cors.lol/?url=$encodedUrl',
            'https://api.allorigins.win/get?url=$encodedUrl',
          ];
        } else {
          // For POST/PUT/DELETE: corsproxy forwards method+body; cors.lol often returns 405
          proxyAttempts = [
            'https://corsproxy-8uo5.onrender.com/?url=$encodedUrl',
            'https://api.cors.lol/?url=$encodedUrl',
          ];
        }
      }
      
      Exception? lastError;
      bool requestSuccessful = false;
      
      // On web with CORS proxy enabled, skip direct request (will always fail due to CORS)
      // Go straight to proxy to save time. Postman works fast because it's a desktop app (no CORS).
      if (!shouldUseProxy) {
        // Direct request
        try {
          switch (selectedMethod) {
            case 'GET':
              response = await http.get(uri, headers: headers).timeout(
                const Duration(seconds: 30),
              );
              break;
            case 'POST':
              response = await http.post(
                uri,
                headers: headers,
                body: bodyString,
              ).timeout(const Duration(seconds: 30));
              break;
            case 'PUT':
              response = await http.put(
                uri,
                headers: headers,
                body: bodyString,
              ).timeout(const Duration(seconds: 30));
              break;
            case 'DELETE':
              response = await http.delete(
                uri,
                headers: headers,
                body: bodyString,
              ).timeout(const Duration(seconds: 30));
              break;
            case 'PATCH':
              response = await http.patch(
                uri,
                headers: headers,
                body: bodyString,
              ).timeout(const Duration(seconds: 30));
              break;
            default:
              throw Exception('Unsupported method: $selectedMethod');
          }
          requestSuccessful = true;
        } catch (e) {
          lastError = e is Exception ? e : Exception(e.toString());
        }
      } else if (!requestSuccessful && shouldUseProxy) {
        // Use proxy with optimized timeout
        // Note: Public CORS proxies are inherently slower than direct requests
        // Postman is fast (113ms) because it's a desktop app with no CORS restrictions
        const proxyTimeout = Duration(seconds: 8); // Reduced timeout - fail faster if proxy is slow
        
        for (int i = 0; i < proxyAttempts.length && !requestSuccessful; i++) {
          try {
            final proxyUrl = proxyAttempts[i];
            if (kDebugMode) {
              print('Trying proxy ${i + 1}/${proxyAttempts.length}: $proxyUrl');
            }
            
            switch (selectedMethod) {
              case 'GET':
                response = await http.get(
                  Uri.parse(proxyUrl),
                  headers: headers,
                ).timeout(proxyTimeout);
                requestSuccessful = true;
                requestUrl = proxyUrl; // Update for response parsing
                break;
              case 'POST':
                response = await http.post(
                  Uri.parse(proxyUrl),
                  headers: headers,
                  body: bodyString,
                ).timeout(proxyTimeout);
                requestSuccessful = true;
                requestUrl = proxyUrl;
                break;
              case 'PUT':
                response = await http.put(
                  Uri.parse(proxyUrl),
                  headers: headers,
                  body: bodyString,
                ).timeout(proxyTimeout);
                requestSuccessful = true;
                requestUrl = proxyUrl;
                break;
              case 'DELETE':
                response = await http.delete(
                  Uri.parse(proxyUrl),
                  headers: headers,
                  body: bodyString,
                ).timeout(proxyTimeout);
                requestSuccessful = true;
                requestUrl = proxyUrl;
                break;
              case 'PATCH':
                response = await http.patch(
                  Uri.parse(proxyUrl),
                  headers: headers,
                  body: bodyString,
                ).timeout(proxyTimeout);
                requestSuccessful = true;
                requestUrl = proxyUrl;
                break;
            }
          } catch (e) {
            lastError = e is Exception ? e : Exception(e.toString());
            if (kDebugMode) {
              print('Proxy ${i + 1} failed: $e');
            }
            // Continue to next proxy immediately (don't wait for full timeout)
          }
        }
      }
      
      // If all attempts failed, throw the last error
      if (!requestSuccessful || response == null) {
        throw lastError ?? Exception('All proxy attempts failed');
      }

      // Handle proxy response format
      dynamic responseData;
      if (shouldUseProxy && selectedMethod == 'GET') {
        // Check if we used the raw endpoint (faster, returns direct response)
        if (requestUrl.contains('/raw?')) {
          // Raw endpoint returns the response directly
          try {
            responseData = jsonDecode(response.body);
          } catch (e) {
            responseData = response.body;
          }
        } else {
          // /get endpoint returns data in a 'contents' field
          try {
            final jsonData = jsonDecode(response.body);
            if (jsonData is Map && jsonData.containsKey('contents')) {
              final contents = jsonData['contents'];
              if (contents is String) {
                try {
                  responseData = jsonDecode(contents);
                } catch (e) {
                  responseData = contents;
                }
              } else {
                responseData = contents;
              }
            } else {
              responseData = jsonData;
            }
          } catch (e) {
            responseData = response.body;
          }
        }
      } else {
        // Parse response body (non-GET or non-proxy)
        try {
          responseData = jsonDecode(response.body);
        } catch (e) {
          responseData = response.body;
        }
      }

      // Calculate request duration and response size
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      
      // Check if this is a login response and extract access_token
      // Handle both direct responses and proxy-wrapped responses
      dynamic dataToCheck = responseData;
      if (responseData is Map) {
        // If response is wrapped in 'contents' (from proxy), check that too
        if (responseData.containsKey('contents')) {
          final contents = responseData['contents'];
          if (contents is Map) {
            dataToCheck = contents;
          }
        }
        
        // Check for access_token and id_token in the response
        if (dataToCheck is Map) {
          bool tokensSaved = false;
          
          // Extract access_token (strip "Bearer " if present to avoid double-prefix on send)
          if (dataToCheck.containsKey('access_token')) {
            var accessToken = dataToCheck['access_token'] as String?;
            if (accessToken != null && accessToken.isNotEmpty) {
              accessToken = accessToken.trim();
              if (accessToken.toLowerCase().startsWith('bearer ')) {
                accessToken = accessToken.substring(7).trim();
              }
              ref.read(loginAccessTokenProvider.notifier).state = accessToken;
              tokensSaved = true;
            }
          }

          // Extract id_token (strip "Bearer " if present)
          if (dataToCheck.containsKey('id_token')) {
            var idToken = dataToCheck['id_token'] as String?;
            if (idToken != null && idToken.isNotEmpty) {
              idToken = idToken.trim();
              if (idToken.toLowerCase().startsWith('bearer ')) {
                idToken = idToken.substring(7).trim();
              }
              ref.read(loginIdTokenProvider.notifier).state = idToken;
              tokensSaved = true;
            }
          }
          
          // Show notification if tokens were saved
          if (tokensSaved && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Center(child: Text('Login tokens (access_token & id_token) saved! You can now use them for other requests.', style: const TextStyle(color: Colors.white))),
                backgroundColor: Color(0xFF10B981),
                duration: Duration(seconds: 3),
              ),
            );
          }
        }
      }
      
      // Format response once (used for both display and size calculation)
      final formattedResponse = _formatResponse(responseData);
      
      // Calculate size from the actual response data (not the proxy wrapper)
      final responseSize = utf8.encode(formattedResponse).length;
      
      ref.read(statusCodeProvider.notifier).state = response.statusCode;
      ref.read(requestDurationProvider.notifier).state = duration;
      ref.read(responseSizeProvider.notifier).state = responseSize;
      _responseController.text = formattedResponse;
      ref.read(isLoadingProviderNM.notifier).state = false;
    } on http.ClientException catch (e) {
      String errorMessage = 'Connection Error: Unable to connect to the server.\n\n';
      final isWeb = kIsWeb;
      final usingProxy = _useCorsProxy && isWeb;
      
      if (usingProxy) {
        errorMessage += 'The CORS proxy service might be:\n'
            '• Temporarily unavailable\n'
            '• Rate-limited (too many requests)\n'
            '• Blocked by your network\n\n'
            '💡 Try:\n'
            '1. Wait a moment and try again (proxy might be rate-limited)\n'
            '2. Disable CORS proxy and check if server allows direct requests\n'
            '3. Check your internet connection\n\n'
            'Note: Postman works because it\'s not subject to browser CORS restrictions.\n\n';
      } else if (isWeb) {
        errorMessage += 'This is a CORS (Cross-Origin Resource Sharing) issue.\n\n'
            'The server does not allow requests from this browser origin.\n\n'
            '✅ SOLUTION: Enable the "CORS ON" toggle above (it should be ON by default).\n\n'
            'Why Postman works: Postman is a desktop app and is not subject to browser CORS restrictions.\n\n';
      } else {
        errorMessage += 'Possible causes:\n'
            '1. Network connectivity issue\n'
            '2. Server is down or unreachable\n'
            '3. Firewall or security software blocking the request\n'
            '4. SSL certificate validation failed\n\n';
      }
      
      errorMessage += 'Error details: ${e.message}';
      
      ref.read(statusCodeProvider.notifier).state = null;
      _responseController.text = errorMessage;
      ref.read(isLoadingProviderNM.notifier).state = false;
    } on TimeoutException catch (e) {
      ref.read(statusCodeProvider.notifier).state = null;
      _responseController.text = 'Connection Timeout: The request took too long to complete.\n\n'
          'The server might be slow or unreachable.\n\n'
          'Error details: ${e.message}';
      ref.read(isLoadingProviderNM.notifier).state = false;
    } catch (e) {
      ref.read(statusCodeProvider.notifier).state = null;
      _responseController.text = 'Error: $e';
      ref.read(isLoadingProviderNM.notifier).state = false;
    }
  }

  String _formatResponse(dynamic data) {
    if (data is Map || data is List) {
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(data);
    }
    return data.toString();
  }

  String _formatDuration(Duration duration) {
    if (duration.inMilliseconds < 1000) {
      return '${duration.inMilliseconds}ms';
    } else if (duration.inSeconds < 60) {
      return '${(duration.inMilliseconds / 1000).toStringAsFixed(2)}s';
    } else {
      final minutes = duration.inMinutes;
      final seconds = duration.inSeconds % 60;
      return '${minutes}m ${seconds}s';
    }
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
  }

  Widget _buildResponseSection() {
    final statusCode = ref.watch(statusCodeProvider);
    final requestDuration = ref.watch(requestDurationProvider);
    final responseSize = ref.watch(responseSizeProvider);
    
    return Column(
      children: [
        // Response header
        Container(
          padding: const EdgeInsets.all(16),
          color: const Color(0xFF2D2D2D),
          child: Row(
            children: [
              const Icon(Icons.code, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Response',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              // Status Code
              if (statusCode != null)
                Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusCode >= 200 && statusCode < 300
                        ? const Color(0xFF10B981)
                        : statusCode >= 400
                            ? const Color(0xFFEF4444)
                            : const Color(0xFFF59E0B),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '$statusCode',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              // Time
              if (requestDuration != null)
                Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3D3D3D),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.timer, size: 14, color: Colors.white70),
                      const SizedBox(width: 4),
                      Text(
                        _formatDuration(requestDuration),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              // Size
              if (responseSize != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3D3D3D),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.storage, size: 14, color: Colors.white70),
                      const SizedBox(width: 4),
                      Text(
                        _formatSize(responseSize),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        // Search bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF252525),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.grey[700]!),
          ),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
            ),
            decoration: InputDecoration(
              hintText: 'Search in response...',
              hintStyle: const TextStyle(color: Colors.grey),
              border: InputBorder.none,
              prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
              suffixIcon: ref.watch(searchQueryProvider).isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        ref.read(searchQueryProvider.notifier).state = '';
                      },
                    )
                  : null,
            ),
            onChanged: (value) {
              ref.read(searchQueryProvider.notifier).state = value;
            },
          ),
        ),
        // Response body
        Expanded(
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF252525),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[800]!),
            ),
            child: _buildResponseWithSearch(),
          ),
        ),
      ],
    );
  }

  Widget _buildResponseWithSearch() {
    final responseText = _responseController.text;
    final searchQuery = ref.watch(searchQueryProvider);
    
    if (searchQuery.isEmpty) {
      return TextField(
        controller: _responseController,
        maxLines: null,
        expands: true,
        readOnly: true,
        style: const TextStyle(
          color: Colors.white,
          fontFamily: 'monospace',
          fontSize: 13,
        ),
        decoration: const InputDecoration(
          hintText: 'Response will appear here...',
          hintStyle: TextStyle(color: Colors.grey),
          border: InputBorder.none,
        ),
      );
    }
    
    // Highlight search results
    final query = searchQuery.toLowerCase();
    final text = responseText.toLowerCase();
    final matches = <int>[];
    int index = text.indexOf(query);
    while (index != -1) {
      matches.add(index);
      index = text.indexOf(query, index + 1);
    }
    
    if (matches.isEmpty) {
      return Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                responseText,
                style: const TextStyle(
                  color: Colors.white70,
                  fontFamily: 'monospace',
                  fontSize: 13,
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            color: const Color(0xFF3D3D3D),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.grey, size: 16),
                const SizedBox(width: 8),
                Text(
                  'No matches found for "$searchQuery"',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      );
    }
    
    // Build text with highlights
    final spans = <TextSpan>[];
    int lastIndex = 0;
    
    for (final matchIndex in matches) {
      // Add text before match
      if (matchIndex > lastIndex) {
        spans.add(TextSpan(
          text: responseText.substring(lastIndex, matchIndex),
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'monospace',
            fontSize: 13,
          ),
        ));
      }
      
      // Add highlighted match
      spans.add(TextSpan(
        text: responseText.substring(matchIndex, matchIndex + searchQuery.length),
        style: const TextStyle(
          color: Colors.black,
          backgroundColor: Color(0xFFFFEB3B),
          fontFamily: 'monospace',
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ));
      
      lastIndex = matchIndex + searchQuery.length;
    }
    
    // Add remaining text
    if (lastIndex < responseText.length) {
      spans.add(TextSpan(
        text: responseText.substring(lastIndex),
        style: const TextStyle(
          color: Colors.white,
          fontFamily: 'monospace',
          fontSize: 13,
        ),
      ));
    }
    
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: SelectableText.rich(
              TextSpan(children: spans),
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          color: const Color(0xFF3D3D3D),
          child: Row(
            children: [
              const Icon(Icons.search, color: Colors.white70, size: 16),
              const SizedBox(width: 8),
              Text(
                '${matches.length} match${matches.length == 1 ? '' : 'es'} found',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getMethodColor(String method) {
    switch (method.toUpperCase()) {
      case 'GET':
        return const Color(0xFF10B981);
      case 'POST':
        return const Color(0xFF3B82F6);
      case 'PUT':
        return const Color(0xFFF59E0B);
      case 'DELETE':
        return const Color(0xFFEF4444);
      case 'PATCH':
        return const Color(0xFF8B5CF6);
      default:
        return Colors.grey;
    }
  }

  /// Builds a cURL command string from the current request state (method, URL, headers, body, query params).
  String _buildCurlFromCurrentState() {
    final method = ref.read(selectedMethodProvider);
    String url = _urlController.text.trim();
    if (url.isEmpty) return '';
    // Append query params to URL
    final effectiveParams = _queryParams
        .where((e) => e.key.trim().isNotEmpty && e.value.trim().isNotEmpty)
        .map((e) => MapEntry(e.key.trim(), e.value.trim()));
    if (effectiveParams.isNotEmpty) {
      final uri = Uri.tryParse(url);
      if (uri != null) {
        final updated = uri.replace(queryParameters: {
          ...uri.queryParameters,
          for (final e in effectiveParams) e.key: e.value,
        });
        url = updated.toString();
      }
    }
    final sb = StringBuffer('curl -X $method ');
    sb.write("'$url'");
    // Authorization from token
    if (_tokenController.text.trim().isNotEmpty) {
      sb.write(" -H 'Authorization: Bearer ${_tokenController.text.trim()}'");
    }
    for (final h in _headers) {
      if (h.key.trim().isNotEmpty && h.value.trim().isNotEmpty) {
        sb.write(" -H '${h.key.trim()}: ${h.value.trim().replaceAll("'", "'\\''")}'");
      }
    }
    if (['POST', 'PUT', 'PATCH'].contains(method) && _bodyController.text.trim().isNotEmpty) {
      final body = _bodyController.text.trim().replaceAll("'", "'\\''");
      sb.write(" --data-raw '$body'");
    }
    return sb.toString();
  }

  void _parseCurl(String curlCommand, {bool showSuccessToast = true}) {
    _isParsingCurl = true;
    try {
      String method = 'GET';
      String url = '';
      final headers = <String, String>{};
      String? body;
      final queryParams = <String, String>{};

      // Remove 'curl' and clean up
      String cleaned = curlCommand.trim();
      if (cleaned.toLowerCase().startsWith('curl')) {
        cleaned = cleaned.substring(4).trim();
      }

      // Extract method
      final methodMatch = RegExp(r'-X\s+(\w+)', caseSensitive: false).firstMatch(cleaned);
      if (methodMatch != null) {
        method = methodMatch.group(1)!.toUpperCase();
      }

      // Extract URL (handle both quoted and unquoted URLs, and URLs with query params)
      // First try to find URL in quotes
      final urlPattern1 = RegExp(r'''["']([^"']*https?://[^"']+)["']''');
      final urlMatch1 = urlPattern1.firstMatch(cleaned);
      if (urlMatch1 != null) {
        url = urlMatch1.group(1)!;
      } else {
        // Try to find URL without quotes (may have query params)
        final urlPattern2 = RegExp(r'(https?://[^\s]+)');
        final match = urlPattern2.firstMatch(cleaned);
        if (match != null) {
          url = match.group(1)!;
        }
      }

      // Extract headers
      final headerPattern = RegExp(r'''-H\s+["']([^"']+)["']''', caseSensitive: false);
      final headerMatches = headerPattern.allMatches(cleaned);
      for (final match in headerMatches) {
        final headerValue = match.group(1)!;
        final colonIndex = headerValue.indexOf(':');
        if (colonIndex > 0) {
          final key = headerValue.substring(0, colonIndex).trim();
          final value = headerValue.substring(colonIndex + 1).trim();
          headers[key] = value;
        }
      }

      // Extract Authorization token
      if (headers.containsKey('Authorization')) {
        final authValue = headers['Authorization']!;
        if (authValue.startsWith('Bearer ')) {
          _tokenController.text = authValue.substring(7);
          headers.remove('Authorization');
        }
      }

      // Extract data/body - improved to handle JSON with nested quotes
      // Try to find -d, --data, or --data-raw
      final dataFlags = ['--data-raw', '--data', '-d'];
      for (final flag in dataFlags) {
        final flagIndex = cleaned.toLowerCase().indexOf(flag.toLowerCase());
        if (flagIndex != -1) {
          // Find the position after the flag
          int startPos = flagIndex + flag.length;
          // Skip whitespace
          while (startPos < cleaned.length && cleaned[startPos].trim().isEmpty) {
            startPos++;
          }
          
          if (startPos < cleaned.length) {
            final char = cleaned[startPos];
            // Check if it starts with a quote
            if (char == "'" || char == '"') {
              // Find the matching closing quote
              final quoteChar = char;
              int endPos = startPos + 1;
              bool foundEnd = false;
              
              while (endPos < cleaned.length) {
                if (cleaned[endPos] == quoteChar) {
                  // Check if it's escaped - count backslashes before the quote
                  int backslashCount = 0;
                  int checkPos = endPos - 1;
                  while (checkPos >= startPos + 1 && cleaned[checkPos] == '\\') {
                    backslashCount++;
                    checkPos--;
                  }
                  // If even number of backslashes (or zero), it's not escaped
                  if (backslashCount % 2 == 0) {
                    foundEnd = true;
                    break;
                  }
                }
                endPos++;
              }
              
              if (foundEnd) {
                body = cleaned.substring(startPos + 1, endPos);
                // Unescape quotes
                if (quoteChar == "'") {
                  body = body.replaceAll("\\'", "'");
                } else {
                  body = body.replaceAll('\\"', '"');
                }
                break;
              }
            } else {
              // No quotes, extract until next flag or end of string
              int endPos = startPos;
              while (endPos < cleaned.length) {
                // Check if we hit a new flag
                bool hitFlag = false;
                for (final otherFlag in dataFlags) {
                  if (endPos + otherFlag.length <= cleaned.length &&
                      cleaned.substring(endPos, endPos + otherFlag.length).toLowerCase() == otherFlag.toLowerCase()) {
                    hitFlag = true;
                    break;
                  }
                }
                if (hitFlag && endPos > startPos) break;
                
                // Check if we hit a header flag
                if (endPos + 2 <= cleaned.length && cleaned.substring(endPos, endPos + 2).toLowerCase() == '-h') {
                  break;
                }
                
                endPos++;
              }
              body = cleaned.substring(startPos, endPos).trim();
              break;
            }
          }
        }
      }

      // Extract query parameters from URL
      final uri = Uri.tryParse(url);
      if (uri != null && uri.hasQuery) {
        // Keep the full URL but extract query params separately
        final baseUrl = '${uri.scheme}://${uri.host}${uri.path}';
        uri.queryParameters.forEach((key, value) {
          queryParams[key] = value;
        });
        // Update URL to base URL without query params (they'll be added as query params)
        url = baseUrl;
      }

      // Update UI
      ref.read(selectedMethodProvider.notifier).state = method;
      _urlController.text = url;
      if (body != null) {
        _bodyController.text = body;
      }
      _headers.clear();
      _headers.addAll(headers.entries.map((e) => MapEntry(e.key, e.value)));
      _queryParams.clear();
      _queryParams.addAll(queryParams.entries.map((e) => MapEntry(e.key, e.value)));

      if (showSuccessToast) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Center(child: Text('cURL command imported successfully!', style: TextStyle(color: Colors.white))),
            backgroundColor: Color(0xFF10B981),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(child: Text('Error parsing cURL: $e', style: const TextStyle(color: Colors.white))),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      _isParsingCurl = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedMethod = ref.watch(selectedMethodProvider);
    final isLoading = ref.watch(isLoadingProviderNM);
    final leftPanelWidth = ref.watch(nahdiManLeftPanelWidthProvider);
    
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D2D2D),
        elevation: 0,
        actions: [
          if (widget.showUpdateToFirebaseButton && widget.onUpdateToFirebase != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ElevatedButton.icon(
                onPressed: isLoading
                    ? null
                    : () async {
                        final curl = _buildCurlFromCurrentState();
                        if (curl.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter a URL first'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }
                        try {
                          await widget.onUpdateToFirebase!(curl);
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to update: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                icon: const Icon(Icons.cloud_upload, size: 18),
                label: const Text('Update to Firebase'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ),
        ],
        title: Row(
          children: [
            Container(
              height: 25,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: _getMethodColor(selectedMethod),
                borderRadius: BorderRadius.circular(6),
              ),
              child: DropdownButton<String>(
                value: selectedMethod,
                dropdownColor: const Color(0xFF2D2D2D),
                underline: const SizedBox(),
                iconSize: 16,
                isDense: true,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
                items: _httpMethods.map((method) {
                  return DropdownMenuItem(
                    value: method,
                    child: Text(
                      method,
                      textAlign: TextAlign.center,
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    ref.read(selectedMethodProvider.notifier).state = value;
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.grey[700]!),
                ),
                child: TextField(
                  controller: _urlController,
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'monospace',
                    fontSize: 13,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Enter request URL',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Send button
            ElevatedButton.icon(
              onPressed: isLoading ? null : _sendRequest,
              icon: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.send, size: 18),
              label: const Text('Send'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ],
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          
          if (isMobile) {
            // Mobile layout: Stack vertically
            return Column(
              children: [
                // Request panel (collapsible on mobile)
                Expanded(
                  child: Container(
                    color: const Color(0xFF252525),
                    child: Column(
                      children: [
                        Container(
                          color: const Color(0xFF2D2D2D),
                          child: TabBar(
                            controller: _tabController,
                            indicatorColor: const Color(0xFF10B981),
                            labelColor: Colors.white,
                            unselectedLabelColor: Colors.grey,
                            tabs: const [
                              Tab(text: 'Params'),
                              Tab(text: 'Headers'),
                              Tab(text: 'Body'),
                            ],
                          ),
                        ),
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _buildParamsTab(),
                              _buildHeadersTab(),
                              _buildBodyTab(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Divider
                Container(
                  height: 4,
                  color: Colors.grey[800],
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[600],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Response panel
                Expanded(
                  child: Container(
                    color: const Color(0xFF1E1E1E),
                    child: _buildResponseSection(),
                  ),
                ),
              ],
            );
          } else {
            // Desktop layout: Side by side
            return Row(
              children: [
                // Left panel - Request configuration
                SizedBox(
                  width: leftPanelWidth,
                  child: Container(
                    color: const Color(0xFF252525),
                    child: Column(
                      children: [
                        Container(
                          color: const Color(0xFF2D2D2D),
                          child: TabBar(
                            controller: _tabController,
                            indicatorColor: const Color(0xFF10B981),
                            labelColor: Colors.white,
                            unselectedLabelColor: Colors.grey,
                            tabs: const [
                              Tab(text: 'Params'),
                              Tab(text: 'Headers'),
                              Tab(text: 'Body'),
                            ],
                          ),
                        ),
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _buildParamsTab(),
                              _buildHeadersTab(),
                              _buildBodyTab(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Draggable Divider
                MouseRegion(
                  cursor: SystemMouseCursors.resizeColumn,
                  child: GestureDetector(
                onPanUpdate: (details) {
                  final newWidth = leftPanelWidth + details.delta.dx;
                  // Constrain the width between 300 and screen width - 400
                  final screenWidth = constraints.maxWidth;
                  ref.read(nahdiManLeftPanelWidthProvider.notifier).state = 
                      newWidth.clamp(300.0, screenWidth - 400.0);
                },
                    child: Container(
                      width: 6,
                      color: Colors.grey[800],
                      child: Center(
                        child: Container(
                          width: 2,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey[500],
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Right panel - Response
                Expanded(
                  child: Container(
                    color: const Color(0xFF1E1E1E),
                    child: _buildResponseSection(),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildParamsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            const Text(
              'Query Parameters',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.add, color: Color(0xFF10B981)),
              onPressed: _addQueryParam,
              tooltip: 'Add parameter',
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...List.generate(_queryParams.length, (index) {
          return _buildKeyValueRow(
            keyController: TextEditingController(text: _queryParams[index].key),
            valueController: TextEditingController(text: _queryParams[index].value),
            onKeyChanged: (value) => _updateQueryParam(index, value, _queryParams[index].value),
            onValueChanged: (value) => _updateQueryParam(index, _queryParams[index].key, value),
            onRemove: () => _removeQueryParam(index),
          );
        }),
      ],
    );
  }

  Widget _buildHeadersTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            const Text(
              'Headers',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.add, color: Color(0xFF10B981)),
              onPressed: _addHeader,
              tooltip: 'Add header',
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Login Access Token Toggle Section
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.lock, color: Colors.grey, size: 16),
              const SizedBox(width: 8),
              const Text(
                'Authorization Token',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        // Toggle for using login access token
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[800]!),
          ),
          child: Row(
            children: [
              const Icon(Icons.login, color: Colors.grey, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Use Login Access Token',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Builder(
                      builder: (context) {
                        final loginAccessToken = ref.watch(loginAccessTokenProvider);
                        final loginIdToken = ref.watch(loginIdTokenProvider);
                        final hasTokens = loginAccessToken != null && loginIdToken != null;
                        return Text(
                          hasTokens
                              ? 'Tokens available (access_token & id_token)'
                              : (loginAccessToken != null || loginIdToken != null)
                                  ? 'Partial tokens available'
                                  : 'No tokens from login yet',
                          style: TextStyle(
                            color: hasTokens
                                ? Colors.green[400]
                                : (loginAccessToken != null || loginIdToken != null)
                                    ? Colors.orange[400]
                                    : Colors.grey[500],
                            fontSize: 11,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Builder(
                builder: (context) {
                  final useLoginToken = ref.watch(useLoginTokenProvider);
                  final loginAccessToken = ref.watch(loginAccessTokenProvider);
                  final loginIdToken = ref.watch(loginIdTokenProvider);
                  final hasTokens = loginAccessToken != null || loginIdToken != null;
                  return Switch(
                    value: useLoginToken,
                    onChanged: hasTokens
                        ? (value) {
                            ref.read(useLoginTokenProvider.notifier).state = value;
                          }
                        : null,
                    activeColor: const Color(0xFF10B981),
                  );
                },
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[800]!),
          ),
          child: Builder(
            builder: (context) {
              final useLoginToken = ref.watch(useLoginTokenProvider);
              return TextField(
                controller: _tokenController,
                enabled: !useLoginToken,
                style: TextStyle(
                  color: useLoginToken ? Colors.grey[600] : Colors.white,
                  fontFamily: 'monospace',
                  fontSize: 13,
                ),
                decoration: InputDecoration(
                  hintText: useLoginToken
                      ? 'Using login token...'
                      : 'Bearer token from cURL...',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  border: InputBorder.none,
                ),
                obscureText: true,
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        const Divider(color: Colors.grey, height: 32),
        const SizedBox(height: 8),
        const Text(
          'Custom Headers',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        // Show Authorization and X-ID-Token headers in custom headers if using login tokens
        Builder(
          builder: (context) {
            final useLoginToken = ref.watch(useLoginTokenProvider);
            final loginAccessToken = ref.watch(loginAccessTokenProvider);
            final loginIdToken = ref.watch(loginIdTokenProvider);
            
            if (useLoginToken && (loginAccessToken != null || loginIdToken != null)) {
              return Column(
                children: [
                  // Authorization header (access_token)
                  if (loginAccessToken != null && loginAccessToken.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green[400], size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Authorization',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Bearer ${loginAccessToken.substring(0, loginAccessToken.length > 20 ? 20 : loginAccessToken.length)}...',
                                  style: TextStyle(
                                    color: Colors.green[400],
                                    fontSize: 11,
                                    fontFamily: 'monospace',
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'access_token',
                            style: TextStyle(
                              color: Colors.green[400],
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  // X-ID-Token header (id_token)
                  if (loginIdToken != null && loginIdToken.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.blue[400], size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'X-ID-Token',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Bearer ${loginIdToken.substring(0, loginIdToken.length > 20 ? 20 : loginIdToken.length)}...',
                                  style: TextStyle(
                                    color: Colors.blue[400],
                                    fontSize: 11,
                                    fontFamily: 'monospace',
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'id_token',
                            style: TextStyle(
                              color: Colors.blue[400],
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 4),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
        ...List.generate(_headers.length, (index) {
          return _buildKeyValueRow(
            keyController: TextEditingController(text: _headers[index].key),
            valueController: TextEditingController(text: _headers[index].value),
            onKeyChanged: (value) => _updateHeader(index, value, _headers[index].value),
            onValueChanged: (value) => _updateHeader(index, _headers[index].key, value),
            onRemove: () => _removeHeader(index),
          );
        }),
      ],
    );
  }

  Widget _buildBodyTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: const Row(
            children: [
              Text(
                'Request Body',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 8),
              Text(
                '(JSON)',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[800]!),
            ),
            child: TextField(
              controller: _bodyController,
              maxLines: null,
              expands: true,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'monospace',
                fontSize: 13,
              ),
              decoration: const InputDecoration(
                hintText: 'Enter JSON body...',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKeyValueRow({
    required TextEditingController keyController,
    required TextEditingController valueController,
    required Function(String) onKeyChanged,
    required Function(String) onValueChanged,
    required VoidCallback onRemove,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey[800]!),
              ),
              child: TextField(
                controller: keyController,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: const InputDecoration(
                  hintText: 'Key',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
                onChanged: onKeyChanged,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey[800]!),
              ),
              child: TextField(
                controller: valueController,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: const InputDecoration(
                  hintText: 'Value',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
                onChanged: onValueChanged,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red, size: 20),
            onPressed: onRemove,
            tooltip: 'Remove',
          ),
        ],
      ),
    );
  }
}
