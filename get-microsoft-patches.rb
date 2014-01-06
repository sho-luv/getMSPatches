require 'rubygems'
require 'net/http'
require 'uri'
require 'json'
require 'american_date'
#require 'date'
require 'pry'

page = 1
patches_per_page = 100
patches = Array.new

while true
    url = "http://technet.microsoft.com"\
		"/sto/services/BulletinSearch.asmx/GetBulletins?productId=-1"\
		"&mostRecent=false&startDate=%27%27&endDate=%27%27&sortField=0&sortOrder=1"\
		"&currentPage=#{page}"\
		"&bulletinsPerPage=#{patches_per_page}"\
		"&languageId=1"\
		"&locale=%27en-us%27"
    page += 1
    req = Net::HTTP::Get.new(url)
    req.content_type = 'application/json'
    uri = URI.parse(url)

    response = Net::HTTP.start(uri.hostname, uri.port) {|http|
	http.request(req)
    }

    if response.code != "200"
	break
    end

    JSON.parse(response.body).each do |key, value|
	value.each do |k,v|
	    if v.is_a? Array
		patches = patches + v
	    end
	end
    end
end

patches.each_with_index do |e, index|
   d = DateTime.parse(e['d'])
   day = d.strftime("%A %B %e, %Y")
   patch = e.map{|k,v| "#{k}=#{v}"}.join(" ")
   puts day+" "+patch
end
