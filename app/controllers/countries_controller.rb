class CountriesController < ApplicationController
  def index
  end

  def show
    @country = Country.find(params[:id])

    @yml_key = @country[:iso3].downcase

    country_yml = I18n.t("countries.#{@yml_key}")

    habitats = I18n.t('global.habitats')
    habitat_citations = country_yml[:habitats_present_citations]

    habitats_present_data = [
      { status: 'present', status_title: getStatusText('present')},
      { status: 'absent', status_title: getStatusText('absent')},
      { status: 'unknown', status_title: getStatusText('unknown')},
      { status: 'present', status_title: getStatusText('present')},
      { status: 'present', status_title: getStatusText('present')}
    ]

    @habitats_present = habitats.zip(habitats_present_data, habitat_citations)

    @red_list_categories = I18n.t('home.red_list.categories')
    red_list_data = [[1,2,3,4,5,6,7],[],[1,2,3,4,5,6,7],[1,2,3,4,5,6,7],[]]

    @red_list_data = habitats.zip(red_list_data)

    @target_tabs = I18n.t('countries.shared.targets.tabs')
    @target_text = country_yml[:targets]

    @habitat_change = [
      { id: 'warm-water-coral', title: '2009-2019',  previous: 80, current: 40 },
      { id: 'mangrove', title: '2000-2010', previous: 50, current: 25 }
    ].to_json
  end

  def getStatusText status
    I18n.t("countries.shared.habitats_present.title_#{status}")
  end
end
