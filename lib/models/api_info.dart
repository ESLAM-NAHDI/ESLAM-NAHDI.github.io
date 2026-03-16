class ApiInfo {
  final String url;
  final String? body;
  final String description;
  final int numberOfCalls;
  final String? postmanLink;
  final String method; // GET, POST, PUT, DELETE, etc.
  final String? curl; // cURL command for the API request

  ApiInfo({
    required this.url,
    this.body,
    required this.description,
    required this.numberOfCalls,
    this.postmanLink,
    this.method = 'GET',
    this.curl,
  });

  ApiInfo copyWith({
    String? url,
    String? body,
    String? description,
    int? numberOfCalls,
    String? postmanLink,
    String? method,
    Object? curl = _undefined,
  }) {
    return ApiInfo(
      url: url ?? this.url,
      body: body ?? this.body,
      description: description ?? this.description,
      numberOfCalls: numberOfCalls ?? this.numberOfCalls,
      postmanLink: postmanLink ?? this.postmanLink,
      method: method ?? this.method,
      curl: curl == _undefined ? this.curl : curl as String?,
    );
  }
}

const _undefined = Object();

class PageInfo {
  final String? id; // Firestore document ID
  final String name;
  final List<ApiInfo> apis;
  final String? screenshot; // Firebase Storage URL or local path

  PageInfo({
    this.id,
    required this.name,
    required this.apis,
    this.screenshot,
  });
}

