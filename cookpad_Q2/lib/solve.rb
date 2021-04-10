require 'pry'
require 'net/http'
require 'json'

class CLI
  class << self
    def listen
      monsters = ARGV.map { |name| Monster.new(name, 0) }
      BattleField.play(monsters)
    end
  end
end

class BattleField
  attr_accessor :monsters

  def initialize(monsters)
    @monsters = monsters
  end

  class << self
    def play(monsters)
      field = new(monsters)
      (monsters.count - 1).times do
        field.monsters.each do |monster|
          break if rival(monster, field).nil?

          result = get_battle_result_as_api(monster.name, rival(monster, field).name)
          monster.win?(result) ? give_point(monster, field) : take_point(monster, field)
        end
        field.monsters = field.monsters.sort_by(&:point).reverse
      end
      field.monsters.map(&:name)
    end

    private

    def get_battle_result_as_api(monster, other_monster)
      uri = URI.parse("https://ob6la3c120.execute-api.ap-northeast-1.amazonaws.com/Prod/battle/#{monster}+#{other_monster}")
      response_body = Net::HTTP.get_response(uri).body
      JSON.parse(response_body)
    end

    def rival(monster, field)
      index = field.monsters.index(monster) + 1
      field.monsters[index]
    end

    def give_point(monster, field)
      monster.level_up
      rival(monster, field).level_down
    end

    def take_point(monster, field)
      monster.level_down
      rival(monster, field).level_up
    end
  end
end

class Monster
  attr_accessor :name, :point

  def initialize(name, point)
    @name = name
    @point = point
  end

  def level_up
    self.point += 1
  end

  def level_down
    self.point -= 1
  end

  def <=>(other)
    point <=> other.point
  end

  def win?(result)
    result['winner'] == name
  end
end

# CLI.listen
