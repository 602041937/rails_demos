# config valid for current version and patch releases of Capistrano
lock "~> 3.11.0"

set :application, "hpd_demos"  ## demo 换成你的项目名
set :repo_url, "https://github.com/602041937/rails_demos.git" ## 这里写上项目代码的托管地址
append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system", "public/uploads", "vendor/bundle"
append :linked_files, "config/database.yml", "config/master.key"

set :rvm_type, :user
set :rvm_ruby_version, '2.4.0'

# 需要运行命令创建这3个文件夹
namespace :deploy do
  namespace :check do
    desc 'Create Directories for Pid, Log and Socket'
    task :make_pid_log_and_socket_dirs do
      on roles(:all) do
        execute "mkdir -p #{shared_path}/tmp/sockets"
        execute "mkdir -p #{shared_path}/tmp/pids"
        execute "mkdir -p #{shared_path}/log"
      end
    end
  end
end



# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, "/var/www/my_app_name"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml"

# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure
