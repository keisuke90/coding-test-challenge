require 'time'

# このオブジェクトの責務はparser?
# ログのデータを表すオブジェクトである
# class LogParser
class LogEntry
  attr_reader :millisec, :meter, :hour

  # parseまでしてしまう
  def initialize(logline)
    time, dist = logline.split(' ')
    @hour = time.split(':')[0].to_i % 24
    @millisec = (Time.parse(@logline.split(' ')[0]).to_f * 1000).to_i
    @meter = dist.to_f
  end

  # def parse
  #   @hour = @logline.split(' ')[0].split(':')[0].to_i % 24
  #   # 99サポートしていない。mod24と/24で分けて計算するor自前で計算
  #   @millisec = (Time.parse(@logline.split(' ')[0]).to_f * 1000).to_i
  #   @meter = (@logline.split(' ')[1].to_f).to_i
  #   self
  # end
end