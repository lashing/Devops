name 'production'
description "Where we run production code"
cookbook 'nginx', '= 0.1.3'
cookbook 'chef-client', '= 2.1.2'
cookbook 'my-nodejs', '= 0.1.1'
