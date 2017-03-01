<!-- Copyright (C) 2017  Atomic Jolt

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>. -->

# Saficite

Welcome to Saficite, a script that aggregates SafeAssign files to a pre-signed Vericite S3 bucket

How to use:

1. Clone the repo.

2. Add archived SafeAssign files into a `sources` folder in project directory.

3. Run `bundle install`.

4. Create a `config.yml` file and add the following:

  ```yaml
  :bucket: <S3 bucket location>
  :bucket_dir: <directory in S3 bucket to upload to>
  :access_key: <access key ID>
  :secret_key: <secret access key>
  :user: <user>
  :region: <region>
  ```

5. Run `ruby saficite.rb`
