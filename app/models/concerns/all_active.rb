###############################################################################
#
# Model concern- returns all "active" rows of a model, and sorts them by
# ascending name order (i.e. asciibetical).   Note that a row is considered
# "active" it its "deactivated" field is anything other than the string FALSE.
#
###############################################################################
module AllActive

  extend ActiveSupport::Concern

  #######################################################################
  #
  # This module is just the one used to include concerns as class, rather
  # than instance, methods.
  #
  #######################################################################
  module ClassMethods

    #############################################################################
    #
    # Helper method; want all active (and want deterministic sort... so results
    # will be same on postgresql database and sqlite
    #
    #############################################################################
    def all_active
      self.where.not(is_retired: true)
    end

    ##############################################################################
    #
    # Same as all_active, but returns a list of names, so this isn't really
    # just a scope.   Note that activenames must be unique for this to work
    #
    ##############################################################################
  #  def all_active_names_with_priority(the_priority_name = nil)
#
#      self.all_active.pluck(:name).sort{|a,b| a == the_priority_name ? -1 : ( b == the_priority_name ? 1 : a <=> b)}
#
#    end
  end
end
