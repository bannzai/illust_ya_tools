require 'nokogiri'
require 'open-uri'
require 'pry'

Category = Struct.new(:name, :link_url, :special)
SubCategory = Struct.new(:category, :name, :link_url)
Result = Struct.new(:name, :page_url, :image_url)

class Scraper
  CHARSET = 'utf-8'
  BASE_URL = "https://www.irasutoya.com"

  def begin
    # First, scraper walk to feature theme and stored category for Next step
    categories_page = doc_open(BASE_URL)
    categories = []
    category_docs = categories_page.xpath('//*[@id="section_banner"]/a')
    category_docs.each { |category_doc| 
      link_url = category_doc.attributes&.[]('href')&.value
      puts "category link_url is #{link_url}"
      next if link_url.nil?
      # Skip instagram link
      next if link_url == "https://www.instagram.com/irasutoya/"

      img = category_doc.children.select { |e| e.name == "img" }.first
      name = img.attributes&.[]("alt").value
      puts "category name is #{name}"
      # irasutoya has special contents. if special content, link url to absolute
      categories.push(Category.new(name, link_url, link_url.include?(BASE_URL)))
    }

    # Second scraper walk to category page and collect sub category 
    sub_categories = []
    categories.each { |category| 
      sub_categories_page = doc_open(URI.join(BASE_URL, category.link_url))
      sub_category_docs = sub_categories_page.xpath('//*[@id="banners"]/a')
      sub_category_docs.each { |sub_category_doc| 
        link_url = sub_category_doc.attributes&.[]("href")&.value
        puts "sub_category link_url is #{link_url}"
        next if link_url.nil?

        img = sub_category_doc.children.select { |e| e.name == "img" }.first
        name = img.attributes&.[]("alt")&.value
        puts "sub_category name is #{name}"
        next if name.nil?

        sub_categories.push(SubCategory.new(category, name, link_url))
      }
    }

    binding.pry
  end

  def doc_open(url)
    Nokogiri::HTML.parse(open(url), nil, CHARSET)
  end
end
