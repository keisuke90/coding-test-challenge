require 'csv'
require './src/fare_calculator'

=begin
入力の制約
2 <= N <= 5*10^5

出力形式
正常な入力：運賃（円）を標準出力に出力して終了コード0で終了する
異常な入力：標準出力には何も出力せず、終了コード0以外で終了する
=end

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

  total_fare += FareCalculator.new(logs).calculate

  puts total_fare
end