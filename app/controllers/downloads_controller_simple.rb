class DownloadsController < ApplicationController
  before_action :set_image, only: [:show]

  def show
    Rails.logger.info "Starting download for image #{params[:id]}"
    
    # Validate that the image has files to download
    if !@image.file.attached? && @image.variations.none? { |v| v.file.attached? }
      Rails.logger.warn "No files available for download for image #{@image.id}"
      redirect_to @image, alert: "No files available for download."
      return
    end

    begin
      # Create zip file directly in tmp directory with timestamp
      timestamp = Time.current.strftime("%Y%m%d_%H%M%S")
      zip_filename = "#{@image.title&.parameterize || "image_#{@image.id}"}_#{timestamp}.zip"
      zip_path = Rails.root.join('tmp', zip_filename)

      # Create the zip file
      create_zip_file_simple(zip_path)

      # Verify zip file was created successfully
      unless File.exist?(zip_path) && File.size(zip_path) > 0
        raise "Failed to create zip file or file is empty"
      end

      Rails.logger.info "Sending zip file: #{zip_path} (#{File.size(zip_path)} bytes)"

      # Send the zip file
      send_file zip_path, 
                filename: zip_filename, 
                type: 'application/zip',
                disposition: 'attachment'
                
    rescue => e
      Rails.logger.error "Download generation failed: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      
      redirect_to @image, alert: "Failed to generate download package: #{e.message}"
    end
  end

  private

  def set_image
    @image = Image.includes(variations: :file_attachment).find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to images_path, alert: "Image not found."
  end

  def create_zip_file_simple(zip_path)
    require 'zip'
    
    file_count = 0
    
    Zip::File.open(zip_path, Zip::File::CREATE) do |zipfile|
      # Add original image
      if @image.file.attached?
        begin
          original_name = "#{@image.title&.parameterize || "image_#{@image.id}"}#{get_file_extension(@image.file)}"
          zipfile.get_output_stream("original/#{original_name}") do |output|
            output.write(@image.file.download)
          end
          file_count += 1
          
          # Create size variants
          [1024, 512, 64].each do |size|
            variant_name = "#{@image.title&.parameterize || "image_#{@image.id}"}_#{size}px#{get_file_extension(@image.file)}"
            begin
              variant = @image.file.variant(resize_to_limit: [size, nil])
              zipfile.get_output_stream("#{size}px/#{variant_name}") do |output|
                output.write(variant.processed.download)
              end
              file_count += 1
            rescue => e
              Rails.logger.warn "Failed to create #{size}px variant: #{e.message}"
            end
          end
        rescue => e
          Rails.logger.error "Failed to process original image: #{e.message}"
        end
      end

      # Add variations
      @image.variations.includes(:file_attachment).each_with_index do |variation, index|
        if variation.file.attached?
          begin
            variation_name = "variation_#{index + 1}#{get_file_extension(variation.file)}"
            zipfile.get_output_stream("original/#{variation_name}") do |output|
              output.write(variation.file.download)
            end
            file_count += 1
            
            # Create size variants for variations
            [1024, 512, 64].each do |size|
              variant_name = "variation_#{index + 1}_#{size}px#{get_file_extension(variation.file)}"
              begin
                variant = variation.file.variant(resize_to_limit: [size, nil])
                zipfile.get_output_stream("#{size}px/#{variant_name}") do |output|
                  output.write(variant.processed.download)
                end
                file_count += 1
              rescue => e
                Rails.logger.warn "Failed to create #{size}px variant for variation #{index + 1}: #{e.message}"
              end
            end
          rescue => e
            Rails.logger.error "Failed to process variation #{index + 1}: #{e.message}"
          end
        end
      end
    end

    if file_count == 0
      raise "No files were added to the zip archive"
    end
    
    Rails.logger.info "Created zip file with #{file_count} files"
  end

  def get_file_extension(attached_file)
    extension = File.extname(attached_file.blob.filename.to_s).downcase
    extension.blank? || !['.jpg', '.jpeg', '.png', '.gif', '.webp'].include?(extension) ? '.jpg' : extension
  end
end
