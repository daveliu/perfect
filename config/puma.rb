APP_ROOT = '/home/meizu/web/perfect/current'
pidfile "#{APP_ROOT}/tmp/pids/puma.pid"
state_path "#{APP_ROOT}/tmp/pids/puma.state"

railsenv = 'production'
directory APP_ROOT
environment railsenv

stdout_redirect "#{APP_ROOT}/log/puma-#{railsenv}.stdout.log", "#{APP_ROOT}/log/puma-#{railsenv}.stderr.log"

daemonize true
workers 4
threads 8,32
preload_app!

bind "unix://#{APP_ROOT}/tmp/pids/#{railsenv}.socket"