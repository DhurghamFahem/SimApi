# SimApi

SimApi is a powerful and flexible library for simulating API responses in Dart. It allows developers to create mock APIs for testing and development purposes without the need for a real backend server.

## Features

- Simulate HTTP methods: GET, POST, PUT, PATCH, DELETE
- Customizable response delay to mimic network latency
- Support for route parameters and query parameters
- Custom route handlers for complex scenarios
- Easy data seeding and management
- Flexible route registration

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  sim_api: ^0.0.5
```
Then run:

```bash
flutter pub get
```

## Usage

### Basic Setup

```dart
import 'package:sim_api/sim_api.dart';

void main() {
  final api = SimApi<int>();
  
  // Register routes
  api.registerRoute('/users');
  api.registerRoute('/users', method: SimApiHttpMethod.get, haveRouteParameters: true);
  
  // Seed some data
  api.seedData('/users', {
    1: {'id': 1, 'name': 'Alice'},
    2: {'id': 2, 'name': 'Bob'},
  });
  
  // Use the API
  api.get(Uri.parse('/users/$1')).then((response) {
    print(response.body);
  });
}
```

### Custom Route Handlers

```dart
simApi.registerRoute(
        '/custom',
        method: SimApiHttpMethod.get,
        handler: (
          url, {
          body,
          headers,
          required delete,
          required get,
          required patch,
          required post,
          required put,
        }) async {
          return SimApiHttpResponse.ok({'message': 'custom route'});
        },
      );
```

### Simulating Network Delay

```dart
// Set a global delay
api.delay = 1000; // 1 second delay

// Or use the constructor
final api = SimApi(defaultDelay: 1000);
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
