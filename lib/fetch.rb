require "fetchable"

%w{
  version
  engine
  base
}.each do |file|
  require "fetch/#{file}"
end