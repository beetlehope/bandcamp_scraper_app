class Album < ApplicationRecord


 def self.search(search)

   where("tags ILIKE ? OR artist ILIKE ?", "%#{search}%", "%#{search}%")
 end

 def self.search1(search1)

   where("license_type ILIKE ? ", "%#{search1}%")
 end
end
