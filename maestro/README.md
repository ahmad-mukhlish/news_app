# Maestro Tests for News App

This directory contains comprehensive Maestro UI tests for the News App.

## Test Suite Overview

### 1. **01-smoke-test.yaml** - Smoke Test
Quick validation that the app launches and basic navigation works.
- App launches successfully
- All 5 navigation tabs are accessible
- Main screens load without crashes

**Run time:** ~30 seconds

### 2. **02-navigation-test.yaml** - Navigation Test
Comprehensive bottom navigation testing.
- Tests all 5 tabs (Home, Search, Categories, Notifications, Profile)
- Verifies proper screen switching
- Tests rapid navigation and state persistence

**Run time:** ~45 seconds

### 3. **03-home-screen-test.yaml** - Home Screen Test
Tests news article loading and interaction on the home screen.
- Verifies articles display correctly
- Tests pull-to-refresh functionality
- Tests scrolling through articles

**Run time:** ~1 minute

### 4. **04-search-screen-test.yaml** - Search Screen Test
Tests search functionality and autocomplete.
- Search input and autocomplete suggestions
- Search results loading
- Clear search functionality
- Multiple search queries

**Run time:** ~1.5 minutes

### 5. **05-categories-screen-test.yaml** - Categories Screen Test
Tests category filtering functionality.
- Category chip selection
- Filtered news loading for each category
- Tests: Business, Entertainment, Sports, Technology, Science, Health, General

**Run time:** ~2 minutes

### 6. **06-notifications-screen-test.yaml** - Notifications Screen Test
Tests notification list and interactions.
- Notification display (handles empty and populated states)
- Mark all as read functionality
- Notification detail navigation
- Pull-to-refresh

**Run time:** ~1 minute

### 7. **07-article-detail-test.yaml** - Article Detail Test
Tests opening and viewing news articles.
- Article card interactions
- External link opening (url_launcher)
- Article viewing from different screens (Home, Search, Categories)

**Run time:** ~1.5 minutes

### 8. **08-pagination-test.yaml** - Pagination Test
Tests infinite scroll pagination.
- Tests pagination on Home screen
- Tests pagination on Search results
- Tests pagination on Category results

**Run time:** ~2 minutes

### 9. **09-edge-cases-test.yaml** - Edge Cases Test
Tests error handling and edge cases.
- Empty search queries
- Special characters in search
- Very long search queries
- Rapid navigation switching
- Multiple refresh attempts
- Back button behavior

**Run time:** ~1.5 minutes

## Prerequisites

1. **Install Maestro:**
   ```bash
   curl -Ls "https://get.maestro.mobile.dev" | bash
   ```

2. **Start an emulator/simulator or connect a device**

3. **Ensure the News App is installed** (or the tests will install it)

## Running Tests

### Run All Tests (using master flow)
```bash
maestro test maestro/all-tests.yaml
```

### Run All Tests (using glob pattern)
```bash
maestro test 'maestro/*.yaml'
```

### Run Specific Test
```bash
maestro test maestro/01-smoke-test.yaml
```

### Run Tests in Order
```bash
maestro test maestro/01-smoke-test.yaml
maestro test maestro/02-navigation-test.yaml
maestro test maestro/03-home-screen-test.yaml
# ... and so on
```

### Run with Continuous Mode (watch for changes)
```bash
maestro test --continuous maestro/01-smoke-test.yaml
```

### Run Tests on Specific Device
```bash
maestro test --device <device-id> maestro/all-tests.yaml
```

## Test Strategy

The tests are organized in a logical order:

1. **Smoke test** - Quick validation
2. **Navigation** - Basic app navigation
3. **Home screen** - Core feature testing
4. **Search** - Key user flow
5. **Categories** - Feature testing
6. **Notifications** - Secondary features
7. **Article details** - Integration testing
8. **Pagination** - Performance/edge case
9. **Edge cases** - Error handling

## Important Notes

### API Key Requirement
The app requires a valid News API key. Make sure your build has a valid API key configured in:
- `APP_CONFIG` or environment variables
- Default: `YOUR_API_KEY_HERE` (needs to be replaced)

### Network Dependency
Most tests require an active internet connection to fetch news articles from the News API.

### Test Data
Tests use real news data, so:
- Article content may vary
- Some tests search for generic terms like "technology", "sports", etc.
- Test stability depends on API availability

### Timing
- Tests include appropriate waits for network requests
- Adjust `timeout` values if running on slower devices/networks

### Conditional Flows
Some tests use conditional flows (e.g., notifications test) to handle:
- Empty states (no notifications)
- Populated states (notifications exist)

## Troubleshooting

### Tests Fail Due to Network Issues
- Check internet connection
- Verify News API is accessible
- Check API key is valid

### Tests Fail on Element Not Found
- Some elements depend on API responses
- Increase timeout values if needed
- Check if app UI has changed

### Tests Are Slow
- Network latency affects test speed
- Consider running smoke test only for quick validation
- Use faster emulator/device

## CI/CD Integration

### GitHub Actions Example
```yaml
- name: Run Maestro Tests
  run: |
    maestro test maestro/01-smoke-test.yaml
    maestro test maestro/02-navigation-test.yaml
```

### Recommended CI Strategy
1. Run smoke test on every commit
2. Run full suite on PRs
3. Run edge cases nightly

## Maintenance

### Updating Tests
When app UI changes:
1. Update element selectors in affected tests
2. Adjust timeouts if performance changes
3. Add new tests for new features

### Adding New Tests
Follow the naming convention:
- `NN-feature-name-test.yaml`
- Include clear comments
- Document in this README

## Contact

For issues or questions about these tests, please refer to:
- [Maestro Documentation](https://maestro.mobile.dev)
- Project repository issues

---

**Total estimated runtime for all tests:** ~11-12 minutes
