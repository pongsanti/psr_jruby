require 'sequel'
require 'logger'
require 'set'
require 'benchmark'
require_relative './query'
require_relative './util'

MINUTE = 1/24.0/60.0
RUN_INTERVAL_SECOND = 30
LOG_FILE = 'smarttrack_daemon.log'

HOST = 'localhost'
PORT = '3306'
DATABASE_NAME = ENV["SINATRA_ENV"] == 'test' ? 'smarttrack_test' : 'smarttrack'
USER = 'root'
PASS = 'root'
DB_URL = "jdbc:mysql://#{HOST}:#{PORT}/#{DATABASE_NAME}?user=#{USER}&password=#{PASS}&charset=utf8"

DB = Sequel.connect(DB_URL)
LOG = Logger.new(LOG_FILE, 10)
DB.loggers << LOG
run_count = 0

def run
  
  plates = Set.new
  user_ids = Set.new
  user_truck_ids = Set.new
  # query current active user_trucks records
  user_trucks = active_user_trucks(DB)
  # build truck plates, users set
  user_trucks.each do |ut|
    user_truck_ids << ut[:id] 
    plates << ut[:License_Plate]
    user_ids << ut[:user_id]
  end
  # query latest locations by target plates
  locations = locations_by_plates(DB, plates.to_a)
  # puts locations
  # query all user stations
  user_stations = user_stations_by_user_ids(DB, user_ids.to_a)
  # for new station arrival
  LOG.info("\n")
  LOG.info("Start finding new truck station arrival...")
  LOG.info("\n")

  user_trucks.each do |ut|
    id = ut[:id]
    user_id = ut[:user_id]
    plate = ut[:License_Plate]
    LOG.info("For user #{user_id} with truck plate #{plate}")

    location = truck_arrival_at_station(plate, locations)
    if location
      LOG.info("Found location #{location}")
      station_id = location[:stationid].to_i
      if station_for_user(user_stations, user_id, station_id)
        LOG.info("Station #{station_id} is for user #{user_id}")
        LOG.info("Checking if the arrival has been recorded...")
        if user_truck_stations_has_been_recorded(DB, id, station_id).size == 0
          LOG.info("Persisting a new station arrival record...")
          insert_user_truck_stations(DB, id, station_id)
          LOG.info("Persisted.")
        else
          LOG.info("The station arrival has been recorded. Done!")
        end
      else
        LOG.info("Station #{station_id} is NOT for user #{user_id}")
      end
    end
    LOG.info("\n")
  end

  # for new station departure
  LOG.info("\n")
  LOG.info("Start finding new truck station departure...")
  LOG.info("\n")
  # for each user_truck_stations with 'depart_at' is null
  # we look for the the truck location with stationid as null
  # because it indicates that truck departs from the stations

  arrived_user_truck_stations = user_truck_stations_arrived_by_user_truck_ids(DB, user_truck_ids.to_a)
  arrived_user_truck_stations.each do |uts|
    id = uts[:id]
    user_id = uts[:user_id]
    station_id = uts[:station_id]
    plate = uts[:License_Plate]
    LOG.info("For `user_truck_station` id #{id}, user_id #{user_id}, plate #{plate}")
    location = truck_departure_from_station(plate, locations)
    if location
      LOG.info("Found location #{location}")
      LOG.info("Updating the station departure record...")
      update_user_truck_stations_departed(DB, id)
      LOG.info("Updated.")
    else
      LOG.info("No truck departure location found. Done.")
    end
  end
end

while true
  LOG.info "Let's work, I've run #{run_count} times...\n"
  Benchmark.bm(20) do |bm|  # The 20 is the width of the first column in the output.
    bm.report("Background task:\n") {
      run
    }
  end
  run_count = run_count + 1
  LOG.info "sleeping for #{RUN_INTERVAL_SECOND} seconds...\n\n"
  sleep RUN_INTERVAL_SECOND
end
