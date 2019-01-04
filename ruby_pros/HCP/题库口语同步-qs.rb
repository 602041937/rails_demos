require 'pg'
require 'time'
require 'AudioInfo'
require 'open-uri'

def get_duration url
  open(url) do |f|
    filename = "tmp/#{Time.now.to_i}.mp3"
    File.open(filename, 'w') do |file|
      file.write(f.read)
    end
    AudioInfo.open(filename) do |info|
      length = info.length
      return length
    end
    File.delete(filename)
  end
  return 0
end

# pc_connection = PG.connect :host => 'rm-wz955u729m2b7e039go.pg.rds.aliyuncs.com', :port => 3432, :dbname => 'hcp-question-bank', :user => 'qiushi', :password => 'HcpGo2018'
# app_connection = PG.connect :host => 'rm-2zeyu6ov54144fq5co.pg.rds.aliyuncs.com', :port => 3433, :dbname => 'ieltsbrov6_production_psql', :user => 'qiushi', :password => 'HCP80128!@#'

require 'rails-html-sanitizer'

def remove_html text
  full_sanitizer = Rails::Html::FullSanitizer.new
  full_sanitizer.sanitize(text)
end

def get_audio_url bank_table_name, bank_uuid, audio_file
  return '' if audio_file == nil
  audio_file = "http://hcp-question-bank.oss-cn-shenzhen.aliyuncs.com/question-bank/uploads/production/#{bank_table_name.chop}/audio_file/#{bank_uuid}/#{audio_file}"
end


def add_part23_questions part2_id, tags
  #statements for add_part23_questions
  pc_connection = PG.connect :host => 'rm-wz955u729m2b7e039go.pg.rds.aliyuncs.com', :port => 3432, :dbname => 'hcp-question-bank', :user => 'qiushi', :password => 'HcpGo2018'
  app_connection = PG.connect :host => 'rm-2zeyu6ov54144fq5co.pg.rds.aliyuncs.com', :port => 3432, :dbname => 'ieltsbrov6_production_psql', :user => 'qiushi', :password => 'HCP80128!@#'

  insert_part23_statement = <<SQL
insert into "public"."app_part23_topics" ( "topic", "content", "is_show", "created_at", "updated_at", "app_oral_practice_part23_category_id", "total_count", "oral_practice_collections", "oral_practice_description", "total_comment_count", "tags", "topic_order", "is_show_tab2", "is_sleep", "is_new", "practice_count", "bank_superior_uuid", "bank_uuid", "bank_sub_uuid", "serial_number", "degree", "answer_explain", "collectionable_count", "time_for_read") values ( $1, $2, 'f', $3, $4, $5, '0', '0', $6, 0, $7, '0', 'f', 't', 't', '0', null, null, null, null, null, null, '0', $8) RETURNING *;
SQL
  insert_part23_question_statement = <<SQL
insert into "public"."app_oral_practice_questions" ( "app_part1_topic_id", "app_part23_topic_id", "topic", "description", "created_at", "updated_at", "is_show", "comment_count", "vu", "uu", "question_order", "part_num", "audio_file", "answer_explain", "sequence", "duration", "bank_uuid", "bank_table_name", "last_sync_pc_time", "collectionable_count") values ( null, $1, $2, $3, $4, $5, 't', '0', '', '', '0', $6, $7, $8, null, $9, $10, $11, $12, '0') RETURNING *;
SQL
  insert_part3_question_statement = <<SQL
