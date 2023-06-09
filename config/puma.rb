require "sidekiq"

# According to https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server#adding-puma-to-your-application

# Specifies the number of `workers` to boot in clustered mode.
# Workers are forked web server processes. If using threads and workers together
# the concurrency of the application would be max `threads` * `workers`.
# Workers do not work on JRuby or Windows (both of which do not support
# processes).
#
workers Integer(ENV['WEB_CONCURRENCY'] || 2)

# Puma can serve each request in a thread from an internal thread pool. This behavior allows Puma to provide additional concurrency for your web application. Loosely speaking, workers consume more RAM and threads consume more CPU, and both offer more concurrency.
# On MRI, there is a Global Interpreter Lock (GIL) that ensures only one thread can run at any time. IO operations such as database calls, interacting with the file system, or making external http calls will not lock the GIL. Most Rails applications heavily use IO, so adding additional threads will allow Puma to process multiple threads, gaining you more throughput. JRuby and Rubinius also benefit from using Puma. These Ruby implementations do not have a GIL and will run all threads in parallel regardless of what is happening in them.
# Puma allows you to configure your thread pool with a min and max setting, controlling the number of threads each Puma instance uses. The min threads setting allows your application to spin down resources when not under load. This feature is not needed on Heroku as your application can consume all of the resources on a given dyno. We recommend setting min to equal max.
# Each Puma worker will be able to spawn up to the maximum number of threads you specify.
threads_count = Integer(ENV['RAILS_MAX_THREADS'] || 5)
threads threads_count, threads_count

# preloading the application is necessary to ensure
# the configuration in your initializer runs before
# the boot callback below.

# Use the `preload_app!` method when specifying a `workers` number.
# This directive tells Puma to first boot the application and load code
# before forking the application. This takes advantage of Copy On Write
# process behavior so workers use less memory.
#
preload_app!

# rackup DefaultRackup if defined?(DefaultRackup)

# Specifies the `port` that Puma will listen on to receive requests; default is 3000.
#
port ENV.fetch("PORT") { 3000 }
environment ENV['RACK_ENV'] || 'development'


x = nil
on_worker_boot do
  ActiveRecord::Base.establish_connection
  x = Sidekiq.configure_embed do |config|
    # config.logger.level = Logger::DEBUG
    config.queues = %w[critical default low]
    config.concurrency = 2
  end
  x.run
end

on_worker_shutdown do
  x&.stop
end
####### OLD
# Puma can serve each request in a thread from an internal thread pool.
# The `threads` method setting takes two numbers: a minimum and maximum.
# Any libraries that use thread pools should be configured to match
# the maximum value specified for Puma. Default is set to 5 threads for minimum
# and maximum; this matches the default thread size of Active Record.
#



# Specifies the `environment` that Puma will run in.
#
environment ENV.fetch("RAILS_ENV") { "development" }

# Specifies the `pidfile` that Puma will use.
pidfile ENV.fetch("PIDFILE") { "tmp/pids/server.pid" }



# Allow puma to be restarted by `rails restart` command.
plugin :tmp_restart
