class Vaquita < ActiveRecord::Base
    belongs_to :creator, class_name: 'Account'

end
