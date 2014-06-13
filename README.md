# vagrant-s3auth

Private, versioned Vagrant boxes hosted on Amazon S3.

## Installation

From the command line:

```bash
$ vagrant plugin install vagrant-s3auth
```

### Requirements

* [Vagrant][vagrant], v1.5.0+

## Usage

vagrant-s3auth will automatically sign requests for S3 URLs

```
s3://bucket.example.com/path/to/metadata
```

with your AWS access key.

This means you can host your team's sensitive, private boxes on S3, and use your
developers' existing AWS credentials to securely grant access.

If you've already got your credentials stored in the standard environment
variables:

```ruby
# Vagrantfile

Vagrant.configure('2') do |config|
  config.vm.box     = 'simple-secrets'
  config.vm.box_url = 's3://example.com/secret.box'
end
```

### Configuration

#### AWS credentials

AWS credentials are read from the standard environment variables
`AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`.

If you need to obtain credentials from elsewhere, drop a block like the
following at the top of your Vagrantfile:

```ruby
creds = File.read(File.expand_path('~/.company-aws-creds')).lines
ENV['AWS_ACCESS_KEY_ID']     = creds[0]
ENV['AWS_SECRET_ACCESS_KEY'] = creds[1]
```

#### S3 URLs

Note that your URL must use the path style of specifying the bucket:

```
http://s3.amazonaws.com/bucket/resource
https://s3.amazonaws.com/bucket/resource
```

Or the S3 protocol shorthand

```
s3://bucket/resource
```

which expands to the path-style HTTPS URL.

Virtual host-style S3 URLs, where the bucket is specified in the hostname are
**not detected**!

```
https://bucket.s3-region.amazonaws.com/resource # ignored
```

##### Non-standard regions

If your bucket is not hosted in the US Standard region, you'll need to specify
the correct region endpoint as part of the URL:

```
https://s3-us-west-2.amazonaws.com/bucket/resource
```

Or just use the S3 protocol shorthand, which will automatically determine the
correct region at the cost of an extra DNS lookup:

```
s3://bucket/resource
```

For additional details on specifying S3 URLs, refer to the [S3 Developer Guide:
Virtual hosting of buckets][bucket-vhost].

#### Simple boxes

Simply point your `box_url` at a [supported S3 URL](#s3-url):

```ruby
Vagrant.configure('2') do |config|
  config.vm.box     = 'simple-secrets'
  config.vm.box_url = 'https://s3.amazonaws.com/bucket.example.com/secret.box'
end
```

#### Vagrant Cloud

Boxes on [Vagrant Cloud][vagrant-cloud] have support for versioning, multiple
providers, and a GUI management tool. If you've got a box version on Vagrant
Cloud, just point it at a [supported S3 URL](#s3-urls):

![Adding a S3 box to Vagrant Cloud](https://cloud.githubusercontent.com/assets/882976/3273399/d5d70966-f323-11e3-8393-22195050aeac.png)

Then just configure your Vagrantfile like normal:

```ruby
Vagrant.configure('2') do |config|
  config.vm.box = 'benesch/test-box'
end
```

#### Metadata (versioned) boxes

[Metadata boxes][metadata-boxes] were added to Vagrant in 1.5 and power Vagrant
Cloud. You can host your own metadata and bypass Vagrant Cloud entirely.

Essentially, you point your `box_url` at a [JSON metadata file][metadata-boxes]
that tells Vagrant where to find all possible versions:

```ruby
# Vagrantfile

Vagrant.configure('2') do |config|
  config.vm.box     = 'examplecorp/secrets'
  config.vm.box_url = 's3://example.com/secrets'
end
```

```json
"s3://example.com/secrets"

{
  "name": "examplecorp/secrets",
  "description": "This box contains company secrets.",
  "versions": [{
    "version": "0.1.0",
    "providers": [{
      "name": "virtualbox",
      "url": "https://s3.amazonaws.com/example.com/secrets.box",
      "checksum_type": "sha1",
      "checksum": "foo"
    }]
  }]
}
```

Within your metadata JSON, be sure to use [supported S3 URLs](#s3-urls).

Note that the metadata itself doesn't need to be hosted on S3. Any metadata that
points to a supported S3 URL will result in an authenticated request.

## Auto-install

The beauty of Vagrant is the magic of "`vagrant up` and done." Making your users
install a plugin is lame.

But wait! Just stick some shell in your Vagrantfile:

```ruby
unless Vagrant.has_plugin?('vagrant-s3auth')
  # Attempt to install ourself. Bail out on failure so we don't get stuck in an
  # infinite loop.
  system('vagrant plugin install vagrant-s3auth') || exit!

  # Relaunch Vagrant so the plugin is detected. Exit with the same status code.
  exit system('vagrant', *ARGV)
end
```


[aws-signed]: http://docs.aws.amazon.com/AmazonS3/latest/dev/RESTAuthentication.html#ConstructingTheAuthenticationHeader
[bucket-vhost]: http://docs.aws.amazon.com/AmazonS3/latest/dev/VirtualHosting.html#VirtualHostingExamples
[metadata-boxes]: http://docs.vagrantup.com/v2/boxes/format.html
[vagrant]: http://vagrantup.com
[vagrant-cloud]: http://vagrantcloud.com
