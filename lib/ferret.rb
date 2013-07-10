module Ferret
  
  class << self
    
    def root
      File.expand_path("../../", __FILE__)
    end
    
  end
end

Dir.glob(File.expand_path("../**/*.rb", __FILE__)).each do |file|
  require file
end

