# Sidekiq::Extensions.enable_delay!
# comment below lines after testing..
Sidekiq.default_job_options = { retry: 0 }
Sidekiq.default_job_options = { 'backtrace' => 0, 'retry' => 0 }
Sidekiq.configure_client do |config|
	config.redis = { url: "redis://redis:6379" }
end