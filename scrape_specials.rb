#!/usr/bin/env ruby

=begin

Name: scrape_specials.rb
Author: Chris Caruso

Script to crawl to Uncle Ike's site and get daily specials.

=end

require 'capybara'
require 'capybara/dsl'
require 'sequel'
require 'yaml'

@dbcfg = YAML::load(File.open("db.yml"))

Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, :browser => :chrome)
end

Capybara.javascript_driver = :chrome
Capybara.current_driver = :chrome   #should this be current or default? Explore reasons.

ikes = "http://ikes.com/23rd-union"

specials = Hash.new
include Capybara::DSL
visit ikes

# If redirected to age confirmation page, click 'I am over 21' box and submit form.
if page.has_xpath?("//div[contains(@id,'form-confirm-checkbox')]")
  page.first(:xpath,"//div[contains(@id,'form-confirm-checkbox')]").click
  page.first(:xpath,'//*[@id="av-submit"]').click
end

page.all(:xpath,"//div[contains(@class,'budbTile')]").each do |z|
  strain_name = z.first(:xpath,".//div[contains(@class,'budbname')]").text
  strain_units = z.first(:xpath,".//div[@class='budbUnit']").text
  strain_price = z.first(:xpath,".//div[@class='budbPrice']").text.sub("00","")
  specials[strain_name] = strain_price if strain_units =~ /1G/ && strain_price.to_i < 8
end

def update_database(specials)
  dbh = Sequel.connect(@dbcfg)
  # Delete old data from table before inserting new rows.
  dbh[:specials].delete
  specials.each do |k,v|
    dbh[:specials].insert([:name],[k])
  end
end

update_database(specials)
