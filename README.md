# Good Night V2 - Sleep Tracking API

A Rails 8 API application for tracking sleep patterns and social sleep sharing.

## Overview

Good Night V2 is a sleep tracking application that allows users to:
- Clock in/out for sleep and wake times
- Follow other users to see their sleep patterns
- View sleep records of followed users from the previous week, sorted by duration

## Technology Stack

- **Ruby 3.3.6** with **Rails 8.0.2+**
- **PostgreSQL**
- **Puma** web server
- **Solid Queue** for background jobs
- **Docker**
- **RSpec** with Factory Bot for testing

## API Endpoints

### Sleep Records
- `POST /sleep_records/clock_in` - Clock in for sleep or wake (toggles based on current state)

### User Following
- `POST /users/:user_id/follow` - Follow a user
- `DELETE /users/:user_id/unfollow` - Unfollow a user

### Sleep Analytics
- `GET /followings/sleep_records` - Get sleep records of followed users from last week

## Setup

### Prerequisites
- Ruby 3.3.6
- PostgreSQL (for production)
- Docker & Docker Compose (optional)

### Local Development

```bash
# Install dependencies
bundle install

# Setup database
bin/rails db:prepare
bin/rails db:migrate

# Start server
bin/rails server
```

### Docker Development

```bash
# Start all services
docker-compose -d up

# Run tests
docker-compose exec web bundle exec rspec
```

## Testing

```bash
# Run all tests
bundle exec rspec

# Run specific test files
bundle exec rspec spec/controllers/
bundle exec rspec spec/models/

# Code quality checks
bin/rubocop
bin/brakeman
```

## Database Models

- **User**: Basic user information
- **SleepRecord**: Sleep/wake times with calculated duration
- **UserFollowing**: User following relationships
- **DailySleepSummary**: Aggregated daily sleep data

## Authentication

The API uses header-based user identification:
- Include `X-User-ID: <user_id>` header in all requests

## Postman Collection
- Import postman collection under postman folder
- To change the user, change the `user_id` environment value
