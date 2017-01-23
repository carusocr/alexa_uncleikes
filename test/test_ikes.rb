require "minitest/autorun"
require "minitest/capybara"
require_relative "test_helper.rb"

class TestIkes < Minitest::Capybara::Test

  def setup
    @ikes = "https://ikes.com/capitol-hill/"
  end

  def test_home_page
    visit @ikes
    assert page.has_content?("This Week's Specials"), "Doesn't have specials link?"
    assert_link " $$$ "
    assert_link find(" $$$ "), "Can't find price sorting link!"
  end

=begin

  other tests:
  1. Test for a sort-by-price button.
  2. Test for retrieval of name + price hash?



=end
end
