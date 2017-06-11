name 'nginx-role' 
description 'Role for all nginx web servers' 
run_list "chef-client","nginx" 
default_attributes 'nginx-test' => { 
  'attribute1' => 'hello from attribute 1', 
  'attribute2' => 'you are great!' 
} 
