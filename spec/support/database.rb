require 'sequel'

RSpec.configure do |config|
  config.before(:suite) do
    db_url = $config["database_url"]
    fail 'configure the database on spec/config.yml' if db_url.nil? || db_url.empty?

    # Drop and recreate the database
    postgres_uri = URI.parse(db_url) + "/postgres"
    Sequel.connect(postgres_uri.to_s) do |db|
      db_name = URI.parse(db_url).path[1..-1]
      db.run("DROP DATABASE IF EXISTS #{db_name.inspect}")
      db.run("CREATE DATABASE #{db_name.inspect}")
    end

    $db = Sequel.connect(db_url)
    Sequel.extension :migration
    Sequel::Migrator.run($db, 'db/migrations')
  end

  config.around(:each) do |example|
    $db.transaction(:rollback => :always) { example.run }
    $db.disconnect
  end
end
