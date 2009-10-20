namespace :db do
  desc "Load seed data into the current environment's database."
  task :seed => :environment do
    require 'active_record/fixtures'
    fixture_dir = 'spec/fixtures'
    ActiveRecord::Base.establish_connection(RAILS_ENV.to_sym)
    Dir.glob(File.join(RAILS_ROOT, fixture_dir, '*.yml')).each do |f|
      Fixtures.create_fixtures(fixture_dir , File.basename(f, '.yml'))
    end
    puts "You will now set up the administrator user."
    create_admin
  end

  task :create_admin => :environment do
    loop do
      print "First name: "
      first = STDIN.gets.chomp
      print "Last name: "
      last = STDIN.gets.chomp
      print "Email address: "
      email = STDIN.gets.chomp
      print "Password: "
      password = STDIN.gets.chomp
      print "Confirm password: "
      password_confirmation = STDIN.gets.chomp
      begin
        u = User.create!(
          :first_name => first,
          :last_name => last,
          :email => email,
          :password => password,
          :password_confirmation => password_confirmation,
          :admin => true
        )
        puts "Created #{u}."
        break
      rescue ActiveRecord::RecordInvalid => e
        puts "Failed to create the administrator: #{e}."
      end
    end
  end
end

