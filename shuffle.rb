# encoding: UTF-8

# This script shuffles all your cards.
# Feed it any plain-text file: .tsv, .csv, .txt, whatever
# USAGE: shuffle.rb <your file> <output file>
# e. g. shuffle.rb sample.txt sample_shuffled.txt
#
# Script is part of Anki Utils by Judith Meyer aka Sprachprofi
# https://github.com/Sprachprofi/anki_utils

filename = ARGV[0] || (raise "You must specify a file whose content you want to shuffle.\nUsage: shuffle.rb <your file> <where to save the result>\nIf the result file name is the same as the source, that file will be overwritten.")
new_filename = ARGV[1] || filename.sub(/^(.+)\.(\w+)$/, '\1_shuffled.\2')

# separate each entry within that file
dic = Array.new
File.open(filename, 'r:utf-8').each_line do | entry |
  dic << entry
end

# shuffle all entries
dic.shuffle!

# write new list to file
File.open(new_filename, 'w:utf-8') do |f|
  dic.each do |entry|
    f.puts(entry)
  end
end

puts "Entries have been shuffled."
