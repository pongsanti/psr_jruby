module SmartTrack::Database::Repository
  class User
    attr_reader :id, :email, :display_name, :password, :admin,
      :user_session
  
    def initialize(attributes)
      @id = attributes[:id]
      @email = attributes[:email]
      @display_name = attributes[:display_name]
      @password = attributes[:password]
      @admin = attributes[:admin]
      @user_session = attributes[:user_session]
    end
    
    def to_json(options={})
      hash = {
        id: id,
        email: email,
        display_name: display_name,
        admin: admin
      }
      hash.to_json
    end
  end

  class UserRepo < ROM::Repository[:users]
    relations :user_sessions

    commands :create, update: :by_pk
    
    def query_first(conditions)
      users.combine(one: {user_session: user_sessions}).map_to(User).where(conditions).first
    end

    def find_by_email(email)
      query_first(email: email)
    end

    def active_users(per_page, page, order_col, direction = :asc)
      order_col = order_col.to_sym

      rel = users.where(deleted_at: nil).per_page(per_page).page(page)
      if (direction.to_sym == :asc)
        rel = rel.order(order_col)
      else
        rel = rel.order(order_col).reverse
      end
      return rel.map_to(User).to_a
    end

  end
end