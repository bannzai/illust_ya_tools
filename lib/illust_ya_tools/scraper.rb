require 'nokogiri'
require 'open-uri'
require 'pry'

Category = Struct.new(:name, :link_url, :special)
Result = Struct.new(:name, :page_url, :image_url)

class Scraper
  CHARSET = 'utf-8'
  BASE_URL = "https://www.irasutoya.com"

  def begin
    document = doc_open(BASE_URL)

    # First, nokogiri walk to feature theme and stored category for Next step
    categories = []
    category_links = document.xpath('//*[@id="section_banner"]/a')
    category_links.each { |category| 
      link = category.attributes['href'].value
      # Skip instagram link
      next if link == "https://www.instagram.com/irasutoya/"
      img = category.children.select { |e| e.name == "img" }.first
      # irasutoya has special contents. if special content, link url to absolute
      categories.push(Category.new(img.name, link, link.include?("https://www.irasutoya.com")))
    }
    binding.pry
  end

  def doc_open(url)
    Nokogiri::HTML.parse(open(url), nil, CHARSET)
  end
end
