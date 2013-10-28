# DeliverIt

DeliverIt is a simple file sharing web application. It mostly oriented in personal use but provides ability to handle multiple users. So if you also want you may use it for all of your family, friends and so on.

## Requirements

DeliverIt was writen with Ruby 2.0 and Rails 4.0, but feel free to check if you can run it on another environment. Though I don't know why are you may want that.
Also for Image processing you must have ImageMagic and MiniMagic.

## Installation

If you didn't install MiniMagic already it's time to do it.
To install Imagemagick on OSX with homebrew type the following:
```
$ brew install imagemagick
```

Clone this repository, deploy on your server. That's it.

## Quick start

First of all you must set database credentials in 'config/database.yml'. Feel free to use any of provided by ActiveRecord adapters. I'm using Postgres for example.

DeliverIt based on variety of gems, so for more deep details you may check appropriate documentations.

Next in 'initializers/devise.rb' you must change 'config.mailer_sender' variable to your own email-address.

Next you must change image store to path in your server. It provides by changing
```
when 'production'
        Rails.root.join('..', '..', 'shared', 'uploads', "#{model.created_at.year}", "#{model.created_at.month}", "#{model.created_at.day}", "#{model.id}").to_s
```
line in 'app/uploaders/file_uploader.rb'. This collect directory structure relative to the application root folder.

Then 'rake:db:migrate'.

That's it for quick start! DeliverIt ready to run.
Note: First registered user(user with id =1 in database) will be admin!

## More configuring

If you don't want to handle multiple users you can disable register abylity by removing ':registerable' argument from 'devise' method in 'app/models/user.rb' (better if you do it after creating the first user).
For authentication DeliverIt use Devise gem. See the Devise documentation for more details: https://github.com/plataformatec/devise

Next you may want to change image handling behaviour.
Most of all that options available in 'app/uploaders/file_uploader.rb'.
So for default DeliverIt provides creating two image sizes except original size - [medium] and [thumb]. You can add another or change resolution od existing by altering:
```
version :thumb, :if => :image? do
    process :resize_and_pad => [200,150]
end
```
Image handling provided by CarrierWave gem, so for more information see - https://github.com/carrierwaveuploader/carrierwave

Also you may want to customize or fully redisign application view.
DeliverIt based on Twitter boostrap. Fot it available dozens of themes - go ahead and play with it.

## Copyright

Copyright (c) 2013 Aleksandrov Denis

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

