require 'csv'
require './src/log_parser'

=begin
入力の制約
2 <= N <= 5 * 10*5

出力形式
正常な入力：運賃（円）を標準出力に出力して終了コード0で終了する
異常な入力：標準出力には何も出力せず、終了コード0以外で終了する
=end

INITIAL_FARE = 410 # 1.052kmまでの初乗運賃
ADDITIONAL_FARE = 80 # 以降237mごとに加算
LOW_SPEED_FARE = 50 # 時速10km以下の走行時間について、1分30秒ごとに加算
NIGHT_RATE = 1.25 # 深夜割増料金。深夜時間帯における走行距離を実際の距離の1.25倍として計算

logs = []
total_fare = 0

# 入力を受け取る
if __FILE__ == $0
  input_path = ARGV[0]

  begin
    CSV.foreach(input_path) do |row|
      logs << row[0]
    end
  rescue Errno::ENOENT
    puts "ファイルが存在しません： #{input_path}"
  end

  data_size = logs.size
  (0..data_size - 2).each do |idx|
    from = LogParser.new(logs[idx]).parse
    to = LogParser.new(logs[idx + 1]).parse
    total_fare += Calculator.new(from, to).calculate
  end

  puts total_fare
end