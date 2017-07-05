name 'nodejs-role' 
description 'Role for all nodejs servers' 
run_list "chef-client","my-nodejs" 
default_attributes 'nodejs-test' => { 
  'attribute1' => 'hello from attribute 1', 
  'attribute2' => 'you are great!' 
} 
