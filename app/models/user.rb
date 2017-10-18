class User < ApplicationRecord

  # Bring in shared scopes from the concerns file
  include AllActive

  # Define any of our own scopes for the user
  

end
