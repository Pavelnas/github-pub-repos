
if %w(staging production).include?(ENV['RAILS_ENV']) && ENV['DB_ADAPTER'] != 'nulldb'
  begin
    client = client = Aws::SecretsManager::Client.new(region: ENV.fetch('AWS_REGION', 'eu-north-1'))
    secrets_string = client.get_secret_value(secret_id: "github-pub-repos/#{ENV['RAILS_ENV']}").secret_string
    parsed_secrets = JSON.parse(secrets_string)

    parsed_secrets.each do |env_key, env_value|
      ENV[env_key] = env_value
    end
  rescue Aws::SecretsManager::Errors::ResourceNotFoundException
  end
end
