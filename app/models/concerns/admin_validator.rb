###############################################################################
#
# Model concern- Validator for changes to users, locations, and skus.
#  Looks at session id to see if the logged in user has admin priv.
#
###############################################################################
module AdminValidator

  class AdminValidator < ActiveModel::Validator

    def validate(record)
        unless User.exists?(record.user_id) &&
               User.find(record.user_id).capabilities =~ /admin/

            record.errors[:base] << "Only admin users may update this"

        end
    end

  end

end
