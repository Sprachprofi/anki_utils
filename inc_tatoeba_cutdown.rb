
# takes the 75+ MB file containing all Tatoeba sentences (downloaded from their website)
# extracts the sentences in one particular language and saves them as separate file for easy access for all future uses
# lang is expected to be a valid Tatoeba language code, e. g. "eng", "deu", "fra", "spa", ...
def cutdown(lang)
	puts "Generating Tatoeba lists for #{lang} - this will only be necessary the first time"
	
	f_all = File.open('tatoeba_sentences.csv', 'r:utf-8') 
	f_lang = File.open("tatoeba_sentences_#{lang}.txt", 'w:utf-8') 
	count_lang = 0

	f_all.each_line do |line|
		line.strip!
		if line != "" and line.include?("\t#{lang}\t")  # sentence in this language
			f_lang.puts line
			count_lang += 1
		end
	end

	f_all.close
	f_lang.close
	
	puts "#{count_lang} sentences have been found for this language code."
	count_lang
end