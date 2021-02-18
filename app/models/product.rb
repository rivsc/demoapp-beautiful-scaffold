class Product < ApplicationRecord
  belongs_to :family, optional: true

  include DefaultSortingConcern
  include FulltextConcern
  include CaptionConcern

  cattr_accessor :fulltext_fields do
    ["description"]
  end

  def self.permitted_attributes
    return :family_id,:price,:color,:description_typetext,:description,:family_id
  end
end
