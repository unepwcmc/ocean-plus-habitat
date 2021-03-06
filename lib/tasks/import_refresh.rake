namespace :import do
  desc "Delete and recreate records"
  task :refresh => [:environment] do
    models =  %w(
      GeoEntityStat ChangeStat GeoRelationship CoastalStat GeoEntity
      GeoEntitiesSpecies Species GeoEntityStatsSources Source CountryCitation
      GlobalChangeCitation GlobalChangeStat Habitat
    )

    models.each do |m|
      p "Deleting #{m}..."
      m.constantize.send(:delete_all)
    end

    tasks = %w(habitats countries regions prebakedstats new_redlist_data coastalstats 
      global_change sources country_citations habitat_sources_per_country bounding_boxes
    )
    
    tasks.each do |t|
      task_name = "import:#{t}"

      p "Running #{task_name}..."
      Rake::Task[task_name].invoke
    end

    Rake::Task["generate:national_csvs"].invoke
  end
end
