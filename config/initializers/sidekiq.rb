# 这里的地址和端口号(1643)都需要配置成正确的
Sidekiq.configure_server do |config|
  config.redis = {url: 'redis://localhost:5566/0'}
end
Sidekiq.configure_client do |config|
  config.redis = {url: 'redis://localhost:5566/0'}
end