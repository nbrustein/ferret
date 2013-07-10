module Ferret
  
  class << self
    
    def root
      File.expand_path("../../", __FILE__)
    end
    
    def clear_databases
      adapter.clear_databases
    end
    
    def configuration(load_default = true)
      if defined? @configuration
        @configuration
      elsif load_default
        @configuration = Ferret::Configuration.load_default
      else
        nil
      end
    end

    def adapter
      configuration.adapter
    end
    
    def set_configuration(config)
      if config.is_a?(String)
        config = Ferret::Configuration.load(config)
      end
      @configuration = config
    end
    
  end
end

Dir.glob(File.expand_path("../**/*.rb", __FILE__)).each do |file|
  require file
end

