# encoding: UTF-8

# This script arranges all your cards alphabetically according to the first field
# Feed it any plain-text file: .tsv, .csv, .txt, whatever
# USAGE: alphabetize.rb <your file> <output file>
# e. g. alphabetize.rb sample.txt sample_sorted.txt
#
# Script is part of Anki Utils by Judith Meyer aka Sprachprofi
# https://github.com/Sprachprofi/anki_utils

def unicode_downcase_and_sortready(txt)
   txt = txt.downcase
   txt.tr!('ΑΒΞΔΕΦΓΗΙΘΚΛΜΝΟΠΡΣΤΥΩXΨΖΆΈΉΊΌΎΏάέήίόύώ', 'αβξδεφγηιθκλμνοπρστυωχψζαεηιουωαεηιουω')
   return txt.tr('ĈĜĤĴŜŬÑÄÖÜÁÀÂÉÈÊÍÌÎÓÒÔÚÙÛÝỲŶ', 'ĉĝĥĵŝŭñäöüáàâéèêíìîóòôúùûýỳŷ')
end

filename = ARGV[0] || (raise "You must specify a file whose content you want to alphabetize.\nUsage: alphabetize.rb <your file> <where to save the result>\nIf the result file name is the same as the source, that file will be overwritten.")
new_filename = ARGV[1] || filename.sub(/^(.+)\.(\w+)$/, '\1_sorted.\2')

# separate each entry within that file
dic = Array.new
File.open(filename, 'r:utf-8').each_line do | entry |
  dic << entry
end

# sort alphabetically without giving importance to capitalisation
dic = dic.sort {|x,y| unicode_downcase_and_sortready(x) <=> unicode_downcase_and_sortready(y) }

# write sorted list to file
File.open(new_filename, 'w:utf-8') do |f|
  dic.each do |entry|
    f.puts(entry)
  end
end

puts "Entries sorted alphabetically."
