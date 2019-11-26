class GeoEntity < ApplicationRecord
  has_many :geo_entities_species, class_name: 'GeoEntitiesSpecies'
  has_many :species, through: :geo_entities_species
  has_one :geo_entity_stat
  # At the moment, only mangroves have got change stats,
  # which means there can only be one change_stat record per country.
  # This can change in the future
  has_one :change_stat

  has_many :region_relationship, foreign_key: :country_id, class_name: 'GeoRelationship'
  has_many :regions, through: :region_relationship, class_name: 'GeoEntity'
  has_many :country_relationship, foreign_key: :region_id, class_name: 'GeoRelationship'
  has_many :countries, through: :country_relationship, class_name: 'GeoEntity'

  scope :countries, -> { where.not(iso3: nil) }
  scope :regions, -> { where(iso3: nil) }

  # Returns species data if directly attached to the GeoEntity,so a country
  # Returns species data for all associated countries if it is a region
  def all_species
    return species if species.present?
    Species.joins(:geo_entities).where(geo_entities: { id: countries.map(&:id) })
  end

  # most common is to be determined in a meeting
  # most threatened is to be ordered as follows;
  #
  # Critically Endangered, Endangered, Vulnerable
  # CR is the most endangered, then comes EN, third VU
  # and if there are not 3 species of these categories, NT (near threatened)
  # could also be considered.

  # Example output:
  # => ["Tabebuia palustris", nil, "VU", "Pelliciera rhizophoreae", nil, "VU", "Avicennia bicolor", nil, "VU"]

  def get_species_images(habitat, type)
    return nil if habitat.nil?
    return [] if type == :most_common
    if type == :most_threatened
      hs = species_by_habitat_and_status(habitat.id)
      return species_image_path(habitat, hs) if hs.count > 2

      hs_nt = species_by_habitat_and_status(habitat.id, ['NT'])
      hs.concat hs_nt if hs_nt.present?

      species_image_path(habitat, hs)
    end
  end

  def species_image_path(habitat, species_hash)
    species_images = []
    species_hash.each do |sh|
      if (Species.get_species_without_image_data.include? sh[:scientific_name])
        species_images << "/species/species.png"
      else
        species_images << "/species/#{habitat.name}/#{sh[:scientific_name].parameterize.underscore}_atlas_of_#{habitat.name}.jpg"
      end
    end
    species_images
  end

  def species_by_habitat_and_status(habitat_id, statuses=Species::THREATENED)
    all_species.where(habitat_id: habitat_id, redlist_status: statuses).map do |_species|
      _species.slice(:scientific_name, :common_name, :redlist_status)
    end
  end
end
