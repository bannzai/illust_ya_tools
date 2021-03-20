require "illust_ya_tools/version"
require "illust_ya_tools/scraper"

module IllustYaTools
  class Error < StandardError; end
  # Your code goes here...
  def self.main
    puts 'main'
    Scraper.new.begin
  end
end
