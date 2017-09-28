module SmartTrack::Database::Repository
  class TblHistory
    attr_reader :vid, :latitude, :longitude, :gps_datetime
    
    def initialize(attributes)
      @vid = attributes[:vid]
      @gps_datetime = attributes[:gps_datetime]
      @latitude = attributes[:latitude]
      @longitude = attributes[:longitude]
    end

    def datetime_format datetime
      datetime.strftime('%F %T')
    end

    def gps_datetime
      datetime_format(@gps_datetime) if @gps_datetime
    end

    def to_json(options={})
      hash = {
        vid: vid,
        gps_datetime: datetime_format(gps_datetime),
        latitude: latitude,
        longitude: longitude
      }

      hash.to_json
    end
  end

  class TblhistoryRepo < ROM::Repository[:tblhistories]  
    def all
      tblhistories.index
    end

    def by_vid vid
      tblhistories.map_to(TblHistory)
      .index
      .by_vid(vid)
      .latest_one
    end
  end
end