require 'csv'

namespace :import do
  desc "import CSV data into database"
  task :regionalstats, [:csv_file] => [:environment] do

    habitats = Habitat.all

    habitats.each do |habitat|
      puts habitat.name
      csv_file = "#{habitat.name}.csv"

      import_regional_csv_file(habitat.name, csv_file)
    end
  end

  def import_regional_csv_file(habitat, csv_file)
    filename = "#{Rails.root}/lib/data/#{csv_file}"
    csv = File.open(filename, encoding: "utf-8")
    csv_headers = File.readlines(csv).first.split(",")

    puts habitat
    puts csv_headers
    puts csv_headers.length

    CSV.parse(csv, headers: true, encoding: "utf-8") do |row|
      csv_regionalstats_row = row.to_hash

      if csv_headers.grep(/baseline/).any?
        parse_change csv_headers, csv_regionalstats_row
      else
        parse_standard csv_headers, csv_regionalstats_row
      end
    end
  end

  def parse_change csv_headers, csv_row
    puts "parse change"
 
    regionalstats_change_hash = {
      iso3: csv_headers[0],
      total_value_1996: csv_headers[1],
      total_value_2007: csv_headers[2],
      total_value_2008: csv_headers[3],
      total_value_2009: csv_headers[4],
      total_value_2010_baseline: csv_headers[5],
      total_value_2015: csv_headers[6],
      total_value_2016: csv_headers[7],
      protected_value: csv_headers[8],
      protected_percentage: csv_headers[9].chomp
    }.freeze

    regionalstats_change_hash.keys.each do |key|
      if key == :iso3
        iso3 = csv_row[strip_key(regionalstats_change_hash[key])]&.strip
        puts "iso3: #{iso3}"
      elsif key == :total_value # TODO: need to extract year and populate appropriately
        total_value = csv_row[strip_key(regionalstats_change_hash[key])]&.strip
        puts "total_value: #{total_value}"
      elsif key == :protected_value
        protected_value = csv_row[strip_key(regionalstats_change_hash[key])]&.strip
        puts "protected_value: #{protected_value}"
      elsif key == :protected_percentage
        protected_percentage = csv_row[strip_key(regionalstats_change_hash[key])]&.strip
        puts "protected_percentage: #{protected_percentage}"
      end
    end
  end

  def parse_standard csv_headers, csv_row
    puts "parse standard"

    regionalstats_standard_hash = {
      iso3: csv_headers[0],
      total_value: csv_headers[1],
      total_value_protected: csv_headers[2],
      protected_percentage: csv_headers[3].chomp
    }.freeze

    regionalstats_standard_hash.keys.each do |key|
      if key == :iso3
        iso3 = csv_row[strip_key(regionalstats_standard_hash[key])]&.strip
        puts "iso3: #{iso3}"
      elsif key == :total_value
        total_value = csv_row[strip_key(regionalstats_standard_hash[key])]&.strip
        puts "total_value: #{total_value}"
      elsif key == :total_value_protected
        total_value_protected = csv_row[strip_key(regionalstats_standard_hash[key])]&.strip
        puts "total_value_protected: #{total_value_protected}"
      elsif key == :protected_percentage
        protected_percentage = csv_row[strip_key(regionalstats_standard_hash[key])]&.strip
        puts "protected_percentage: #{protected_percentage}"
      end
    end
  end

  def insert_regional_stat

  end

  def strip_key key
    key.tr('"\"', '')
  end
end