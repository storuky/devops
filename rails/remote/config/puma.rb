environment "production"

#bind 'tcp://0.0.0.0:3000'
bind 'unix:/home/deploy/project_name/shared/tmp/sockets/puma.sock'
pidfile "/home/deploy/project_name/shared/tmp/pids/puma.pid"
state_path "/home/deploy/project_name/shared/tmp/sockets/puma.state"
directory "/home/deploy/project_name/current"

workers 2
threads 1,2

daemonize true

activate_control_app 'unix:/home/deploy/project_name/shared/tmp/sockets/pumactl.sock'

prune_bundler