class YearAnnualReportsByCountry < ActiveRecord::Base
  attr_accessible :no,
                  :name_en,
                  :year,
                  :reporter_type
end