get_users_schema = Dry::Validation.Form do
  required(:page).maybe(:int?)
  required(:size).maybe(:int?)
  required(:order).maybe(format?: /^\D*$/)
  required(:direction).maybe(:str?, included_in?: ['asc', 'desc'])
  required(:email).maybe(:str?)
end

namespace '/api' do
  get '/users' do
    authorize_admin? env

    page = params['page'] || 1
    size = params['size'] || SmartTrack::Constant::PAGE_SIZE
    order = params['order'] || 'id'
    direction = params['direction'] || 'asc'
    email = params['email'] || nil
    result = get_users_schema.call(
      page: page, size: size,
      order: order, direction: direction,
      email: email)
    return [500, json(errors: result.errors)] if result.failure?    

    search_hash = email == nil ? {} : {email: email}
    users_dataset = @user_repo.active_users_dataset(size, page, order, direction, search_hash)
    users = users_dataset.to_a
    pager = users_dataset.pager

    [200, json(users: users, pager: pager_to_hash(pager))]
  end
end

def pager_to_hash(pager)
  hash = {}
  methods = [:current_page, :limit_value, :next_page, :prev_page, :total, :total_pages]
  methods.each do |m|
    hash[m] = pager.send(m)
  end
  hash
end