insert into "public"."app_oral_practice_questions" ( "app_part1_topic_id", "app_part23_topic_id", "topic", "description", "created_at", "updated_at", "is_show", "comment_count", "vu", "uu", "question_order", "part_num", "audio_file", "answer_explain", "sequence", "duration", "bank_uuid", "bank_table_name", "last_sync_pc_time", "collectionable_count") values ( null, $1, $2, $3, $4, $5, 't', '0', '', '', '1', $6, $7, $8, null, $9, $10, $11, $12, '0') RETURNING *;
SQL
  app_connection.prepare 'create_part2_topic', insert_part23_statement
  app_connection.prepare 'create_part2_question', insert_part23_question_statement
  app_connection.prepare 'create_part3_question', insert_part3_question_statement
  # part2_id = 61
  # tags = '2018年9-12月'
  part2_questions = pc_connection.exec("select * from oral_twos where id = #{part2_id}")
  part2_question = part2_questions.first
  part2_topic = pc_connection.exec("select * from topics where id = #{part2_question['topic_id']}").first
  while (!part2_topic['superior_topic_id'].nil?)
    part2_topic = pc_connection.exec("select * from topics where id = #{part2_topic['superior_topic_id']}").first
  end
  part_zh_to_en = {'事物' => 'thing', '人物' => 'person', '事件' => 'event', '地点' => 'location'}
  en_name = part_zh_to_en[part2_topic['name']]
  part2_category_id = app_connection.exec("select id from app_oral_practice_part23_categories where name = '#{en_name}'").first['id']
  following_part3_questions = pc_connection.exec("select * from oral_three_questions where oral_two_id = #{part2_question['id']}")
  # 插入Part23Topic

  topic = part2_question['name']
  content = part2_question['question']
  created_at = Time.now
  updated_at = Time.now
  app_oral_practice_part23_category_id = part2_category_id.to_i
  oral_practice_description = remove_html(part2_question['question']).gsub(/\r/, '').gsub(/\n\n/, "\n")
  tags = tags
  time_for_read = Time.now.to_i

  topic_result = app_connection.exec_prepared 'create_part2_topic', [topic, content, created_at, updated_at, app_oral_practice_part23_category_id, oral_practice_description, tags, time_for_read]

  topic_id = topic_result.first['id']

  #插入Part2题卡
  topic_id
  topic
  description = oral_practice_description
  created_at = Time.now
  updated_at = Time.now
  part_num = 2
  audio_file = ''
  answer_explain = part2_question['answer_explain']
  duration = 0
  bank_uuid = part2_question['id']
  bank_table_name = 'oral_twos'
  last_sync_pc_time = Time.now

  part2_question_result = app_connection.exec_prepared 'create_part2_question', [topic_id, topic, description, created_at, updated_at, part_num, audio_file, answer_explain, duration, bank_uuid, bank_table_name, last_sync_pc_time]

  #插入Part3

  following_part3_questions.each do |part3_question|
    topic_id
    topic
    description = remove_html(part3_question['question']).gsub(/\r/, '').gsub(/\n\n/, "\n")
    created_at = Time.now
    updated_at = Time.now
    part_num = 3
    audio_file = get_audio_url 'oral_three_questions', part3_question['id'], part3_question['audio_file']
    answer_explain = part3_question['answer_explain']
    duration = get_duration audio_file
    bank_uuid = part3_question['id']
    bank_table_name = 'oral_three_questions'
    last_sync_pc_time = Time.now

    part3_question_result = app_connection.exec_prepared 'create_part3_question', [topic_id, topic, description, created_at, updated_at, part_num, audio_file, answer_explain, duration, bank_uuid, bank_table_name, last_sync_pc_time]
  end

  #显示topic
  app_connection.exec "update app_part23_topics set is_show = true, is_show_tab2 = true, is_sleep = false where id =#{topic_id}"
  pc_connection.close
  app_connection.close
end

##########################################


def add_part1_questions part1_id, tags
  pc_connection = PG.connect :host => 'rm-wz955u729m2b7e039go.pg.rds.aliyuncs.com', :port => 3432, :dbname => 'hcp-question-bank', :user => 'qiushi', :password => 'HcpGo2018'
  app_connection = PG.connect :host => 'rm-2zeyu6ov54144fq5co.pg.rds.aliyuncs.com', :port => 3432, :dbname => 'ieltsbrov6_production_psql', :user => 'qiushi', :password => 'HCP80128!@#'

  insert_part1_topic_statement = <<SQL
insert into "public"."app_part1_topics" ( "topic", "content", "is_show", "created_at", "updated_at", "app_oral_practice_part1_category_id", "total_count", "oral_practice_collections", "oral_practice_description", "total_comment_count", "tags", "topic_order", "is_show_tab2", "is_sleep", "is_new", "practice_count",  "collectionable_count", "time_for_read") values ( $1, $2, 'f', $3, $4, $5, '0', '0', $6, 0, $7, '0', 'f', 't', 't', '0', '0', $8) RETURNING *;
SQL

  insert_part1_question_statement = <<SQL
