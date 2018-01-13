require 'sketchup.rb'

def convert

  model = Sketchup.active_model
  selection = model.selection

  if (! selection.count == 1)
    UI.messagebox("Please select only one group to convert.")
    return
  end

  if (! selection[0].is_a? Sketchup::Group)
    UI.messagebox("Please select a group to convert.")
    return
  end

  model.start_operation('Convert', true)

  group = selection[0]
  scale_transform = Geom::Transformation.scaling(0.0393701,0.0393701,0.0393701)
  group.transformation *= scale_transform

  translate = Geom::Transformation.new(Geom::Point3d.new(0, 0, 0) - group.transformation.origin)
  group.transform! translate
  model.commit_operation

  puts "Conversion complete."

end

if( not file_loaded?(__FILE__) )
  UI.menu("Plugins").add_item("Convert to MM") { convert }
  file_loaded(__FILE__)
end
