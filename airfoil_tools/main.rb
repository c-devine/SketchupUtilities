require 'sketchup.rb'

module WGB
  module AirfoilUtils

    def self.import_dat

      model = Sketchup.active_model
      model.start_operation('Import Dat', true)

      chosen_file = UI.openpanel("Open .dat File", "C:/", "DAT|*.dat||")

      firstLine = true;
      vertices = []

      IO.foreach(chosen_file){ |line|
        if firstLine
          firstLine = false;
          next
        end

        if line.empty?
          next
        end

        coords = line.split
        vertices.push [coords[0].to_f * 10.to_f, coords[1].to_f * 10.to_f, 0.to_f]
      }

      model.active_entities.add_face vertices
      model.commit_operation

    end

    def self.export_dat

      model = Sketchup.active_model
      model.start_operation('Export Dat', true)
      selection = model.selection
      face_count = 0
      vert_count = 0
      vertices = []

      # Look at all of the entities in the selection.
      selection.each { |entity|
        if entity.is_a? Sketchup::Face
          face_count = face_count + 1
          vertices = entity.outer_loop.vertices
          vert_count = entity.vertices.length
        end
      }

      if  face_count != 1
        UI.messagebox("There are must be only 1 face selected.")
        return
      end

      # find the min vertice
      minVert = vertices[0]

      vertices.each { |v|
        if v.position.x < minVert.position.x
          minVert = v
        end
      }

      # add offset
      offsetVertices = []
      vertices.each { |v|
        offsetVertices.push [v.position.x - minVert.position.x, v.position.y - minVert.position.y]
      }

     chosen_file = UI.savepanel("Save .dat File", "C:/", "DAT|*.dat||")
     if chosen_file.empty?
       return
     end

     if !chosen_file.end_with? '.dat'
       chosen_file = chosen_file + ".dat"
     end


     File.open(chosen_file, 'w') { |file|

     file.puts "Airfoil exported from Sketchup " + Time.now.strftime("%d/%m/%Y %H:%M").to_s
     file.puts "     "

      maxX = 0
      maxIndex = 0
      loop = 0

      # vertices are clockwise -  find max x
      offsetVertices.each { |v|
       if v[0] > maxX
        maxIndex = loop
        maxX = v[0]
       end
        loop += 1
      }

      for i in 0...maxIndex
        x = offsetVertices[maxIndex - i][0] / maxX
        y = offsetVertices[maxIndex - i][1] / maxX
        file.puts x.to_s + "    " + y.to_s
      end

      for i in 1... (offsetVertices.length - (maxIndex-1) )
        x = offsetVertices[offsetVertices.length - i][0] / maxX
        y = offsetVertices[vertices.length - i][1] / maxX
        file.puts x.to_s + "    " + y.to_s
      end

      }

      model.commit_operation
      puts "File exported to: " + chosen_file
      UI.messagebox("File exported to : " + chosen_file)
    end

    unless file_loaded?(__FILE__)
      menu = UI.menu('Plugins')
      menu.add_item('Export .dat file.') {
        self.export_dat
      }
      menu.add_item('Import .dat file.') {
        self.import_dat
      }
      file_loaded(__FILE__)
    end

  end # module AirfoilUtils
end # module WGB