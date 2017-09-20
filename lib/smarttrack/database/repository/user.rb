module SmartTrack::Database::Repository
  class User
    attr_reader :id, :email, :display_name, :password, :admin,
      :created_at,
      :user_session,
      :stations
  
    def initialize(attributes)
      @id = attributes[:id]
      @email = attributes[:email]
      @display_name = attributes[:display_name]
      @password = attributes[:password]
      @admin = attributes[:admin]
      @created_at = attributes[:created_at]
      @user_session = attributes[:user_session]
      @stations = attributes[:stations]
    end

    def created_at
      @created_at.strftime('%F %T') if @created_at
    end
    
    def to_json(options={})
      hash = {
        id: id,
        email: email,
        display_name: display_name,
        created_at: created_at,
        admin: admin
      }
      hash.to_json
    end
  end

  class UserRepo < ROM::Repository[:users]
    relations :user_sessions, :stations

    commands :create, update: :by_pk

    def stations_by_user(user_id)
      users.active.by_pk(user_id).combine(many: {stations: stations})
    end
    
    def query_first(conditions)
      users.combine(one: {user_session: user_sessions}).map_to(User).where(conditions).one
    end

    def find_by_email(email)
      query_first(email: email)
    end

    def find_by_like_email(text)
      users.map_to(User).like(:email, text).active.to_a
    end

    def active_user(id)
      users.map_to(User).active.by_pk(id).one
    end

    def active_users_dataset(per_page, page, order_col, direction = :asc, search_hash = nil)
      order_col = order_col.to_sym

      rel = users.active

      # searching
      if search_hash
        search_hash.each do |key, value|
          rel = rel.like(key, value)
        end
      end

      # pagination
      rel = rel.per_page(per_page).page(page)
      
      # ordering
      if (direction.to_sym == :asc)
        rel = rel.order(order_col)
      else
        rel = rel.order(order_col).reverse
      end
      return rel.map_to(User)
    end

  end
end