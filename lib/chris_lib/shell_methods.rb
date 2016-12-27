module ShellMethods
	def precompile_assets(target: 'development')
	  puts "Precompiling assets for #{target}"
	  if target == 'development'
	    asset_host = ENV['RAILS_HOST_PATH']
	  elsif target == 'staging'
	    asset_host = 'cstaging-golf.herokuapp.com'
	  elsif target == 'producton'
	    asset_host = 'www.thegolfmentor.com'
	  else
	    raise "Invalid target for precompile: #{target}"
	  end
	  `rake assets:clobber`
	  system("RAILS_ENV=production RAILS_HOST_PATH=#{asset_host} rake assets:precompile")
	  system('rake heroku:make_hashless_assets') if target == 'production'
	  `git add .`
	  commit_msg = "Add precompiled assets for #{target}"
	  system(%[git commit -m "#{commit_msg}"])
	end
	def time_hash
		time=Time.now
		time.day.to_s + time.month.to_s + time.year.to_s + '-' + time.hour.to_s + time.min.to_s
	end
	def same_db_version(remote: nil)
		destination=(remote.nil? ? nil : "--remote #{remote}")
		lv=`rake db:version`;lr=$?.success?
		puts "Local version: ",lv
		hv=`heroku run rake db:version #{destination}`;hr=$?.success?
		puts hv
		key='version: '
		nl=lv.index(key)+9
		l_version=lv.slice(nl..-1)
		nh=hv.index(key)+9
		h_version=hv.slice(nh..-1)
		l_version==h_version
	end
	def check_git_clean
		puts "Checking git status"
		gs=`git status`; lr=$?.success?
		if gs['working directory clean'].nil?
			puts "Exiting, you need to commit files"
			exit 1
		end
	end
	def check_chris_lib_status
		gs=`cd ../chris_lib;git status`; lr=$?.success?
		if gs['working directory clean'].nil? && gs['up-to-date'].nil?
			puts "Exiting, chris_lib is not up to date with master."
			exit 3
		end
		system('cd $OLDPWD')
	end
	def migrate_if_necessary(remote: nil,migrate: nil)
		if migrate == '--no_migrate'
			puts "No migration will be performed due to --no_migrate option"
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