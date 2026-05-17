# Contributing Guide

## Welcome to Smart Passenger Alert System

Thank you for your interest in contributing! This guide will help you understand how to contribute effectively to the project.

## Code of Conduct

- Be respectful and inclusive
- Provide constructive feedback
- Report bugs responsibly
- Give credit where it's due
- Follow the project's standards

## Getting Started

1. **Fork the Repository**
   ```bash
   # Click "Fork" on GitHub
   ```

2. **Clone Your Fork**
   ```bash
   git clone https://github.com/YOUR_USERNAME/smart_passenger_alert.git
   cd smart_passenger_alert
   ```

3. **Add Upstream Remote**
   ```bash
   git remote add upstream https://github.com/ORIGINAL_OWNER/smart_passenger_alert.git
   ```

4. **Create Feature Branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

## Development Standards

### Dart/Flutter Code Style

```dart
// ✅ DO: Use camelCase for variables and functions
final String userName = "John";
void updateUserProfile() { }

// ❌ DON'T: Use snake_case for variables
final String user_name = "John";

// ✅ DO: Use PascalCase for classes
class FlightModel { }
class UserProvider { }

// ✅ DO: Use proper type annotations
List<Flight> flights = [];
Map<String, dynamic> json = {};

// ❌ DON'T: Use var without clear context
var flights = [];
var data = {};

// ✅ DO: Use const constructors
const SizedBox(height: 16);

// ✅ DO: Group imports
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/flight_model.dart';
import 'services/api_service.dart';
```

### File Naming Conventions

```
models/
  - flight_model.dart (PascalCase class + _model.dart suffix)
  - user_model.dart

screens/
  - flight_details_screen.dart (feature_screen.dart)
  - login_screen.dart

widgets/
  - flight_card.dart (feature_card.dart)
  - glass_morphism_container.dart

services/
  - api_service.dart
  - firebase_service.dart

providers/
  - app_providers.dart (all providers grouped)

utils/
  - constants.dart
  - app_utils.dart
  - validators.dart
```

### Commit Message Format

```bash
# Use semantic commit messages
git commit -m "type(scope): description"

# Types:
# feat:  New feature
# fix:   Bug fix
# docs:  Documentation
# style: Code style (formatting, missing semicolons, etc)
# refactor: Code refactoring
# perf:  Performance improvement
# test:  Adding or updating tests
# chore: Build process, dependencies, etc

# Examples:
git commit -m "feat(flights): Add flight delay prediction"
git commit -m "fix(notifications): Correct FCM message handling"
git commit -m "docs(api): Update API endpoint documentation"
git commit -m "refactor(providers): Simplify flight provider logic"
git commit -m "test(models): Add flight model serialization tests"
```

## Coding Guidelines

### 1. Model Classes

```dart
// Always use JSON serialization
import 'package:json_annotation/json_annotation.dart';

part 'flight_model.g.dart';

@JsonSerializable()
class Flight {
  final String flightNumber;
  final String origin;
  final String destination;
  final DateTime scheduledDeparture;
  
  const Flight({
    required this.flightNumber,
    required this.origin,
    required this.destination,
    required this.scheduledDeparture,
  });

  factory Flight.fromJson(Map<String, dynamic> json) => 
      _$FlightFromJson(json);
  
  Map<String, dynamic> toJson() => _$FlightToJson(this);
}
```

### 2. Service Classes

```dart
// Keep services focused and injectable
class ApiService {
  final Dio _dio;
  
  ApiService(this._dio);
  
  // One responsibility per method
  Future<List<Flight>> getFlights() async {
    try {
      final response = await _dio.get('/flights');
      return (response.data as List)
          .map((f) => Flight.fromJson(f))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
```

### 3. Riverpod Providers

```dart
// Organize providers by feature
final apiServiceProvider = Provider((ref) => ApiService());

final flightsProvider = FutureProvider((ref) {
  final service = ref.watch(apiServiceProvider);
  return service.getFlights();
});

// Use family for parameterized providers
final flightDetailsProvider = FutureProvider.family((ref, String id) {
  final service = ref.watch(apiServiceProvider);
  return service.getFlightDetails(id);
});

// Use StateNotifier for complex state
final alertNotifierProvider = StateNotifierProvider((ref) {
  return AlertNotifier(ref.watch(apiServiceProvider));
});
```

### 4. Widget Structure

```dart
class FlightCard extends ConsumerWidget {
  final Flight flight;
  
  const FlightCard({
    Key? key,
    required this.flight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use ref for providers
    final favorites = ref.watch(favoritesProvider);
    
    return GestureDetector(
      onTap: () {
        // Handle tap
      },
      child: Container(
        // Widget content
      ),
    );
  }
}
```

### 5. Error Handling

```dart
// Always handle errors appropriately
try {
  final flights = await apiService.getFlights();
} on DioException catch (e) {
  logger.error('API Error: ${e.message}');
  // Show user-friendly error message
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Failed to load flights')),
  );
} catch (e) {
  logger.error('Unexpected error: $e');
}
```

### 6. Documentation

```dart
/// Fetches all flights for the current user.
/// 
/// Returns a list of [Flight] objects sorted by departure time.
/// 
/// Throws [DioException] if the API request fails.
/// 
/// Example:
/// ```dart
/// final flights = await apiService.getFlights();
/// print(flights.length);
/// ```
Future<List<Flight>> getFlights() async {
  // Implementation
}
```

## Testing Requirements

### Unit Tests

```dart
// test/models/flight_model_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_passenger_alert/models/flight_model.dart';

