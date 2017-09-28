module SmartTrack::Database::Repository
  class TblcarsetRepo < ROM::Repository[:tblcarsets]  
    def all
      tblcarsets.index
    end
  end
end