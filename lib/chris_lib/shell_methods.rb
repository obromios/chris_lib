# methods for bash ruby scripts
module ShellMethods
  require 'dotenv'
  require 'bundler'
  require 'optparse'
  Dotenv.load

  # runs an R script from ruby
  # script_path is absolute path of R script
  # arg1 is an argument passed to script, can access in R by
  # arg1 <- commandArgs(trailingOnly=TRUE)[1]
  def r_runner(script_path, arg1)
    `Rscript --vanilla #{script_path} #{arg1}`
  end

  def file_size(file_path)
    `stat -f%z #{file_path}`.to_i
  end

  def osx_imessage_admin(msg)
    `osascript -e 'tell application "Messages" to send "#{msg}" to buddy "admin"'`
  end

  def osx_notification(msg, title)
    `osascript -e 'display notification "#{msg}" with title "#{title}"'`
  end

  def osx_hostname
    `hostname`
  end

  # mail to osx user
  # https://stackoverflow.com/q/41602984/1299362
  def osx_send_mail(subject, body = nil)
    `echo "#{body}" | mail -s "#{subject}" 'Chris'`
  end

  def parse_options
    @options = {}
    OptionParser.new do |opts|
      opts.on("-s", "--skip_migration", "Skip migrations") do
        @options[:skip_migration] = true
      end
      opts.on("-f", "--fast", "Deploy without warnings and skip migrations") do
        @options[:fast] = true
      end
      opts.on("-r", "--special_rake", "Run special rake task") do
        @options[:special_rake] = true
      end
    end.parse!
    @options[:skip_migration] = true   if @options[:fast]
  end

  def run_special_rake_task
    fail 'Need to implement by asking for name of rake task and
    also requiring confirmation'
  end

  def backup_database
    file_path = "../backups/prod#{time_hash}.dump"
    system('./script/getSnapShot.sh production ' + file_path)
  end

  def warn_users
    system('heroku run rake util:three_min_warning --remote production')
    # spend one minute precompiling 
    progress_bar = ProgressBar.create
    # now 2 minutes waiting
    increment = 3 * 60 / 100
    (1..100).each do |_i|
      sleep increment
      progress_bar.increment
      progress_bar.refresh
    end
    system('heroku run rake util:delete_newest_announcement --remote production')
    system('heroku run rake util:warn_under_maintenance --remote production')
  end

  def precompile_assets(target: 'local')
    puts "Precompiling assets for #{target}"
    if target == 'local'
      asset_host = ENV['RAILS_HOST_PATH']
    elsif target == 'staging'
      asset_host = 'cstaging-golf.herokuapp.com'
    elsif target == 'production'
      asset_host = 'www.thegolfmentor.com'
    else
      raise "Invalid target for precompile: #{target}"
    end
    puts "precompile asset_host is #{asset_host}"
    system("RAILS_ENV=production RAILS_HOST_PATH=#{asset_host} rake assets:precompile")
    `git add .`
    commit_msg = "Add precompiled assets for #{target}"
    system(%[git commit -m "#{commit_msg}"])
  end

  def time_hash
    time = Time.now
    time.day.to_s + time.month.to_s + time.year.to_s + '-' + time.hour.to_s + time.min.to_s
  end

  def same_db_version(remote: nil)
    destination = (remote.nil? ? nil : "--remote #{remote}")
    lv = `rake db:version`
    puts 'Local version: ', lv
    hv = Bundler.with_clean_env { 
      `heroku run rake db:version #{destination}`
    }
    puts hv
    return nil if hv.nil? || hv.empty?
    return nil if lv.nil? || lv.empty?
    key = 'version: '
    nl = lv.index(key) + 9
    l_version = lv.slice(nl..-1)
    nh = hv.index(key) + 9
    h_version = hv.slice(nh..-1)
    l_version == h_version
  end

  def check_git_clean
    puts "Checking git status"
    gs = `git status`
    return unless gs['working tree clean'].nil?
    puts "Exiting, you need to commit files"
    exit 1
  end

  def check_chris_lib_status
    gs=`cd ../chris_lib;git status`; lr=$?.successful?
    return unless gs['working tree clean'].nil? && gs['up-to-date'].nil?
    puts "Exiting, chris_lib is not up to date with master."
    exit 3
    system('cd $OLDPWD')
  end

  def migrate_if_necessary(remote: nil, skip_migration: false)
    if skip_migration
      puts "No migration will be performed due to --fast or --skip_migration options"
    else
      destination=(remote.nil? ? nil : "--remote #{remote}")
      puts "Checking local and remote databases have same version and migrates if necessary"
      if same_db_version(remote: remote)
         puts "No migration necessary"
      else
         puts "Warning, different db versions"
         system('tput bel')
         puts "Press m<cr> to migrate or q<cr> to exit"
         ans=$stdin.gets()
         exit 2 if ans[0]!='m'
         system("heroku run rake db:migrate #{destination}")
      end
    end
  end

  def notify_rollbar_of_deploy(access_token: nil)
    system("ACCESS_TOKEN=#{access_token}")
    system("ENVIRONMENT=production")
    system("LOCAL_USERNAME=`whoami`")
    system("COMMENT=v#{TGM_VERSION}")
    sha = `git log -n 1 --pretty=format:'%H'`
    system("REVISION=sha")
    puts "Notifiying of revision #{sha}"
    cr = `curl https://api.rollbar.com/api/1/deploy/ \
    -F access_token=$ACCESS_TOKEN \
    -F environment=$ENVIRONMENT \
    -F revision=$REVISION \
    -F comment=$COMMENT \
    -F local_username=$LOCAL_USERNAME`
    if cr.class == Hash && cr['data'].empty?
      puts "Rollbar was notified of deploy of v#{TGM_VERSION} with SHA #{sha[0..5]}"
    else
      system('tput bel;tput bel')
      puts "Failure to notify Rollbar of deploy of v#{TGM_VERSION} with SHA #{sha[0..5]}", cr
    end
  end
end