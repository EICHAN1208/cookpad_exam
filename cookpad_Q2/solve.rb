require 'pry'
require 'net/http'
require 'json'

class CLI
  class << self
    def listen
      monsters = ARGV.map.with_index { |name, rank| Monster.new(name, rank) }
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
          monster.win?(result) ? revel_up(monster, field) : revel_down(monster, field)
        end
        field.monsters = field.monsters.sort_by(&:rank)
      end
      puts field.monsters.map(&:name)
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

    def revel_up(monster, field)
      monster.be_strong
      rival(monster, field).be_weak
    end

    def revel_down(monster, field)
      monster.be_weak
      rival(monster, field).be_strong
    end
  end
end

class Monster
  attr_accessor :name, :rank

  def initialize(name, rank)
    @name = name
    @rank = rank
  end

  def be_strong
    self.rank -= 1
  end

  def be_weak
    self.rank += 1
  end

  def <=>(other)
    rank <=> other.rank
  end

  def win?(result)
    result['winner'] == name
  end
end

CLI.listen
