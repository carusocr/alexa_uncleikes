#!/usr/bin/env ruby

=begin

Name: scrape_specials.rb
Author: Chris Caruso

Script to crawl to Uncle Ike's site and get daily specials.

=end

require 'capybara'
require 'capybara/dsl'
require 'sequel'

dbfile = 'db.ini'
dbcfg=[]
File.readlines(dbfile).each do |l|
  dbcfg << l[/=(.*)/,1]
end
host,user,pwd,db = dbcfg


Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, :browser => :chrome)
end

Capybara.javascript_driver = :chrome
Capybara.current_driver = :chrome   #should this be current or default? Explore reasons.

ikes = "http://ikes.com/23rd-union"

specials = Hash.new
include Capybara::DSL
visit ikes

page.first(:xpath,"//div[contains(@id,'form-confirm-checkbox')]").click
page.first(:xpath,'//*[@id="av-submit"]').click

page.all(:xpath,"//div[contains(@class,'budbTile')]").each do |z|
  strain_name = z.first(:xpath,".//div[contains(@class,'budbname')]").text
  strain_units = z.first(:xpath,".//div[@class='budbUnit']").text
  strain_price = z.first(:xpath,".//div[@class='budbPrice']").text.sub("00","")
  specials[strain_name] = strain_price if strain_units =~ /1G/ && strain_price.to_i < 8
end
#testing 

$dbh = Sequel.connect("mysql2://#{user}:#{pwd}@#{host}/#{db}")
def update_database(specials)
  #delete old data from table
  $dbh.run("delete from specials")
  specials.each do |k,v|
    $dbh.run("insert into specials(name) values ('#{k}')")
  end
end

update_database(specials)
