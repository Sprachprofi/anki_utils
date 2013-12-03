# encoding: UTF-8

# takes a list of words in a strictly-specified tab-delimited format
# goes to Forvo's Finnish section, looks for the word there
# if the word exists, the mp3 gets downloaded to the same folder as this script

# Script is part of Anki Utils by Judith Meyer aka Sprachprofi
# https://github.com/Sprachprofi/anki_utils


# some standard modules to make this easier
require 'rubygems'
require 'nokogiri'
require 'uri'
require 'open-uri'
require 'net/http'

puts "Welcome! This utility will let you download lots of human pronunciations from Forvo."
puts "You must have an account with Forvo and sign up for their API key. A free subscription (for educational non-commercial use) gets you 500 word requests a day."
puts "What's your API key? (find it at http://api.forvo.com/account/) "
apikey = gets.chomp

puts "What is the file containing your words? Must be in the same folder as this script. Must be UTF-8."
filename = gets.chomp

puts "What is the Forvo language code for the language these words are in? E. g. 'en' or 'de' or 'ind', full list at http://www.forvo.com/languages-codes/"
lang = gets.chomp

skip = false
puts "If resuming: what's the last word for which you downloaded the pronunciation? (leave empty for none)"
last_known = gets.chomp
skip = true if last_known.length > 0

filecontent = ""
File.open(filename, 'r:utf-8') do |f|
	filecontent = f.read
end

nomore = false
x = 0
filecontent.split(/\n/u).each do | line |   # go over each line of the word list
	line.strip!
	if !nomore and !skip and line != "" and !line.include?("!!")  # if the line isn't commented out and shouldn't be skipped
		
		word = line.split("\t", 2).first
		translation = ""
		x += 1
		if x <= 500
			
			origword = String.new(word)
			word = URI.escape(word, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
			# look up the word on Forvo
			url = "http://apifree.forvo.com/key/#{apikey}/format/xml/action/standard-pronunciation/word/" + word + "/language/" + lang
			begin 
				body = open(url).read
			rescue Timeout::Error => e
				puts "Timeout searching for " + word
			end
			
			body_text = body.to_s
			
			if body and !body_text.include?("<items></items>")  # if Forvo has an entry for this
				
				pathmp3_match = body_text.match(/<pathmp3>(.+)<\/pathmp3>/)  # extract path of mp3
				if pathmp3_match and pathmp3_match[1]
					puts "Found mp3 for " + origword
					pathmp3 = pathmp3_match[1]
					pathmp3.sub!("http://apifree.forvo.com", "")
				
					# download mp3 and save it to the same location as this script
					origword.gsub!(/\W+/, '')
					Net::HTTP.start("apifree.forvo.com") { |http|
					resp = http.get(pathmp3)		 
						open(origword + ".mp3", "wb") { |file|
							file.write(resp.body)
						}
					}
				end
				
			end
			
		else
			skip = true
		end
    elsif line.split("\t", 2).first == last_known  # start from next line
		skip = false
	end
end

puts "Mass pronunciation complete. Look for the mp3s in this folder. "
puts "You can add these mp3s to your cards by using the search & replace in Anki's browser:"
puts "Check the regular expressions checkbox, search for (.*) in your target language field \nand replace it with \"\\1 [sound:\\1.mp3]\"."
