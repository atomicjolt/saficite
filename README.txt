Welcome to Saficite, a script that aggregates SafeAssign files to a pre-signed Vericite s3 bucket

How to use:

1. Download archived SafeAssign files into the /sources folder.

2. Gem install zip, aws-sdk, and aws-sdk-resources

3. Run script.rb with the following arguments: 

	arg0 = bucket name
	arg1 = access key
	arg2 = secret key
	arg3 = region