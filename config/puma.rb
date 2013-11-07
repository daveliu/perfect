APP_ROOT = '/Users/dave/homebrew/code/perfect'
pidfile "#{APP_ROOT}/tmp/pids/puma.pid"
state_path "#{APP_ROOT}/tmp/pids/puma.state"

railsenv = 'production'

stdout_redirect "#{APP_ROOT}/log/puma-#{railsenv}.stdout.log", "#{APP_ROOT}/log/puma-#{railsenv}.stderr.log"

daemonize true
workers 4
threads 8,32
preload_app!

bind "unix://#{APP_ROOT}/tmp/#{railsenv}.socket"