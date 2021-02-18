class Family < ApplicationRecord
  has_many :products, :dependent => :nullify

  include DefaultSortingConcern
  include FulltextConcern
  include CaptionConcern

  cattr_accessor :fulltext_fields do
    ["description"]
  end

  def self.permitted_attributes
    return :description,:name,:description_typetext,:description
  end
end
