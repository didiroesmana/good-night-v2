require 'database_cleaner/active_record'

RSpec.configure do |config|
  config.use_transactional_fixtures = false

  config.prepend_before(:suite) do
    DatabaseCleaner.clean_with(:deletion)
  rescue DatabaseCleaner::Safeguard::Error::RemoteDatabaseUrl
    DatabaseCleaner.allow_remote_database_url = true
    DatabaseCleaner.clean_with(:deletion)
  end

  config.prepend_before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.append_after(:each) do
    DatabaseCleaner.clean
  end
end
