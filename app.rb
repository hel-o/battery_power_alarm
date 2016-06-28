class PowerAlarm

  MP3_BATTERY_CHARGED = 'charged_battery.mp3'
  MP3_LOW_BATTERY = 'low_battery.mp3'
  BATTERY_CHARGING = 'Charging'
  BATTERY_DISCHARGING = 'Discharging'

  attr_reader :pid_mp3_player

  def start
    puts '*' * 30
    print ' ' * 5
    puts 'BATTERY MONITOR'
    puts '*' * 30

    while true
      start_watcher
      sleep 3
    end

  end

  private

  def start_watcher
    power_capacity = get_data('capacity').to_i

    if power_capacity > 92
      alert_battery_charged
    elsif power_capacity < 22
      alert_low_battery
    end

  end

  def alert_low_battery
    play_mp3(MP3_LOW_BATTERY)
    check_status(BATTERY_CHARGING)
  end

  def alert_battery_charged
    play_mp3(MP3_BATTERY_CHARGED)
    check_status(BATTERY_DISCHARGING)
  end

  def play_mp3(mp3_name)
    output = IO.popen("cvlc --loop #{mp3_name}")
    @pid_mp3_player = output.pid
  end

  def check_status(battery_status)

    while true
      status = get_data('status')
      # puts "CURRENT STATUS: #{status}|#{battery_status} --> #{status == battery_status}|pid: #{@pid_mp3_player}"
      if status == battery_status
        Process.kill("KILL", @pid_mp3_player)
        break
      end

      sleep 1

    end

  end

  def get_data(filename)
    data = ''
    File.open("/sys/class/power_supply/BAT1/#{filename}", 'r') do |file|
      data = file.readline.chomp
    end
    data
  end

end


power_alarm = PowerAlarm.new
power_alarm.start
