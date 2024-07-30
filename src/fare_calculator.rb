require 'time'
require './src/log_parser'


class FareCalculator
  INITIAL_FARE_DIST = 1052 # 初乗り運賃の距離。1052m。
  INITIAL_FARE = 410 # 初乗運賃。
  ADDITIONAL_FARE_DIST = 237 # 追加運賃の基準距離。237mごとに加算。
  ADDITIONAL_FARE = 80 # 追加運賃。
  LOW_SPEED = 10000 # 低速運賃の基準。10km/h = 10000m/h。
  LOW_SPEED_BILLING_INTERVAL = 90000 # 90000ms = 1分30秒。
  LOW_SPEED_FARE = 80 # 時速10km以下の走行時間について、1分30秒ごとに加算。
  NIGHT_TIME_RANGE = [
    (0..4),
    (22..28),
    (46..52),
    (70..76),
    (94..99)
  ]
  NIGHT_RATE = 1.25 # 深夜割増料金。深夜時間帯における走行距離を実際の距離の1.25倍として計算。

  def initialize
    # @logs = logs
    # @data_size = logs.size
    # @total_fare = INITIAL_FARE
    @distance = 0
    @last_entry = nil
  end

  #　メソッドの命名（calc_fareと似ている）
  def calculate(log_entry)
    if @last_entry
      add_distance(@last_entry, log_entry)
      add_low_speed_fare(@last_entry, log_entry)
    end

    @last_entry = log_entry
    # (0..@data_size - 2).each do |idx|
    #   from = LogParser.new(@logs[idx]).parse
    #   to = LogParser.new(@logs[idx + 1]).parse
    #   add_distance(from, to)
    #   add_low_speed_fare(from, to)
    # end

    # calc_fare
    # @total_fare
  end

  def fare
    calc_fare
  end

  private

  def low_speed?(from, to)
    time = (to.millisec - from.millisec).to_f / 1000 / 60 / 60 # hour
    speed_per_hour = to.meter / time
    speed_per_hour < LOW_SPEED
  end

  def add_low_speed_fare(from, to)
    return unless low_speed?(from, to)
    time = to.millisec - from.millisec
    @total_fare += time / LOW_SPEED_BILLING_INTERVAL * LOW_SPEED_FARE
  end

  def night_time?(from, to)
    NIGHT_TIME_RANGE.any? { |range| range.include?(from.hour) && range.include?(to.hour) }
  end

  def add_distance(from, to)
    tmp_distance = to.meter
    if night_time?(from, to)
      tmp_distance *= NIGHT_RATE
    end
    @distance += tmp_distance
  end

  # マイナス考慮できてない
  # 区間運賃計算が正しくない
  def calc_fare
    @distance -= INITIAL_FARE_DIST
    total_fare = @distance / ADDITIONAL_FARE_DIST * ADDITIONAL_FARE
    return total_fare
  end
end