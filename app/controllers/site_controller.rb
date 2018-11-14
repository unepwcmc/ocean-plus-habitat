class SiteController < ApplicationController
  before_action :load_habitat
  before_action :load_global
  before_action :load_charts_data

  def warmwater
    @commitments = [
      @aichi_targets,
      @sdgs,
      @sdgs = YAML.load(File.open("#{Rails.root}/lib/data/content/meas-warmwater.yml", 'r'))
    ]
  end

  def saltmarshes
    @commitments = [
      @aichi_targets,
      @sdgs,
      @sdgs = YAML.load(File.open("#{Rails.root}/lib/data/content/meas-saltmarshes.yml", 'r'))
    ]
  end

  def mangroves
    @commitments = [
      @aichi_targets,
      @sdgs,
      @sdgs = YAML.load(File.open("#{Rails.root}/lib/data/content/meas-mangroves.yml", 'r'))
    ]
  end

  def seagrasses
    @commitments = [
      @aichi_targets,
      @sdgs,
      @sdgs = YAML.load(File.open("#{Rails.root}/lib/data/content/meas-seagrasses.yml", 'r'))
    ]
  end

  def coldcorals
    @commitments = [
      @aichi_targets,
      @sdgs,
      @sdgs = YAML.load(File.open("#{Rails.root}/lib/data/content/meas-coldwater.yml", 'r'))
    ]
  end

  private

  def load_habitat
    @habitat = Habitat.where(name: action_name).first
    @habitat ||= Habitat.where(name: 'coralreef').first
  end

  def load_global
    @global = YAML.load(File.open("#{Rails.root}/lib/data/content/global.yml", 'r'))
    @aichi_targets = YAML.load(File.open("#{Rails.root}/lib/data/content/aichi-targets.yml", 'r'))
    @sdgs = YAML.load(File.open("#{Rails.root}/lib/data/content/sdgs.yml", 'r'))
  end

  def calculate_percentage(arbitrary_value, country_total_area)
    byebug
    percentage_total_area = country_total_area.each_with_object({}) { |(key, value), hash| hash[key] = 100*(value/total_area) }
    percentage_total_area
  end

  def sum_country_areas(total_area_by_country)
    country_total_area = {}
    total_area_by_country.flatten.each do |country_data|
      next if country_data["iso3"].include? "/" #remove areas which have multiple iso
      next if country_data["iso3"].include? "ABNJ" #remove ABNJ
      country_total_area[country_data["iso3"]] = country_total_area[country_data["iso3"]].nil? ?  country_data["sum"] : country_total_area[country_data["iso3"]] + country_data["sum"]
    end
    country_total_area
  end

  def sort_country_count(total_value_by_country)
    country_total_points = {}
    total_value_by_country.each do |total_value|
      next if total_value["iso3"].include? "ABNJ"
      country_total_points[total_value["iso3"]] = total_value["count"]
    end
    country_total_points
  end


  def load_charts_data
    c = Carto.new(@habitat.name)
    total_value_by_country = 0
    top_five_countries = []
    arbitrary_value = 0

    if @habitat.name == "coldcorals"
      byebug
      total_value_by_country = c.total_points_by_country
      total_value_by_country = sort_country_count(total_value_by_country)
    else
      total_value_by_country = c.total_area_by_country
      total_value_by_country = sum_country_areas(total_value_by_country)
    end

    top_five_countries = total_value_by_country.sort_by {|_key, value| value}.last(5)
    arbitrary_value = top_five_countries.last.last.to_f * 1.05

    @chart_greatest_coverage = top_five_countries.reverse.map do |country|
      label = Country.find_by(iso3: country.first).name
      {
        label: label,
        value: country.last.round(0),
        percent: 100*country.last/arbitrary_value
      }
    end

    @chart_protected_areas = [
      {
        label: 'Australia',
        percent: '94',
      },
      {
        label: 'United Kingdom',
        percent: '63',
      },
      {
        label: 'Spain',
        percent: '75',
      },
      {
        label: 'Italy',
        percent: '50',
      },
      {
        label: 'Russia',
        percent: '10',
      }
    ]
  end
end
