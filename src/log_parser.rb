require 'time'

class LogParser
  attr_reader :millisec, :meter, :hour

  def initialize(logline)
    @logline = logline
    @hour = 0
    @millisec = 0
    @meter = 0
  end

  def parse
    @hour = @logline.split(' ')[0].split(':')[0].to_i
    @millisec = (Time.parse(@logline.split(' ')[0]).to_f * 1000).to_i
    @meter = (@logline.split(' ')[1].to_f * 1000).to_i
    self
  end
end