# !/usr/bin/env ruby
# prerequisites
# -------------
# gem install 'zip'
# gem install 'aws-sdk'
# gem install 'aws-sdk-resources'
require 'rubygems'
require 'zip'
require 'aws-sdk'
require 'aws-sdk-resources'

@sources = "/#{Dir.pwd}/sources"
@archive_dir = "/#{Dir.pwd}/unzipped_archives"
@gz_files = Array.new
@bucket = ARGV[0]  # (e.g. openlmshost.datamigration)
@access_key = ARGV[1] # access key
@secret_key = ARGV[2] # secret key
@region = ARGV[3] # region (e.g. 'us-east-1')

def extract_zip_archives(file)
  folder = "#{@archive_dir}/#{file}"
  print "Extracting documents from #{file}.\n"
  Zip::ZipFile.open("#{@sources}/#{file}") { |zip_file|
    zip_file.each { |f|
      f_path = File.join(folder, f.name)
      FileUtils.mkdir_p(File.dirname(f_path))
      if(!File.exist?(f_path))
        zip_file.extract(f, f_path)
      end
      @gz_files.push(f_path)
      print "\r#{@gz_files.size} files found. "
    }
    print "\n"
  }
end

def upload_presigned(obj, file)
  url = URI.parse(obj.presigned_url(:put))

  body = file
  # This is the contents of your object. In this case, it's a simple string.

  Net::HTTP.start(url.host) do |http|
    response = http.send_request("PUT", url.request_uri, body, {
  # This is required, or Net::HTTP will add a default unsigned content-type.
      "content-type" => "",
    })
  end
end

def upload_files(file)
  Aws.config.update({
    access_key_id: @access_key,
    secret_access_key: @secret_key
  })
  s3 = Aws::S3::Resource.new(region:@region)
  i = 0
  @gz_files.each { |f|
    upload_dest = "Saficite/#{File.basename(file, ".*")}"
    obj = s3.bucket(@bucket).object("#{upload_dest}/#{File.basename(f)}")
    #obj.upload_file(f) # built in method that uploads just fine and is smaller

    upload_presigned(obj, f)

    i += 1
    print "\r#{i} of #{@gz_files.size} files uploaded to #{upload_dest}"
  }
  print "\n\n"
  @gz_files.clear
end

def aggregate_files()
  print "\n"
  Dir.foreach(@sources) do |file|
    next if file == '.' or file == '..'
    if(File.extname(file) == '.zip')
      folder = extract_zip_archives(file)
      upload_files(file)
    end
  end
end

aggregate_files()
