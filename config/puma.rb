# config/puma.rb

# Set the port Puma will listen on (default is 4567 for Sinatra)
port ENV.fetch("PORT") { 4567 }

# Configure Puma threads (min/max threads to use)
threads_count = ENV.fetch("PUMA_MAX_THREADS") { 5 }.to_i
threads threads_count, threads_count

# Configure the number of workers (useful for multi-core machines)
workers ENV.fetch("WEB_CONCURRENCY") { 2 }

# Preload the app to speed up startup
preload_app!

# Optional: Specify the environment (default to development)
environment ENV.fetch("RACK_ENV") { "development" }

# Optional: Use the "on_worker_boot" hook to run code specific to worker processes
on_worker_boot do
  # Example: Reconnect to database if needed
end
