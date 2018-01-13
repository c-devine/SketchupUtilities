require 'sketchup.rb'
require 'extensions.rb'

module WGB
  module AirfoilUtils

    unless file_loaded?(__FILE__)
      ex = SketchupExtension.new('Import/Export Airfoils', 'airfoil_tools/main')
      ex.description = 'Import / Export airfoil.dat files'
      ex.version     = 'c-devine'
      Sketchup.register_extension(ex, true)
      file_loaded(__FILE__)
    end

  end # module AirfoilUtils
end # module WGB