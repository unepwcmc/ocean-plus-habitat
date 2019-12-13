class SiteController < ApplicationController
  def index
    @global = YAML.load(File.open("#{Rails.root}/lib/data/content/global.yml", 'r'))

    @habitats = habitats

    red_list_data = Species.count_species

    @red_list_data = @habitats.each { |habitat| habitat['data'] = red_list_data[habitat[:id]] }

    @habitat_cover = Serializers::HabitatCoverSerializer.new.serialize

    doughnut_chart = I18n.t('home.sdg.doughnut_chart_data')
    @doughnut_chart = []

    doughnut_chart.each do |item|
      @doughnut_chart.push({
        'title': item[:title],
        'colour': item[:colour],
        'icon': ActionController::Base.helpers.image_url(item[:icon]),
        'description': item[:description],
        'url': item[:url],
        'source': item[:source]
      })
    end
  end
end
