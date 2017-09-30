module SmartTrack::Database::Repository
  class TblRealtime
    attr_reader :serial_sim, :lattitude, :longitude, :server_datetime
    
    def initialize(attributes)
      @serial_sim = attributes[:serial_sim]
      @server_datetime = attributes[:server_datetime]
      @lattitude = attributes[:lattitude]
      @longitude = attributes[:longitude]
    end

    def datetime_format datetime
      datetime.strftime('%F %T')
    end

    def server_datetime
      datetime_format(@server_datetime) if @server_datetime
    end
  end

  class TblrealtimeRepo < ROM::Repository[:tblrealtimes]
    def all
      tblrealtimes.index
    end

    def by_serial_sim ss
      tblrealtimes.map_to(TblRealtime)
      .index
      .where(serial_sim: ss)
    end
  end
end