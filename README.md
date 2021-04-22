# HttpClient

## Introduction

HttpClient is a wrapper for any library, handling http connections (at the moment Faraday) in more
convinient and well organized way.

The purpose of this library is to provide easy-to-use standartized intefrace to access specific endpoints
and handle any possible error nicely.

# Contents
* [Compatibility](#compatibility)
* [Installation](#installation)
* [Encodings](#encodings)
* [Usage](#usage)
* [License](#license)

## Compatibility

HttpClient supports Ruby 1.8.7+, including JRuby and Rubinius.

## Usage

All major connections functions should be able to happen from the WS::HttpClient module.
So, you should be able to just <code>require 'http_client'</code> to get started.


## License

(The MIT License)

Copyright (c) 2009-2016 Mikel Lindsaar

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
