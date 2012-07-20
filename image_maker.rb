require 'RMagick'

module ImageMaker
	def self.make_image(params)
		pic = Magick::Image.new(851,319){
		self.background_color =params[:background_color]
		}
		content = Magick::Draw.new
		content_text = params[:card_content].gsub("\r","")
		p content_text
		content.font = "#{Dir.pwd}/public/fonts/#{params[:font_type]}.ttf"
		content.font_stretch = Magick::UltraCondensedStretch
		content.pointsize = params[:font_size].to_i
		content.interline_spacing = 0
		content.gravity = Magick::CenterGravity
		top_x = params[:top_x].to_i
		top_y = params[:top_y].to_i
		bottom_x = params[:bottom_x].to_i
		bottom_y = params[:bottom_y].to_i
		pic.annotate(content,800,250,bottom_x,bottom_y,content_text){
			self.fill = params[:text_color]
		}
		file_name = (0...25).map{65.+(rand(25)).chr}.join
		pic.write("#{Dir.pwd}/public/images/#{file_name}.png")
		return "#{file_name}.png"
	end
end