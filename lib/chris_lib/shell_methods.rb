# Helpers for shell-friendly Ruby scripts and deployment utilities.
module ShellMethods
  require 'dotenv'
  require 'bundler'
  require 'optparse'
  Dotenv.load

  # Run an R script via `Rscript --vanilla`
  #
  # @param script_path [String] absolute path to the R script
  # @param arg1 [String] first argument passed to the script (accessible in R via `commandArgs(trailingOnly=TRUE)[1]`)
  # @return [String] stdout from the R script
  # @note Warns and returns `nil` when the script is missing.
  def r_runner(script_path, arg1)
    raise ArgumentError, 'script_path must be provided' unless script_path.respond_to?(:to_s)
    path = script_path.to_s
    unless File.exist?(path)
      warn "r_runner: #{path} does not exist"
      return nil
    end
    arg = arg1.to_s
    `Rscript --vanilla #{path} #{arg}`
  end

  # @param file_path [String]
  # @return [Integer] file size in bytes
  # @note Returns 0 and warns when the file is missing.
  def file_size(file_path)
    raise ArgumentError, 'file_path must be provided' unless file_path.respond_to?(:to_s)
    path = file_path.to_s
    unless File.exist?(path)
      warn "file_size: #{path} does not exist"
      return 0
    end
    `stat -f%z #{path}`.to_i
  end

  # Send an iMessage to the "admin" buddy on macOS.
  # @param msg [String]
  # @return [String]
  # @note Warns and no-ops when `msg` is blank.
  def osx_imessage_admin(msg)
    if msg.nil? || msg.strip.empty?
      warn 'osx_imessage_admin called without a message; skipping'
      return nil
    end
    `osascript -e 'tell application "Messages" to send "#{msg}" to buddy "admin"'`
  end

  # Trigger a macOS notification via AppleScript.
  # @param msg [String]
  # @param title [String]
  # @return [String]
  # @note Warns and no-ops when `msg` is blank. Supplies a default title when missing.
  def osx_notification(msg, title)
    if msg.nil? || msg.strip.empty?
      warn 'osx_notification called without a message; skipping'
      return nil
    end
    if title.nil? || title.strip.empty?
      warn 'osx_notification called without a title; using default'
      title = 'Notification'
    end
    `osascript -e 'display notification "#{msg}" with title "#{title}"'`
  end

  # @return [String] hostname of the current machine
  def osx_hostname
    `hostname`
  end

  # Mail the signed-in macOS user using the BSD `mail` command.
  # @param subject [String]
  # @param body [String]
  # @return [String]
  # @note Warns and no-ops when `subject` is blank.
  def osx_send_mail(subject, body = nil)
    if subject.nil? || subject.strip.empty?
      warn 'osx_send_mail called without a subject; skipping'
      return nil
    end
    `echo "#{body}" | mail -s "#{subject}" 'Chris'`
  end

  # Parse CLI options for deployment scripts.
  # @return [Hash] options hash with keys :skip_migration, :fast, :special_rake
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

  # Placeholder for future custom rake tasks.
  # @raise [RuntimeError] always, prompting implementers to override
  def run_special_rake_task
    fail 'Need to implement by asking for name of rake task and
    also requiring confirmation'
  end

  # Create a Postgres snapshot by delegating to `script/getSnapShot.sh`.
  # @return [Boolean] command exit status
  def backup_database
    file_path = "../backups/prod#{time_hash}.dump"
    system('./script/getSnapShot.sh production ' + file_path)
  end

  # Notify users of an impending deploy via Heroku and progress bar countdown.
  # @return [void]
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

  # Timestamp helper used to build backup filenames.
  # @return [String]
  def time_hash
    time = Time.now
    time.day.to_s + time.month.to_s + time.year.to_s + '-' + time.hour.to_s + time.min.to_s
  end

# change in response to
#[DEPRECATED] `Bundler.with_clean_env` has been deprecated in favor of `Bundler.with_unbundled_env`. If you instead want the environment before bundler was originally loaded, use `Bundler.with_original_env`
# remove this comment when clear that this works.
  # Compare local and remote database schema versions.
  # @param remote [String, nil] Heroku remote name
  # @return [Boolean, nil] true when versions match, false when mismatched, nil when versions cannot be read
  def same_db_version(remote: nil)
    destination = (remote.nil? ? nil : "--remote #{remote}")
    lv = `rake db:version`
    puts 'Local version: ', lv
    hv = Bundler.with_unbundled_env{ 
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

  # Ensure git workspace is clean before deploying.
  def check_git_clean
    puts "Checking git status"
    gs = `git status`
    return unless gs['working tree clean'].nil?
    puts "Exiting, you need to commit files"
    exit 1
  end

  # Verify that `chris_lib` is up to date before deploying.
  def check_chris_lib_status
    gs=`cd ../chris_lib;git status`; lr=$?.successful?
    return unless gs['working tree clean'].nil? && gs['up-to-date'].nil?
    puts "Exiting, chris_lib is not up to date with master."
    exit 3
    system('cd $OLDPWD')
  end

  # Optionally run migrations if local and remote schema versions differ.
  # @param remote [String, nil]
  # @param skip_migration [Boolean]
  # @return [void]
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

  # Notify Rollbar of a new deploy via its API.
  # @param access_token [String, nil]
  # @return [void]
  def notify_rollbar_of_deploy(access_token: nil)
    warn 'notify_rollbar_of_deploy called without access token' if access_token.nil? || access_token.empty?
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
