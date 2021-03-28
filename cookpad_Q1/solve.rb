require 'pry'

class Mediator
  class << self
    def recieve
      infos = ARGV.map { |arg| arg.split(':') }
      boxes = convert(infos)
      Distributer.recieve(boxes)
    end

    def convert(infos)
      infos.map { |info| Box.new(info[0].to_i, info[1].to_i) }
    end
  end
end

class Distributer
  class << self
    def distribute(sorted_boxes)
      tracks = 3.times.map { |i| Track.new(i) }
      sorted_boxes.each do |box|
        find_lightest(tracks).track_bed << box
      end
      Renderer.render(tracks)
    end

    def recieve(boxes)
      sorted_boxes = boxes.sort { |i, j| i.weight <=> j.weight }.reverse
      distribute(sorted_boxes)
    end

    def find_lightest(tracks)
      tracks.min { |i, j| i.sum_weight <=> j.sum_weight }
    end
  end
end

class Track
  attr_accessor :number, :track_bed

  def initialize(number)
    @number = number
    @track_bed = []
  end

  def sum_weight
    track_bed.map(&:weight).sum
  end
end

class Box
  attr_accessor :id, :weight

  def initialize(id, weight)
    @id = id
    @weight = weight
  end
end

class Renderer
  def self.render(result)
    p result
  end
end

Mediator.recieve
