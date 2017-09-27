module SmartTrack::Database::Relations
  class Tblcarsets < ROM::Relation[:sql]
    schema(:tblcarsets) do
      attribute :vid, Types::String
      attribute :plate, Types::String
    end

    def index
      select(:vid, :plate)
    end
  end
end