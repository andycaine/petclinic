namespace :db do
  DBDEPLOY = group('dbdeploy-core', 'dbdeploy-ant', :under => 'com.dbdeploy', :version => '3.0M3')
  MYSQL_DRIVER = 'com.mysql.jdbc.Driver'

  def db_settings
    Buildr.settings.user['database']
  end

  def db_username
    db_settings['username']
  end

  def db_password
    db_settings['password']
  end

  def db_host
    db_settings['host']
  end

  desc 'Drop the database'
  task :drop do
    sql :sql => 'drop database if exists petclinic'
  end

  desc 'Recreate and populate the database with test data'
  task :populate => ['db:drop', 'db:init'] do
    sql :src => 'src/main/resources/db/mysql/populateDB.sql', :db => 'petclinic'
  end
  
  desc 'Initialise the database'
  task :init => :artifacts do
    sql :src => 'src/main/resources/db/mysql/initDB.sql'
  end

  directory 'db'
  desc 'Migrate the database to the latest version'
  task :migrate => ['db', :init] do
    ant('dbmigrate') do |ant|
      ant.taskdef :name => 'dbdeploy',
      :classname => 'com.dbdeploy.AntTarget',
      :classpath => artifacts(DBDEPLOY, MYSQL).join(':')
      
      ant.dbdeploy :driver => MYSQL_DRIVER,
      :url => "jdbc:mysql://#{db_host}/petclinic",
      :userid => db_username,
      :password => db_password,
      :dir => 'db'
    end
  end

  def sql(opts = {})
    ant('sql') do |ant|
      ant_sql_opts = {
        :userid => db_username,
        :url => "jdbc:mysql://#{db_host}/#{opts[:db]}",
        :password => db_password,
        :driver => MYSQL_DRIVER,
        :classpath => MYSQL
      }
      if opts[:src]
        ant_sql_opts[:src] = opts[:src]
        ant.sql ant_sql_opts
      else
        ant.sql(ant_sql_opts) {
          ant.transaction(:pcdata => opts[:sql])
        }
      end
    end
  end
  
end
