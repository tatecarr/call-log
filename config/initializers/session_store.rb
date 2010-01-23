# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_call-log_session',
  :secret      => '6ea481a3c989e5b8d395d6068ee0e70dbc8033f84854f39431cf48ea9215822a8095e486fae4f4171f677d86461a58192d7f5fd4a8ef37b6a71a6e068d4dddaf'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
