# This script adds a sample sentence and its translation to each of your cards.
#
# Script is part of Anki Utils by Judith Meyer aka Sprachprofi
# https://github.com/Sprachprofi/anki_utils

require File.join(File.dirname(__FILE__), 'inc_tatoeba_cutdown')

puts "Welcome! This utility will let you add lots of sample sentences to your exported tab-separated flashcards."

puts "Which file contains your cards? The first column must be in your target language."
filename = gets.chomp
raise "Could not find your file" if !File.exists?(filename)
new_filename = filename.sub(/^(.+)\.(\w+)$/, '\1_with_sample_sentences.\2')

puts "What is the Tatoeba code for your target language? E. g. 'eng', 'fra', 'deu', 'spa' ..."
target_lang = gets.chomp

puts "Do you want the translations of the sample sentences as well? If so, enter the appropriate Tatoeba code for the language to translate them to (e. g. 'eng' for English). Leave blank if you don't want a translation."
source_lang = gets.chomp

# Check for trimmed down versions of the Tatoeba database containing target language sentences only
if !File.exists?("tatoeba_sentences_#{target_lang}.txt")
	number = cutdown(target_lang)
	raise "Are you sure this is the right code for your target language? There are only #{number} sentences for it. If it is correct, try downloading a more recent Tatoeba export into this folder." if number < 100
elsif source_lang != "" and !File.exists?("tatoeba_sentences_#{source_lang}.txt")
	number = cutdown(source_lang)
	raise "Are you sure this is the right code for your target language? There are only #{number} sentences for it. If it is correct, try downloading a more recent Tatoeba export into this folder." if number < 100
end

puts "Preparing the sentence data..."

# read in Tatoeba's sentence links and put into memory as a Hash
f_links = File.open('tatoeba_links.csv', 'r:ascii') 
links = Hash.new
f_links.each_line do |line|
	line.strip!
	if line != ""
		id1, id2 = line.split("\t")
		if links[id1]
			links[id1] << id2.to_i
		else
			links[id1] = [id2.to_i]
		end
	end
end
f_links.close

# read in Tatoeba's target-language sentences and save as Array
f_fi = File.open("tatoeba_sentences_#{target_lang}.txt", "r:utf-8")
finnish_sentences = Array.new
first_sentence = f_fi.first
f_fi.each_line do |line|
	line.strip!
	if line != ""
		id, lang, sentence = line.split("\t")
		finnish_sentences[id.to_i] = sentence
	end
end
f_fi.close

# read in Tatoeba's source-language sentences and save as Array
english_sentences = Array.new
if source_lang != ""
	f_en = File.open("tatoeba_sentences_#{source_lang}.txt", "r:utf-8")
	f_en.each_line do |line|
		line.strip!
		if line != ""
			id, lang, sentence = line.split("\t")
			english_sentences[id.to_i] = sentence
		end
	end
	f_en.close
end

# ensure that this is a language that has spaces between words
space = " "
space = "" if first_sentence.include?(" ")

puts "Finding sample sentences for your words..."

f_original = File.read(filename)  # source file with the words needing sample sentences
f_result = File.open(new_filename, 'w:utf-8')   # target file

f_original.each_line do |line|   # go over each line of the original word list
	line.strip!
	chosen_fi_sentence = nil
	chosen_en_sentence = nil
	word = nil
	
	word, rest = line.split("\t", 2) if line != ""   # parse word list
	if word and !word.empty?
		
		# try to find a sample_sentence that contains this word
		finnish_ids = []
		finnish_sentences.each_with_index do |sentence, i|
			finnish_ids << i if sentence and sentence.match(space + word + space)  # try full word
			break if finnish_ids.size > 9
		end
		
		# otherwise try with a word without ending (important for European languages)
		if finnish_ids.size < 9 and space == " "
			finnish_sentences.each_with_index do |sentence, i|
				finnish_ids << i if sentence and sentence.match(space + word[0..-1])
				break if finnish_ids.size > 9
			end
		end
		
		# otherwise try with a word that may have a prefix and suffix (important for African languages, Indonesian etc.)
		if finnish_ids.size < 9 and space == " "
			finnish_sentences.each_with_index do |sentence, i|
				finnish_ids << i if sentence and sentence.match(word)
				break if finnish_ids.size > 9
			end
		end
		
		# now check for translations
		if source_lang != ""
			finnish_ids.each do |fi_id|
				possible_translation_ids = links[fi_id.to_s]  # these are possible translations, but not necessarily to our source language; many won't exist
				en_id = possible_translation_ids.detect { |id| english_sentences[id] } if possible_translation_ids
				if en_id
					# this is the first sentence with a translation
					chosen_fi_sentence = finnish_sentences[fi_id]
					chosen_en_sentence = english_sentences[en_id]
					break
				end
			end
		end
		
		chosen_fi_sentence ||= finnish_sentences[finnish_ids.first] if !finnish_ids.empty?    # otherwise use a Finnish sentence without translation
		chosen_fi_sentence ||= ""
		chosen_en_sentence ||= ""
		
		puts "Example for #{word}: #{chosen_fi_sentence}"
		f_result.puts(line + "\t" + chosen_fi_sentence + "\t" + chosen_en_sentence)  # save all previous information plus the new sample sentence and translation
	end
end

f_result.close

puts "Done! Your flashcards with sample sentences have been saved in #{new_filename}."