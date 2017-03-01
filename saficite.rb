# !/usr/bin/env ruby

# Copyright (C) 2017  Atomic Jolt
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

require "zip"
require "aws-sdk"
require "aws-sdk-resources"

@sources = "/#{Dir.pwd}/sources"
@archive_dir = "/#{Dir.pwd}/unzipped_archives"
@gz_files = []

def config
  @config ||= if File.exists? "config.yml"
                YAML::safe_load(File.read("config.yml"), [Symbol])
              else
                {}
              end
end

def extract_zip_archives(file)
  folder = "#{@archive_dir}/#{file}"

  print "Extracting documents from #{file}.\n"

  Zip::ZipFile.open("#{@sources}/#{file}") do |zip_file|
    zip_file.each do |f|
      f_path = File.join(folder, f.name)
      FileUtils.mkdir_p(File.dirname(f_path))

      if !File.exist?(f_path)
        zip_file.extract(f, f_path)
      end

      @gz_files.push(f_path)
      print "\r#{@gz_files.size} files found. "
    end

    print "\n"
  end
end

def upload_presigned(obj, file)
  url = URI.parse(obj.presigned_url(:put))

  body = file
  # This is the contents of your object. In this case, it's a simple string.

  Net::HTTP.start(url.host) do |http|
    http.send_request(
      "PUT",
      url.request_uri,
      body,
      # This is required, or Net::HTTP will add a default unsigned content-type.
      "content-type" => "",
    )
  end
end

def upload_files
  Aws.config.update(
    access_key_id: config[:access_key],
    secret_access_key: config[:secret_key],
  )
  s3 = Aws::S3::Resource.new(region: config[:region])
  index = 0

  @gz_files.each do |file|
    upload_dest = "Saficite/#{File.basename(file, '.*')}"
    obj = s3.bucket(config[:bucket]).object("#{upload_dest}/#{File.basename(file)}")

    upload_presigned(obj, file)

    index += 1
    print "\r#{index} of #{@gz_files.size} files uploaded to #{upload_dest}"
  end

  print "\n\n"
  @gz_files.clear
end

def aggregate_files
  print "\n"
  Dir.foreach(@sources) do |file|
    next if file == "." || file == ".."

    if File.extname(file) == ".zip"
      extract_zip_archives(file)
      upload_files(file)
    end
  end
end

aggregate_files
