%w{
  version
  engine
}.each do |file|
  require "fetch/#{file}"
end