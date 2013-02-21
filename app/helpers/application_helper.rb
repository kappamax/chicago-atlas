module ApplicationHelper

  def current_menu
    @current_menu
  end
  
  def current_menu_class(menu_name)
    return "active" if current_menu == menu_name
  end

  def get_datasets(geography_id, category_id)
    Dataset.joins(:statistics)
      .select("datasets.id, datasets.name, statistics.name as stat_name")
      .where("statistics.geography_id = #{geography_id} AND datasets.category_id = #{category_id}")
      .group("datasets.id, datasets.name, statistics.name")
      .order("datasets.name, statistics.name")
  end

  # def fetch_chart_average_data(dataset_id, stat_name, start_year, end_year)
  #   sum_query = ""
  #   (start_year..end_year).each do |year|
  #     sum_query = ""
  #   stats = Statistic.select().where("dataset_id = #{dataset_id} AND name = '#{stat_name}'")
  #                    .order("year")

  #   stats_array = []
  #   stats.each do |s|
  #     stats_array << s[:value]
  #   end

  #   {:data => stats_array.join(','), :start_year => stats.first.year.to_s, :end_year => stats.last.year.to_s}
  # end

  def fetch_chart_data(dataset_id, geography_id, stat_name)
    stats = Statistic.where("dataset_id = #{dataset_id} AND name = '#{stat_name}' AND geography_id = #{geography_id}")
                     .order("year")

    stats_array = []
    stats.each do |s|
      stats_array << s[:value]
    end

    error_bars = []
    stats.each do |s|
      unless (s[:lower_ci].nil? or s[:upper_ci].nil?)
        error_bars << [s[:lower_ci],s[:upper_ci]]
      end
    end

    {:data => stats_array, :error_bars => error_bars, :start_year => stats.first.year.to_s, :end_year => stats.last.year.to_s}
  end

  def to_dom_id(s)
    #strip the string
    ret = s.strip.downcase

    #blow away apostrophes
    ret.gsub! /['`.]/,""

    # @ --> at, and & --> and
    ret.gsub! /\s*@\s*/, " at "
    ret.gsub! /\s*&\s*/, " and "

    #replace all non alphanumeric, underscore or periods with underscore
     ret.gsub! /\s*[^A-Za-z0-9\.\-]\s*/, '_'  

     #convert double underscores to single
     ret.gsub! /_+/,"_"

     #strip off leading/trailing underscore
     ret.gsub! /\A[_\.]+|[_\.]+\z/,""

     ret
  end

  def atlas_view_modes
    return {"Births" => 
                { "views" => ["Birth Rate",
                              "General Fertility Rate",
                              "Low Birth Weight",
                              "Prenatal Care Beginning in First Trimester",
                              "Preterm Births",
                              "Teen Birth Rate"],
                  "colors" =>  ["#BDD7E7", "#6BAED6", "#3182BD", "#08519C"]
                },
            "Deaths" => 
                { "views" => ["Assault (Homicide)",
                              "Breast cancer in females",
                              "Cancer (All Sites)",
                              "Colorectal Cancer",
                              "Diabetes-related",
                              "Firearm-related",
                              "Infant Mortality Rate",
                              "Lung Cancer",
                              "Prostate Cancer in Males",
                              "Stroke (Cerebrovascular Disease)"],
                  "colors" =>  ["#FCAE91", "#FB6A4A", "#DE2D26", "#A50F15"]
                },
            "Lead" => 
                { "views" => ["Childhood Blood Lead Level Screening",
                              "Childhood Lead Poisoning"],
                  "colors" =>  ["#CCCCCC", "#969696", "#636363", "#252525"]
                },
            "Infectious disease" => 
                { "views" => ["Gonorrhea in Females",
                              "Gonorrhea in Males",
                              "Tuberculosis"],
                  "colors" =>  ["#FDBE85", "#FD8D3C", "#E6550D", "#A63603"]
                },
            "Demographics" => 
                { "views" => ["Below Poverty Level",
                              "Crowded Housing",
                              "Dependency",
                              "No High School Diploma",
                              "Per Capita Income",
                              "Unemployment"],
                  "colors" =>  ["#CBC9E2", "#9E9AC8", "#756BB1", "#54278F"]
                }
            }
  end

end
