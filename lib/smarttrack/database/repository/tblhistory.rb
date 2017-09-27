module SmartTrack::Database::Repository
  class TblhistoryRepo < ROM::Repository[:tblhistories]  
    def all
      tblhistories.index
    end
  end
end