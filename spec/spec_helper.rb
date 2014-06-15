require 'vagrant-s3auth'

# AWS signatures are timezone-dependent. Ensure a consistent timezone.
ENV['TZ'] = 'EST+5'
