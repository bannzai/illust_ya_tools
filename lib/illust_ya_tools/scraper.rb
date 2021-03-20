require 'nokogiri'
require 'open-uri'
require 'pry'
require 'csv'
require 'selenium-webdriver'

Category = Struct.new(:name, :link_url, :special)
SubCategory = Struct.new(:category, :name, :link_url)
Element = Struct.new(:sub_category, :link_url)
Monster = Struct.new(:name, :page_url, :image_url, :attack_point)
Result = Struct.new(:name, :page_url, :image_url)

class Scraper
  CHARSET = 'utf-8'
  BASE_URL = "https://www.irasutoya.com"

  def begin
    @i = 0
    # First, scraper walk to feature theme and stored category for Next step
    categories_page = doc_open(BASE_URL)
    categories = []
    category_docs = categories_page.xpath('//*[@id="section_banner"]/a')
    category_docs.each { |category_doc| 
      link_url = category_doc.attributes&.[]('href')&.value
      next if link_url.nil?
      # Skip instagram link
      next if link_url == "https://www.instagram.com/irasutoya/"

      img = category_doc.children.select { |e| e.name == "img" }.first
      name = img.attributes&.[]("alt").value
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
        next if link_url.nil?

        img = sub_category_doc.children.select { |e| e.name == "img" }.first
        name = img.attributes&.[]("alt")&.value
        next if name.nil?

        sub_categories.push(SubCategory.new(category, name, link_url))
      }
    }

    # Third scraper walk to sub category page and collect each final elements 
    elements = []
    sub_categories.each { |sub_category|
      element_page = doc_open(sub_category.link_url)
      elements.push(walk_to_next_element_page(element_page, sub_category, 0))
      elements = elements.flatten!
    }

    monsters = []
    elements.each { |element|
      element_page = doc_open(element.link_url)
      name = element_page.xpath('//*[@id="post"]/div[1]/h2').first
      next if name.nil?
      image_url = element_page.xpath('//*[@id="post"]/div[2]/div[1]/a/img').first
      binding.pry
      next if image_url.nil?

      attack_point = rand(100...10000)
      attack_point = attack_point / 100 * 100
      monsters.push(Monster.new(name, element.link_url, image_url, attack_point))
    }

    CSV.open("seed.csv", "wb") do |csv|
      monsters.each { |monster| 
        csv << [monster.name.children[0].to_s.delete_prefix("\n").delete_suffix("\n"), monster.page_url, monster.image_url, monster.attack_point]
      }
    end

    binding.pry
  end

  def walk_to_next_element_page(element_page, sub_category, page) 
    elements = collect_element(element_page, sub_category)

    return elements if page == 1
  
    next_button_doc = element_page.xpath('//*[@id="Blog1_blog-pager-older-link"]')
    return elements if next_button_doc.nil?
    return elements if next_button_doc.empty?

    next_element_page_link_url = next_button_doc[0].attributes&.[]("href").value
    return elements if next_element_page_link_url.nil?
    puts "next_element_page_link_url: #{next_element_page_link_url}"

    next_element_page = doc_open(next_element_page_link_url)
    n = walk_to_next_element_page(next_element_page, sub_category, page + 1)
    return elements if n.nil?
    elements.push(n)
    elements = elements.flatten!

    return elements
  end

  def collect_element(element_page, sub_category)
    elements = []
    element_docs = element_page.xpath('//*[@id="post"]/div[1]/a')
    element_docs.each { |element_doc|
      link_url = element_doc.attributes&.[]("href")&.value
      next if link_url.nil?

      elements.push(Element.new(sub_category, link_url))
    }
    elements
  end

  def doc_open(url)
    Nokogiri::HTML.parse(URI.open(URI.escape(url.to_s).to_s), nil, CHARSET)
  end
end
