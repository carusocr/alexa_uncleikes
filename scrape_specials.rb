#!/usr/bin/env ruby

=begin

Name: scrape_specials.rb
Author: Chris Caruso

Script to crawl to Uncle Ike's site and get daily specials.

xpath:

1. Ike's age check default page:
page.first(:xpath,"//div[contains(@id,'form-confirm-checkbox')]").click
page.first(:xpath,'//*[@id="av-submit"]').click

2. Then to main page:

Sort by descending price:
page.first(:xpath,"//div[contains(@class,'budbSortPrice')]").click

Then get first...? prices?

Iterate through budbTile list:
z = page.first(:xpath,"//div[contains(@class,'budbTile')]")
[36] pry(main)> z.first(:xpath,".//div[@class='budbUnit']").text
=> "1G"
[37] pry(main)> z.first(:xpath,".//div[@class='budbPrice']").text
=> "500"

page.all(:xpath,"//div[contains(@class,'budbTile')]").each do |z|

z.first(:xpath,".//div[contains(@class,'budbname')]").text
z.first(:xpath,".//div[contains(@class,'budbPriceSections')]/div[contains(@class,'budbPrice')]").text
z.first(:xpath,".//div[contains(@class,'budbPriceSections')]/div[contains(@class,'budbUnit')]").text
# add name + price to hash of specials if qty == 1g and price < $9  

We want to get name+price of any 1g strains that are under...8 bucks? Hmm.

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

specials = []
include Capybara::DSL
visit ikes
s = page.first(:xpath,"//div[@class='imp-extras']").text
specials = s[/available: (.*)\. /,1].sub(' and',',').split(',').map {|x| x.sub('.','').sub(/^ /,'').sub(/\'/,'')}
#testing 

specials.each do |i|
  puts i
end

$dbh = Sequel.connect("mysql2://#{user}:#{pwd}@#{host}/#{db}")
def update_database(specials)
  #delete old data from table
  $dbh.run("delete from specials")
  specials.each do |i|
    $dbh.run("insert into specials(name) values ('#{i}')")
  end
end

update_database(specials)

