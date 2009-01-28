#!/usr/bin/env ruby
#
# == Synopsis
#
# create_fdoc.rb:: Create latex and html documentation from instrumented
#                  Fortran95 source files.
#
# == Usage
#
# create_fdoc.rb --help --xml FILE1 [FILE2|...|FILEN]
#
# --help (-h):
#    you're looking at it
#
# --xml (-x)
#    Set this option to use XML-style documentation delimiters,
#      <tag>  and  </tag>
#    The default FDoc documentation delimiters are,
#      :tag+:  and  :tag-: 
#
#
# Written by:: Paul van Delst, 15-Jan-2009 (paul.vandelst@noaa.gov)
#


require 'getoptlong'
require 'rdoc/usage'
require 'fdoc'

# Define the script name for messages
script_name=File.basename($0)

# Specify accepted options
options=GetoptLong.new([ "--help", "-h", GetoptLong::NO_ARGUMENT], 
                       [ "--xml" , "-x", GetoptLong::NO_ARGUMENT])

# Specify default options
delimiter_type = FDoc::Source::DEFAULT_DELIMITER_TYPE

# Parse the command line options
begin
  options.each do |opt, arg|
    case opt
      when "--xml"
        delimiter_type = "xml"
      when "--help"
        RDoc::usage
        exit(0)
    end
  end
rescue StandardError=>error_message
  puts("ERROR: #{error_message}")
  puts("Try \"#{script_name} --help\"\n ")
  exit(1)
end

# Check the arguments
if ARGV.length == 0
  puts("\n  #{script_name}: No Fortran source files specified, nothing to do. Exiting...\n\n")
  exit(0)
end

# Process the source files
ARGV.each do |source_file|
  source = FDoc::Source.load(source_file,delimiter_type)
  FDoc::Generator.new.generate(source)
end