void main() {
  group('Flight Model', () {
    test('should parse JSON correctly', () {
      final json = {
        'flightNumber': 'BA-173',
        'origin': 'LHR',
        'destination': 'JFK',
        'scheduledDeparture': '2024-01-15T10:30:00Z',
      };
      
      final flight = Flight.fromJson(json);
      
      expect(flight.flightNumber, equals('BA-173'));
      expect(flight.origin, equals('LHR'));
    });

    test('should serialize to JSON correctly', () {
      final flight = Flight(
        flightNumber: 'BA-173',
        origin: 'LHR',
        destination: 'JFK',
        scheduledDeparture: DateTime(2024, 1, 15, 10, 30),
      );
      
      final json = flight.toJson();
      
      expect(json['flightNumber'], equals('BA-173'));
    });
  });
}
```

### Widget Tests

```dart
// test/widgets/flight_card_test.dart
void main() {
  group('FlightCard Widget', () {
    testWidgets('should display flight information', 
        (WidgetTester tester) async {
      final flight = Flight(
        flightNumber: 'BA-173',
        origin: 'LHR',
        destination: 'JFK',
        scheduledDeparture: DateTime(2024, 1, 15, 10, 30),
      );
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlightCard(flight: flight),
          ),
        ),
      );
      
      expect(find.text('BA-173'), findsOneWidget);
      expect(find.text('LHR → JFK'), findsOneWidget);
    });
  });
}
```

## Pull Request Process

### Before Submitting

1. **Update Your Branch**
   ```bash
   git fetch upstream
   git rebase upstream/main
   ```

2. **Run All Checks**
   ```bash
   # Format code
   flutter format .
   
   # Run analysis
   flutter analyze
   
   # Run tests
   flutter test
   
   # Check coverage
   flutter test --coverage
   ```

3. **Build Release Version**
   ```bash
   flutter build apk --release
   flutter build ios --release
   ```

4. **Commit & Push**
   ```bash
   git add .
   git commit -m "type(scope): description"
   git push origin feature/your-feature-name
   ```

### Pull Request Template

```markdown
## Description
Brief description of the changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Related Issues
Fixes #(issue number)

## Changes Made
- Change 1
- Change 2

## Testing
- [ ] Tested locally
- [ ] Added tests
- [ ] All tests pass

## Screenshots (if applicable)
Add screenshots for UI changes

## Checklist
- [ ] Code follows style guidelines
- [ ] Comments added for complex logic
- [ ] Documentation updated
- [ ] Tests added/updated
- [ ] No new warnings generated
```

### Review Process

1. **Automatic Checks**
   - Code formatting verification
   - Linting analysis
   - Unit tests execution
   - Build verification

2. **Code Review**
   - Minimum 2 approvals required
   - All conversations must be resolved
   - No failing CI checks

3. **Merge**
   - Use "Squash and merge" for cleaner history
   - Delete branch after merge

## Feature Development Workflow

### 1. Plan
- Create issue describing the feature
- Discuss approach in comments
- Get approval before starting

### 2. Implement
```bash
git checkout -b feature/flight-delay-prediction
# Write code following guidelines
# Add tests
# Update documentation
```

### 3. Test Locally
```bash
flutter test
flutter analyze
flutter format .
```

### 4. Submit PR
- Link related issue
- Provide description and testing details
- Address review feedback

### 5. Deploy
- Merge to main after approval
- CI/CD pipeline builds and deploys automatically

## Areas for Contribution

### High Priority
- [ ] Complete API integration with real backend
- [ ] Firebase configuration setup
- [ ] Smartwatch (ESP32) integration
- [ ] Real-time sensor data handling

### Medium Priority
- [ ] Performance optimization
- [ ] Additional test coverage
- [ ] UI/UX improvements
- [ ] Localization support

### Low Priority
- [ ] Documentation improvements
- [ ] Code refactoring
- [ ] Dependencies updates
- [ ] Accessibility enhancements

## Reporting Issues

### Bug Report

```markdown
## Description
Clear description of the bug

## Steps to Reproduce
1. Navigate to screen X
2. Perform action Y
3. Expected result vs Actual result

## Environment
- Device: (e.g., Pixel 6)
- OS: (e.g., Android 14)
- App Version: (e.g., 1.0.0)
- Flutter Version: (flutter --version)

## Logs
```
[Paste error logs here]
```

## Screenshots
[Add relevant screenshots]
```

### Feature Request

```markdown
## Description
Clear description of the feature

## Motivation
Why is this feature needed?

## Proposed Solution
How should it work?

## Alternatives Considered
Any alternative approaches?

## Additional Context
Any other context?
```

## Communication

- **GitHub Issues**: Bug reports and feature requests
- **GitHub Discussions**: Questions and suggestions
- **Pull Request Comments**: Code review feedback
- **Discord/Slack**: Team communication (link in README)

## Resources

- [Flutter Official Docs](https://flutter.dev/docs)
- [Dart Style Guide](https://dart.dev/guides/language/effective-dart)
- [Riverpod Docs](https://riverpod.dev)
- [Testing Best Practices](https://flutter.dev/docs/testing)

## Questions?

Feel free to:
1. Check existing issues and discussions
2. Ask in GitHub Discussions
3. Contact team lead
4. Review similar implementations

## Recognition

Contributors will be recognized in:
- README.md contributors section
- GitHub releases notes
- Monthly contributor shoutout

---

Thank you for contributing to Smart Passenger Alert System! 🚀
