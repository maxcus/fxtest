# coding: utf-8

require 'thread'
require 'securerandom'
require 'jiji/model/trading/processes/abstract_process'

module Jiji
module Model
module Trading
module Processes
  
  class BackTestProcess < AbstractProcess
    def initialize(job, pool, logger)
      super job, pool, logger
    end
    
  end

end
end
end
end