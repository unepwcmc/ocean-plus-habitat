module ApplicationHelper
  def site_title
    'The first authoritative online resource on marine habitats'
  end

  def site_description
    'Ocean+ Habitats is an evolving tool that provides insight into the known extent, protection and other statistics of ecologically and economically important ocean habitats, such as corals, mangroves, seagrasses and saltmarshes.'
  end

  def title_meta_tag
    "Ocean+ Habitats"
  end

  def url_encode text
    ERB::Util.url_encode(text)
  end

  def encoded_home_url
    url_encode(request.base_url)
  end

  def social_image
    image_url('social.png')
  end

  def social_image_alt
    'Guanaco Torres del Paine Chile Gregoire Dubois'
  end

  COUNTRIES = %w(indonesia united_arab_emirates).freeze
  REGIONS = %w(mediterranean wider_caribbean).freeze
  def get_nav_items
    #FERDI - get all countries and then fill out object as follows
    {
      countries: COUNTRIES.map { |c| nav_item(c) },
      regions: REGIONS.map { |r| nav_item(r) }
    }
  end

  def nav_item(item)
    geo_entity_name = item.humanize.split(' ').map(&:capitalize).join(' ')
    geo_entity_id = GeoEntity.find_by_name(geo_entity_name)&.id
    return {} unless geo_entity_id
    {
      title: I18n.t("countries.#{item}.title"),
      url: country_path(geo_entity_name)
    }
  end

  def get_habitat_icon_class(habitat, status='')
    status = status == 'present' || status == '' ? '' : "-#{status}"

    "icon--#{habitat}#{status}"
  end

  def country_path (country)
    '/' + country.gsub(/ /, '-').gsub("'", '%27').downcase
  end

  def country_name_from_param (param_name)
    param_name.gsub('-', ' ').gsub('%27', "'").titleize
  end

  def footer_citation
    if params[:name] 
      return t(
        'shared.footer_citation.region', 
        region: country_name_from_param(params[:name]),
        year: Date.today.year,
        month: Date.today.strftime('%B')
      ).html_safe
    end
    
    t('shared.footer_citation.global').html_safe
  end

  def nav_tertiary
    I18n.t('home.nav_sticky').to_json
  end

  def red_list_categories
    I18n.t('home.red_list.categories')
  end

  def habitat_cover_modal
    { title: 'Title hardcoded in controller', text: I18n.t('home.habitat_cover.citation') }.to_json
  end

  def red_list_modal
    { title: 'Title hardcoded in controller', text: I18n.t('home.red_list.citation') }.to_json
  end

  def habitat_change_modal
    {
      title: 'Title hardcoded in controller',
      text: I18n.t('home.habitat_change.citation')
    }.to_json
  end
end
