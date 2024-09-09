# Stage 1: Builder
FROM ruby:3.1-alpine AS builder

WORKDIR /app

# Install build dependencies (if needed for gems)
RUN apk add --no-cache build-base

# Copy the Gemfile and install dependencies
COPY Gemfile Gemfile.lock ./
RUN gem install bundler && bundle install

# Stage 2: Application
FROM ruby:3.1-alpine

WORKDIR /app

# Install runtime dependencies
RUN apk add --no-cache libstdc++ tzdata

# Copy Gemfile and Gemfile.lock from the builder stage
COPY --from=builder /app/Gemfile /app/Gemfile.lock ./
COPY --from=builder /usr/local/bundle /usr/local/bundle

# Copy the application code
COPY . .

# Expose the port that Puma will listen on
EXPOSE 4567

# Command to run the application with Puma
CMD ["puma", "-p", "4567", "config.ru"]

