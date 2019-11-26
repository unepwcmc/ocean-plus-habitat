require 'csv'

namespace :import do
  desc "import RedList species data into database"
  task :regions => [:environment] do
    current_regions_count = GeoEntity.regions.count
    current_relationships_count = GeoRelationship.count
    CSV.foreach('lib/data/regionalseas.csv', headers: true) do |row|
      name, iso2, iso3 = [row['name'], nil, nil]
      region = GeoEntity.where(name: name, iso2: iso2, iso3: iso3).first_or_create
      countries_iso_codes = row['iso3'].split('/')
      countries_iso_codes.each do |country_iso|
        country_id = GeoEntity.find_by(iso3: country_iso)
        unless country_id
          Rails.logger.info("Country with iso3 #{country_iso} not found...")
          next
        end
        GeoRelationship.where(country_id: country_id, region_id: region.id).first_or_create
      end
    end
    new_regions_count = GeoEntity.regions.count
    new_relationships_count = GeoRelationship.count
    Rails.logger.info("#{new_regions_count - current_regions_count} regions were created successfully!")
    Rails.logger.info("#{new_relationships_count - current_relationships_count} relationships were created successfully!")
  end
end