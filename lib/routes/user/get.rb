get_users_schema = Dry::Validation.Form do
  required(:page).maybe(:int?)
  required(:size).maybe(:int?)
  required(:order).maybe(:str?)
  required(:direction).maybe(:str?, included_in?: ['asc', 'desc'])
end

namespace '/api' do
  get '/users' do
    authorize? env

    page = params['page'] || 1
    size = params['size'] || SmartTrack::Constant::PAGE_SIZE
    order = params['order'] || 'id'
    direction = params['direction'] || 'asc'
    result = get_users_schema.call(
      page: page, size: size,
      order: order, direction: direction)
    return [500, json(errors: result.errors)] if result.failure?    

    users = @user_repo.active_users(size, page, order, direction)
    pager = @rom.relations[:users].per_page(size).page(page).pager

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