insert into "public"."app_oral_practice_questions" ( "app_part1_topic_id", "app_part23_topic_id", "topic", "description", "created_at", "updated_at", "is_show", "comment_count", "vu", "uu", "question_order", "part_num", "audio_file", "answer_explain", "sequence", "duration", "bank_uuid", "bank_table_name", "last_sync_pc_time", "collectionable_count") values ( $1, null, $2, $3, $4, $5, 't', '0', '', '', $13, $6, $7, $8, null, $9, $10, $11, $12, '0') RETURNING *;
SQL

  app_connection.prepare 'create_part1_topic', insert_part1_topic_statement

  app_connection.prepare 'create_part1_question', insert_part1_question_statement

  # part1_id = 36
  # tags = '2018年9-12月'
  part1_topic = pc_connection.exec("select * from oral_ones where id = #{part1_id}").first
  part1_questions = pc_connection.exec("select oral_one_question_id from oral_one_question_references where referrable_id = #{part1_topic['id']} order by sequence").map {|x| x['oral_one_question_id']}.map {|id| pc_connection.exec("select * from oral_one_questions where id = #{id}").first}
  #查找part1 category
  part1_cat = pc_connection.exec("select * from topics where id = #{part1_topic['topic_id']}").first
  while (!part1_cat['superior_topic_id'].nil?)
    part1_cat = pc_connection.exec("select * from topics where id = #{part1_cat['superior_topic_id']}").first
  end
  part_zh_to_en = {'事物' => 'thing', '人物' => 'person', '事件' => 'event', '地点' => 'location'}
  en_name = part_zh_to_en[part1_cat['name']]
  part1_category_id = app_connection.exec("select id from app_oral_practice_part1_categories where name = '#{en_name}'").first['id']
  # 插入Part1Topic
  topic = part1_topic['name']
  content = part1_questions.first['question']
  created_at = Time.now
  updated_at = Time.now
  app_oral_practice_part1_category_id = part1_category_id.to_i
  oral_practice_description = remove_html(content).gsub(/\r/, '').gsub(/\n\n/, "\n")
  tags = tags
  time_for_read = Time.now.to_i
  topic_result = app_connection.exec_prepared 'create_part1_topic', [topic, content, created_at, updated_at, app_oral_practice_part1_category_id, oral_practice_description, tags, time_for_read]
  topic_id = topic_result.first['id']
  #插入Part1Question
  part1_questions.each_with_index do |part1_question, index|
    topic_id
    topic
    description = remove_html(part1_question['question']).gsub(/\r/, '').gsub(/\n\n/, "\n")
    created_at = Time.now
    updated_at = Time.now
    part_num = 1
    audio_file = get_audio_url 'oral_one_questions', part1_question['id'], part1_question['audio_file']
    answer_explain = part1_question['answer_explain']
    duration = get_duration audio_file
    bank_uuid = part1_question['id']
    bank_table_name = 'oral_one_questions'
    last_sync_pc_time = Time.now
    sequence = index + 1
    part1_question_result = app_connection.exec_prepared 'create_part1_question', [topic_id, topic, description, created_at, updated_at, part_num, audio_file, answer_explain, duration, bank_uuid, bank_table_name, last_sync_pc_time, sequence]
  end
  #显示topic
  app_connection.exec "update app_part1_topics set is_show = true, is_show_tab2 = true, is_sleep = false where id =#{topic_id}"
  pc_connection.close
  app_connection.close
end


# add_part23_questions 82, '2018年9-12月'
# puts 'process 82'
# add_part23_questions 83, '2018年9-12月'
# puts 'process 83'
# add_part23_questions 84, '2018年9-12月'
# puts 'process 84'
# add_part23_questions 85, '2018年9-12月'
# puts 'process 85'
# add_part23_questions 86, '2018年9-12月'
# puts 'process 86'
# add_part23_questions 87, '2018年9-12月'
# puts 'process 87'
# add_part23_questions 88, '2018年9-12月'
# puts 'process 88'
# add_part1_questions 48, '2018年9-12月'
# puts 'process 48'
#
# add_part23_questions 89, '2019年1-4月'
# puts 'process 89'
# add_part1_questions 49, '2019年1-4月'
# puts 'process 49'

# for i in 90..113 do
#   add_part23_questions i, '2019年1-4月'
#   puts "process #{i}"
# end