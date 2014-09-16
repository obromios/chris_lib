module ShellMethods
	def time_hash
		time=Time.now
		time.day.to_s + time.month.to_s + time.year.to_s + '-' + time.hour.to_s + time.min.to_s
	end
	def same_db_version
		lv=`rake db:version`;lr=$?.success?
		puts "Local version: ",lv
		hv=`heroku run rake db:version`;hr=$?.success?
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
		puts "Checking chris_lib_status"
		if gs['working directory clean'].nil? || gs['up-to-date'].nil?
			puts "Exiting, chris_lib is not up to date with master."
			exit 3
		end
		system('cd $OLDPWD')
	end
	def migrate_if_necessary
		puts "Checking local and remote databases have same version and migrates if necessary"
		if same_db_version
		 	puts "No migration necessary"
		elsif ARGV[0] == '--no_migrate'
			puts "No migration will be performed due to --no_migrate option"
		else
		 	puts "Warning, different db versions"
		 	puts "Press m<cr> to migrate or q<cr> to exit"
		 	ans=$stdin.gets()
		 	exit 2 if ans[0]!='m'
		 	system("heroku run rake db:migrate")
		end
	end
end