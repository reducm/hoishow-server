# encoding: utf-8
json.(banner, :id, :subject_type, :subject_id)
json.poster banner.poster_url || ''

if !banner.is_article?
  subject_downcase = banner.subject_type.downcase
  json.subject do
    json.partial!("api/v1/#{subject_downcase.pluralize}/#{subject_downcase}", locals: Hash[subject_downcase.to_sym, banner.subject])
  end
end

json.description description_url(subject_type: "Banner", subject_id: banner.id)
