require "bundler/capistrano"

server "37.139.21.44", :web, :app, :db, primary: true

set :application, "deliverit"
set :user, "deployer"
set :deploy_to, "/home/#{user}/apps/#{application}"
set :deploy_via, :remote_cache
set :use_sudo, false
set :all_app, ["deliverit", "mymovieslist"]

set :scm, "git"
set :repository, "git@github.com:wildDAlex/#{application}.git"
set :branch, "master"

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

after "deploy", "deploy:cleanup" # keep only the last 5 releases

namespace :deploy do
  %w[start stop restart].each do |command|
    desc "#{command} unicorn server"
    task command, roles: :app, except: {no_release: true} do
      run "/etc/init.d/unicorn_#{application} #{command}"
    end
  end

  task :setup_config, roles: :app do
    sudo "ln -nfs #{current_path}/config/nginx.conf /etc/nginx/sites-enabled/#{application}"
    sudo "ln -nfs #{current_path}/config/unicorn_init.sh /etc/init.d/unicorn_#{application}"
    run "mkdir -p #{shared_path}/config"
    put File.read("config/database.example.yml"), "#{shared_path}/config/database.yml"
    put File.read("config/secrets.example.yml"), "#{shared_path}/config/secrets.yml"
    put File.read("config/environments/production.example.rb"), "#{shared_path}/config/environments/production.rb"
    puts "Now edit the config files in #{shared_path}."
  end
  after "deploy:setup", "deploy:setup_config"

  task :symlink_config, roles: :app do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{shared_path}/config/secrets.yml #{release_path}/config/secrets.yml"
    run "ln -nfs #{shared_path}/config/environments/production.rb #{release_path}/config/environments/production.rb"
  end
  after "deploy:finalize_update", "deploy:symlink_config"

  desc "Make sure local git is in sync with remote."
  task :check_revision, roles: :web do
    unless `git rev-parse HEAD` == `git rev-parse origin/master`
      puts "WARNING: HEAD is not the same as origin/master"
      puts "Run `git push` to sync changes."
      exit
    end
  end
  before "deploy", "deploy:check_revision"

  # Restarting all unicorn app
  after "deploy", "deploy:restart_all_apps"

  task :restart_all_apps, roles: :app, except: {no_release: true} do
    all_app.each do |app|
      run "/etc/init.d/unicorn_#{app} stop"
    end
    sleep(10)
    all_app.each do |app|
      run "/etc/init.d/unicorn_#{app} start"
    end
  end

end


namespace :rails do
  desc "Open the rails console on each of the remote servers"
  task :console, :roles => :app do
    execute_interactively "bundle exec rails console #{rails_env}"
  end

  desc "Open the rails dbconsole on each of the remote servers"
  task :dbconsole, :roles => :app do
    execute_interactively "bundle exec rails dbconsole #{rails_env}"
  end

  def execute_interactively(command)
    user = fetch(:user)
    port = 22
    server ||= find_servers_for_task(current_task).first
    exec "ssh -l #{user} #{server} -p #{port} -t 'cd #{deploy_to}/current && #{command}'"
  end
end




##set :application, "set your application name here"
##set :repository,  "set your repository location here"

# set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

##role :web, "your web-server here"                          # Your HTTP server, Apache/etc
##role :app, "your app-server here"                          # This may be the same as your `Web` server
##role :db,  "your primary db-server here", :primary => true # This is where Rails migrations will run
##role :db,  "your slave db-server here"

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end