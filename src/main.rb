require 'csv'
require './src/fare_calculator'
require '.src/log_entry'

=begin
入力の制約
2 <= N <= 5*10^4

出力形式
正常な入力：運賃（円）を標準出力に出力して終了コード0で終了する
異常な入力：標準出力には何も出力せず、終了コード0以外で終了する
=end

LOG_REGEXP = /^(\d{2}):(\d{2}):(\d{2}\.\d{3})\s+(\d{1,2}\.\d)$/

logs = []
total_fare = 0

input_path = ARGV[0]
fare_calculator = FareCalculator.new

begin
  # 逐次処理する
  CSV.foreach(input_path) do |row|
    if row[0] !~ LOG_REGEXP
      puts "ログの形式が不正です： #{row[0]}"
      exit 1
    end
    # ここで計算行う
    # logs << row[0]
    fare_calculator.calculate(LogEntry.new(row))
  end
rescue Errno::ENOENT
  puts "ファイルが存在しません： #{input_path}"
  exit 1
end

# total_fare += FareCalculator.new(logs).calculate

puts fare_calculator.fare
exit 0