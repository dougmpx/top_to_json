require 'json'

class TopToJSON
  CMD = 'top'

  def initialize(cmd=CMD, &block)
    @top_cmd = cmd
    @json_top = {}
  end

  def parse output=nil, &block
    output ||= `#{@top_cmd} -bn1`
    @json_top = {}

    output.each_line do |line|
      line = line.strip

      case line
        when /^top/       then parse_load(line);
        when /^\d/        then parse_process(line);
        when /^ta/i       then parse_tasks(line);
        when /^%cpu/i     then parse_cpu(line);
        when /^kib mem/i  then parse_memory(line);
        when /^kib swap/i then parse_swap(line);
      end
    end

    yield(@json_top) if block_given?
    @json_top
  end

  def to_json
    @json_top.to_json
  end

  private

  def parse_load line
    columns = line.split
    @json_top[:uptime] = "#{columns[4]} #{columns[5]}".chomp(',')
  end

  def parse_process line
    columns = line.split

    @json_top[:processes] ||= []
    @json_top[:processes] << {
      pid: columns[0],
      user: columns[1],
      cpu: columns[8],
      mem: columns[9],
      time: columns[10],
      name: columns[11]
    }
  end

  def parse_tasks line
    columns = line.split(':')[1].split
    @json_top[:tasks] = {
      total: columns[0],
      running: columns[2],
      sleeping: columns[4],
      stopped: columns[6],
      zombie: columns[8]
    }
  end

  def parse_cpu line
    columns = line.split(':')[1].split
    @json_top[:cpu] = {
      us: columns[0].gsub(',','.'),
      sy: columns[2].gsub(',','.'),
      ni: columns[4].gsub(',','.'),
      id: columns[6].gsub(',','.'),
      wa: columns[8].gsub(',','.'),
      hi: columns[10].gsub(',','.'),
      si: columns[12].gsub(',','.'),
      st: columns[14].gsub(',','.')
    }
  end

  def parse_memory line
    columns = line.split(':')[1].split
    @json_top[:memory] = {
      total: columns[0].gsub(',','.'),
      free: columns[2].gsub(',','.'),
      used: columns[4].gsub(',','.'),
      buff: columns[6].gsub(',','.')
    }
  end

  def parse_swap line
    columns = line.split(':')[1].split
    @json_top[:swap] = {
      total: columns[0].gsub(',','.'),
      free: columns[2].gsub(',','.'),
      used: columns[4].gsub(',','.'),
      available: columns[6].gsub(',','.')
    }
  end

end
