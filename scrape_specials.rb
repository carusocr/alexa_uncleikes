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

ikes = "http://uncleikespotshop.com/menu"

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
    i = "Alaskan Thunder Fuck" if i == "ATF"
    $dbh.run("insert into specials(name) values ('#{i}')")
  end
end

update_database(specials)
