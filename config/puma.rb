APP_ROOT = '/home/dave/web/perfect/current'
pidfile "#{APP_ROOT}/tmp/puma.pid"
state_path "#{APP_ROOT}/tmp/puma.state"

railsenv = 'production'

stdout_redirect "#{APP_ROOT}/log/puma-#{railsenv}.stdout.log", "#{APP_ROOT}/log/puma-#{railsenv}.stderr.log"

daemonize true
workers 4
threads 8,32
preload_app!

bind "unix://#{APP_ROOT}/tmp/#{railsenv}.socket"