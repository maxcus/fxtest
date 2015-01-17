# coding: utf-8

require 'jiji/configurations/mongoid_configuration'
require 'jiji/utils/value_object'
require 'thread'
require 'singleton'
require 'jiji/web/transport/transportable'

module Jiji
module Model
module Trading

  class Pair
  
    include Mongoid::Document
    include Jiji::Utils::ValueObject
    include Jiji::Web::Transport::Transportable
    
    store_in collection: "pairs"
    
    field :pair_id,       type: Integer
    field :name,          type: Symbol
    
    index({ :pair_id => 1 }, { unique: true, name: "pairs_pair_id_index" })
    index({ :name    => 1 }, { unique: true, name: "pairs_name_index" })
    
    def to_h
      {:pair_id =>pair_id, :name=> name}
    end
  end
  
  class Pairs
    
    include Singleton
    include Jiji::Errors
    
    def initialize
      @lock = Mutex.new
      load
    end
    
    def register(name)
      name = name.to_sym
      @lock.synchronize {
        unless @by_name.include?(name)
          pair = register_new_pair(name) 
          @by_name[name]       = pair
          @by_id[pair.pair_id] = pair
        end
        @by_name[name]
      }
    end
   
    def create_or_get(name)
      register(name)
    end
    
    def get_by_id(id)
      @lock.synchronize {
        @by_id[id] || not_found("pair", :id=>id  )
      }
    end
    
    def get_by_name(name)
      @lock.synchronize {
        @by_name[name] || not_found("pair", :name=>name )
      }
    end
    
    def all
      @lock.synchronize {
        @by_id.values.sort_by {|v| v.id}
      }
    end
    
    def reload
      load
    end
    
  private 
    def load
      @by_name = {}
      @by_id   = {}
      Pair.each {|pair|
        @by_name[pair.name]  = pair
        @by_id[pair.pair_id] = pair
      }
    end
    def register_new_pair(name)
      pair = Pair.new {|p|
        p.name    = name
        p.pair_id = new_id
      }
      pair.save
      return pair
    end
    def new_id
      max = @by_name.values.max_by {|p| p.pair_id }
      max ? max.pair_id + 1 : 0
    end
    
  end

end
end
end